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

--Unregister default underground biomes, 
minetest.unregister_biome("icesheet_under")
--minetest.unregister_biome("icesheet_ocean")
minetest.unregister_biome("tundra_under")
minetest.unregister_biome("icesheet_ocean")
minetest.unregister_biome("taiga_under")
minetest.unregister_biome("taiga_ocean")
minetest.unregister_biome("snowy_grassland_under")
minetest.unregister_biome("snowy_grassland_ocean")
minetest.unregister_biome("grassland_under")
minetest.unregister_biome("grassland_ocean")
minetest.unregister_biome("coniferous_forest_under")
minetest.unregister_biome("coniferous_forest_ocean")
minetest.unregister_biome("deciduous_forest_under")
minetest.unregister_biome("deciduous_forest_ocean")
minetest.unregister_biome("desert_under")
minetest.unregister_biome("desert_ocean")
minetest.unregister_biome("sandstone_desert_under")
minetest.unregister_biome("sandstone_desert_ocean")
minetest.unregister_biome("cold_desert_under")
minetest.unregister_biome("cold_desert_ocean")
minetest.unregister_biome("savanna_under")
minetest.unregister_biome("savanna_ocean")
minetest.unregister_biome("rainforest_under")
minetest.unregister_biome("rainforest_ocean")



--[[
--Surface biome types can stay, but use mostly sewer-style nodes underneath them
for k, _ in pairs(minetest.registered_biomes) do
	minetest.registered_biomes[k].node_stone = "voxeldungeon:sewerstone"
	minetest.registered_biomes[k].node_dungeon = "voxeldungeon:sewerwall"
	minetest.registered_biomes[k].node_dungeon_alt = nil
	minetest.registered_biomes[k].node_dungeon_stair = nil
end
--]]



minetest.register_alias_force("mapgen_stone", "voxeldungeon:sewerstone")



--For the underground, use these instead
minetest.register_biome({
	name = "sewers",
	node_top = "default:sand",
	depth_top = 1,
	node_filler = "default:sand",
	depth_filler = 3,
	node_stone = "voxeldungeon:sewerstone",
	node_dungeon = "voxeldungeon:sewerwall",
	y_max = 4,
	y_min = -304,
	vertical_blend = 8,
})

minetest.register_biome({
	name = "prisons",
	node_stone = "voxeldungeon:prisonstone",
	node_dungeon = "voxeldungeon:prisonwall",
	y_max = -308,
	y_min = -604,
	vertical_blend = 8,
})

minetest.register_biome({
	name = "caves",
	node_stone = "voxeldungeon:cavestone",
	node_dungeon = "voxeldungeon:cavewall",
	y_max = -608,
	y_min = -904,
	vertical_blend = 8,
})

minetest.register_biome({
	name = "cities",
	node_stone = "voxeldungeon:citystone",
	node_dungeon = "voxeldungeon:citywall",
	y_max = -908,
	y_min = -1204,
	vertical_blend = 8,
})

minetest.register_biome({
	name = "halls",
	node_stone = "voxeldungeon:hallstone",
	node_dungeon = "voxeldungeon:hallwall",
	y_max = -1208,
	y_min = -31000,
	vertical_blend = 8,
})



--"Simple Decorations" which include plants, foilage, chests, and both hidden and revealed traps

minetest.register_decoration({
	name = "voxeldungeon:dormant_chest",
	deco_type = "simple",
	place_on = voxeldungeon.utils.any_valid_ground,

	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.015,
		spread = {x = 100, y = 100, z = 100},
		seed = 7848,
		octaves = 3,
		persist = 0.6
	},

        y_max = 6,
	y_min = -31000,

	flags = "all_floors",
	decoration = {"voxeldungeon:dormant_chest"}
})

