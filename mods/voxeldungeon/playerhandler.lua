--[[
Voxel Dungeon
Copyright (C) 2019 Noodlemire

Pixel Dungeon
Copyright (C) 2012-2015 Oleg Dolya

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>
--]]

voxeldungeon.playerhandler = {}

voxeldungeon.playerhandler.playerdata = {} --data that gets saved
voxeldungeon.playerhandler.tempdata = {} --data that gets reset once the player leaves

local startingPlayerStats =
{
	HT = 20,
	STR = 10,
}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	voxeldungeon.playerhandler.playerdata[name] = {}

	local keyHT = name.."_HT"
	local keySTR = name.."_STR"

	local playerHT = voxeldungeon.storage.getNum(keyHT)
	local playerSTR = voxeldungeon.storage.getNum(keySTR)

	if playerHT then
		voxeldungeon.playerhandler.playerdata[name].HT = playerHT
		player:set_properties({hp_max = playerHT})
	else
		voxeldungeon.playerhandler.playerdata[name].HT = startingPlayerStats.HT
		voxeldungeon.storage.put(keyHT, startingPlayerStats.HT)
	end

	if playerSTR then
		voxeldungeon.playerhandler.playerdata[name].STR = playerSTR
	else
		voxeldungeon.playerhandler.playerdata[name].STR = startingPlayerStats.STR
		voxeldungeon.storage.put(keySTR, startingPlayerStats.STR)
	end

	voxeldungeon.playerhandler.tempdata[name] = 
	{
		time_from_last_punch = 0,
		paralysis = 0
	}

	--player:set_properties({
	--	eye_height = 0.667,
	--	collision_box = {-0.5, 0.0, -0.5, 0.5, 1.0, 0.5},
	--	visual_size = {x = 0.5, y = 0.5, z = 0.5},
	--})

	voxeldungeon.glog.h("Welcome to Voxel Dungeon!", player)
end)

local function leaveplayer(player)
	local name = player:get_player_name()

	local keyHT = name.."_HT"
	local keySTR = name.."_STR"

	voxeldungeon.storage.put(keyHT, voxeldungeon.playerhandler.playerdata[name].HT)
	voxeldungeon.storage.put(keySTR, voxeldungeon.playerhandler.playerdata[name].STR)
end

minetest.register_on_leaveplayer(function(player)
	leaveplayer(player)
end)

minetest.register_on_shutdown(function()
	for _, v in pairs(minetest.get_connected_players()) do
		leaveplayer(v)
	end
end)

function voxeldungeon.playerhandler.setHT(player, amount, fullheal)
	local prev = voxeldungeon.playerhandler.playerdata[player:get_player_name()].HT
	player:set_properties({hp_max = amount})
	voxeldungeon.playerhandler.playerdata[player:get_player_name()].HT = amount

	if fullheal or amount < prev then
		player:set_hp(amount)
	end
end

function voxeldungeon.playerhandler.changeHT(player, change, heal)
	voxeldungeon.playerhandler.setHT(player, voxeldungeon.playerhandler.playerdata[player:get_player_name()].HT + change, false)
	player:set_hp(player:get_hp() + change)
end

function voxeldungeon.playerhandler.setSTR(player, amount)
	voxeldungeon.playerhandler.playerdata[player:get_player_name()].STR = amount
end

function voxeldungeon.playerhandler.changeSTR(player, change)
	voxeldungeon.playerhandler.setSTR(player, voxeldungeon.playerhandler.playerdata[player:get_player_name()].STR + change)
end

function voxeldungeon.playerhandler.getSTR(player)
	local STR = voxeldungeon.playerhandler.playerdata[player:get_player_name()].STR

	if voxeldungeon.buffs.get_buff("voxeldungeon:weakness", player) then
		STR = STR - 2
	end

	return STR
end

minetest.register_chatcommand("mystats", {
	params = "",
	description = "View your stats like max hp, strength, etc.",
	privs = {},

	func = function(name)
		local data = voxeldungeon.playerhandler.playerdata[name]
		voxeldungeon.glog.i("Max HP = "..data.HT..", STR = "..data.STR, name)
	end
})

