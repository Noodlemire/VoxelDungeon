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

local function register_food(name, desc, foodval, on_eat)
	minetest.register_craftitem("voxeldungeon:"..name, {
		description = voxeldungeon.utils.itemDescription(desc),
		inventory_image = "voxeldungeon_item_food_"..name..".png",

		on_use = function(itemstack, user, pointed_thing)
			minetest.do_item_eat(0, nil, itemstack, user, pointed_thing)

			if on_eat then
				on_eat(itemstack, user, pointed_thing)
			end
		end,
	})

	hbhunger.register_food("voxeldungeon:"..name, foodval)
end

register_food("ration", "Ration of Food\n \nNothing fancy here: dried meat, some biscuits - things like that.", 8)

register_food("pasty", "Pasty\n \nThis is an authentic Cornish pasty with a traditional filling of beef and potato.", 12)

register_food("mystery_meat", "Mystery Meat\n \nEat at your own risk!", 4, function(itemstack, user) 
	local effect = math.random(1, 2)

	if effect == 2 then
		voxeldungeon.glog.w("You are not feeling well.", user)
		voxeldungeon.buffs.attach_buff("voxeldungeon:poison", user, voxeldungeon.playerhandler.playerdata[user:get_player_name()].HT / 5)
	end
end)

register_food("chargrilled_meat", "Chargrilled Meat\n \nIt looks like a decent steak.", 4)

register_food("cooked_meat", "Cooked Meat\n \nThis meat has been cooked well in a furnace, and should be safe to eat.", 8)