minetest.register_decoration({
	name = "voxeldungeon:plant",
	deco_type = "simple",
	place_on = voxeldungeon.utils.any_valid_ground,

	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.01,
		spread = {x = 100, y = 100, z = 100},
		seed = 8479,
		octaves = 3,
		persist = 0.6
	},

        y_max = 6,
	y_min = -31000,

	flags = "all_floors",
	decoration = {"voxeldungeon:plant_fadeleaf", "voxeldungeon:plant_firebloom", "voxeldungeon:plant_sorrowmoss", "voxeldungeon:plant_sungrass"}
})

minetest.register_decoration({
	name = "voxeldungeon:traps_sewers",
	
	deco_type = "simple",
	place_on = voxeldungeon.utils.sewers_valid_ground,

	sidelen = 16,
	noise_params = {
		offset = 0,
		scale = 0.01,
		spread = {x = 100, y = 100, z = 100},
		seed = 5478,
		octaves = 3,
		persist = 0.6
	},

        y_max = 6,
	y_min = -31000,

	flags = "all_floors",
	decoration = {"voxeldungeon:trap_sewers_poisondart", "voxeldungeon:trap_sewers_teleport"}
})



--Foilage is a bit of a special case, because it is meant to come in patches. However, patches are mixtures of short grass (simple), and tall grass (schematic)

minetest.register_decoration({
	name = "voxeldungeon:sewers_shortgrass",
	
	deco_type = "simple",
	place_on = voxeldungeon.utils.sewers_valid_ground,

	sidelen = 16,
	noise_params = {
		offset = -0.9,
		scale = 1.75,
		spread = {x = 10, y = 10, z = 10},
		seed = 329,
		octaves = 1,
		persist = 0.0,
		flags = "absvalue, eased"
	},

        y_max = 6,
	y_min = -31000,

	flags = "all_floors",
	decoration = "voxeldungeon:sewergrass"
})

minetest.register_decoration({
	name = "voxeldungeon:sewers_tallgrass",
	
	deco_type = "schematic",
	place_on = voxeldungeon.utils.sewers_valid_ground,

	sidelen = 16,
	noise_params = {
		offset = -0.9,
		scale = 1.5,
		spread = {x = 10, y = 10, z = 10},
		seed = 329,
		octaves = 1,
		persist = 0.0,
		flags = "absvalue, eased"
	},

	schematic = minetest.get_modpath("voxeldungeon") .. "/schematics/sewers_tallgrass.mts",

        y_max = 6,
	y_min = -31000,

	flags = "all_floors, force_placement",
	place_offset_y = 1,
})

minetest.register_decoration({
	name = "voxeldungeon:prisons_shortgrass",
	
	deco_type = "simple",
	place_on = voxeldungeon.utils.prisons_valid_ground,

	sidelen = 16,
	noise_params = {
		offset = -0.9,
		scale = 1.75,
		spread = {x = 10, y = 10, z = 10},
		seed = 329,
		octaves = 1,
		persist = 0.0,
		flags = "absvalue, eased"
	},

        y_max = 6,
	y_min = -31000,

	flags = "all_floors",
	decoration = "voxeldungeon:prisongrass"
})

minetest.register_decoration({
	name = "voxeldungeon:prisons_tallgrass",
	
	deco_type = "schematic",
	place_on = voxeldungeon.utils.prisons_valid_ground,

	sidelen = 16,
	noise_params = {
		offset = -0.9,
		scale = 1.5,
		spread = {x = 10, y = 10, z = 10},
		seed = 329,
		octaves = 1,
		persist = 0.0,
		flags = "absvalue, eased"
	},

	schematic = minetest.get_modpath("voxeldungeon") .. "/schematics/prisons_tallgrass.mts",

        y_max = 6,
	y_min = -31000,

	flags = "all_floors, force_placement",
	place_offset_y = 1,
})

minetest.register_decoration({
	name = "voxeldungeon:caves_shortgrass",
	
	deco_type = "simple",
	place_on = voxeldungeon.utils.caves_valid_ground,

	sidelen = 16,
	noise_params = {
		offset = -0.9,
		scale = 1.75,
		spread = {x = 10, y = 10, z = 10},
		seed = 329,
		octaves = 1,
		persist = 0.0,
		flags = "absvalue, eased"
	},

        y_max = 6,
	y_min = -31000,

	flags = "all_floors",
	decoration = "voxeldungeon:cavegrass"
})

