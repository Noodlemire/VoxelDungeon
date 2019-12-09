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

local scroll_defs = 
{
	{
		name = "upgrade",
		desc = "Upgrade\n \nThis scroll will upgrade a single item, improving its quality. A wand will increase in power and in number of charges; a weapon will inflict more damage or find its mark more frequently; a suit of armor will deflect additional blows; the effect of a ring on its wearer will intensify. Weapons and armor will also require less strength to use, and any curses on the item will be lifted.",

		read = function(itemstack, user, pointed_thing)
			local itemname = itemstack:get_name()
			voxeldungeon.utils.take_item(user, itemstack)

			voxeldungeon.itemselector.showSelector(user, "Select an item to upgrade.", function(player, item)
				if item then
					voxeldungeon.tools.upgrade(item)
					voxeldungeon.glog.p("Your "..voxeldungeon.tools.getShortDescriptionOf(item).." looks much better now.", player)
					return item
				else
					voxeldungeon.utils.return_item(user, itemname)
				end
			end)

			return itemstack
		end
	},
	{
		name = "identify",
		desc = "Identify",

		read = function(itemstack, user, pointed_thing)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "removecurse",
		desc = "Remove Curse",

		read = function(itemstack, user, pointed_thing)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "enchantment",
		desc = "Enchantment",

		read = function(itemstack, user, pointed_thing)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "terror",
		desc = "Terror",

		read = function(itemstack, user, pointed_thing)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "rage",
		desc = "Rage",

		read = function(itemstack, user, pointed_thing)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "magicmapping",
		desc = "Magic Mapping",

		read = function(itemstack, user, pointed_thing)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "lullaby",
		desc = "Lullaby",

		read = function(itemstack, user, pointed_thing)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "psionicblast",
		desc = "Psionic Blast",

		read = function(itemstack, user, pointed_thing)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "teleportation",
		desc = "Teleportation\n \nThe spell on this parchment instantly transports the reader to a random location up to 100 blocks away. It can be used to escape a dangerous situation, but an unlucky reader might find himself in an even more dangerous place.",

		read = function(itemstack, user, pointed_thing)
			voxeldungeon.utils.randomteleport(user)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "mirrorimage",
		desc = "Mirror Image",

		read = function(itemstack, user, pointed_thing)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "recharging",
		desc = "Recharging",

		read = function(itemstack, user, pointed_thing)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	}
}

local runes =
{
	{
		name = "sowilo", 
		desc = "SOWILO"
	},
	{
		name = "odal", 
		desc = "ODAL"
	},
	{
		name = "tiwaz", 
		desc = "TIWAZ"
	},
	{
		name = "naudiz", 
		desc = "NAUDIZ"
	},
	{
		name = "gyfu", 
		desc = "GYFU"
	},
	{
		name = "yngvi", 
		desc = "YNGVI"
	},
	{
		name = "berkanan", 
		desc = "BERKANAN"
	},
	{
		name = "raido", 
		desc = "RAIDO"
	},
	{
		name = "isaz", 
		desc = "ISAZ"
	},
	{
		name = "mannaz", 
		desc = "MANNAZ"
	},
	{
		name = "laguz", 
		desc = "LAGUZ"
	},
	{
		name = "kaunan", 
		desc = "KAUNAN"
	},
}

local function register_scroll(name, desc, rune, use)
	minetest.register_craftitem("voxeldungeon:scroll_"..name,
	{
		description = voxeldungeon.utils.itemDescription("Scroll of "..desc.."\n \nLeft click while holding a scroll to read it."),
		inventory_image = "voxeldungeon_item_scroll_"..rune..".png",
		_cornerLR = "voxeldungeon_icon_scroll_"..name..".png",
		on_use = use
	})
end

local filePath = voxeldungeon.wp.."scrolldata.txt"
local file = io.open(filePath, "r")
if file then
	--read all contents of file into a table of strings
	local contents = {}
	for line in file:lines() do
		table.insert(contents, line)
	end
	
	for i = 1, #contents do
		register_scroll(scroll_defs[i].name, scroll_defs[i].desc, contents[i], scroll_defs[i].read)
	end

	io.close(file)
else
	--create file because it doesn't exist yet
	file = io.open(filePath, "w")

	for k, v in ipairs(scroll_defs) do
		local rune = table.remove(runes, math.ceil(math.random() * #runes))
		file:write(rune.name..'\n')

		register_scroll(v.name, v.desc, rune.name, v.read)
	end

	io.close(file)
end
