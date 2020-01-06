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

voxeldungeon.armor = {} --global variable



function voxeldungeon.armor.getDefenseOf(armor)
	local level = armor:get_meta():get_int("voxeldungeon:level")

	local def = armor:get_definition()
	local tier = def._tier

	return tier + tier * level
end

function voxeldungeon.armor.updateDescription(armor)
	local meta = armor:get_meta()
	local level = meta:get_int("voxeldungeon:level")

	local def = armor:get_definition()
	local tier = def._tier
	local info = def._info

	local defense = voxeldungeon.armor.getDefenseOf(armor)
	local strreq = voxeldungeon.tools.getStrengthRequirementOf(armor)

	local strTip = "\n \nBe careful about equipping armor without enough strength, your movement speed will decrease."
	
	meta:set_string("description", voxeldungeon.utils.itemDescription(voxeldungeon.utils.itemShortDescription(armor).."\n \n"..info.. 
								"\n \nThis tier-"..tier.." armor blocks "..defense.." damage and requires "..strreq..
								" points of strength to wear properly."..strTip))
end

function voxeldungeon.armor.updateStrdiffArmor(player)
	local playername = player:get_player_name()
	local armor_inv = minetest.get_inventory({type="detached", name=playername.."_armor"})
	if not armor_inv then return end
	local armor = armor_inv:get_stack("armor", 1)

	player_monoids.speed:del_change(player, "voxeldungeon:armor_strreq_penalty")

	if not armor:is_empty() then
		local strdiff = voxeldungeon.playerhandler.getSTR(player) - voxeldungeon.tools.getStrengthRequirementOf(armor)

		if strdiff < 0 then
			player_monoids.speed:add_change(player, 1 / (-strdiff + 1), "voxeldungeon:armor_strreq_penalty")
		end
	end
end

function voxeldungeon.armor.register_armor(name, desc, tier, info)
	info = info or "!!!NO TEXT FOUND!!!"

	armor:register_armor("voxeldungeon:armor_"..name, {
		description = desc,
		inventory_image = "voxeldungeon_tool_armor_"..name..".png",

		armor_groups = {fleshy = 0},

		groups = {armor_torso = 1, armor = 1, upgradable = 1},

		_info = info,
		_tier = tier,
		_durabilityPerUse = (6 - tier),

		on_equip = function(player, index, itemstack)
			local strdiff = voxeldungeon.playerhandler.getSTR(player) - voxeldungeon.tools.getStrengthRequirementOf(itemstack)

			if strdiff < 0 then
				player_monoids.speed:add_change(player, 1 / (-strdiff + 1), "voxeldungeon:armor_strreq_penalty")
			end
		end,

		on_unequip = function(player, index, itemstack)
			player_monoids.speed:del_change(player, "voxeldungeon:armor_strreq_penalty")
		end,
	})
end



voxeldungeon.armor.register_armor("cloth", "Cloth Armor", 1, "This lightweight armor offers basic protection.")
voxeldungeon.armor.register_armor("cactus", "Cactus Armor", 1, "A rather unconventional type of armor, which offers more discomfort than it does defense.")
voxeldungeon.armor.register_armor("wood", "Wood Armor", 1, "Constructed from wooden planks, this boxy clothing will offer a small level of protection against monster attacks.")

voxeldungeon.armor.register_armor("leather", "Leather Armor", 2, "Armor made from tanned monster hide. Not as light as cloth armor but provides better protection.")
voxeldungeon.armor.register_armor("steel", "Steel Armor", 2, "A set of solid steel armor, albiet a thin one with no padding. While it won't compare to professionally made plate armor, it does offer decent protection.")

voxeldungeon.armor.register_armor("mail", "Mail Armor", 3, "Interlocking metal links make for a tough but flexible suit of armor.")
voxeldungeon.armor.register_armor("mese", "Mese Armor", 3, "A bright golden suit of sturdy armor, the material strong enough to take a beating so that you won't have to.")

voxeldungeon.armor.register_armor("scale", "Scale Armor", 4, "Metal scales are sewn onto a leather vest create a flexible, yet protective armor.")
voxeldungeon.armor.register_armor("diamond", "Diamond Armor", 4, "Finely cut diamond armor ready to take on even the toughest of foes, as long as they're the kind that won't think to strike at just the right angle to cut the suit in half.")

voxeldungeon.armor.register_armor("plate", "Plate Armor", 5, "Enormous plates of metal are joined together into a suit that provides unmatched "..
								"protection to any adventurer strong enough to bear its staggering weight.")
voxeldungeon.armor.register_armor("demonite", "Demonite Armor", 5, "A set of armor created out of pure demonite, one of the world's strongest and heaviest materials.")
