
-- our API object
doors = {
	mod = "redo",
	registered_doors = {},
	registered_trapdoors = {}
}


-- translation support
local S
if minetest.get_translator then
	S = minetest.get_translator("doors") -- 5.x translation function
else
	S = function(str, ...) -- boilerplate function
		local args = {...}
		return str:gsub("@%d+", function(match)
			return args[tonumber(match:sub(2))]
		end)
	end
end


local function replace_old_owner_information(pos)

	local meta = minetest.get_meta(pos)
	local owner = meta and meta:get_string("doors_owner")

	if owner and owner ~= "" then
		meta:set_string("owner", owner)
		meta:set_string("doors_owner", "")
	end
end


-- returns an object to a door object or nil
function doors.get(pos)

	local node_name = minetest.get_node(pos).name

	if doors.registered_doors[node_name] then

		-- A normal upright door
		return {

			pos = pos,

			open = function(self, player)

				if self:state() then
					return false
				end

				return doors.door_toggle(self.pos, nil, player)
			end,

			close = function(self, player)

				if not self:state() then
					return false
				end

				return doors.door_toggle(self.pos, nil, player)
			end,

			toggle = function(self, player)
				return doors.door_toggle(self.pos, nil, player)
			end,

			state = function(self)

				local state = minetest.get_meta(self.pos):get_int("state")

				return state %2 == 1
			end
		}

	elseif doors.registered_trapdoors[node_name] then

		-- A trapdoor
		return {

			pos = pos,

			open = function(self, player)

				if self:state() then
					return false
				end

				return doors.trapdoor_toggle(self.pos, nil, player)
			end,

			close = function(self, player)

				if not self:state() then
					return false
				end

				return doors.trapdoor_toggle(self.pos, nil, player)
			end,

			toggle = function(self, player)
				return doors.trapdoor_toggle(self.pos, nil, player)
			end,

			state = function(self)
				return minetest.get_node(self.pos).name:sub(-5) == "_open"
			end
		}
	end

	return nil
end


local can_dig_door = function(pos, digger)

	if not (digger and digger:is_player()) then return false end

	if minetest.check_player_privs(digger, "protection_bypass") then
		return true
	end

	replace_old_owner_information(pos)

	local meta = minetest.get_meta(pos) ; if not meta then return false end
	local owner = meta:get_string("owner")
	local prot = meta:get_string("doors_protected")
	local pname = digger:get_player_name()

	if prot ~= "" and ( prot == pname or not minetest.is_protected(pos, pname) ) then
		return true
	elseif prot ~= "" then
		return false
	end

	if owner ~= "" and pname == owner then
		return true
	elseif owner ~= "" then
		return false
	end

	if not minetest.is_protected(pos, pname) then
		return true
	end

	return false
end


local can_toggle = function(clicker, pos)

	-- check for fake player
	if clicker and clicker.is_fake_player then
		return true
	end

	if can_dig_door(pos, clicker) then
		return true
	end

	local meta = minetest.get_meta(pos)
	local owner = meta:get_string("owner")
	local prot  = meta:get_string("doors_protected")

	if owner == "" and prot == "" then
		return true
	end

	local item = clicker and clicker:get_wielded_item()

	if not item or minetest.get_item_group(item:get_name(), "key") ~= 1 then
		return false
	end

	local key_meta = item:get_meta()

	if key_meta:get_string("secret") == "" then

		local key_oldmeta = item:get_metadata()

		if key_oldmeta == "" or not minetest.parse_json(key_oldmeta) then
			return false
		end

		key_meta:set_string("secret", minetest.parse_json(key_oldmeta).secret)
		item:set_metadata("")
	end

	if meta:get_string("key_lock_secret") == key_meta:get_string("secret") then
		return true
	end

	return false
end


-- this hidden node is placed on top of the bottom, and prevents
-- nodes from being placed in the top half of the door.
minetest.register_node("doors:hidden", {
	description = S("Hidden Door Segment"),
	-- can't use airlike otherwise falling nodes will turn to entities
	-- and will be forever stuck until door is removed.
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	sunlight_propagates = true,
	use_texture_alpha = "clip",
	-- has to be walkable for falling nodes to stop falling.
	walkable = true,
	pointable = false,
	diggable = false,
	buildable_to = false,
	floodable = false,
	drop = "",
	groups = {not_in_creative_inventory = 1},
	on_blast = function() end,
	tiles = {"doors_blank.png"},
	-- 1px transparent block inside door hinge near node top.
	node_box = {
		type = "fixed",
		fixed = {-15/32, 13/32, -15/32, -13/32, 1/2, -13/32}
	},
	-- collision_box needed otherise selection box would be full node size
	collision_box = {
		type = "fixed",
		fixed = {-15/32, 13/32, -15/32, -13/32, 1/2, -13/32}
	}
})


