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

local function register_food(name, def)
	def.description = voxeldungeon.utils.itemDescription(def.description or "!!!NO TEXT FOUND!!!")
	def.inventory_image = "voxeldungeon_item_food_"..name..".png"

	def.on_use = function(itemstack, user, pointed_thing)
		minetest.do_item_eat(0, nil, itemstack, user, pointed_thing)

		if def.on_eat then
			def.on_eat(itemstack, user, pointed_thing)
		end

		return voxeldungeon.utils.take_item(user, itemstack)
	end

	minetest.register_craftitem("voxeldungeon:"..name, def)

	if minetest.settings:get_bool("enable_damage") then
		hbhunger.register_food("voxeldungeon:"..name, def.foodval)
	end
end

register_food("ration", {description = "Ration of Food\n \nNothing fancy here: dried meat, some biscuits - things like that.", foodval = 8})

register_food("pasty", {description = "Pasty\n \nThis is an authentic Cornish pasty with a traditional filling of beef and potato.", foodval = 12})

register_food("mystery_meat", {
	description = "Mystery Meat\n \nEat at your own risk!", 
	foodval = 4, 
	groups = {freezable = 1, flammable = 1},

	on_eat = function(itemstack, user) 
		local effect = math.random(4)

		if effect == 2 then
			voxeldungeon.glog.w("You are not feeling well.", user)
			voxeldungeon.buffs.attach_buff("voxeldungeon:poison", user, voxeldungeon.playerhandler.playerdata[user:get_player_name()].HT / 5)
		elseif effect == 3 then
			voxeldungeon.glog.w("You can't feel your legs!", user)
			voxeldungeon.buffs.attach_buff("voxeldungeon:rooted", user, 10)
		elseif effect == 4 then
			voxeldungeon.glog.w("Oh, it's hot!", user)
			voxeldungeon.buffs.attach_buff("voxeldungeon:burning", user, 8)
		end
	end,

	on_burn = function(pos, user)
		if not user then
			minetest.add_item(pos, ItemStack("voxeldungeon:chargrilled_meat"))
		elseif user:is_player() then
			local chargrilled = user:get_inventory():add_item("main", ItemStack("voxeldungeon:chargrilled_meat"))

			if chargrilled and not chargrilled:is_empty() then
				minetest.add_item(user:get_pos(), chargrilled)
			end
		else
			mobkit.remember(user:get_luaentity(), "stolen", "voxeldungeon:chargrilled_meat")
		end
	end,

	on_freeze = function(pos, user)
		if not user then
			minetest.add_item(pos, ItemStack("voxeldungeon:frozen_carpaccio"))
		elseif user:is_player() then
			local carpaccio = user:get_inventory():add_item("main", ItemStack("voxeldungeon:frozen_carpaccio"))

			if carpaccio and not carpaccio:is_empty() then
				minetest.add_item(user:get_pos(), carpaccio)
			end
		else
			mobkit.remember(user:get_luaentity(), "stolen", "voxeldungeon:frozen_carpaccio")
		end
	end,
})

register_food("chargrilled_meat", {description = "Chargrilled Meat\n \nIt looks like a decent steak.", foodval = 4})

register_food("cooked_meat", {description = "Cooked Meat\n \nThis meat has been cooked well in a furnace, and should be safe to eat.", foodval = 8})

register_food("frozen_carpaccio", {
	description = "Frozen Carpaccio\n \nIt's a piece of frozen raw meat. The only way to eat it is by cutting thin slices of it. Surprisingly, it is very good!", 
	foodval = 4, 

	on_eat = function(itemstack, user) 
		local effect = math.random(3)

		if effect == 2 then
			voxeldungeon.glog.i("You feel better!", user)
			user:set_hp(user:get_hp() + voxeldungeon.playerhandler.playerdata[user:get_player_name()].HT / 4)
		elseif effect == 3 then
			voxeldungeon.glog.i("Refreshing!", user)
			voxeldungeon.buffs.detach_buff("voxeldungeon:bleeding", user)
			voxeldungeon.buffs.detach_buff("voxeldungeon:crippled", user)
			voxeldungeon.buffs.detach_buff("voxeldungeon:poison", user)
		end
	end
})
