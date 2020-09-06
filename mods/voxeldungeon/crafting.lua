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



--Armor

minetest.register_craft({
	output = "voxeldungeon:armor_wood",
	recipe = 
	{
		{"group:wood", "", "group:wood"},
		{"group:wood", "group:wood", "group:wood"},
		{"group:wood", "group:wood", "group:wood"}
	}
})

minetest.register_craft({
	output = "voxeldungeon:armor_cactus",
	recipe = 
	{
		{"default:cactus", "", "default:cactus"},
		{"default:cactus", "default:cactus", "default:cactus"},
		{"default:cactus", "default:cactus", "default:cactus"}
	}
})

minetest.register_craft({
	output = "voxeldungeon:armor_steel",
	recipe = 
	{
		{"default:steel_ingot", "", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"}
	}
})

minetest.register_craft({
	output = "voxeldungeon:armor_mese",
	recipe = 
	{
		{"default:mese_crystal", "", "default:mese_crystal"},
		{"default:mese_crystal", "default:mese_crystal", "default:mese_crystal"},
		{"default:mese_crystal", "default:mese_crystal", "default:mese_crystal"}
	}
})

minetest.register_craft({
	output = "voxeldungeon:armor_diamond",
	recipe = 
	{
		{"default:diamond", "", "default:diamond"},
		{"default:diamond", "default:diamond", "default:diamond"},
		{"default:diamond", "default:diamond", "default:diamond"}
	}
})



--General Demonite stuff

minetest.register_craft({
	type = "cooking",
	output = "voxeldungeon:demonite_ingot",
	recipe = "voxeldungeon:demonite_lump"
})

minetest.register_craft({
	output = "voxeldungeon:armor_demonite",
	recipe = 
	{
		{"voxeldungeon:demonite_ingot", "", "voxeldungeon:demonite_ingot"},
		{"voxeldungeon:demonite_ingot", "voxeldungeon:demonite_ingot", "voxeldungeon:demonite_ingot"},
		{"voxeldungeon:demonite_ingot", "voxeldungeon:demonite_ingot", "voxeldungeon:demonite_ingot"}
	}
})

minetest.register_craft({
	output = "voxeldungeon:pick_demonite",
	recipe = {
		{"voxeldungeon:demonite_ingot", "voxeldungeon:demonite_ingot", "voxeldungeon:demonite_ingot"},
		{"", "default:stick", ""},
		{"", "default:stick", ""}
	}
})

minetest.register_craft({
	output = "voxeldungeon:weapon_sword_demonite",
	recipe = 
	{
		{"", "voxeldungeon:demonite_ingot", ""},
		{"", "voxeldungeon:demonite_ingot", ""},
		{"", "default:stick", ""}
	}
})

minetest.register_craft({
	output = "voxeldungeon:demonite_block",
	recipe = 
	{
		{"voxeldungeon:demonite_ingot", "voxeldungeon:demonite_ingot", "voxeldungeon:demonite_ingot"},
		{"voxeldungeon:demonite_ingot", "voxeldungeon:demonite_ingot", "voxeldungeon:demonite_ingot"},
		{"voxeldungeon:demonite_ingot", "voxeldungeon:demonite_ingot", "voxeldungeon:demonite_ingot"},
	}
})

minetest.register_craft({
	output = "voxeldungeon:ball_demonite 5",
	recipe = 
	{
		{"", "voxeldungeon:demonite_ingot", ""},
		{"voxeldungeon:demonite_ingot", "voxeldungeon:demonite_ingot", "voxeldungeon:demonite_ingot"},
		{"", "voxeldungeon:demonite_ingot", ""},
	}
})



--Any crafted item is instantly identified
minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	voxeldungeon.items.identify(itemstack)
	return itemstack
end)



--Bed recipes that allow any wool

minetest.register_craft({
	output = "beds:bed_bottom",
	recipe = 
	{
		{"group:wool", "group:wool", "group:wool"},
		{"group:wood", "group:wood", "group:wood"}
	}
})

minetest.register_craft({
	output = "beds:fancy_bed_bottom",
	recipe = 
	{
		{"", "", "group:stick"},
		{"group:wool", "group:wool", "group:wool"},
		{"group:wood", "group:wood", "group:wood"}
	}
})



--Cannon Ball recipes

minetest.register_craft({
	output = "voxeldungeon:ball_stone 5",
	recipe = 
	{
		{"", "group:stone", ""},
		{"group:stone", "group:stone", "group:stone"},
		{"", "group:stone", ""}
	}
})

minetest.register_craft({
	output = "voxeldungeon:ball_steel 5",
	recipe = 
	{
		{"", "default:steel_ingot",""},
		{"default:steel_ingot", "default:steel_ingot", "default:steel_ingot"},
		{"", "default:steel_ingot",""},
	}
})

minetest.register_craft({
	output = "voxeldungeon:ball_mese 5",
	recipe = 
	{
		{"", "default:mese_crystal",""},
		{"default:mese_crystal", "default:mese_crystal", "default:mese_crystal"},
		{"", "default:mese_crystal",""},
	}
})

minetest.register_craft({
	output = "voxeldungeon:ball_diamond 5",
	recipe = 
	{
		{"", "default:diamond",""},
		{"default:diamond", "default:diamond", "default:diamond"},
		{"", "default:diamond",""},
	}
})



--Ankh Blessing

minetest.register_craft({
	type = "shapeless",
	output = "voxeldungeon:ankh_blessed",
	recipe = {"voxeldungeon:ankh", "voxeldungeon:dewvial"}
})

minetest.register_on_craft(function(itemstack, player, old_craft_grid, craft_inv)
	if itemstack:get_name() == "voxeldungeon:ankh_blessed" then
		local vial
		local ankh

		for i = 1, #old_craft_grid do
			local itemstack = old_craft_grid[i]

			if itemstack:get_name() == "voxeldungeon:dewvial" then
				vial = {i = i, item = itemstack}
			elseif itemstack:get_name() == "voxeldungeon:ankh" then
				ankh = {i = i, item = itemstack}
			end
		end

		if not vial or not ankh then return itemstack end

		if vial.item:get_meta():get_int("voxeldungeon:dew") == 20 then
			local newvial = ItemStack("voxeldungeon:dewvial")
			voxeldungeon.items.update_vial_description(newvial)
			craft_inv:set_stack("craft", vial.i, newvial)

			voxeldungeon.glog.h("You bless the ankh with clean water.")

			return itemstack
		else
			craft_inv:set_stack("craft", ankh.i, ankh.item)
			craft_inv:set_stack("craft", vial.i, vial.item)

			voxeldungeon.glog.w("You need a full dew vial to bless your ankh.", player)

			return ItemStack("")
		end
	end

	return itemstack
end)



--Misc

minetest.register_craft({
	type = "cooking",
	output = "voxeldungeon:cooked_meat",
	recipe = "voxeldungeon:mystery_meat"
})