-- table used to aid door opening/closing
local transform = {
	{
		{ v = "_a", param2 = 3 },
		{ v = "_a", param2 = 0 },
		{ v = "_a", param2 = 1 },
		{ v = "_a", param2 = 2 }
	},
	{
		{ v = "_b", param2 = 1 },
		{ v = "_b", param2 = 2 },
		{ v = "_b", param2 = 3 },
		{ v = "_b", param2 = 0 }
	},
	{
		{ v = "_b", param2 = 1 },
		{ v = "_b", param2 = 2 },
		{ v = "_b", param2 = 3 },
		{ v = "_b", param2 = 0 }
	},
	{
		{ v = "_a", param2 = 3 },
		{ v = "_a", param2 = 0 },
		{ v = "_a", param2 = 1 },
		{ v = "_a", param2 = 2 }
	}
}


function doors.door_toggle(pos, node, clicker)

	local meta = minetest.get_meta(pos)

	if not meta then return false end

	node = node or minetest.get_node(pos)

	local def = minetest.registered_nodes[node.name]
	local name = def.door.name
	local state = meta:get_string("state")

	if state == "" then

		-- fix up lvm-placed right-hinged doors, default closed
		if node.name:sub(-2) == "_b" then
			state = 2
		else
			state = 0
		end
	else
		state = tonumber(state)
	end

	replace_old_owner_information(pos)

	if not can_toggle(clicker, pos) then
		return false
	end

	-- until Lua-5.2 we have no bitwise operators :(
	if state % 2 == 1 then
		state = state - 1
	else
		state = state + 1
	end

	local dir = node.param2

	-- It's possible param2 is messed up, so, validate before using
	-- the input data. This indicates something may have rotated
	-- the door, even though that is not supported.
	if not transform[state + 1] or not transform[state + 1][dir + 1] then
		return false
	end

	if state % 2 == 0 then

		minetest.sound_play(def.door.sounds[1],
				{pos = pos, gain = def.door.gains[1], max_hear_distance = 10}, true)
	else
		minetest.sound_play(def.door.sounds[2],
				{pos = pos, gain = def.door.gains[2], max_hear_distance = 10}, true)
	end

	minetest.swap_node(pos, {
		name = name .. transform[state + 1][dir + 1].v,
		param2 = transform[state + 1][dir + 1].param2
	})

	meta:set_int("state", state)

	return true
end


local function on_place_node(place_to, newnode, placer, oldnode, itemstack, pointed_thing)

	-- Run script hook
	for _, callback in ipairs(minetest.registered_on_placenodes) do

		-- Deepcopy pos, node and pointed_thing because callback can modify them
		local place_to_copy = {x = place_to.x, y = place_to.y, z = place_to.z}
		local newnode_copy = {
			name = newnode.name, param1 = newnode.param1, param2 = newnode.param2}
		local oldnode_copy = {
			name = oldnode.name, param1 = oldnode.param1, param2 = oldnode.param2}
		local pointed_thing_copy = {
			type = pointed_thing.type,
			above = vector.new(pointed_thing.above),
			under = vector.new(pointed_thing.under),
			ref = pointed_thing.ref
		}

		callback(place_to_copy, newnode_copy, placer, oldnode_copy, itemstack,
				pointed_thing_copy)
	end
end


function doors.register(name, def)

	if not name:find(":") then
		name = "doors:" .. name
	end

	-- replace old doors of this type automatically
	minetest.register_lbm({
		name = ":doors:replace_" .. name:gsub(":", "_"),
		nodenames = {name.."_b_1", name.."_b_2"},

		action = function(pos, node)

			local l = tonumber(node.name:sub(-1))
			local meta = minetest.get_meta(pos)
			local h = meta:get_int("right") + 1
			local p2 = node.param2
			local replace = {
				{{ type = "a", state = 0 }, { type = "a", state = 3 }},
				{{ type = "b", state = 1 }, { type = "b", state = 2 }}
			}
			local new = replace[l][h]

			-- retain infotext and doors_owner fields
			minetest.swap_node(pos, {name = name .. "_" .. new.type, param2 = p2})
			meta:set_int("state", new.state)

			-- properly place doors:hidden at the right spot
			local p3 = p2

			if new.state >= 2 then
				p3 = (p3 + 3) % 4
			end

			if new.state % 2 == 1 then

				if new.state >= 2 then
					p3 = (p3 + 1) % 4
				else
					p3 = (p3 + 3) % 4
				end
			end

			-- wipe meta on top node as it's unused
			minetest.set_node({x = pos.x, y = pos.y + 1, z = pos.z},
				{name = "doors:hidden", param2 = p3})
		end
	})

	minetest.register_craftitem(":" .. name, {
		description = def.description,
		inventory_image = def.inventory_image,
		groups = table.copy(def.groups),

		on_place = function(itemstack, placer, pointed_thing)

			local pos

			if pointed_thing.type ~= "node" then
				return itemstack
			end

			local doorname = itemstack:get_name()
			local node = minetest.get_node(pointed_thing.under)
			local pdef = minetest.registered_nodes[node.name]

			if pdef
			and pdef.on_rightclick
			and not (placer and placer:is_player()
			and placer:get_player_control().sneak) then

				return pdef.on_rightclick(pointed_thing.under,
						node, placer, itemstack, pointed_thing)
			end

			if pdef and pdef.buildable_to then
				pos = pointed_thing.under
			else
				pos = pointed_thing.above
				node = minetest.get_node(pos)
				pdef = minetest.registered_nodes[node.name]

				if not pdef or not pdef.buildable_to then
					return itemstack
				end
			end

			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			local top_node = minetest.get_node_or_nil(above)
			local topdef = top_node and minetest.registered_nodes[top_node.name]

			if not topdef or not topdef.buildable_to then
				return itemstack
			end

			local pn = placer and placer:get_player_name() or ""

			if minetest.is_protected(pos, pn) or minetest.is_protected(above, pn) then
				return itemstack
			end

			local dir = placer and minetest.dir_to_facedir(placer:get_look_dir()) or 0

			local ref = {
				{x = -1, y = 0, z = 0},
				{x = 0, y = 0, z = 1},
				{x = 1, y = 0, z = 0},
				{x = 0, y = 0, z = -1}
			}

			local aside = {
				x = pos.x + ref[dir + 1].x,
				y = pos.y + ref[dir + 1].y,
				z = pos.z + ref[dir + 1].z
			}

			local state = 0

			if minetest.get_item_group(minetest.get_node(aside).name, "door") == 1 then
				state = state + 2
				minetest.set_node(pos, {name = doorname .. "_b", param2 = dir})
				minetest.set_node(above, {name = "doors:hidden", param2 = (dir + 3) % 4})
			else
				minetest.set_node(pos, {name = doorname .. "_a", param2 = dir})
				minetest.set_node(above, {name = "doors:hidden", param2 = dir})
			end

			local meta = minetest.get_meta(pos)

			meta:set_int("state", state)

			if def.protected then

				meta:set_string("owner", pn)
				meta:set_string("infotext", def.description .. "\n" .. S("Owned by @1", pn))
			end

			if not minetest.is_creative_enabled(pn) then
				itemstack:take_item()
			end

			minetest.sound_play(def.sounds.place, {pos = pos}, true)

			on_place_node(pos, minetest.get_node(pos), placer, node, itemstack,
					pointed_thing)

			return itemstack
		end
	})

	def.inventory_image = nil

	if def.recipe then

		minetest.register_craft({
			output = name,
			recipe = def.recipe
		})
	end

	def.recipe = nil
	def.sounds = def.sounds or default.node_sound_wood_defaults()
	def.sound_open = def.sound_open or "doors_door_open"
	def.sound_close = def.sound_close or "doors_door_close"
	def.groups.not_in_creative_inventory = 1
	def.groups.door = 1
	def.drop = name
	def.door = {
		name = name,
		sounds = {def.sound_close, def.sound_open},
		gains = {def.gain_close or 0.2, def.gain_open or 0.2}
	}

	if not def.on_rightclick then

		def.on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)

			doors.door_toggle(pos, node, clicker)

			return itemstack
		end
	end

	def.after_dig_node = function(pos, node, meta, digger)

		minetest.remove_node({x = pos.x, y = pos.y + 1, z = pos.z})

		minetest.check_for_falling({x = pos.x, y = pos.y + 1, z = pos.z})
	end

	def.on_rotate = function(pos, node, user, mode, new_param2)
		return false
	end

	def.can_dig = can_dig_door

	def.on_key_use = function(pos, player)

		local door = doors.get(pos)

		door:toggle(player)
	end

	def.on_skeleton_key_use = function(pos, player, newsecret)

		replace_old_owner_information(pos)

		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		local pname = player:get_player_name()
		local prot  = meta:get_string("doors_protected")

		-- Door is neither owned not protected
		if owner == "" and prot == "" then
			return nil
		end

		-- verify placer is owner of lockable door
		if owner ~= pname and prot ~= pname then
			minetest.record_protection_violation(pos, pname)
			minetest.chat_send_player(pname, S("You do not own this locked door."))
			return nil
		end

		local secret = meta:get_string("key_lock_secret")

		if secret == "" then
			secret = newsecret
			meta:set_string("key_lock_secret", secret)
		end

		return secret, S("a locked door"), owner
	end

	def.node_dig_prediction = ""

	def.on_blast = function(pos, intensity)

		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner") or ""

		if owner ~= "" or minetest.is_protected(pos, "") then
			return
		end

		minetest.remove_node(pos)

		-- hidden node doesn't get blasted away.
		minetest.remove_node({x = pos.x, y = pos.y + 1, z = pos.z})

		return {name}
	end

	def.on_destruct = function(pos)
		minetest.remove_node({x = pos.x, y = pos.y + 1, z = pos.z})
	end

	def.drawtype = "mesh"
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.sunlight_propagates = true
	def.use_texture_alpha = def.use_texture_alpha or "clip"
	def.walkable = true
	def.is_ground_content = false
	def.buildable_to = false
	def.selection_box = {type = "fixed", fixed = {-1/2,-1/2,-1/2,1/2,3/2,-6/16}}
	def.collision_box = {type = "fixed", fixed = {-1/2,-1/2,-1/2,1/2,3/2,-6/16}}

	-- mesecons support
	if minetest.get_modpath("mesecons") then

		local function door_switch(pos, node)
			doors.door_toggle(pos, node, {is_fake_player = true})
		end

		def.mesecons = {effector = {
			action_on = door_switch,
			action_off = door_switch
		}}
	end

	def.mesh = "door_a.b3d"
	minetest.register_node(":" .. name .. "_a", table.copy(def))

	minetest.register_alias(name .. "_c", name .. "_b")

	def.mesh = "door_b.b3d"
	minetest.register_node(":" .. name .. "_b", table.copy(def))

	minetest.register_alias(name .. "_d", name .. "_a")

	doors.registered_doors[name .. "_a"] = true
	doors.registered_doors[name .. "_b"] = true
