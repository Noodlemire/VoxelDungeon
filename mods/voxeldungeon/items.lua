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



local function get_pointed_pos(pointed_thing)
	if pointed_thing.type == "node" then
		return pointed_thing.above
	elseif pointed_thing.type == "object" then
		return pointed_thing.ref:get_pos()
	end
end

function voxeldungeon.register_throwingitem(name, desc, callback, itemdef, entdef)
	itemdef = itemdef or {}
	entdef = entdef or {}

	itemdef.description = voxeldungeon.utils.itemDescription(desc)
	itemdef.inventory_image = itemdef.inventory_image or "voxeldungeon_item_"..name..".png"

	itemdef.on_place = function(itemstack, placer, pointed_thing)
		callback(get_pointed_pos(pointed_thing))

		return voxeldungeon.utils.take_item(placer, itemstack)
	end

	itemdef.on_secondary_use = function(itemstack, user, pointed_thing)
		local pos = vector.add(user:get_pos(), {x=0, y=1, z=0})
		local offset = vector.multiply(user:get_look_dir(), 2)

		local projectile = minetest.add_entity(vector.add(pos, offset), "voxeldungeon:thrown_"..name)
		projectile:set_velocity(vector.multiply(offset, 8))
		projectile:set_acceleration({x = 0, y = -12, z = 0})

		return voxeldungeon.utils.take_item(user, itemstack)
	end

	entdef.initial_properties = {
		visual = "sprite",
		pointable = false,
		textures = {(itemdef.inventory_image or "voxeldungeon_item_"..name..".png")},
	}

	entdef.on_step = function(self, dtime)
		local pos = self.object:get_pos()

		if voxeldungeon.utils.solid(vector.add(pos, vector.normalize(self.object:get_velocity()))) then
			callback(pos)
			self.object:remove()
		end
	end

	minetest.register_craftitem("voxeldungeon:"..name, itemdef)
	minetest.register_entity("voxeldungeon:thrown_"..name, entdef)
end



voxeldungeon.register_throwingitem("bomb", "Bomb\n \nThis is a relatively small bomb, filled with black powder. Conveniently, its fuse is lit automatically when the bomb is thrown.\n \nRight-click while holding a bomb to throw it.", function(pos)
	tnt.boom(pos, {radius = 2, damage_radius = 2})
end)

minetest.register_craftitem("voxeldungeon:demonite_lump", {
	description = "Demonite Lump",
	inventory_image = "voxeldungeon_item_demonite_lump.png"
})

minetest.register_craftitem("voxeldungeon:demonite_ingot", {
	description = "Demonite Ingot",
	inventory_image = "voxeldungeon_item_demonite_ingot.png"
})

minetest.register_craftitem("voxeldungeon:dew", {
	description = voxeldungeon.utils.itemDescription("Dew Drop\n \nA crystal clear dewdrop; due to the magic of the underground, it has minor restorative properties."),
	inventory_image = "voxeldungeon_item_dew.png"
})
local super_on_punch = minetest.registered_entities["__builtin:item"].on_punch
entitycontrol.override_entity("__builtin:item", {
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local items = ItemStack(self.itemstring)
	
		if items:get_name() == "voxeldungeon:dew" then
			puncher:set_hp(puncher:get_hp() + items:get_count())
			self.itemstring = ""
			self.object:remove()
		else
			return super_on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)
		end
	end
})

minetest.register_craftitem("voxeldungeon:gold", {
	description = voxeldungeon.utils.itemDescription("Gold\n \nA pile of gold coins. Collect these to spend them later in a shop."),
	inventory_image = "voxeldungeon_item_gold.png",
	stack_max = 99999,
})

voxeldungeon.register_throwingitem("honeypot", "Honeypot\n \nThis large honeypot is only really lined with honey, instead it houses a giant bee! These sorts of massive bees usually stay in their hives, perhaps the pot is some sort of specialized trapper's cage? The bee seems pretty content inside the pot with its honey, and buzzes at you warily when you look at it.\n \nRight-click while holding a honeypot to throw it.", function(pos)
	minetest.add_entity(pos, "voxeldungeon:bee")
end)

minetest.override_item("default:torch", {
	description = voxeldungeon.utils.itemDescription("Torch\n \nIt's an indispensable item in the underground, which is notorious for its poor ambient lighting."),
	inventory_image = "voxeldungeon_item_torch.png",
	wield_image = "voxeldungeon_item_torch.png"
})



local super_book_on_use = minetest.registered_items["default:book"].on_use
minetest.override_item("default:book", {
	on_use = function(itemstack, user, pointed_thing)
		if voxeldungeon.buffs.get_buff("voxeldungeon:blind", user) then
			voxeldungeon.glog.w("You can't read a book while blinded.", user)
		else
			return super_book_on_use(itemstack, user, pointed_thing)
		end
	end
})

local super_booklocked_on_use = minetest.registered_items["books_plus:booklocked"].on_use
minetest.override_item("books_plus:booklocked", {
	on_use = function(itemstack, user, pointed_thing)
		if voxeldungeon.buffs.get_buff("voxeldungeon:blind", user) then
			voxeldungeon.glog.w("You can't read a book while blinded.", user)
		else
			return super_booklocked_on_use(itemstack, user, pointed_thing)
		end
	end
})

local super_bookwritten_on_use = minetest.registered_items["books_plus:written_book"].on_use
minetest.override_item("books_plus:written_book", {
	on_use = function(itemstack, user, pointed_thing)
		if voxeldungeon.buffs.get_buff("voxeldungeon:blind", user) then
			voxeldungeon.glog.w("You can't read a book while blinded.", user)
		else
			return super_bookwritten_on_use(itemstack, user, pointed_thing)
		end
	end
})