minetest.register_decoration({
	name = "voxeldungeon:caves_tallgrass",
	
	deco_type = "schematic",
	place_on = voxeldungeon.utils.caves_valid_ground,

	sidelen = 16,
	noise_params = {
		offset = -0.9,
		scale = 1.5,
		spread = {x = 10, y = 10, z = 10},
		seed = 329,
		octaves = 1,
		persist = 0.0,
		flags = "absvalue, eased"
	},

	schematic = minetest.get_modpath("voxeldungeon") .. "/schematics/caves_tallgrass.mts",

        y_max = 6,
	y_min = -31000,

	flags = "all_floors, force_placement",
	place_offset_y = 1,
})

minetest.register_decoration({
	name = "voxeldungeon:cities_shortgrass",
	
	deco_type = "simple",
	place_on = voxeldungeon.utils.cities_valid_ground,

	sidelen = 16,
	noise_params = {
		offset = -0.9,
		scale = 1.75,
		spread = {x = 10, y = 10, z = 10},
		seed = 329,
		octaves = 1,
		persist = 0.0,
		flags = "absvalue, eased"
	},

        y_max = 6,
	y_min = -31000,

	flags = "all_floors",
	decoration = "voxeldungeon:citygrass"
})

minetest.register_decoration({
	name = "voxeldungeon:citie_tallgrass",
	
	deco_type = "schematic",
	place_on = voxeldungeon.utils.cities_valid_ground,

	sidelen = 16,
	noise_params = {
		offset = -0.9,
		scale = 1.5,
		spread = {x = 10, y = 10, z = 10},
		seed = 329,
		octaves = 1,
		persist = 0.0,
		flags = "absvalue, eased"
	},

	schematic = minetest.get_modpath("voxeldungeon") .. "/schematics/cities_tallgrass.mts",

        y_max = 6,
	y_min = -31000,

	flags = "all_floors, force_placement",
	place_offset_y = 1,
})

minetest.register_decoration({
	name = "voxeldungeon:halls_shortgrass",
	
	deco_type = "simple",
	place_on = voxeldungeon.utils.halls_valid_ground,

	sidelen = 16,
	noise_params = {
		offset = -0.9,
		scale = 1.75,
		spread = {x = 10, y = 10, z = 10},
		seed = 329,
		octaves = 1,
		persist = 0.0,
		flags = "absvalue, eased"
	},

        y_max = 6,
	y_min = -31000,

	flags = "all_floors",
	decoration = "voxeldungeon:hallgrass"
})

minetest.register_decoration({
	name = "voxeldungeon:halls_tallgrass",
	
	deco_type = "schematic",
	place_on = voxeldungeon.utils.halls_valid_ground,

	sidelen = 16,
	noise_params = {
		offset = -0.9,
		scale = 1.5,
		spread = {x = 10, y = 10, z = 10},
		seed = 329,
		octaves = 1,
		persist = 0.0,
		flags = "absvalue, eased"
	},

	schematic = minetest.get_modpath("voxeldungeon") .. "/schematics/halls_tallgrass.mts",

        y_max = 6,
	y_min = -31000,

	flags = "all_floors, force_placement",
	place_offset_y = 1,
})



--Remove all default ores
minetest.clear_registered_ores()