end


doors.register("door_wood", {
	tiles = {{name = "doors_door_wood.png", backface_culling = true}},
	description = S("Wooden Door"),
	inventory_image = "doors_item_wood.png",
	groups = {node = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	gain_open = 0.06,
	gain_close = 0.13,
	recipe = {
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"}
	}
})


doors.register("door_steel", {
	tiles = {{name = "doors_door_steel.png", backface_culling = true}},
	description = S("Steel Door"),
	inventory_image = "doors_item_steel.png",
	protected = true,
	groups = {node = 1, cracky = 1, level = 2},
	sounds = default.node_sound_stone_defaults(),
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",
	gain_open = 0.2,
	gain_close = 0.2,
	recipe = {
		{"default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot"}
	}
})


doors.register("door_glass", {
	tiles = { "doors_door_glass.png"},
	description = S("Glass Door"),
	inventory_image = "doors_item_glass.png",
	groups = {node = 1, cracky = 3, oddly_breakable_by_hand = 3},
	sounds = default.node_sound_glass_defaults(),
	sound_open = "doors_glass_door_open",
	sound_close = "doors_glass_door_close",
	gain_open = 0.3,
	gain_close = 0.25,
	recipe = {
		{"default:glass", "default:glass"},
		{"default:glass", "default:glass"},
		{"default:glass", "default:glass"}
	}
})


doors.register("door_obsidian_glass", {
	tiles = { "doors_door_obsidian_glass.png" },
	description = S("Obsidian Glass Door"),
	inventory_image = "doors_item_obsidian_glass.png",
	groups = {node = 1, cracky = 3},
	sounds = default.node_sound_glass_defaults(),
	sound_open = "doors_glass_door_open",
	sound_close = "doors_glass_door_close",
	gain_open = 0.3,
	gain_close = 0.25,
	recipe = {
		{"default:obsidian_glass", "default:obsidian_glass"},
		{"default:obsidian_glass", "default:obsidian_glass"},
		{"default:obsidian_glass", "default:obsidian_glass"}
	}
})


-- special doors (CC0 textures by Phiwari123 and IceAgeComing)
doors.register("door_phiwari", {
	tiles = {{name = "doors_door_phiwari.png", backface_culling = true}},
	description = "Phiwari: " .. S("Wooden Door"),
	inventory_image = "doors_item_phiwari.png",
	groups = {node = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	gain_open = 0.06,
	gain_close = 0.13,
	recipe = {
		{"group:wood", "default:obsidian_glass"},
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"}
	}
})


doors.register("door_iceage", {
	tiles = {{name = "doors_door_iceage.png", backface_culling = true}},
	description = "IceAge: " .. S("Wooden Door"),
	inventory_image = "doors_item_iceage.png",
	groups = {node = 1, choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
	gain_open = 0.06,
	gain_close = 0.13,
	recipe = {
		{"group:wood", "default:iron_lump"},
		{"group:wood", "group:wood"},
		{"group:wood", "group:wood"}
	}
})


-- Capture mods using the old API as best as possible.
function doors.register_door(name, def)

	if def.only_placer_can_open then
		def.protected = true
	end

	def.only_placer_can_open = nil

	local i = name:find(":")
	local modname = name:sub(1, i - 1)

	if not def.tiles then

		if def.protected then
			def.tiles = {{name = "doors_door_steel.png", backface_culling = true}}
		else
			def.tiles = {{name = "doors_door_wood.png", backface_culling = true}}
		end

		minetest.log("warning", modname .. " registered door \"" .. name .. "\" " ..
				"using deprecated API method \"doors.register_door()\" but " ..
				"did not provide the \"tiles\" parameter. A fallback tiledef " ..
				"will be used instead.")
	end

	doors.register(name, def)
end

----trapdoor----

function doors.trapdoor_toggle(pos, node, clicker)

	replace_old_owner_information(pos)

	node = node or minetest.get_node(pos)

	if not can_toggle(clicker, pos) then
		return false
	end

	local def = minetest.registered_nodes[node.name]

	if string.sub(node.name, -5) == "_open" then

		minetest.sound_play(def.sound_close,
				{pos = pos, gain = def.gain_close, max_hear_distance = 10}, true)

		minetest.swap_node(pos, {
			name = string.sub(node.name, 1, string.len(node.name) - 5),
			param1 = node.param1, param2 = node.param2
		})
	else
		minetest.sound_play(def.sound_open,
				{pos = pos, gain = def.gain_open, max_hear_distance = 10}, true)

		minetest.swap_node(pos, {
			name = node.name .. "_open",
			param1 = node.param1, param2 = node.param2
		})
	end
end


function doors.register_trapdoor(name, def)

	if not name:find(":") then
		name = "doors:" .. name
	end

	local name_closed = name
	local name_opened = name.."_open"

	def.on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)

		doors.trapdoor_toggle(pos, node, clicker)

		return itemstack
	end

	-- Common trapdoor configuration
	def.drawtype = "nodebox"
	def.paramtype = "light"
	def.paramtype2 = "facedir"
	def.use_texture_alpha = def.use_texture_alpha or "clip"
	def.is_ground_content = false

	def.can_dig = can_dig_door

	def.after_place_node = function(pos, placer, itemstack, pointed_thing)

		if not def.protected then return end

		local pn = placer:get_player_name()
		local meta = minetest.get_meta(pos)

		meta:set_string("owner", pn)
		meta:set_string("infotext", def.description .. "\n" .. S("Owned by @1", pn))

		return minetest.is_creative_enabled(pn)
	end

	def.on_key_use = function(pos, player)

		local door = doors.get(pos)

		door:toggle(player)
	end

	def.on_skeleton_key_use = function(pos, player, newsecret)

		replace_old_owner_information(pos)

		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner")
		local pname = player:get_player_name()
		local prot  = meta:get_string("doors_protected")

		-- Door is neither owned not protected
		if owner == "" and prot == "" then
			return nil
		end

		-- verify placer is owner of lockable door
		if owner ~= pname and prot ~= pname then
			minetest.record_protection_violation(pos, pname)
			minetest.chat_send_player(pname, S("You do not own this trapdoor."))
			return nil
		end

		local secret = meta:get_string("key_lock_secret")

		if secret == "" then
			secret = newsecret
			meta:set_string("key_lock_secret", secret)
		end

		return secret, S("a locked trapdoor"), owner
	end

	def.node_dig_prediction = ""

	def.on_blast = function(pos, intensity)

		local meta = minetest.get_meta(pos)
		local owner = meta:get_string("owner") or ""

		if owner ~= "" or minetest.is_protected(pos, "") then
			return
		end

		minetest.remove_node(pos)

		return {name}
	end

	def.sounds = def.sounds or default.node_sound_wood_defaults()
	def.sound_open = def.sound_open or "doors_door_open"
	def.sound_close = def.sound_clode or "doors_door_close"
	def.gain_open = def.gain_open or 0.2
	def.gain_close = def.gain_close or 0.2

	-- mesecons support
	if minetest.get_modpath("mesecons") then

		local function trapdoor_switch(pos, node)
			doors.trapdoor_toggle(pos, node, {is_fake_player = true})
		end

		def.mesecons = {effector = {
			action_on = trapdoor_switch,
			action_off = trapdoor_switch
		}}
	end

	local def_opened = table.copy(def)
	local def_closed = table.copy(def)

	if def.nodebox_closed and def.nodebox_opened then
		def_closed.node_box = def.nodebox_closed
	else
		def_closed.node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -6/16, 0.5}
		}
	end

	def_closed.selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, -0.5, 0.5, -6/16, 0.5}
	}

	def_closed.tiles = {
		def.tile_front,
		def.tile_front .. "^[transformFY",
		def.tile_side,
		def.tile_side,
		def.tile_side,
		def.tile_side
	}

	if def.nodebox_opened and def.nodebox_closed then
		def_opened.node_box = def.nodebox_opened
	else
		def_opened.node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, 6/16, 0.5, 0.5, 0.5}
		}
	end

	def_opened.selection_box = {
		type = "fixed",
		fixed = {-0.5, -0.5, 6/16, 0.5, 0.5, 0.5}
	}

	def_opened.tiles = {
		def.tile_side,
		def.tile_side .. "^[transform2",
		def.tile_side .. "^[transform3",
		def.tile_side .. "^[transform1",
		def.tile_front .. "^[transform46",
		def.tile_front .. "^[transform6"
	}

	def_opened.drop = name_closed
	def_opened.groups.not_in_creative_inventory = 1

	minetest.register_node(name_opened, def_opened)
	minetest.register_node(name_closed, def_closed)

	doors.registered_trapdoors[name_opened] = true
	doors.registered_trapdoors[name_closed] = true
