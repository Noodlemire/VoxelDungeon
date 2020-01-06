nodeglow = {}



function nodeglow.node_to_glow(nodename)
	if nodename:sub(1, 9) == "nodeglow:" then
		return nodename
	else
		return "nodeglow:"..(nodename:gsub(":", "__"))
	end
end

function nodeglow.node_from_glow(glowname)
	if glowname:sub(1, 9) == "nodeglow:" then
		return glowname:sub(10):gsub("__", ":")
	else
		return glowname
	end
end



local LIGHT_LEVEL = minetest.LIGHT_MAX

local function deepcopy(orig)
	local orig_type = type(orig)
	local copy

	if orig_type == 'table' then
		copy = {}

		for orig_key, orig_value in next, orig, nil do
			copy[deepcopy(orig_key)] = deepcopy(orig_value)
		end

		setmetatable(copy, deepcopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end

	return copy
end

local nodeglow_defs = {}

for name, d in pairs(minetest.registered_nodes) do
	local def = deepcopy(d)

	if name ~= "ignore" and def.light_source ~= LIGHT_LEVEL then
		def.description = "Glowing "..def.description
		--def.light_source = LIGHT_LEVEL
		def.sunlight_propagates = true
		def.groups.not_in_creative_inventory = 1

		nodeglow_defs[name] = def
	end
end

for oldname, def in pairs(nodeglow_defs) do
	local newname = nodeglow.node_to_glow(oldname)
	local old_move_out = def._on_move_out
	local old_move_in = def._on_move_in

	minetest.register_node(newname, def)

	minetest.override_item(newname, {
		light_source = LIGHT_LEVEL,
		drop = def.drop or oldname,

		--[[_on_move_out = function(pos, obj)
			if old_move_out then old_move_out(pos, obj) end

			if obj:is_player() then
				minetest.after(0.5, function()
					local node = minetest.get_node_or_nil(pos)
					if node then
						node.name = oldname
						minetest.swap_node(pos, node)
					end
				end)
			end
		end,--]]
	})


	--[[minetest.override_item(oldname, {
		_on_move_in = function(pos, obj)
			if old_move_in then old_move_in(pos, obj) end

			if obj:is_player() then
				local node = minetest.get_node_or_nil(pos)
				if node then
					node.name = newname
					minetest.swap_node(pos, node)
				end
			end
		end,
	})--]]
end