--Use these instead
minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:sewergold",
	wherein = "voxeldungeon:sewerstone",
	clust_scarcity = 16 * 16 * 16,
	clust_num_ores = 2,
	clust_size = 2,
	y_min = -31000,
        y_max = 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:prisongold",
	wherein = "voxeldungeon:prisonstone",
	clust_scarcity = 14 * 14 * 14,
	clust_num_ores = 3,
	clust_size = 2,
	y_min = -31000,
        y_max = 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:cavegold",
	wherein = "voxeldungeon:cavestone",
	clust_scarcity = 12 * 12 * 12,
	clust_num_ores = 5,
	clust_size = 3,
	y_min = -31000,
        y_max = 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:citygold",
	wherein = "voxeldungeon:citystone",
	clust_scarcity = 12 * 12 * 12,
	clust_num_ores = 5,
	clust_size = 3,
	y_min = -31000,
        y_max = 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:hallgold",
	wherein = "voxeldungeon:hallstone",
	clust_scarcity = 12 * 12 * 12,
	clust_num_ores = 3,
	clust_size = 2,
	y_min = -31000,
        y_max = 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:sewercoal",
	wherein = "voxeldungeon:sewerstone",
	clust_scarcity = 8 * 8 * 8,
	clust_num_ores = 8,
	clust_size = 4,
	y_min = -31000,
        y_max = 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:prisoncoal",
	wherein = "voxeldungeon:prisonstone",
	clust_scarcity = 9 * 9 * 9,
	clust_num_ores = 8,
	clust_size = 4,
	y_min = -31000,
        y_max = 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:cavecoal",
	wherein = "voxeldungeon:cavestone",
	clust_scarcity = 10 * 10 * 10,
	clust_num_ores = 8,
	clust_size = 4,
	y_min = -31000,
        y_max = 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:citycoal",
	wherein = "voxeldungeon:citystone",
	clust_scarcity = 11 * 11 * 11,
	clust_num_ores = 8,
	clust_size = 4,
	y_min = -31000,
        y_max = 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:hallcoal",
	wherein = "voxeldungeon:hallstone",
	clust_scarcity = 12 * 12 * 12,
	clust_num_ores = 8,
	clust_size = 4,
	y_min = -31000,
        y_max = 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:prisoniron",
	wherein = "voxeldungeon:prisonstone",
	clust_scarcity = 10 * 10 * 10,
	clust_num_ores = 12,
	clust_size = 4,
	y_min = -31000,
        y_max = 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:caveiron",
	wherein = "voxeldungeon:cavestone",
	clust_scarcity = 12 * 12 * 12,
	clust_num_ores = 10,
	clust_size = 4,
	y_min = -31000,
        y_max = 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:cityiron",
	wherein = "voxeldungeon:citystone",
	clust_scarcity = 14 * 14 * 14,
	clust_num_ores = 8,
	clust_size = 3,
	y_min = -31000,
        y_max = 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:halliron",
	wherein = "voxeldungeon:hallstone",
	clust_scarcity = 16 * 16 * 16,
	clust_num_ores = 6,
	clust_size = 3,
	y_min = -31000,
        y_max = 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:cavemese",
	wherein = "voxeldungeon:cavestone",
	clust_scarcity = 12 * 12 * 12,
	clust_num_ores = 5,
	clust_size = 3,
	y_min = -31000,
        y_max = 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:citymese",
	wherein = "voxeldungeon:citystone",
	clust_scarcity = 13 * 13 * 13,
	clust_num_ores = 5,
	clust_size = 3,
	y_min = -31000,
        y_max = 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:hallmese",
	wherein = "voxeldungeon:hallstone",
	clust_scarcity = 14 * 14 * 14,
	clust_num_ores = 4,
	clust_size = 2,
	y_min = -31000,
        y_max = 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:citydiamond",
	wherein = "voxeldungeon:citystone",
	clust_scarcity = 14 * 14 * 14,
	clust_num_ores = 6,
	clust_size = 3,
	y_min = -31000,
        y_max = 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:halldiamond",
	wherein = "voxeldungeon:hallstone",
	clust_scarcity = 16 * 16 * 16,
	clust_num_ores = 4,
	clust_size = 2,
	y_min = -31000,
        y_max = 31000,
})

minetest.register_ore({
	ore_type = "scatter",
	ore = "voxeldungeon:halldemonite",
	wherein = "voxeldungeon:hallstone",
	clust_scarcity = 14 * 14 * 14,
	clust_num_ores = 4,
	clust_size = 2,
	y_min = -31000,
        y_max = 31000,
})