minetest.register_on_punchplayer(function(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)
	if voxeldungeon.playerhandler.isParalyzed(hitter) then return end

	local playername = player:get_player_name()

	if playername then
		if hitter:is_player() then
			local weapon = hitter:get_wielded_item()
			time_from_last_punch = voxeldungeon.playerhandler.getTimeFromLastPunch(hitter)

			if minetest.get_item_group(weapon:get_name(), "weapon") > 0 then
				weapon, tool_capabilities = voxeldungeon.weapons.on_use(weapon, hitter, player, time_from_last_punch)
				minetest.after(0, function() hitter:set_wielded_item(weapon) end)
			end
		end

		local damage = voxeldungeon.utils.round(math.max(0, (tool_capabilities.damage_groups.fleshy or 1) 
			* math.min(1, time_from_last_punch / (tool_capabilities.full_punch_interval or 1))))

		local armor_inv = minetest.get_inventory({type="detached", name=playername.."_armor"})
		local armor_item = armor_inv:get_stack("armor", 1)
		if not armor_item:is_empty() then
			local defense = voxeldungeon.armor.getDefenseOf(armor_item)

			damage = math.max(0, damage - defense)

			voxeldungeon.armor.checkLevelKnown(armor_item, player)

			local wear = math.floor(65535 / (1000 / armor_item:get_definition()._durabilityPerUse))
			armor_item:add_wear(wear)
			armor_inv:set_stack("armor", 1, armor_item)

			armor:save_armor_inventory(player)
		end

		voxeldungeon.utils.on_punch_common(player, hitter, time_from_last_punch, tool_capabilities, dir, damage)

		local earthroot = voxeldungeon.buffs.get_buff("voxeldungeon:herbal_armor", player)

		if earthroot then
			local diff = earthroot.left() - damage

			if diff >= 0 then
				earthroot.duration = earthroot.duration - damage
				damage = 0
			else
				earthroot.detach()
				damage = -diff
			end
		end

		player:set_hp(player:get_hp() - damage)

		if hitter and not hitter:is_player() then
			local def = minetest.registered_entities[hitter:get_luaentity().name]

			if def._attackProc then
				damage = def._attackProc(hitter:get_luaentity(), player, damage)
			end
		end

		voxeldungeon.particles.burst(voxeldungeon.particles.blood, player:get_pos(), 5, {
			angle = vector.direction(hitter:get_pos(), player:get_pos())
		})

		return true
	end
end)

minetest.register_on_player_hpchange(function(player, hp_change, reason)
	if player:get_hp() + hp_change <= 0 then
		local inv = player:get_inventory()
		local ankh

		for i = 1, inv:get_size("main") do
			local item = inv:get_stack("main", i)

			if item:get_name() == "voxeldungeon:ankh_blessed" then
				ankh = {i = i, item = item}
				break
			elseif item:get_name() == "voxeldungeon:ankh" then
				ankh = {i = i, item = item}
			end
		end

		if ankh then
			if ankh.item:get_name() == "voxeldungeon:ankh" then
				for i = 1, inv:get_size("main") do
					if i ~= player:get_wield_index() and 
							minetest.get_item_group(inv:get_stack("main", i):get_name(), "unique") == 0 then 
						inv:set_stack("main", i, "")
					end
				end
			end

			inv:set_stack("main", ankh.i, "")
			voxeldungeon.glog.i("Your "..voxeldungeon.utils.itemShortDescription(ankh.item).." explodes with life-giving energy!", player)
			player:set_hp(voxeldungeon.playerhandler.playerdata[player:get_player_name()].HT)

			return 0, true
		else
			return hp_change
		end
	else
		return hp_change
	end
end, true)

