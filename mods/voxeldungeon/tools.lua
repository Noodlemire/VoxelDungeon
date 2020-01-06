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



voxeldungeon.tools = {}



if not minetest.settings:get_bool("creative_mode") then
	minetest.override_item("", {
		tool_capabilities = {
			full_punch_interval = 0.667,
			max_drop_level = 0,
			groupcaps = {
				crumbly = {times={[2]=3.00, [3]=0.70}, uses=0, maxlevel=1},
				snappy = {times={[3]=0.40}, uses=0, maxlevel=1},
				oddly_breakable_by_hand = {times={[1]=3.50,[2]=2.00,[3]=0.70}, uses=0}
			},
			damage_groups = {fleshy = 1},
		}
	})
end

minetest.override_item("default:pick_wood", {
	max_drop_level=1
})

minetest.override_item("default:pick_stone", {
	max_drop_level=1
})

minetest.override_item("default:pick_steel", {
	max_drop_level=2
})

minetest.override_item("default:pick_diamond", {
	tool_capabilities = {
		max_drop_level=4,
		groupcaps={
			cracky = {times={[1]=2.0, [2]=1.0, [3]=0.50}, uses=30, maxlevel=4},
		},
	}
})

minetest.register_tool("voxeldungeon:pick_demonite", {
	description = "Demonite Pickaxe",
	inventory_image = "voxeldungeon_tool_pickaxe_demonite.png",
	tool_capabilities = {
		full_punch_interval = 0.8,
		max_drop_level=5,
		groupcaps={
			cracky = {times={[1]=1.6, [2]=0.8, [3]=0.4}, uses=40, maxlevel=5},
		},
		damage_groups = {fleshy=6},
	},
	sound = {breaks = "default_tool_breaks"},
	groups = {pickaxe = 1}
})



--general upgradable item methods

function voxeldungeon.tools.getStrengthRequirementOf(tierItem)
	local level = tierItem:get_meta():get_int("voxeldungeon:level")
	local tier = tierItem:get_definition()._tier

	--strength requirement decreases at +1, +3, +6, +10, etc.
	return 8 + 2 * tier - math.floor(math.floor(math.sqrt(8 * level + 1) - 1) / 2)
end

function voxeldungeon.tools.setLevelOf(upItem, level)
	upItem:get_meta():set_int("voxeldungeon:level", level)

	if minetest.get_item_group(upItem:get_name(), "weapon") > 0 then
		voxeldungeon.weapons.updateDescription(upItem)
	elseif minetest.get_item_group(upItem:get_name(), "wand") > 0 then
		voxeldungeon.wands.fullRecharge(upItem)
		voxeldungeon.wands.updateDescription(upItem)
	elseif minetest.get_item_group(upItem:get_name(), "armor_torso") > 0 then
		voxeldungeon.armor.updateDescription(upItem)
	end
end

function voxeldungeon.tools.upgrade(upItem)
	local level = upItem:get_meta():get_int("voxeldungeon:level")
	voxeldungeon.tools.setLevelOf(upItem, level + 1)
	upItem:set_wear(0)
end



minetest.register_on_craft(function(itemstack)
	if minetest.get_item_group(itemstack:get_name(), "weapon") > 0 then
		voxeldungeon.weapons.updateDescription(itemstack)
		return itemstack
	elseif minetest.get_item_group(itemstack:get_name(), "wand") > 0 then 
		voxeldungeon.wands.updateDescription(itemstack)
		return itemstack
	elseif minetest.get_item_group(itemstack:get_name(), "armor_torso") > 0 then 
		voxeldungeon.armor.updateDescription(itemstack)
		return itemstack
	end
end)