end


doors.register_trapdoor("doors:trapdoor", {
	description = S("Wooden Trapdoor"),
	inventory_image = "doors_trapdoor.png",
	wield_image = "doors_trapdoor.png",
	tile_front = "doors_trapdoor.png",
	tile_side = "doors_trapdoor_side.png",
	gain_open = 0.06,
	gain_close = 0.13,
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2, door = 1}
})

minetest.register_craft({
	output = "doors:trapdoor 2",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:wood", "group:wood", "group:wood"},
		{"", "", ""}
	}
})

doors.register_trapdoor("doors:trapdoor_steel", {
	description = S("Steel Trapdoor"),
	inventory_image = "doors_trapdoor_steel.png",
	wield_image = "doors_trapdoor_steel.png",
	tile_front = "doors_trapdoor_steel.png",
	tile_side = "doors_trapdoor_steel_side.png",
	protected = true,
	sound_open = "doors_steel_door_open",
	sound_close = "doors_steel_door_close",
	gain_open = 0.2,
	gain_close = 0.2,
	groups = {cracky = 1, level = 2, door = 1}
})

minetest.register_craft({
	output = "doors:trapdoor_steel",
	recipe = {
		{"default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot"}
	}
})

-- based on castle_2 texture by sorcerykid's extra_doors mod
doors.register_trapdoor("doors:trapdoor_oak", {
	description = S("Oak Trapdoor"),
	inventory_image = "doors_trapdoor_oak.png",
	wield_image = "doors_trapdoor_oak.png",
	tile_front = "doors_trapdoor_oak.png",
	tile_side = "doors_trapdoor_oak_side.png",
	gain_open = 0.06,
	gain_close = 0.13,
	groups = {choppy = 1, oddly_breakable_by_hand = 1, flammable = 2, door = 1}
})

