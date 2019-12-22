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

local function trash(...)
	for _, name in ipairs({...}) do
		minetest.unregister_item(name)
	end
end

trash(
	--All bronze stuff, as well as tin and copper. Neither material has a real purpose by default, if bronze is removed.
	"default:bronze_ingot", "default:pick_bronze", "default:axe_bronze", "default:shovel_bronze", "default:sword_bronze", "default:bronzeblock", 
	"stairs:slab_bronzeblock", "stairs:stair_bronzeblock", "stairs:stair_inner_bronzeblock", "stairs:stair_outer_bronzeblock", "default:copper_ingot", 
	"default:copper_lump", "default:stone_with_copper", "default:copperblock", "stairs:slab_copperblock", "stairs:stair_copperblock", 
	"stairs:stair_inner_copperblock", "stairs:stair_outer_copperblock", "default:tin_ingot", "default:tin_lump", "default:stone_with_tin", 
	"default:tinblock", "stairs:slab_tinblock", "stairs:stair_tinblock", "stairs:stair_inner_tinblock", "stairs:stair_outer_tinblock", 

	--Default ore types, because the underground is now populated with other kinds of stone
	"default:stone_with_coal", "default:stone_with_diamond", "default:stone_with_gold", "default:stone_with_iron", "default:stone_with_mese", 

	--No.
	"mobs:pick_lava",

	--Various cannons items, many of which would've been unused already or get replaced
	"cannons:ball_exploding_stack_1", "cannons:ball_exploding_stack_2", "cannons:ball_exploding_stack_3", "cannons:ball_exploding_stack_4", 
	"cannons:ball_exploding_stack_5", 
	"cannons:ball_fire_stack_1", "cannons:ball_fire_stack_2", "cannons:ball_fire_stack_3", "cannons:ball_fire_stack_4", "cannons:ball_fire_stack_5", 
	"cannons:ball_wood_stack_1", "cannons:ball_wood_stack_2", "cannons:ball_wood_stack_3", "cannons:ball_wood_stack_4", "cannons:ball_wood_stack_5",
	"cannons:ball_stone_stack_1", "cannons:ball_stone_stack_2", "cannons:ball_stone_stack_3", "cannons:ball_stone_stack_4", "cannons:ball_stone_stack_5",
	"cannons:ball_steel_stack_1", "cannons:ball_steel_stack_2", "cannons:ball_steel_stack_3", "cannons:ball_steel_stack_4", "cannons:ball_steel_stack_5",
	"cannons:cannon_bronze", "cannons:ship_stand_with_cannon_bronze", "cannons:wood_stand_with_cannon_bronze", "cannons:gunpowder",

	--Various spawn eggs for mobs_redo versions of mobs
	"mobs_monster:dirt_monster", "mobs_monster:sand_monster", "mobs_monster:spider", "mobs_monster:tree_monster")

--Mobs from mobs_monster which have been remade using Mobkit
entitycontrol.unregister_entity("mobs_monster:dirt_monster")
entitycontrol.unregister_entity("mobs_monster:sand_monster")
entitycontrol.unregister_entity("mobs_monster:spider")
entitycontrol.unregister_entity("mobs_monster:tree_monster")
