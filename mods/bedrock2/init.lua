local S = minetest.get_translator("bedrock2")

local bedrock = {}

bedrock.layer = -30912 -- determined as appropriate by experiment
bedrock.node = {name = "bedrock2:bedrock"}

local depth = tonumber(minetest.settings:get("bedrock2_y"))
if depth ~= nil then
	bedrock.layer = depth
end

minetest.register_on_generated(function(minp, maxp)
	if maxp.y >= bedrock.layer and minp.y <= bedrock.layer then
		local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
		local data = vm:get_data()
		local area = VoxelArea:new({MinEdge=emin, MaxEdge=emax})
		local c_bedrock = minetest.get_content_id("bedrock2:bedrock")

		for x = minp.x, maxp.x do
			for z = minp.z, maxp.z do
				local p_pos = area:index(x, bedrock.layer, z)
				data[p_pos] = c_bedrock
			end
		end

		vm:set_data(data)
		vm:calc_lighting()
		vm:update_liquids()
		vm:write_to_map()
	end
end)

minetest.register_node("bedrock2:bedrock", {
	description = S("Bedrock"),
	_doc_items_longdesc = S("Bedrock is a very hard block. It cannot be mined, altered, destroyed or moved by any means. It appears at the bottom of the world in a flat layer."),
	tiles = {"bedrock2_bedrock.png"},
	groups = {immortal=1, unbreakable=1, not_in_creative_inventory=1, },
	sounds = { footstep = { name = "bedrock2_step", gain = 1 } },
	is_ground_content = false,
	on_blast = function() end,
	on_destruct = function () end,
	can_dig = function() return false end,
	diggable = false,
	drop = "",
})

if minetest.get_modpath("mesecons_mvps") ~= nil then
	mesecon.register_mvps_stopper("bedrock2:bedrock")
end