minetest.register_craft({
	output = "doors:trapdoor_oak 3",
	recipe = {
		{"group:wood", "group:wood", "group:wood"},
		{"group:wood", "default:tree", "group:wood"},
		{"", "", ""}
	}
})

-----lock tool-----

minetest.register_tool("doors:lock_tool", {
	description = S("Lock Tool"),
	inventory_image = "doors_lock_tool.png",

	on_use = function(itemstack, user, pointed_thing)

		local pos = pointed_thing.under

		if pointed_thing.type ~= "node"
		or not doors.get(pos) then
			return
		end

		replace_old_owner_information(pos)

		local player_name = user:get_player_name()
		local meta = minetest.get_meta(pos) ; if not meta then return end
		local owner = meta:get_string("owner")
		local prot = meta:get_string("doors_protected")
		local ok = 0
		local infotext = ""

		if prot == ""
		and owner == "" then

			-- flip normal to owned
			if minetest.is_protected(pos, player_name) then
				minetest.record_protection_violation(pos, player_name)
			else
				infotext = ItemStack(minetest.get_node(pos).name):get_description()
					.. "\n" .. S("Owned by @1", player_name)
				owner = player_name
				prot = ""
				ok = 1
			end

		elseif prot == ""
		and owner ~= "" then

			-- flip owned to protected
			if player_name == owner then
				infotext = ItemStack(minetest.get_node(pos).name):get_description()
					.. "\n" .. S("Protected by @1", player_name)
				owner = ""
				prot = player_name
				ok = 1
			end

		elseif prot ~= ""
		and owner == "" then

			-- flip protected to normal
			if player_name == prot then
				infotext = " "
				owner = ""
				prot = ""
				ok = 1
			end
		end

		if ok == 1 then

			meta:set_string("infotext", infotext)
			meta:set_string("owner", owner)
			meta:set_string("doors_protected", prot)

			if not minetest.is_creative_enabled(player_name) then
				itemstack:add_wear(65535 / 50)
			end
		end

		minetest.sound_play("doors_fencegate_open", {pos = pos, gain = 0.15,
				max_hear_distance = 8, pitch = 1.5}, true)

		return itemstack
	end
})

