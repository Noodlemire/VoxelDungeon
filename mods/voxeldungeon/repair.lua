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

local function register_repair(name, desc)
	local def = {}

	def.description = voxeldungeon.utils.itemDescription(desc.."\n \nRight click while holding a repair tool to use it.")
	def.inventory_image = "voxeldungeon_tool_repair_"..name..".png"

	def.tool_capabilities = {
		full_punch_interval = 1,
		damage_groups = {fleshy = 0},
		max_drop_level = 0,
		groupcaps = {},
	}

	def.groups = {repair = 1}

	local do_repair = function(itemstack, user, pointed_thing)
		voxeldungeon.itemselector.showSelector(user, "Choose which "..name.." to repair.", 
			function(item)
				return item:get_wear() > 0 and minetest.get_item_group(item:get_name(), name) > 0
			end, 
			function(player, choice)
				if choice then
					if choice:get_wear() == 0 then
						voxeldungeon.glog.i("That "..name.." is already fully repaired.")
					else
						local amount = math.ceil(65536 / 3)
						itemstack:add_wear(amount)
						user:get_inventory():set_stack("main", user:get_wield_index(), itemstack)

						choice:add_wear(-amount)
					end

					return choice
				end
			end
		)
	end

	def.on_place = do_repair
	def.on_secondary_use = do_repair

	minetest.register_tool("voxeldungeon:repair_"..name, def)
end

register_repair("armor", "Armorer's Kit\n \nUsing this kit of small tools and materials, anybody can repair any armor in quite a short amount of time. No skills in tailoring, leatherworking or blacksmithing are required, but it only has enough materials to be used 3 times at most.")

register_repair("weapon", "Whetstone\n \nUsing a whetstone, you can repair your melee weapons, bringing them back to their former glory. This whetstone can only be used 3 times in total.")

register_repair("wand", "Arcane Battery\n \nThis is a narrow piece of some dark, very hard stone. Using it, you can partially recharge the core of any magic wand, restoring it to a better condition. It can only be used 3 times at most.")
