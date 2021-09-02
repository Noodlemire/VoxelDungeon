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

voxeldungeon.items = {}



function voxeldungeon.items.identify(item)
	if minetest.get_item_group(item:get_name(), "armor") > 0 then
		voxeldungeon.armor.identify(item)
	elseif minetest.get_item_group(item:get_name(), "wand") > 0 then
		voxeldungeon.wands.identify(item)
	elseif minetest.get_item_group(item:get_name(), "weapon") > 0 then
		voxeldungeon.weapons.identify(item)
	end
end



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
		if pointed_thing.type == "object" then
			callback(get_pointed_pos(pointed_thing))
		else
			local pos = vector.add(user:get_pos(), {x=0, y=1.5, z=0})
			local offset = vector.multiply(user:get_look_dir(), 2)

			local projectile = minetest.add_entity(vector.add(pos, offset), "voxeldungeon:thrown_"..name)
			projectile:set_velocity(vector.multiply(offset, 8))
			projectile:set_acceleration({x = 0, y = -12, z = 0})
		end

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



minetest.register_craftitem("voxeldungeon:ankh", {
	description = voxeldungeon.utils.itemDescription("Ankh\n \nThis ancient symbol of immortality grants the ability to return to life after death. Upon resurrection, most items that aren't equipped or wielded are lost. By crafting it with a full dew vial, the ankh can be blessed with extra strength."),
	inventory_image = "voxeldungeon_item_ankh.png",
	stack_max = 1
})

minetest.register_craftitem("voxeldungeon:ankh_blessed", {
	description = voxeldungeon.utils.itemDescription("Blessed Ankh\n \nThis ancient symbol of immortality grants the ability to return to life after death. The ankh has been blessed and is now much stronger. The Ankh will sacrifice itself to save you and your entire inventory in a moment of deadly peril."),
	inventory_image = "voxeldungeon_item_ankh_blessed.png",
	stack_max = 1
})

minetest.override_item("fire:basic_flame", {
	on_construct = function(pos)
		minetest.remove_node(pos)
		voxeldungeon.blobs.seed("fire", pos, 2)
	end
})

voxeldungeon.register_throwingitem("bomb", "Bomb\n \nThis is a relatively small bomb, filled with black powder. Conveniently, its fuse is lit automatically when the bomb is thrown.\n \nRight-click while holding a bomb to throw it.", function(pos)
	tnt.boom(pos, {radius = 2, damage_radius = 2})
end, {
	groups = {flammable = 1},
	on_burn = function(pos)
		tnt.boom(pos, {radius = 2, damage_radius = 2})
	end
})

minetest.register_craftitem("voxeldungeon:demonite_lump", {
	description = "Demonite Lump",
	inventory_image = "voxeldungeon_item_demonite_lump.png"
})

