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
	local do_activate = function(pos, obj)
		minetest.set_node(pos, {name = "voxeldungeon:sewers_shortgrass"})
		activate(pos, obj)
		check_foilage(pos)
		voxeldungeon.particles.burst(voxeldungeon.particles.grass, pos, 6)
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
		floodable = true,
		
		after_dig_node = function(pos) do_activate(pos) end,
		on_blast = function(pos) do_activate(pos) end,
		_on_move_in = do_activate
	})
end

function voxeldungeon.register_foilage(name, desc, trampled, ch)
	local do_activate = function(pos, obj)
		minetest.set_node(pos, {name = "voxeldungeon:"..trampled})
		check_foilage(pos)
		
		if math.random(18) == 1 then
			local seedname = voxeldungeon.generator.randomSeed()
			minetest.add_item(pos, {name = seedname})
		end
		
		if math.random(6) == 1 then
			minetest.add_item(pos, {name = "voxeldungeon:dew"})
		end

		voxeldungeon.particles.burst(voxeldungeon.particles.grass, pos, 4, {chapter = ch})
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
		floodable = true,
		
		on_construct = place_top,

		on_punch = check_for_top,
		
		after_dig_node = do_activate,
		on_blast = do_activate,
		on_flood = do_activate,
		_on_move_in = do_activate
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
		floodable = true,
		
		on_punch = check_for_bottom,
		
		after_dig_node = check_foilage,
		on_blast = check_foilage,
		on_flood = minetest.dig_node,
		_on_move_in = check_foilage,
	})
end



voxeldungeon.register_plant("earthroot", "Earthroot\n \nWhen a creature touches an Earthroot, its roots create a kind of natural armor around it, which absorb all damage until they break.", function(pos, obj)
	if obj and obj:is_player() then
		voxeldungeon.buffs.attach_buff("voxeldungeon:herbal_armor", obj,
			voxeldungeon.playerhandler.playerdata[obj:get_player_name()].HT)
	end
end)

voxeldungeon.register_plant("fadeleaf", "Fadeleaf\n \nTouching a Fadeleaf will teleport any creature to a random place within 100 blocks.", function(pos, obj)
	for i = 1, entitycontrol.count_entities() do
		local e = entitycontrol.get_entity(i)

		if entitycontrol.isAlive(i) and vector.equals(vector.round(e:get_pos()), pos) then
			voxeldungeon.utils.randomTeleport(e)
		end
	end

	for _, p in ipairs(minetest.get_connected_players()) do
		if p:get_pos() and vector.equals(vector.round(p:get_pos()), pos) then
			voxeldungeon.utils.randomTeleport(p)
		end
	end
end)

voxeldungeon.register_plant("firebloom", "Firebloom\n \nWhen something touches a Firebloom, it bursts into flames.", function(pos)
	minetest.set_node(pos, {name = "fire:basic_flame"})
end)

voxeldungeon.register_plant("icecap", "Icecap\n \nUpon being touched, an Icecap excretes a pollen that freezes everything in its vicinity.", function(p)
	for _, n in ipairs(voxeldungeon.utils.NEIGHBORS27) do
		local pos = vector.add(vector.round(p), n)

		for _, p in pairs(minetest.get_connected_players()) do
			if vector.equals(vector.round(p:get_pos()), pos) then
				voxeldungeon.buffs.attach_buff("voxeldungeon:frozen", p, math.random(10, 15))
			end
		end

		for i = 1, entitycontrol.count_entities() do
			local e = entitycontrol.get_entity(i)

			if entitycontrol.isAlive(e) and vector.equals(vector.round(e:get_pos()), pos) then
				if e:get_luaentity().name == "__builtin:item" then
					local item = ItemStack(e:get_luaentity().itemstring)

					if minetest.get_item_group(item:get_name(), "freezable") > 0 then
						local on_freeze = minetest.registered_items[item:get_name()].on_freeze

						if on_freeze then
							on_freeze(nil, pos)
						end

						e:remove()
					end
				else
					voxeldungeon.buffs.attach_buff("voxeldungeon:frozen", e, math.random(10, 15))
				end
			end
		end

		local node = minetest.get_node_or_nil(pos)
		if minetest.get_item_group(node.name, "water") > 0 then
			minetest.place_node(pos, {name="default:ice"})
		elseif node.name == "default:lava_source" then
			minetest.place_node(pos, {name="default:obsidian"})
		elseif node.name == "default:lava_flowing" then
			minetest.place_node(pos, {name="default:stone"})
		end
	end
end)

voxeldungeon.register_plant("rotberry", "Rotberry", function(pos)
	voxeldungeon.blobs.seed("toxicgas", pos, 300)
end)

voxeldungeon.register_plant("sorrowmoss", "Sorrowmoss\n \nA Sorrowmoss is a flower (not a moss) with razor-sharp petals, coated with a deadly venom.", function(pos, obj)
	for i = 1, entitycontrol.count_entities("mobs") do
		local e = entitycontrol.get_entity("mobs", i)

		if entitycontrol.isAlive("mobs", i) and vector.equals(vector.round(e:get_pos()), pos) then
			voxeldungeon.buffs.attach_buff("voxeldungeon:poison", e, 5 + math.floor(voxeldungeon.utils.getDepth(pos) * 2 / 3))
		end
	end

	for _, p in ipairs(minetest.get_connected_players()) do
		if p:get_pos() and vector.equals(vector.round(p:get_pos()), pos) then
			voxeldungeon.buffs.attach_buff("voxeldungeon:poison", p, 5 + math.floor(voxeldungeon.utils.getDepth(pos) * 2 / 3))
		end
	end

	voxeldungeon.particles.burst(voxeldungeon.particles.poison, pos, 3)
end)

voxeldungeon.register_plant("sungrass", "Sungrass\n \nSungrass is renowned for its sap's healing properties, though the user must stand still for it to work.", function(pos, obj)
	if obj and obj:is_player() then
		voxeldungeon.buffs.attach_buff("voxeldungeon:herbal_healing", obj, voxeldungeon.playerhandler.playerdata[obj:get_player_name()].HT)
	end
	
	voxeldungeon.particles.factory(voxeldungeon.particles.light, vector.add(pos, {x=0,y=1,z=0}), 3, 1.2)
end)

voxeldungeon.register_foilage("sewers_tallgrass", "Sewer Tall Grass", "sewers_shortgrass", "sewers")
voxeldungeon.register_foilage("prisons_tallgrass", "Prison Tall Grass", "prisons_shortgrass", "prisons")
voxeldungeon.register_foilage("caves_tallgrass", "Cave Tall Grass", "caves_shortgrass", "caves")
voxeldungeon.register_foilage("cities_tallgrass", "City Tall Grass", "cities_shortgrass", "cities")
voxeldungeon.register_foilage("halls_tallgrass", "Hall Tall Grass", "halls_shortgrass", "halls")



local function set_foilage_checks()
	for nodename, _ in pairs(minetest.registered_nodes) do
		voxeldungeon.override.add_dig_event(nodename, check_foilage)
		voxeldungeon.override.add_after_place_event(nodename, check_foilage)
	end
end
minetest.after(0, set_foilage_checks)