minetest.register_on_dieplayer(function(player)
	if creative.is_enabled_for(player:get_player_name()) then return end

	local playername = player:get_player_name()
	local pos = vector.round(player:get_pos())
	local inv = player:get_inventory()
	local max = inv:get_size("main")

	local empty_slots = {}
	local must_have = {}
	local can_have = {}

	for i = 1, max do
		empty_slots[i] = i

		local item = inv:get_stack("main", i)

		if not item:is_empty() then
			if i == player:get_wield_index() or minetest.get_item_group(item:get_name(), "unique") > 0 then
				table.insert(must_have, item)
			else
				table.insert(can_have, item)
			end
		end
	end

	for i = 1, inv:get_size("craft") do
		local item = inv:get_stack("craft", i)

		if not item:is_empty() then
			table.insert(can_have, item)
		end
	end

	local armor_inv = minetest.get_inventory({type="detached", name=playername.."_armor"})
	local armor_item = armor_inv:get_stack("armor", 1)

	if not armor_item:is_empty() then
		table.insert(must_have, armor_item)
	end

	inv:set_list("main", {})
	inv:set_list("craft", {})
	armor_inv:set_list("armor", {})
	armor:save_armor_inventory(player)
	armor:set_player_armor(player)



	if #must_have == 0 and #can_have <= 1 then
		table.insert(must_have, ItemStack("voxeldungeon:gold"))
	end

	minetest.set_node(pos, {name = "bones:bones", param2 = minetest.dir_to_facedir(player:get_look_dir())})

	local bone_meta = minetest.get_meta(pos)
	local bone_inv = bone_meta:get_inventory()
	bone_inv:set_size("main", 8 * 4)

	for _, item in ipairs(must_have) do
		local i = table.remove(empty_slots, math.random(#empty_slots))
		bone_inv:set_stack("main", i, item)
	end

	local can_have_amount = math.min(voxeldungeon.utils.round(#can_have / 4), #empty_slots)

	for i = 1, can_have_amount do
		local item = voxeldungeon.utils.randomObject(can_have, true)
		local i = voxeldungeon.utils.randomObject(empty_slots, true)

		bone_inv:set_stack("main", i, item)
	end

	bone_meta:set_string("owner", playername)
	bone_meta:set_string("infotext", playername.."'s bones")

	bone_meta:set_string("formspec", "size[8,9]" ..
		"list[current_name;main;0,0.3;8,4;]" ..
		"list[current_player;main;0,4.85;8,1;]" ..
		"list[current_player;main;0,6.08;8,3;8]" ..
		"listring[current_name;main]" ..
		"listring[current_player;main]" ..
		default.get_hotbar_bg(0,4.85))
end)



--Player punch time handling
minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		voxeldungeon.playerhandler.tempdata[name].time_from_last_punch = voxeldungeon.playerhandler.tempdata[name].time_from_last_punch + dtime
	end
end)

function voxeldungeon.playerhandler.getTimeFromLastPunch(player)
	local name = player:get_player_name()
	local time = voxeldungeon.playerhandler.tempdata[name].time_from_last_punch

	voxeldungeon.playerhandler.tempdata[name].time_from_last_punch = 0

	return time
end



--Stop a player in place, while allowing gravity and fall damage to still occur.
minetest.register_entity("voxeldungeon:stop_player", {
	initial_properties = {
		physical = true,
		collide_with_objects = false,
		pointable = false,
		is_visible = false,
		collisionbox = {-0.1, 0.0, -0.1, 0.1, 0.2, 0.1}
	}
})

function voxeldungeon.playerhandler.halt(player)
	local obj = minetest.add_entity(player:get_pos(), "voxeldungeon:stop_player")

	player:set_attach(obj, "", {x = 0, y = 1, z = 0}, {x = 0, y = 0, z = 0})

	minetest.after(0.1, function()
		player:set_detach()
		obj:remove()
	end)
end



--Paralysis, a stackable effect that stops most actions until every source of it is gone
function voxeldungeon.playerhandler.paralyze(player)
	voxeldungeon.playerhandler.halt(player)
	
	local name = player:get_player_name()
	local temp = voxeldungeon.playerhandler.tempdata[name]
	
	temp.paralysis = temp.paralysis + 1
end

function voxeldungeon.playerhandler.deparalyze(player)
	local temp = voxeldungeon.playerhandler.tempdata[player:get_player_name()]
	
	temp.paralysis = temp.paralysis - 1
end

function voxeldungeon.playerhandler.isParalyzed(player)
	return player and player:is_player() and voxeldungeon.playerhandler.tempdata[player:get_player_name()].paralysis > 0
end

minetest.register_on_mods_loaded(function()
	for name, def in pairs(minetest.registered_items) do
		local super_can_dig = def.can_dig or function() return true end
		local super_on_place = def.on_place
		local super_on_use = def.on_use
		local super_on_secondary_use = def.on_secondary_use or function() end

		def = {
			can_dig = function(pos, player)
				if voxeldungeon.playerhandler.isParalyzed(player) then
					return false
				else
					return super_can_dig(pos, player)
				end
			end,

			on_place = function(itemstack, placer, pointed_thing)
				if not voxeldungeon.playerhandler.isParalyzed(placer) then
					return super_on_place(itemstack, placer, pointed_thing)
				end
			end,

			on_secondary_use = function(itemstack, user, pointed_thing)
				if not voxeldungeon.playerhandler.isParalyzed(user) then
					return super_on_secondary_use(itemstack, user, pointed_thing)
				end
			end
		}

		if super_on_use then
			def.on_use = function(itemstack, user, pointed_thing)
				if not voxeldungeon.playerhandler.isParalyzed(user) then
					return super_on_use(itemstack, user, pointed_thing)
				end
			end
		end

		minetest.override_item(name, def)
	end

	local super_calculate_knockback = minetest.calculate_knockback

	minetest.calculate_knockback = function(player, hitter, time_from_last_punch, tool_capabilities, dir, distance, damage)
		if not voxeldungeon.playerhandler.isParalyzed(player) and not voxeldungeon.buffs.get_buff("voxeldungeon:rooted", player) then
			return super_calculate_knockback(player, hitter, time_from_last_punch, tool_capabilities, dir, distance, damage)
		end

		return 0
	end
end)



--Give Initial Stuff
minetest.register_on_newplayer(function(player)
	local inv = player:get_inventory()

	inv:add_item("main", ItemStack("voxeldungeon:ration"))

	local armor = ItemStack("voxeldungeon:armor_cloth")
	voxeldungeon.armor.updateDescription(armor)
	inv:add_item("main", armor)

	--hbhunger.hunger[player:get_player_name()] = 30
	--hbhunger.set_hunger_raw(player)
end)

minetest.register_on_respawnplayer(function(player)
	--hbhunger.hunger[player:get_player_name()] = 30
	--hbhunger.set_hunger_raw(player)
end)



--Visual effects on player models
--FIXME: ew ugly and doesn't work at all anyways
player_api.register_model("character_frozen.b3d", {
	animation_speed = 30,
	textures = {"character_frozen.png"},
	animations = {
		-- Standard animations.
		stand     = {x = 0,   y = 79},
		lay       = {x = 162, y = 166},
		walk      = {x = 168, y = 187},
		mine      = {x = 189, y = 198},
		walk_mine = {x = 200, y = 219},
		sit       = {x = 81,  y = 160},
	},
	collisionbox = {-0.3, 0.0, -0.3, 0.3, 1.7, 0.3},
	stepheight = 0.6,
	eye_height = 1.47,
})
