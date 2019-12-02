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

local function check_foilage(pos)
	for _, offset in ipairs(voxeldungeon.utils.NEIGHBORS26) do
		minetest.punch_node(vector.add(pos, offset))
	end
end

function voxeldungeon.register_plant(name, desc, activate)
	local do_activate = function(pos, objs)
		minetest.set_node(pos, {name = "voxeldungeon:sewergrass"})
		activate(pos, objs)
		check_foilage(pos)
		voxeldungeon.particles.burst("grass", pos, 6)
	end
	
	minetest.register_node("voxeldungeon:plant_"..name,
	{
		description = voxeldungeon.utils.itemDescription("Seed of "..desc.."\n \nPlacing a seed on the ground will plant and grow it instantly."),
		drawtype = "plantlike",
		tiles = {"voxeldungeon_plant_"..name..".png"},
		inventory_image = "voxeldungeon_item_seed_"..name..".png",
		wield_image = "voxeldungeon_item_seed_"..name..".png",
		paramtype = "light",
		sunlight_propogates = true,
		walkable = false,
		buildable_to = true,
		groups = {flammable = 1, attached_node = 1, dig_immediate = 3},
		drop = {},
		
		after_dig_node = do_activate,
		on_blast = do_activate,
		on_step = do_activate
	})
end

function voxeldungeon.register_foilage(name, desc, trampled)
	local do_activate = function(pos, objs)
		minetest.set_node(pos, {name = "voxeldungeon:"..trampled})
		check_foilage(pos)
		
		if math.floor(math.random(18)) == 1 then
			local seedname = voxeldungeon.generator.randomSeed()
			minetest.add_item(pos, {name = seedname})
		end
		
		if math.floor(math.random(6)) == 1 then
			minetest.add_item(pos, {name = "voxeldungeon:dew"})
		end
		
		voxeldungeon.particles.burst("grass", pos, 4)
	end
	
	local place_top = function(pos)
		local above = 
		{
			x = pos.x,
			y = pos.y + 1,
			z = pos.z
		}

		if not voxeldungeon.utils.solid(above) then
			minetest.set_node(above, {name = "voxeldungeon:foilage_"..name.."_top"})
		else
			do_activate(pos)
		end
	end
	
	local check_for_top = function(pos)
		local above = 
		{
			x = pos.x,
			y = pos.y + 1,
			z = pos.z
		}

		local nodename = minetest.get_node(above).name
		local nodedef = minetest.registered_nodes[nodename]
			
		if not nodedef or nodename ~= "voxeldungeon:foilage_"..name.."_top" then
			do_activate(pos)
		end
	end
	
	local check_for_bottom = function(pos)
		local below = 
		{
			x = pos.x,
			y = pos.y - 1,
			z = pos.z
		}

		local nodename = minetest.get_node(below).name
		local nodedef = minetest.registered_nodes[nodename]
			
		if not nodedef or nodename ~= "voxeldungeon:foilage_"..name then
			minetest.set_node(pos, {name = "air"})
		end
	end
	
	minetest.register_node("voxeldungeon:foilage_"..name,
	{
		description = desc,
		drawtype = "plantlike",
		tiles = {"voxeldungeon_foilage_"..name..".png"},
		inventory_image = "voxeldungeon_icon_"..name..".png",
		wield_image = "voxeldungeon_icon_"..name..".png",
		paramtype = "light",
		walkable = false,
		buildable_to = true,
		groups = {flammable = 1, attached_node = 1, dig_immediate = 3},
		drop = {},
		
		on_construct = place_top,

		on_punch = check_for_top,
		
		after_dig_node = do_activate,
		on_blast = do_activate,
		on_step = do_activate
	})
	
	minetest.register_node("voxeldungeon:foilage_"..name.."_top",
	{
		drawtype = "plantlike",
		tiles = {"voxeldungeon_foilage_"..name.."_top.png"},
		paramtype = "light",
		walkable = false,
		buildable_to = true,
		groups = {flammable = 1, dig_immediate = 3},
		drop = {},
		
		on_punch = check_for_bottom,
		
		after_dig_node = check_foilage,
		on_blast = check_foilage,
		on_step = check_foilage
	})
end



voxeldungeon.register_plant("fadeleaf", "Fadeleaf\n \nTouching a Fadeleaf will teleport any creature to a random place within 100 blocks.", function(pos, objs)
	for i = 1, #objs do
		voxeldungeon.randomteleport(objs[i])
	end
end)

voxeldungeon.register_plant("firebloom", "Firebloom\n \nWhen something touches a Firebloom, it bursts into flames.", function(pos)
	minetest.set_node(pos, {name = "fire:basic_flame"})
end)

voxeldungeon.register_plant("rotberry", "Rotberry", function(pos)
	voxeldungeon.blobs.seed("toxicgas", pos, 100)
end)

voxeldungeon.register_plant("sorrowmoss", "Sorrowmoss\n \nA Sorrowmoss is a flower (not a moss) with razor-sharp petals, coated with a deadly venom.", function(pos, objs)
	for i = 1, #objs do
		voxeldungeon.buffs.attach_buff("voxeldungeon:poison", objs[i], 5 + math.floor(voxeldungeon.utils.getDepth(pos) * 2 / 3))
	end
	
	voxeldungeon.particles.burst("poison", pos, 3)
end)

voxeldungeon.register_plant("sungrass", "Sungrass\n \n	Sungrass is renowned for its sap's healing properties, though the user must stand still for it to work.", function(pos, objs)
	for i = 1, #objs do
		if objs[i]:is_player() then
			voxeldungeon.buffs.attach_buff("voxeldungeon:herbal_healing", objs[i],
				voxeldungeon.playerhandler.playerdata[objs[i]:get_player_name()].HT)
		end 
	end
	
	voxeldungeon.particles.factory("shaft", vector.add(pos, {x=0,y=1,z=0}), 3, 1.2)
end)

voxeldungeon.register_foilage("sewers_tallgrass", "Sewer Tall Grass", "sewergrass")
voxeldungeon.register_foilage("prisons_tallgrass", "Prison Tall Grass", "prisongrass")
voxeldungeon.register_foilage("caves_tallgrass", "Cave Tall Grass", "cavegrass")
voxeldungeon.register_foilage("cities_tallgrass", "City Tall Grass", "citygrass")
voxeldungeon.register_foilage("halls_tallgrass", "Hall Tall Grass", "hallgrass")



local function set_foilage_checks()
	for nodename, _ in pairs(minetest.registered_nodes) do
		voxeldungeon.override.add_dig_event(nodename, check_foilage)
		voxeldungeon.override.add_after_place_event(nodename, check_foilage)
	end
end
minetest.after(0, set_foilage_checks)