minetest.register_craftitem("voxeldungeon:demonite_ingot", {
	description = "Demonite Ingot",
	inventory_image = "voxeldungeon_item_demonite_ingot.png"
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



local DEW_VIAL_MAX = 20

function voxeldungeon.items.update_vial_description(vial)
	local meta = vial:get_meta()
	local dew = meta:get_int("voxeldungeon:dew")

	local def = vial:get_definition()
	local desc = def.description
	local info = def._info

	meta:set_string("description", voxeldungeon.utils.itemDescription(desc.." ("..dew..'/'..DEW_VIAL_MAX..")\n \n"
		..info))
end

local function do_drink(itemstack, user, pointed_thing)
	if user then
		local meta = itemstack:get_meta()
		local dew = meta:get_int("voxeldungeon:dew")
		local HT = voxeldungeon.playerhandler.playerdata[user:get_player_name()].HT

		local percent = math.min(dew / DEW_VIAL_MAX, voxeldungeon.utils.round((HT - user:get_hp()) / HT, 20))

		if percent > 0 then
			user:set_hp(user:get_hp() + HT * percent)
			meta:set_int("voxeldungeon:dew", dew - DEW_VIAL_MAX * percent)
			voxeldungeon.items.update_vial_description(itemstack)
		elseif user:get_hp() == HT then
			voxeldungeon.glog.i("Your HP is already full!", user)
		else
			voxeldungeon.glog.i("Your dew vial is empty!", user)
		end
	end

	return itemstack
end

minetest.register_craftitem("voxeldungeon:dew", {
	description = voxeldungeon.utils.itemDescription("Dew Drop\n \nA crystal clear dewdrop; due to the magic of the underground, it has minor restorative properties."),
	inventory_image = "voxeldungeon_item_dew.png",
	groups = {flammable = 1}
})

minetest.register_craftitem("voxeldungeon:dewvial", {
	description = "Dew Vial",
	inventory_image = "voxeldungeon_item_dewvial.png",
	_info = "You can store excess dew in this tiny vessel and drink it later. The more full the vial is, the more you will be instantly healed when drinking it. You will only drink as much as you need.\n \nVials like this one used to be imbued with revival magic, but that power has faded. There still seems to be some residual power left, perhaps a full vial can bless another revival item.\n \nRight click while holding it to drink from it.",

	stack_max = 1,
	groups = {unique = 1},

	on_place = do_drink,
	on_secondary_use = do_drink,
})

local super_on_punch = minetest.registered_entities["__builtin:item"].on_punch
local super_on_step = minetest.registered_entities["__builtin:item"].on_step
entitycontrol.override_entity("__builtin:item", {
	on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		local items = ItemStack(self.itemstring)
	
		if items:get_name() == "voxeldungeon:dew" then
			local inv = puncher:get_inventory()

			for i = 1, inv:get_size("main") do
				local vial = inv:get_stack("main", i)
				local meta = vial:get_meta()
				local amount = meta:get_int("voxeldungeon:dew")

				if vial:get_name() == "voxeldungeon:dewvial" and amount < DEW_VIAL_MAX then
					meta:set_int("voxeldungeon:dew", math.min(amount + items:get_count(), DEW_VIAL_MAX))
					voxeldungeon.items.update_vial_description(vial)
					inv:set_stack("main", i, vial)

					if amount + items:get_count() < DEW_VIAL_MAX then
						voxeldungeon.glog.i("You put the dew drop in your dew vial.", puncher)
					else
						voxeldungeon.glog.p("Your dew vial is full!", puncher)
					end

					self.itemstring = ""
					self.object:remove()
					return
				end
			end

			puncher:set_hp(puncher:get_hp() + items:get_count())
			self.itemstring = ""
			self.object:remove()
		else
			return super_on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir)
		end
	end,

	on_step = function(self, dtime, moveresult)
		super_on_step(self, dtime, moveresult)

		if not self.object:get_pos() then return end

		if voxeldungeon.blobs.get("voxeldungeon:blob_fire", self.object:get_pos()) > 0 then
			local item = ItemStack(self.itemstring)

			if item:get_definition().groups.flammable then
				local on_burn = item:get_definition().on_burn

				if on_burn then
					on_burn(self.object:get_pos())
				end

				self.itemstring = ""
				self.object:remove()
			end
		end
	end
})



local function do_augment(itemstack, user, augment_type)
	local itemname = itemstack:get_name()
	voxeldungeon.utils.take_item(user, itemstack)

	voxeldungeon.itemselector.showSelector(user, "Choose a weapon to augment for "..augment_type..".", "weapon", function(player, choice)
		if choice and choice:get_meta():get_string("voxeldungeon:augment") ~= augment_type then
			choice:get_meta():set_string("voxeldungeon:augment", augment_type)
			voxeldungeon.glog.h("You augmented your "..voxeldungeon.utils.itemShortDescription(choice).." to increase "..augment_type..".", player)
			voxeldungeon.weapons.updateDescription(choice)
		else
			if choice then
				voxeldungeon.glog.i("That weapon is already augmented for "..augment_type..".", player)
			end

			voxeldungeon.utils.return_item(user, itemname)
		end

		return choice
	end)

	return itemstack
end

minetest.register_craftitem("voxeldungeon:weightstone", {
	description = voxeldungeon.utils.itemDescription("Weightstone\n \nUsing a weightstone, you can augment your melee weapon to increase its speed or durability. However, this increase must come at the cost of the other.\n \nLeft click while holding it to augment for speed.\nRight click while holding it to augment for durability."),
	inventory_image = "voxeldungeon_tool_weightstone.png",

	on_use = function(itemstack, user, pointed_thing)
		return do_augment(itemstack, user, "speed")
	end,

	on_place = function(itemstack, user, pointed_thing)
		return do_augment(itemstack, user, "durability")
	end,

	on_secondary_use = function(itemstack, user, pointed_thing)
		return do_augment(itemstack, user, "durability")
	end,
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