minetest.register_craft({
	output = "doors:lock_tool",
	recipe = {
		{"", "default:steel_ingot", ""},
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"default:steel_ingot", "default:gold_ingot", "default:steel_ingot"}
	}
})

minetest.register_alias("doors:key", "doors:lock_tool")

----fence gate----

local fence_collision_extra = minetest.settings:get_bool("enable_fence_tall") and 3/8 or 0


function doors.fencegate_toggle(pos, node, clicker)

	local node_def = minetest.registered_nodes[node.name]

	minetest.swap_node(pos, {name = node_def._gate, param2 = node.param2})

	minetest.sound_play(node_def._gate_sound, {pos = pos, gain = 0.15,
			max_hear_distance = 8}, true)
end


function doors.register_fencegate(name, def)

	local fence = {
		description = def.description,
		drawtype = "mesh",
		tiles = {},
		paramtype = "light",
		paramtype2 = "facedir",
		sunlight_propagates = true,
		is_ground_content = false,
		drop = name .. "_closed",
		connect_sides = {"left", "right"},
		groups = def.groups,
		sounds = def.sounds,

		on_rightclick = function(pos, node, clicker, itemstack, pointed_thing)

			doors.fencegate_toggle(pos, node, clicker)

			return itemstack
		end,

		selection_box = {
			type = "fixed",
			fixed = {-1/2, -1/2, -1/4, 1/2, 1/2, 1/4}
		}
	}

	if type(def.texture) == "string" then
		fence.tiles[1] = {name = def.texture, backface_culling = true}
	elseif def.texture.backface_culling == nil then
		fence.tiles[1] = table.copy(def.texture)
		fence.tiles[1].backface_culling = true
	else
		fence.tiles[1] = def.texture
	end

	if not fence.sounds then
		fence.sounds = default.node_sound_wood_defaults()
	end

	fence.groups.fence = 1

	-- mesecons support
	if minetest.get_modpath("mesecons") then

		local function fencegate_switch(pos, node)
			doors.fencegate_toggle(pos, node, {is_fake_player = true})
		end

		fence.mesecons = {effector = {
			action_on = fencegate_switch,
			action_off = fencegate_switch
		}}
	end

	local fence_closed = table.copy(fence)

	fence_closed.mesh = "doors_fencegate_closed.obj"
	fence_closed._gate = name .. "_open"
	fence_closed._gate_sound = "doors_fencegate_open"
	fence_closed.collision_box = {
		type = "fixed",
		fixed = {-1/2, -1/2, -1/8, 1/2, 1/2 + fence_collision_extra, 1/8}
	}

	local fence_open = table.copy(fence)

	fence_open.mesh = "doors_fencegate_open.obj"
	fence_open._gate = name .. "_closed"
	fence_open._gate_sound = "doors_fencegate_close"
	fence_open.groups.not_in_creative_inventory = 1
	fence_open.collision_box = {
		type = "fixed",
		fixed = {{-1/2, -1/2, -1/8, -3/8, 1/2 + fence_collision_extra, 1/8},
			{-1/2, -3/8, -1/2, -3/8, 3/8, 0}},
	}

	minetest.register_node(":" .. name .. "_closed", fence_closed)
	minetest.register_node(":" .. name .. "_open", fence_open)

	minetest.register_craft({
		output = name .. "_closed",
		recipe = {
			{"group:stick", def.material, "group:stick"},
			{"group:stick", def.material, "group:stick"}
		}
	})
