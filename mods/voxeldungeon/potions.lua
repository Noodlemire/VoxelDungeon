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

local potion_defs = 
{
	{
		name = "strength",
		desc = "Strength\n \nThis powerful liquid will course through your muscles, permanently increasing your strength by one point.",

		drink = function(itemstack, user, pointed_thing)
			voxeldungeon.playerhandler.changeSTR(user, 1)
			voxeldungeon.glog.p("Newfound strength surges through your body.", user) 
			voxeldungeon.armor.updateStrdiffArmor(user)
		end
	},
	{
		name = "toxicgas",
		desc = "Toxic Gas\n \nUncorking or shattering this pressurized glass will cause its contents to explode into a deadly cloud of toxic green gas. You might choose to fling this potion at distant enemies instead of uncorking it by hand.",

		shatter = function(pos)
			voxeldungeon.blobs.seed("toxicgas", pos, 3000)
		end
	},
	{
		name = "liquidflame",
		desc = "Liquid Flame",

		shatter = function(pos)
			--[[for _, n in ipairs(voxeldungeon.utils.NEIGHBORS27) do
				local f = vector.add(pos, n)

				voxeldungeon.blobs.seed("fire", f, 200)
			end--]]
		end
	},
	{
		name = "might",
		desc = "Might\n \nThis smooth liquid is able to strengthen your heart and other vital organs, permanently allowing you to survive damage that would otherwise kill you. There is enough contents to increase your maximum health by 5.",

		drink = function(itemstack, user, pointed_thing)
			voxeldungeon.playerhandler.changeHT(user, 5, true)
			voxeldungeon.glog.p("Newfound will surges through your heart.", user) 
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "frost",
		desc = "Frost\n \nUpon exposure to open air, this chemical will evaporate into a freezing cloud, causing any creature that contacts it to be frozen in place, unable to act and move.",

		shatter = function(p)
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
		end
	},
	{
		name = "healing",
		desc = "Healing\n \nAn elixir that will instantly return you to full health and cure poison.",

		drink = function(itemstack, user, pointed_thing)
			user:set_hp(voxeldungeon.playerhandler.playerdata[user:get_player_name()].HT)

			voxeldungeon.buffs.detach_buff("voxeldungeon:bleeding", user)
			voxeldungeon.buffs.detach_buff("voxeldungeon:crippled", user)
			voxeldungeon.buffs.detach_buff("voxeldungeon:poison", user)

			voxeldungeon.glog.p("Your wounds heal completely", user)

			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "invisibility",
		desc = "Invisibility",
	},
	{
		name = "levitation",
		desc = "Levitation\n \nDrinking this curious liquid will cause you to hover in the air, able to drift effortlessly over traps and pits. However, try not to jump into open air, as levitation offers little to no control over your vertical position.",

		drink = function(itemstack, user, pointed_thing)
			voxeldungeon.buffs.attach_buff("voxeldungeon:levitating", user, 20)

			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "mindvision",
		desc = "Mind Vision\n \nAfter drinking this, your mind will become attuned to the psychic signature of distant creatures, enabling you to sense biological presences through walls.",

		drink = function(itemstack, user, pointed_thing)
			voxeldungeon.buffs.attach_buff("voxeldungeon:mindvision", user, 20)

			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "paralyticgas",
		desc = "Paralytic Gas\n \nUpon exposure to open air, the liquid in this flask will vaporize into a numbing yellow haze. Anyone who inhales the cloud will be paralyzed instantly, unable to move or act for some time after the cloud dissipates. This item can be thrown at distant enemies to catch them within the effect of the gas.",

		shatter = function(pos)
			voxeldungeon.blobs.seed("paralyticgas", pos, 3000)
		end
	},
	{
		name = "purification",
		desc = "Purification\n \nThis reagent will quickly neutralize all harmful gases in the area of effect. Drinking it will give you a temporary immunity to such gases.",

		drink = function(itemstack, user, pointed_thing)
			voxeldungeon.buffs.attach_buff("voxeldungeon:gasimmunity", user, 20)

			return voxeldungeon.utils.take_item(user, itemstack)
		end,

		shatter = function(pos)
			local r = 10

			for a = -r, r do
				for b = -r, r do
					for c = -r, r do
						local clearPos = vector.add(pos, {x = a, y = b, z = c})

						if voxeldungeon.utils.directLineOfSight(pos, clearPos) then
							voxeldungeon.blobs.clear({"voxeldungeon:blob_toxicgas", "voxeldungeon:blob_paralyticgas", "voxeldungeon:blob_corrosivegas"}, clearPos)
						end
					end
				end
			end

			for _, player in ipairs(voxeldungeon.utils.getPlayersInArea(pos, r)) do
				voxeldungeon.glog.i("The flask shatters and you feel an unnatural freshness in the air.", player)
			end
		end,
	},
	{
		name = "haste",
		desc = "Haste\n \nDrinking this oddly sweet liquid will imbue you with tremendous energy for a short time, allowing you to run at high speeds.",

		drink = function(itemstack, user, pointed_thing)
			voxeldungeon.buffs.attach_buff("voxeldungeon:haste", user, 20)

			return voxeldungeon.utils.take_item(user, itemstack)
		end,
	}
}

local colors = {"turquoise", "crimson", "azure", "jade", "golden", "magenta", "charcoal", "bistre", "amber", "ivory", "silver", "indigo"}



local function register_potion(name, desc, color, drink, shatter)
	local do_shatter = function(pos)
		if shatter then
			shatter(pos)
		else
			for _, player in ipairs(voxeldungeon.utils.getPlayersInArea(pos, 20)) do
				voxeldungeon.glog.i("The flask shatters and "..color.." liquid splashes harmlessly.", player)
			end
		end

		voxeldungeon.particles.burst(voxeldungeon.particles.splash, pos, 5, {color = color})
	end

	voxeldungeon.register_throwingitem("potion_"..name, "Potion of "..desc..
								"\n \nLeft click while holding a potion to drink it."..
								"\nRight click while holding a potion to throw it.", 

	do_shatter,

	{
		inventory_image = "voxeldungeon_item_potion_"..color..".png",
		_cornerLR = "voxeldungeon_icon_potion_"..name..".png",
		groups = {freezable = 1, vessel = 1},

		on_use = function(itemstack, user)
			if drink then
				drink(itemstack, user)
			else
				do_shatter(user:get_pos())
			end

			return voxeldungeon.utils.take_item(user, itemstack)
		end,

		on_freeze = function(user, pos)
			do_shatter(pos)
		end
	})
end

local loadColors = voxeldungeon.storage.getBool("loadedPotions")
for k, v in ipairs(potion_defs) do
	local color
	local colorKey = v.name.."_color"

	if loadColors then
		color = voxeldungeon.storage.getStr(colorKey)
	else
		color = table.remove(colors, math.random(#colors))
		voxeldungeon.storage.put(colorKey, color)
	end

	register_potion(v.name, v.desc, color, v.drink, v.shatter)
end
voxeldungeon.storage.put("loadedPotions", true)
