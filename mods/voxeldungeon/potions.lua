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
			voxeldungeon.tools.updateStrdiffArmor(user)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "toxicgas",
		desc = "Toxic Gas\n \nUncorking or shattering this pressurized glass will cause its contents to explode into a deadly cloud of toxic green gas. You might choose to fling this potion at distant enemies instead of uncorking it by hand.",

		shatter = function(pos)
			voxeldungeon.blobs.seed("toxicgas", pos, 1000)
		end
	},
	{
		name = "liquidflame",
		desc = "Liquid Flame",
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
		desc = "Frost",
	},
	{
		name = "healing",
		desc = "Healing\n \nAn elixir that will instantly return you to full health and cure poison.",

		drink = function(itemstack, user, pointed_thing)
			user:set_hp(voxeldungeon.playerhandler.playerdata[user:get_player_name()].HT)
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
		desc = "Levitation",
	},
	{
		name = "mindvision",
		desc = "Mind Vision",
	},
	{
		name = "paralyticgas",
		desc = "Paralytic Gas",
	},
	{
		name = "purification",
		desc = "Purification",
	},
	{
		name = "haste",
		desc = "Haste",
	}
}

local colors =
{
	{
		name = "turquoise", 
		desc = "Turquoise"
	},
	{
		name = "crimson", 
		desc = "Crimson"
	},
	{
		name = "azure", 
		desc = "Azure"
	},
	{
		name = "jade", 
		desc = "Jade"
	},
	{
		name = "golden", 
		desc = "Golden"
	},
	{
		name = "magenta", 
		desc = "Magenta"
	},
	{
		name = "charcoal", 
		desc = "Charcoal"
	},
	{
		name = "bistre", 
		desc = "Bistre"
	},
	{
		name = "amber", 
		desc = "Amber"
	},
	{
		name = "ivory", 
		desc = "Ivory"
	},
	{
		name = "silver", 
		desc = "Silver"
	},
	{
		name = "indigo", 
		desc = "Indigo"
	},
}

local function default_shatter(pos, color)
	voxeldungeon.glog.i("The flask shatters and "..color.." liquid splashes harmlessly.")
end

local function register_potion(name, desc, color, drink, shatter)
	minetest.register_entity("voxeldungeon:thrownpotion_"..color, {
		initial_properties = {
			visual = "sprite",
			pointable = false,
			textures = {"voxeldungeon_item_potion_"..color..".png"},
		},

		on_step = function(self, dtime)
			if voxeldungeon.utils.solid(vector.add(self.object:get_pos(), vector.normalize(self.object:get_velocity()))) then
				if shatter then
					shatter(self.object:get_pos())
				else
					default_shatter(self.object:get_pos(), color)
				end

				self.object:remove()
			end
		end
	})

	minetest.register_craftitem("voxeldungeon:potion_"..name,
	{
		description = voxeldungeon.utils.itemDescription("Potion of "..desc..
								"\n \nLeft click while holding a potion to drink it."..
								"\nRight click while holding a potion to throw it."),
		inventory_image = "voxeldungeon_item_potion_"..color..".png",
		_cornerLR = "voxeldungeon_icon_potion_"..name..".png",

		on_use = drink or function(itemstack, user) 
			if shatter then
				shatter(user:get_pos())
			else
				default_shatter(user:get_pos(), color) 
			end

			return voxeldungeon.utils.take_item(user, itemstack)
		end,

		on_place = function(itemstack, placer, pointed_thing)
			if shatter then
				shatter(pointed_thing.above)
			else
				default_shatter(pointed_thing.above, color)
			end

			return voxeldungeon.utils.take_item(placer, itemstack)
		end,

		on_secondary_use = function(itemstack, user, pointed_thing)
			local pos = vector.add(user:get_pos(), {x=0, y=1, z=0})
			local offset = vector.multiply(user:get_look_dir(), 2)

			local projectile = minetest.add_entity(vector.add(pos, offset), "voxeldungeon:thrownpotion_"..color)
			projectile:set_velocity(vector.multiply(offset, 8))
			projectile:set_acceleration({x = 0, y = -12, z = 0})
		end,
	})
end

local filePath = voxeldungeon.wp.."potiondata.txt"
local file = io.open(filePath, "r")
if file then
	--read all contents of file into a table of strings
	local contents = {}
	for line in file:lines() do
		table.insert(contents, line)
	end
	
	for i = 1, #contents do
		register_potion(potion_defs[i].name, potion_defs[i].desc, contents[i], potion_defs[i].drink, potion_defs[i].shatter)
	end

	io.close(file)
else
	--create file because it doesn't exist yet
	file = io.open(filePath, "w")

	for k, v in ipairs(potion_defs) do
		local color = table.remove(colors, math.ceil(math.random() * #colors))
		file:write(color.name..'\n')

		register_potion(v.name, v.desc, color.name, v.drink)
	end

	io.close(file)
end