end


doors.register_fencegate("doors:gate_wood", {
	description = S("Apple Wood Fence Gate"),
	texture = "default_wood.png",
	material = "default:wood",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2}
})

doors.register_fencegate("doors:gate_acacia_wood", {
	description = S("Acacia Wood Fence Gate"),
	texture = "default_acacia_wood.png",
	material = "default:acacia_wood",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2}
})

doors.register_fencegate("doors:gate_junglewood", {
	description = S("Jungle Wood Fence Gate"),
	texture = "default_junglewood.png",
	material = "default:junglewood",
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2}
})

doors.register_fencegate("doors:gate_pine_wood", {
	description = S("Pine Wood Fence Gate"),
	texture = "default_pine_wood.png",
	material = "default:pine_wood",
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 3}
})

doors.register_fencegate("doors:gate_aspen_wood", {
	description = S("Aspen Wood Fence Gate"),
	texture = "default_aspen_wood.png",
	material = "default:aspen_wood",
	groups = {choppy = 3, oddly_breakable_by_hand = 2, flammable = 3}
})

----fuels----

minetest.register_craft({
	type = "fuel",
	recipe = "doors:trapdoor",
	burntime = 7
})

minetest.register_craft({
	type = "fuel",
	recipe = "doors:trapdoor_oak",
	burntime = 10
})

minetest.register_craft({
	type = "fuel",
	recipe = "doors:door_wood",
	burntime = 14
})

minetest.register_craft({
	type = "fuel",
	recipe = "doors:gate_wood_closed",
	burntime = 7
})

minetest.register_craft({
	type = "fuel",
	recipe = "doors:gate_acacia_wood_closed",
	burntime = 8
})

minetest.register_craft({
	type = "fuel",
	recipe = "doors:gate_junglewood_closed",
	burntime = 9
})

minetest.register_craft({
	type = "fuel",
	recipe = "doors:gate_pine_wood_closed",
	burntime = 6
})

minetest.register_craft({
	type = "fuel",
	recipe = "doors:gate_aspen_wood_closed",
	burntime = 5
})

-- old key into iron

minetest.register_craft({
	output = "default:iron_lump",
	recipe = {{"default:key"}}
})


print("[MOD] Doors Redo loaded")
