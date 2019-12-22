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

local function register_flatnode(name, desc, image, grps, flood)
	local i = "voxeldungeon_"..image..".png"
	minetest.register_node("voxeldungeon:"..name,
	{
		description = desc, 
		
		tiles = {i},
		inventory_image = i,
		wield_image = i,
		use_texture_alpha = true,
		
		node_box = {
			type = "fixed",
			fixed = {-0.5, -0.5, -0.5, 0.5, -0.499, 0.5},
		},
		drawtype = "nodebox",

		paramtype = "light",
		sunlight_propogates = true,
		walkable = false,
		buildable_to = true,
		drop = {},
		groups = grps,
		floodable = flood,
	})
end



minetest.register_node("voxeldungeon:sewerstone", {
	description = "Limestone",
	tiles = {"voxeldungeon_tiles_sewers_stone.png"},
	groups = {cracky=3, level=1, stone = 2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("voxeldungeon:sewerwall", {
	description = "Sewer Wall",
	tiles = {"voxeldungeon_tiles_sewers_wall.png"},
	groups = {cracky=3, level=2}
})

minetest.register_node("voxeldungeon:sewerfloor", {
	description = "Sewer Floor",
	tiles = {"voxeldungeon_tiles_sewers_floor.png"},
	groups = {cracky=3, level=1}
})

register_flatnode("sewers_shortgrass", "Sewer Grass", "tiles_sewers_grass", {flammable = 1, attached_node = 1, dig_immediate = 3}, true)
register_flatnode("prisons_shortgrass", "Prison Grass", "tiles_prisons_grass", {flammable = 1, attached_node = 1, dig_immediate = 3}, true)
register_flatnode("caves_shortgrass", "Cave Grass", "tiles_caves_grass", {flammable = 1, attached_node = 1, dig_immediate = 3}, true)
register_flatnode("cities_shortgrass", "City Grass", "tiles_cities_grass", {flammable = 1, attached_node = 1, dig_immediate = 3}, true)
register_flatnode("halls_shortgrass", "Hall Grass", "tiles_halls_grass", {flammable = 1, attached_node = 1, dig_immediate = 3}, true)

register_flatnode("embers", "Embers", "tiles_embers", {attached_node = 1, dig_immediate = 3}, true)

register_flatnode("sewermoss", "Sewer Moss", "tiles_sewers_moss", {attached_node = 1, dig_immediate = 3}, true)

minetest.register_node("voxeldungeon:sewerwood", {
	description = "Sewer Wood",
	tiles = {"voxeldungeon_tiles_sewers_special.png"},
	groups = {choppy=3}
})

minetest.register_node("voxeldungeon:sewerbookshelf", {
	description = "Sewer Bookshelf",
	tiles = {"voxeldungeon_tiles_sewers_special.png", "voxeldungeon_tiles_sewers_special.png",
		{name = "voxeldungeon_tiles_sewers_bookshelf.png",
		tileable_vertical = false}},
	groups = {choppy=2}
})

minetest.register_node("voxeldungeon:sewerpedestal", {
	description = "Sewer Pedestal",
	tiles = {"voxeldungeon_tiles_sewers_pedestal.png", "voxeldungeon_tiles_sewers_pedestal.png",
		{name = "voxeldungeon_tiles_sewers_pedestal_side.png",
		tileable_vertical = false}},
	groups = {cracky=3}
})

register_flatnode("sewerwater", "Sewer Water", "tiles_sewers_water", {attached_node = 1, dig_immediate = 3}, true)
minetest.registered_nodes["voxeldungeon:sewerwater"].tiles = 
{{
	name = "voxeldungeon_tiles_sewers_water0.png",
	animation = {type = "vertical_frames", aspect_w = 16, aspect_h = 16, length = 6}
}}

register_flatnode("trap_sewers_wornout", "Worn Out Sewer Trap", "tiles_sewers_trap_wornout", {attached_node = 1, dig_immediate = 3}, true)
register_flatnode("trap_prisons_wornout", "Worn Out Prison Trap", "tiles_prisons_trap_wornout", {attached_node = 1, dig_immediate = 3}, true)
register_flatnode("trap_caves_wornout", "Worn Out Cave Trap", "tiles_caves_trap_wornout", {attached_node = 1, dig_immediate = 3}, true)
register_flatnode("trap_cities_wornout", "Worn Out City Trap", "tiles_cities_trap_wornout", {attached_node = 1, dig_immediate = 3}, true)
register_flatnode("trap_halls_wornout", "Worn Out Hall Trap", "tiles_halls_trap_wornout", {attached_node = 1, dig_immediate = 3}, true)

minetest.register_node("voxeldungeon:sewerpipe", {
	description = "Sewer Pipe",
	tiles = {"voxeldungeon_tiles_sewers_wall.png", "voxeldungeon_tiles_sewers_wall.png",
		{name = "voxeldungeon_tiles_sewers_wall_pipe.png",
		tileable_vertical = false}},
	groups = {cracky=3}
})



--Prisons



minetest.register_node("voxeldungeon:prisonstone", {
	description = "Travertine",
	tiles = {"voxeldungeon_tiles_prisons_stone.png"},
	groups = {cracky=3, level=2, stone = 2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("voxeldungeon:prisonfloor", {
	description = "Prison Floor",
	tiles = {"voxeldungeon_tiles_prisons_floor.png"},
	groups = {cracky=3, level=2}
})

minetest.register_node("voxeldungeon:prisonwall", {
	description = "Prison Wall",
	tiles = {"voxeldungeon_tiles_prisons_wall.png"},
	groups = {cracky=3, level=3}
})

minetest.register_node("voxeldungeon:prisongrate", {
	description = "Prison Grating",
	tiles = {"voxeldungeon_tiles_prisons_special.png"},
	groups = {cracky=3}
})

minetest.register_node("voxeldungeon:prisonbookshelf", {
	description = "Prison Bookshelf",
	tiles = {"voxeldungeon_tiles_sewers_special.png", "voxeldungeon_tiles_sewers_special.png",
		{name = "voxeldungeon_tiles_prisons_bookshelf.png",
		tileable_vertical = false}},
	groups = {choppy=2}
})

minetest.register_node("voxeldungeon:prisontorch", {
	description = "Prison Torch",
	tiles = {"voxeldungeon_tiles_prisons_wall.png", "voxeldungeon_tiles_prisons_wall.png",
		{name = "voxeldungeon_tiles_prisons_wall_torch.png",
		tileable_vertical = false}},
	groups = {cracky=3}
})



--Caves



minetest.register_node("voxeldungeon:cavestone", {
	description = "Slate",
	tiles = {"voxeldungeon_tiles_caves_stone.png"},
	groups = {cracky=3, level=3, stone = 2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("voxeldungeon:cavefloor", {
	description = "Cave Floor",
	tiles = {"voxeldungeon_tiles_caves_floor.png"},
	groups = {cracky=3, level=3}
})

minetest.register_node("voxeldungeon:cavewall", {
	description = "Cave Wall",
	tiles = {"voxeldungeon_tiles_caves_wall.png"},
	groups = {cracky=3, level=4}
})

minetest.register_node("voxeldungeon:cavecrate", {
	description = "Cave Crate",
	tiles = {"voxeldungeon_tiles_caves_special.png"},
	groups = {cracky=3}
})

minetest.register_node("voxeldungeon:cavebookshelf", {
	description = "Cave Bookshelf",
	tiles = {"voxeldungeon_tiles_sewers_special.png", "voxeldungeon_tiles_sewers_special.png",
		{name = "voxeldungeon_tiles_caves_bookshelf.png",
		tileable_vertical = false}},
	groups = {choppy=2}
})

minetest.register_node("voxeldungeon:caveembedded", {
	description = "Embedded Cave Wall",
	tiles = {"voxeldungeon_tiles_caves_wall_embedded.png"},
	groups = {cracky=3}
})



--Cities



minetest.register_node("voxeldungeon:citystone", {
	description = "Serpentine",
	tiles = {"voxeldungeon_tiles_cities_stone.png"},
	groups = {cracky=3, level=4, stone = 2}
})

minetest.register_node("voxeldungeon:cityfloor", {
	description = "City Floor",
	tiles = {"voxeldungeon_tiles_cities_floor.png"},
	groups = {cracky=3, level=4}
})

minetest.register_node("voxeldungeon:citywall", {
	description = "City Wall",
	tiles = {"voxeldungeon_tiles_cities_wall.png"},
	groups = {cracky=3, level=5}
})

minetest.register_node("voxeldungeon:citycarpet", {
	description = "City Carpet",
	tiles = {"voxeldungeon_tiles_cities_special.png"},
	groups = {cracky=3}
})

minetest.register_node("voxeldungeon:citybookshelf", {
	description = "City Bookshelf",
	tiles = {"voxeldungeon_tiles_sewers_special.png", "voxeldungeon_tiles_sewers_special.png",
		{name = "voxeldungeon_tiles_cities_bookshelf.png",
		tileable_vertical = false}},
	groups = {choppy=2}
})

minetest.register_node("voxeldungeon:citydecayed", {
	description = "Decayed City Wall",
	tiles = {"voxeldungeon_tiles_cities_wall_decayed.png"},
	groups = {cracky=3}
})



--Halls



minetest.register_node("voxeldungeon:hallstone", {
	description = "Granite",
	tiles = {"voxeldungeon_tiles_halls_stone.png"},
	groups = {cracky=3, level=5, stone = 2},
	sounds = default.node_sound_stone_defaults()
})

minetest.register_node("voxeldungeon:hallfloor", {
	description = "Hall Floor",
	tiles = {"voxeldungeon_tiles_halls_floor.png"},
	groups = {cracky=3, level=5}
})

minetest.register_node("voxeldungeon:hallwall", {
	description = "Hall Wall",
	tiles = {"voxeldungeon_tiles_halls_wall.png"},
	groups = {cracky=3, level=5}
})

minetest.register_node("voxeldungeon:hallbrick", {
	description = "Hall Bricks",
	tiles = {"voxeldungeon_tiles_halls_special.png"},
	groups = {cracky=3}
})

minetest.register_node("voxeldungeon:hallbookshelf", {
	description = "Hall Bookshelf",
	tiles = {"voxeldungeon_tiles_sewers_special.png", "voxeldungeon_tiles_sewers_special.png",
		{name = "voxeldungeon_tiles_halls_bookshelf.png",
		tileable_vertical = false}},
	groups = {choppy=2}
})

minetest.register_node("voxeldungeon:hallstainedglass", {
	description = "Hall Stained Glass Wall",
	tiles = {"voxeldungeon_tiles_halls_wall.png", "voxeldungeon_tiles_halls_wall.png",
		{name = "voxeldungeon_tiles_halls_wall_decorated.png",
		tileable_vertical = false}},
	groups = {cracky=3}
})



--slabs



stairs.register_slab("voxeldungeon:sewertiles", "voxeldungeon:sewertiles",
	{cracky=3}, 
	{"voxeldungeon_tiles_sewers_floor.png", "voxeldungeon_tiles_sewers_floor.png",
		{name = "voxeldungeon_tiles_sewers_floor_slab.png",
		tileable_vertical = false}},
	"Sewer Tiles")



--doors



doors.register_door("voxeldungeon:sewerdoor", {
	description = "Sewer Door",
	tiles = {{name = "voxeldungeon_tiles_sewers_door.png", backface_culling = true }},
	inventory_image = "voxeldungeon_icons_sewers_door.png",
	wield_image = "voxeldungeon_icons_sewers_door.png",
	
	groups = {choppy = 2, oddly_breakable_by_hand = 2, flammable = 2},
})



--traps

local namelist = {"sewers", "prisons", "caves", "cities", "halls"}
local desclist = {"Sewers", "Prisons", "Caves", "Cities", "Halls"}

local function register_trap(name, desc, on_trigger)
	for i = 1, 5 do
		local img = "voxeldungeon_tiles_"..namelist[i].."_trap_"..name..".png"

		minetest.register_node("voxeldungeon:trap_"..namelist[i].."_"..name, 
		{
			description = desc.." Trap ("..desclist[i]..")", 
			tiles = {img},
			inventory_image = img,
			wield_image = img,
			
			node_box = 
			{
				type = "fixed",
				fixed = {-0.5, -0.5, -0.5, 0.5, -0.499, 0.5},
			},
			drawtype = "nodebox",

			paramtype = "light",
			sunlight_propogates = true,
			walkable = false,
			groups = {attached_node = 1, oddly_breakable_by_hand = 2}, 
			on_step = function(pos, objs)
				minetest.set_node(pos, {name = "voxeldungeon:trap_"..namelist[i].."_wornout"})
				on_trigger(pos, objs)
			end,
		})

		local reveal = function(pos, node, player)
			if player and player:is_player() then
				voxeldungeon.glog.w("You noticed something.", player)
				minetest.set_node(pos, {name = "voxeldungeon:trap_"..namelist[i].."_"..name})
			end
		end

		minetest.register_node("voxeldungeon:trap_"..namelist[i].."_"..name.."_hidden", 
		{
			description = "Hidden "..desc.." Trap ("..desclist[i]..")", 
			tiles = {"voxeldungeon_blank.png"},
			inventory_image = img,
			wield_image = img,
			
			node_box = 
			{
				type = "fixed",
				fixed = {-0.5, -0.5, -0.5, 0.5, -0.499, 0.5},
			},
			drawtype = "nodebox",

			paramtype = "light",
			sunlight_propogates = true,
			walkable = false,
			groups = {attached_node = 1, oddly_breakable_by_hand = 2}, 

			on_step = function(pos, objs)
				for _, obj in ipairs(objs) do
					if obj:is_player() then
						voxeldungeon.glog.i("A hidden pressure plate clicks!", obj)
					end
				end

				minetest.set_node(pos, {name = "voxeldungeon:trap_"..namelist[i].."_wornout"})
				on_trigger(pos, objs)
			end,

			on_punch = reveal,
			on_rightclick = reveal,
		})
	end
end

register_trap("gripping", "Gripping", function(pos, objs)
	for i = 1, #objs do
		if objs[i] then
			local damage = math.max(0, voxeldungeon.utils.getDepth(pos) + 3)

			voxeldungeon.buffs.attach_buff("voxeldungeon:bleeding", objs[i], damage)
			voxeldungeon.buffs.attach_buff("voxeldungeon:crippled", objs[i], 10)
		end 
	end
end)

register_trap("poisondart", "Poison Dart", function(pos, objs)
	for i = 1, #objs do
		if objs[i] then
			voxeldungeon.buffs.attach_buff("voxeldungeon:poison", objs[i], 4 + math.floor(voxeldungeon.utils.getDepth(pos) / 2))
		end 
	end
	voxeldungeon.particles.burst("poison", pos, 3)
end)

register_trap("teleport", "Teleportation", function(pos, objs)
	for i = 1, #objs do
		voxeldungeon.utils.randomTeleport(objs[i])
	end
end)

register_trap("toxicgas", "Toxic Gas", function(pos, objs)
	voxeldungeon.blobs.seed("toxicgas", pos, 8000)
end)



--Ores



minetest.register_node("voxeldungeon:sewergold", {
	description = "Gold Ore",
	tiles = {"voxeldungeon_ore_sewers_gold.png"},
	groups = {cracky=3, level=1},
	drop = "default:gold_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("voxeldungeon:prisongold", {
	description = "Gold Ore",
	tiles = {"voxeldungeon_ore_prisons_gold.png"},
	groups = {cracky=3, level=2},
	drop = "default:gold_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("voxeldungeon:cavegold", {
	description = "Gold Ore",
	tiles = {"voxeldungeon_ore_caves_gold.png"},
	groups = {cracky=3, level=3},
	drop = "default:gold_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("voxeldungeon:citygold", {
	description = "Gold Ore",
	tiles = {"voxeldungeon_ore_cities_gold.png"},
	groups = {cracky=3, level=4},
	drop = "default:gold_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("voxeldungeon:hallgold", {
	description = "Gold Ore",
	tiles = {"voxeldungeon_ore_halls_gold.png"},
	groups = {cracky=3, level=5},
	drop = "default:gold_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("voxeldungeon:sewercoal", {
	description = "Coal Ore",
	tiles = {"voxeldungeon_ore_sewers_coal.png"},
	groups = {cracky=3, level=1},
	drop = "default:coal_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("voxeldungeon:prisoncoal", {
	description = "Coal Ore",
	tiles = {"voxeldungeon_ore_prisons_coal.png"},
	groups = {cracky=3, level=2},
	drop = "default:coal_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("voxeldungeon:cavecoal", {
	description = "Coal Ore",
	tiles = {"voxeldungeon_ore_caves_coal.png"},
	groups = {cracky=3, level=3},
	drop = "default:coal_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("voxeldungeon:citycoal", {
	description = "Coal Ore",
	tiles = {"voxeldungeon_ore_cities_coal.png"},
	groups = {cracky=3, level=4},
	drop = "default:coal_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("voxeldungeon:hallcoal", {
	description = "Coal Ore",
	tiles = {"voxeldungeon_ore_halls_coal.png"},
	groups = {cracky=3, level=5},
	drop = "default:coal_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("voxeldungeon:prisoniron", {
	description = "Iron Ore",
	tiles = {"voxeldungeon_ore_prisons_iron.png"},
	groups = {cracky=3, level=2},
	drop = "default:iron_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("voxeldungeon:caveiron", {
	description = "Iron Ore",
	tiles = {"voxeldungeon_ore_caves_iron.png"},
	groups = {cracky=3, level=3},
	drop = "default:iron_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("voxeldungeon:cityiron", {
	description = "Iron Ore",
	tiles = {"voxeldungeon_ore_cities_iron.png"},
	groups = {cracky=3, level=4},
	drop = "default:iron_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("voxeldungeon:halliron", {
	description = "Iron Ore",
	tiles = {"voxeldungeon_ore_halls_iron.png"},
	groups = {cracky=3, level=5},
	drop = "default:iron_lump",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("voxeldungeon:cavemese", {
	description = "Mese Ore",
	tiles = {"voxeldungeon_ore_caves_mese.png"},
	groups = {cracky=3, level=3},
	drop = "default:mese_crystal",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("voxeldungeon:citymese", {
	description = "Mese Ore",
	tiles = {"voxeldungeon_ore_cities_mese.png"},
	groups = {cracky=3, level=4},
	drop = "default:mese_crystal",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("voxeldungeon:hallmese", {
	description = "Mese Ore",
	tiles = {"voxeldungeon_ore_halls_mese.png"},
	groups = {cracky=3, level=5},
	drop = "default:mese_crystal",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("voxeldungeon:citydiamond", {
	description = "Diamond Ore",
	tiles = {"voxeldungeon_ore_cities_diamond.png"},
	groups = {cracky=3, level=4},
	drop = "default:diamond",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("voxeldungeon:halldiamond", {
	description = "Diamond Ore",
	tiles = {"voxeldungeon_ore_halls_diamond.png"},
	groups = {cracky=3, level=5},
	drop = "default:diamond",
	sounds = default.node_sound_stone_defaults(),
})

minetest.register_node("voxeldungeon:halldemonite", {
	description = "Demonite Ore",
	tiles = {"voxeldungeon_ore_halls_demonite.png"},
	groups = {cracky=3, level=5},
	drop = "voxeldungeon:demonite_lump",
	sounds = default.node_sound_stone_defaults(),
})



--Misc



minetest.register_node("voxeldungeon:demonite_block", {
	description = "Demonite Block",
	tiles = {"voxeldungeon_tiles_demonite_block.png"},
	groups = {cracky=3, level=5},
	sounds = default.node_sound_stone_defaults(),
})

minetest.after(0, minetest.override_item, "default:chest", 
{
	tiles = {
		"voxeldungeon_node_chest_top.png",
		"voxeldungeon_node_chest_bottom.png",
		"voxeldungeon_node_chest_right.png",
		"voxeldungeon_node_chest_left.png",
		"voxeldungeon_node_chest_back.png",
		"voxeldungeon_node_chest_front.png",
	},

	inventory_image = "voxeldungeon_node_chest_icon.png",
	wield_image = "voxeldungeon_node_chest_icon.png",
})

minetest.after(0, minetest.override_item, "default:chest_open", 
{
	tiles = {
		"voxeldungeon_node_chest_top.png",
		"voxeldungeon_node_chest_bottom.png",
		"voxeldungeon_node_chest_right.png",
		"voxeldungeon_node_chest_left.png",
		"voxeldungeon_node_chest_front.png",
		"default_chest_inside.png"
	},

	inventory_image = "voxeldungeon_node_chest_icon.png",
	wield_image = "voxeldungeon_node_chest_icon.png",
})
