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

voxeldungeon.generator = {}

voxeldungeon.generator.limited_drops = {}

local armorChances = {
	{
		["voxeldungeon:armor_cloth"] = 64,
		["voxeldungeon:armor_leather"] = 32,
		["voxeldungeon:armor_mail"] = 16, 
		["voxeldungeon:armor_scale"] = 8,
		["voxeldungeon:armor_plate"] = 4,
	},
	{
		["voxeldungeon:armor_cloth"] = 0,
		["voxeldungeon:armor_leather"] = 64,
		["voxeldungeon:armor_mail"] = 32, 
		["voxeldungeon:armor_scale"] = 16,
		["voxeldungeon:armor_plate"] = 8,
	},
	{
		["voxeldungeon:armor_cloth"] = 0,
		["voxeldungeon:armor_leather"] = 32,
		["voxeldungeon:armor_mail"] = 64, 
		["voxeldungeon:armor_scale"] = 32,
		["voxeldungeon:armor_plate"] = 16,
	},
	{
		["voxeldungeon:armor_cloth"] = 0,
		["voxeldungeon:armor_leather"] = 16,
		["voxeldungeon:armor_mail"] = 32, 
		["voxeldungeon:armor_scale"] = 64,
		["voxeldungeon:armor_plate"] = 32,
	},
	{
		["voxeldungeon:armor_cloth"] = 0,
		["voxeldungeon:armor_leather"] = 8,
		["voxeldungeon:armor_mail"] = 16, 
		["voxeldungeon:armor_scale"] = 32,
		["voxeldungeon:armor_plate"] = 64,
	},
}

local foodChances = {
	["voxeldungeon:ration"] = 4,
	["voxeldungeon:pasty"] = 1,
}

local goldChances = {
	["voxeldungeon:gold"] = 100
}

local miscChances = {
	["voxeldungeon:ankh"] = 1,
	["voxeldungeon:bomb"] = 8,
	["voxeldungeon:honeypot"] = 4,
	["voxeldungeon:weightstone"] = 2,
}

local oreChances = {
	{
		["default:coal_lump"] = 100,
		["default:gold_lump"] = 30,
		["default:gold_ingot"] = 10,
		["default:iron_lump"] = 0,
		["default:steel_ingot"] = 0,
		["default:mese_crystal"] = 0,
		["default:diamond"] = 0,
		["voxeldungeon:demonite_lump"] = 0,
		["voxeldungeon:demonite_ingot"] = 0,
	},
	{
		["default:coal_lump"] = 45,
		["default:gold_lump"] = 20,
		["default:gold_ingot"] = 5,
		["default:iron_lump"] = 50,
		["default:steel_ingot"] = 10,
		["default:mese_crystal"] = 0,
		["default:diamond"] = 0,
		["voxeldungeon:demonite_lump"] = 0,
		["voxeldungeon:demonite_ingot"] = 0,
	},
	{
		["default:coal_lump"] = 40,
		["default:gold_lump"] = 25,
		["default:gold_ingot"] = 5,
		["default:iron_lump"] = 40,
		["default:steel_ingot"] = 5,
		["default:mese_crystal"] = 50,
		["default:diamond"] = 0,
		["voxeldungeon:demonite_lump"] = 0,
		["voxeldungeon:demonite_ingot"] = 0,
	},
	{
		["default:coal_lump"] = 35,
		["default:gold_lump"] = 30,
		["default:gold_ingot"] = 5,
		["default:iron_lump"] = 35,
		["default:steel_ingot"] = 5,
		["default:mese_crystal"] = 40,
		["default:diamond"] = 50,
		["voxeldungeon:demonite_lump"] = 0,
		["voxeldungeon:demonite_ingot"] = 0,
	},
	{
		["default:coal_lump"] = 30,
		["default:gold_lump"] = 40,
		["default:gold_ingot"] = 10,
		["default:iron_lump"] = 30,
		["default:steel_ingot"] = 5,
		["default:mese_crystal"] = 35,
		["default:diamond"] = 40,
		["voxeldungeon:demonite_lump"] = 50,
		["voxeldungeon:demonite_ingot"] = 10,
	},
}

local potionChances = {
	["voxeldungeon:potion_strength"] = 0,
	["voxeldungeon:potion_toxicgas"] = 3,
	["voxeldungeon:potion_liquidflame"] = 3,
	["voxeldungeon:potion_might"] = 0,
	["voxeldungeon:potion_frost"] = 3,
	["voxeldungeon:potion_healing"] = 6,
	["voxeldungeon:potion_invisibility"] = 2,
	["voxeldungeon:potion_levitation"] = 2,
	["voxeldungeon:potion_mindvision"] = 4,
	["voxeldungeon:potion_paralyticgas"] = 2,
	["voxeldungeon:potion_purification"] = 2,
	["voxeldungeon:potion_haste"] = 2,
}

local repairChances = {
	["voxeldungeon:repair_armor"] = 1,
	["voxeldungeon:repair_wand"] = 1,
	["voxeldungeon:repair_weapon"] = 1,
}

local scrollChances = {
	["voxeldungeon:scroll_upgrade"] = 0,
	["voxeldungeon:scroll_identify"] = 6,
	["voxeldungeon:scroll_removecurse"] = 4,
	["voxeldungeon:scroll_enchantment"] = 0,
	["voxeldungeon:scroll_terror"] = 2,
	["voxeldungeon:scroll_rage"] = 2,
	["voxeldungeon:scroll_magicmapping"] = 2,
	["voxeldungeon:scroll_lullaby"] = 2,
	["voxeldungeon:scroll_psionicblast"] = 1,
	["voxeldungeon:scroll_teleportation"] = 3,
	["voxeldungeon:scroll_mirrorimage"] = 3,
	["voxeldungeon:scroll_recharging"] = 3,
}

local seedChances = {
	["voxeldungeon:plant_earthroot"] = 4,
	["voxeldungeon:plant_fadeleaf"] = 4,
	["voxeldungeon:plant_firebloom"] = 5,
	["voxeldungeon:plant_icecap"] = 4,
	["voxeldungeon:plant_sorrowmoss"] = 5,
	["voxeldungeon:plant_sungrass"] = 3,
	["voxeldungeon:plant_rotberry"] = 0,
}

local wandChances = {
	["voxeldungeon:wand_avalanche"] = 4,
	["voxeldungeon:wand_blastwave"] = 3,
	["voxeldungeon:wand_corrosion"] = 4,
	["voxeldungeon:wand_disintegration"] = 4,
	["voxeldungeon:wand_fireblast"] = 3,
	["voxeldungeon:wand_flock"] = 3,
	["voxeldungeon:wand_frost"] = 3,
	["voxeldungeon:wand_lightning"] = 4,
	["voxeldungeon:wand_magicmissile"] = 4,
	["voxeldungeon:wand_prismaticlight"] = 3,
	["voxeldungeon:wand_regrowth"] = 3,
	["voxeldungeon:wand_vampirism"] = 2,
}

local weaponChances = {
	{
		["voxeldungeon:weapon_shortsword"] = 60,
		["voxeldungeon:weapon_knuckleduster"] = 55,
		["voxeldungeon:weapon_dagger"] = 55,
		["voxeldungeon:weapon_quarterstaff"] = 33,
		["voxeldungeon:weapon_spear"] = 30,
		["voxeldungeon:weapon_handaxe"] = 30,
		["voxeldungeon:weapon_sword"] = 12,
		["voxeldungeon:weapon_scimitar"] = 10,
		["voxeldungeon:weapon_mace"] = 10,
		["voxeldungeon:weapon_longsword"] = 5,
		["voxeldungeon:weapon_stonegauntlet"] = 4,
		["voxeldungeon:weapon_battleaxe"] = 4,
		["voxeldungeon:weapon_greatsword"] = 2,
		["voxeldungeon:weapon_glaive"] = 1,
		["voxeldungeon:weapon_warhammer"] = 1,
	},
	{
		["voxeldungeon:weapon_shortsword"] = 0,
		["voxeldungeon:weapon_knuckleduster"] = 0,
		["voxeldungeon:weapon_dagger"] = 0,
		["voxeldungeon:weapon_quarterstaff"] = 60,
		["voxeldungeon:weapon_spear"] = 55,
		["voxeldungeon:weapon_handaxe"] = 55,
		["voxeldungeon:weapon_sword"] = 33,
		["voxeldungeon:weapon_scimitar"] = 30,
		["voxeldungeon:weapon_mace"] = 30,
		["voxeldungeon:weapon_longsword"] = 12,
		["voxeldungeon:weapon_stonegauntlet"] = 10,
		["voxeldungeon:weapon_battleaxe"] = 10,
		["voxeldungeon:weapon_greatsword"] = 5,
		["voxeldungeon:weapon_glaive"] = 4,
		["voxeldungeon:weapon_warhammer"] = 4,
	},
	{
		["voxeldungeon:weapon_shortsword"] = 0,
		["voxeldungeon:weapon_knuckleduster"] = 0,
		["voxeldungeon:weapon_dagger"] = 0,
		["voxeldungeon:weapon_quarterstaff"] = 33,
		["voxeldungeon:weapon_spear"] = 30,
		["voxeldungeon:weapon_handaxe"] = 30,
		["voxeldungeon:weapon_sword"] = 60,
		["voxeldungeon:weapon_scimitar"] = 55,
		["voxeldungeon:weapon_mace"] = 55,
		["voxeldungeon:weapon_longsword"] = 33,
		["voxeldungeon:weapon_stonegauntlet"] = 30,
		["voxeldungeon:weapon_battleaxe"] = 30,
		["voxeldungeon:weapon_greatsword"] = 12,
		["voxeldungeon:weapon_glaive"] = 10,
		["voxeldungeon:weapon_warhammer"] = 10,
	},
	{
		["voxeldungeon:weapon_shortsword"] = 0,
		["voxeldungeon:weapon_knuckleduster"] = 0,
		["voxeldungeon:weapon_dagger"] = 0,
		["voxeldungeon:weapon_quarterstaff"] = 12,
		["voxeldungeon:weapon_spear"] = 10,
		["voxeldungeon:weapon_handaxe"] = 10,
		["voxeldungeon:weapon_sword"] = 30,
		["voxeldungeon:weapon_scimitar"] = 33,
		["voxeldungeon:weapon_mace"] = 33,
		["voxeldungeon:weapon_longsword"] = 60,
		["voxeldungeon:weapon_stonegauntlet"] = 55,
		["voxeldungeon:weapon_battleaxe"] = 55,
		["voxeldungeon:weapon_greatsword"] = 33,
		["voxeldungeon:weapon_glaive"] = 30,
		["voxeldungeon:weapon_warhammer"] = 30,
	},
	{
		["voxeldungeon:weapon_shortsword"] = 0,
		["voxeldungeon:weapon_knuckleduster"] = 0,
		["voxeldungeon:weapon_dagger"] = 0,
		["voxeldungeon:weapon_quarterstaff"] = 5,
		["voxeldungeon:weapon_spear"] = 4,
		["voxeldungeon:weapon_handaxe"] = 4,
		["voxeldungeon:weapon_sword"] = 12,
		["voxeldungeon:weapon_scimitar"] = 10,
		["voxeldungeon:weapon_mace"] = 10,
		["voxeldungeon:weapon_longsword"] = 33,
		["voxeldungeon:weapon_stonegauntlet"] = 30,
		["voxeldungeon:weapon_battleaxe"] = 30,
		["voxeldungeon:weapon_greatsword"] = 60,
		["voxeldungeon:weapon_glaive"] = 55,
		["voxeldungeon:weapon_warhammer"] = 55,
	},
}

local function randomLevel()
	local level = 0

	for i = 3, 1, -1 do
		if math.random(math.pow(3, i)) == 1 then
			level = i
		end
	end

	return level
end

function voxeldungeon.generator.randomArmor(t)
	local tier = t or 1
	local arm = voxeldungeon.utils.randomChances(armorChances[tier])

	local itemstack = ItemStack({name = arm, count = 1, wear = 0, metadata = ""})
	voxeldungeon.tools.setLevelOf(itemstack, randomLevel())
	return itemstack
end

function voxeldungeon.generator.randomFood()
	return {name = voxeldungeon.utils.randomChances(foodChances), count = 1, wear = 0, metadata = ""}
end

function voxeldungeon.generator.randomGold(t)
	local tier = t or 1
	return {name = voxeldungeon.utils.randomChances(goldChances), count = math.random(20 + tier * 40, 20 + tier * 80), wear = 0, metadata = ""}
end

function voxeldungeon.generator.randomMisc()
	return {name = voxeldungeon.utils.randomChances(miscChances), count = 1, wear = 0, metadata = ""}
end

function voxeldungeon.generator.randomOre(t)
	local tier = t or 1
	return {name = voxeldungeon.utils.randomChances(oreChances[tier]), count = math.random(1, 4), wear = 0, metadata = ""}
end

function voxeldungeon.generator.randomPotion()
	return {name = voxeldungeon.utils.randomChances(potionChances), count = 1, wear = 0, metadata = ""}
end

function voxeldungeon.generator.randomRepair()
	return {name = voxeldungeon.utils.randomChances(repairChances), count = 1, wear = 0, metadata = ""}
end

function voxeldungeon.generator.randomScroll()
	return {name = voxeldungeon.utils.randomChances(scrollChances), count = 1, wear = 0, metadata = ""}
end

function voxeldungeon.generator.randomSeed()
	return {name = voxeldungeon.utils.randomChances(seedChances), count = 1, wear = 0, metadata = ""}
end

function voxeldungeon.generator.randomWand()
	local wand = voxeldungeon.utils.randomChances(wandChances)

	local itemstack = ItemStack({name = wand, count = 1, wear = 0, metadata = ""})
	voxeldungeon.tools.setLevelOf(itemstack, randomLevel())
	return itemstack
end

function voxeldungeon.generator.randomWeapon(t)
	local tier = t or 1
	local wep = voxeldungeon.utils.randomChances(weaponChances[tier])

	local itemstack = ItemStack({name = wep, count = 1, wear = 0, metadata = ""})
	voxeldungeon.tools.setLevelOf(itemstack, randomLevel())
	return itemstack
end



local function allChances(t)
	local tier = t or 1

	return {
		[voxeldungeon.generator.randomArmor] = voxeldungeon.utils.sumChances(armorChances[tier]),
		[voxeldungeon.generator.randomFood] = voxeldungeon.utils.sumChances(foodChances) * 15,
		[voxeldungeon.generator.randomGold] = voxeldungeon.utils.sumChances(goldChances),
		[voxeldungeon.generator.randomMisc] = voxeldungeon.utils.sumChances(miscChances) * 15,
		[voxeldungeon.generator.randomOre] = voxeldungeon.utils.sumChances(oreChances[tier]),
		[voxeldungeon.generator.randomPotion] = voxeldungeon.utils.sumChances(potionChances) * 10,
		[voxeldungeon.generator.randomRepair] = voxeldungeon.utils.sumChances(repairChances),
		[voxeldungeon.generator.randomScroll] = voxeldungeon.utils.sumChances(scrollChances) * 10,
		[voxeldungeon.generator.randomSeed] = voxeldungeon.utils.sumChances(seedChances) * 10,
		[voxeldungeon.generator.randomWand] = voxeldungeon.utils.sumChances(wandChances) * 3,
		[voxeldungeon.generator.randomWeapon] = voxeldungeon.utils.sumChances(weaponChances[tier]) * 0.4,
	}
end

function voxeldungeon.generator.random(t)
	--[[voxeldungeon.glog.i("armor: "..voxeldungeon.utils.sumChances(armorChances[t]))
	voxeldungeon.glog.i("food: "..voxeldungeon.utils.sumChances(foodChances) * 15)
	voxeldungeon.glog.i("gold: "..voxeldungeon.utils.sumChances(goldChances))
	voxeldungeon.glog.i("misc: "..voxeldungeon.utils.sumChances(miscChances) * 25)
	voxeldungeon.glog.i("ore: "..voxeldungeon.utils.sumChances(oreChances[t]))
	voxeldungeon.glog.i("potion: "..voxeldungeon.utils.sumChances(potionChances) * 10)
	voxeldungeon.glog.i("repair: "..voxeldungeon.utils.sumChances(repairChances))
	voxeldungeon.glog.i("scroll: "..voxeldungeon.utils.sumChances(scrollChances) * 10)
	voxeldungeon.glog.i("seed: "..voxeldungeon.utils.sumChances(seedChances) * 10)
	voxeldungeon.glog.i("wand: "..voxeldungeon.utils.sumChances(wandChances) * 3)
	voxeldungeon.glog.i("weapon: "..voxeldungeon.utils.sumChances(weaponChances[t]) * 0.4)--]]

	return voxeldungeon.utils.randomChances(allChances(t))(t)
end

minetest.register_node("voxeldungeon:dormant_chest", {
	description = "Dormant Chest",

	tiles = {
		"voxeldungeon_node_chest_top.png",
		"voxeldungeon_node_chest_bottom.png",
		"voxeldungeon_node_chest_right.png",
		"voxeldungeon_node_chest_left.png",
		"voxeldungeon_node_chest_back.png",
		"voxeldungeon_node_chest_front.png",
	},

	inventory_image = "voxeldungeon_node_chest_icon.png",
	wield_image = "voxeldungeon_node_chest_icon.png",

	sounds = default.node_sound_wood_defaults(),
	visual = "mesh",
	paramtype = "light",
	paramtype2 = "facedir",
	legacy_facedir_simple = true,
	is_ground_content = false,

	can_dig = function(pos,player)
		return false
	end,

	on_blast = function(pos)
		if math.random(4) == 1 then
			minetest.remove_node(pos)
			local mimic = minetest.add_entity(pos, "voxeldungeon:mimic")
		else
			minetest.registered_nodes[minetest.get_node(pos).name].on_rightclick(pos, minetest.get_node(pos))
			local blast = minetest.registered_nodes[minetest.get_node(pos).name].on_blast
			if blast then return blast(pos) end
		end
	end,

	on_rightclick = function(pos, node, clicker)
		if math.random(1, 4) == 1 then
			minetest.remove_node(pos)
			minetest.add_entity(pos, "voxeldungeon:mimic")

			if clicker then voxeldungeon.glog.w("This is a mimic!", clicker) end
		else
			minetest.swap_node(pos, {name = "default:chest", param1 = node.param1, param2 = node.param2})

			local name
			if clicker then name = clicker:get_player_name() end

			local newnode = minetest.get_node(pos)
			local newdef = minetest.registered_nodes[newnode.name]
			newdef.on_construct(pos)
			local inv = minetest.get_meta(pos):get_inventory()
			local tier = voxeldungeon.utils.getChapter(pos)
			
			for i = 1, math.random(4, 8) do
				local itemSlot
				local slotNum

				repeat
					slotNum = math.random(1, inv:get_size("main"))
					itemSlot = inv:get_stack("main", slotNum)
				until(itemSlot and itemSlot:is_empty())

				if not clicker then
					inv:set_stack("main", slotNum, voxeldungeon.generator.random(tier))

				elseif voxeldungeon.generator.limited_drops[name].repair >= voxeldungeon.generator.drop_limits.repair then
					voxeldungeon.generator.limited_drops[name].repair = 0
					inv:set_stack("main", slotNum, voxeldungeon.generator.randomRepair())

				elseif voxeldungeon.generator.limited_drops[name].vial < voxeldungeon.generator.drop_limits.vial then
					local vial = ItemStack("voxeldungeon:dewvial")
					voxeldungeon.items.update_vial_description(vial)
					inv:set_stack("main", slotNum, vial)
					voxeldungeon.generator.limited_drops[name].vial = voxeldungeon.generator.limited_drops[name].vial + 1

				elseif voxeldungeon.generator.limited_drops[name].sou[tier] < voxeldungeon.generator.drop_limits.sou[tier] and 
						math.random(12) == 1 then
					inv:set_stack("main", slotNum, ItemStack("voxeldungeon:scroll_upgrade"))
					voxeldungeon.generator.limited_drops[name].sou[tier] = voxeldungeon.generator.limited_drops[name].sou[tier] + 1

				elseif voxeldungeon.generator.limited_drops[name].pos[tier] < voxeldungeon.generator.drop_limits.pos[tier] and 
						math.random(12) == 1 then
					inv:set_stack("main", slotNum, ItemStack("voxeldungeon:potion_strength"))
					voxeldungeon.generator.limited_drops[name].pos[tier] = voxeldungeon.generator.limited_drops[name].pos[tier] + 1

				elseif voxeldungeon.generator.limited_drops[name].pom[tier] < voxeldungeon.generator.drop_limits.pom[tier] and 
						math.random(12) == 1 then
					inv:set_stack("main", slotNum, ItemStack("voxeldungeon:potion_might"))
					voxeldungeon.generator.limited_drops[name].pom[tier] = voxeldungeon.generator.limited_drops[name].pom[tier] + 1
				else
					voxeldungeon.generator.limited_drops[name].repair = voxeldungeon.generator.limited_drops[name].repair + 1
					inv:set_stack("main", slotNum, voxeldungeon.generator.random(tier))
				end
			end

			if clicker then
				voxeldungeon.generator.saveDropLimits(clicker)
				newdef.on_rightclick(pos, node, clicker)
			end
		end
	end,
})



voxeldungeon.generator.drop_limits = {
	vial = 1,
	repair = 24,
	sou = {3, 3, 3, 3, 3},
	pos = {2, 2, 2, 2, 2},
	pom = {5, 5, 5, 5, 5},
}

function voxeldungeon.generator.saveDropLimits(player)
	local name = player:get_player_name()

	voxeldungeon.storage.put(name.."_vial", voxeldungeon.generator.limited_drops[name].vial)
	voxeldungeon.storage.put(name.."_repair", voxeldungeon.generator.limited_drops[name].repair)

	for i, v in ipairs(voxeldungeon.generator.limited_drops[name].sou) do
		voxeldungeon.storage.put(name.."_sou_"..i, v)
	end

	for i, v in ipairs(voxeldungeon.generator.limited_drops[name].pos) do
		voxeldungeon.storage.put(name.."_pos_"..i, v)
	end

	for i, v in ipairs(voxeldungeon.generator.limited_drops[name].pom) do
		voxeldungeon.storage.put(name.."_pom_"..i, v)
	end
end

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	
	voxeldungeon.generator.limited_drops[name] = {}

	voxeldungeon.generator.limited_drops[name].vial = voxeldungeon.storage.getNum(name.."_vial") or 0
	voxeldungeon.generator.limited_drops[name].repair = voxeldungeon.storage.getNum(name.."_repair") or 0

	voxeldungeon.generator.limited_drops[name].sou = {}
	voxeldungeon.generator.limited_drops[name].pos = {}
	voxeldungeon.generator.limited_drops[name].pom = {}

	for i = 1, 5 do
		voxeldungeon.generator.limited_drops[name].sou[i] = voxeldungeon.storage.getNum(name.."_sou_"..i) or 0
		voxeldungeon.generator.limited_drops[name].pos[i] = voxeldungeon.storage.getNum(name.."_pos_"..i) or 0
		voxeldungeon.generator.limited_drops[name].pom[i] = voxeldungeon.storage.getNum(name.."_pom_"..i) or 0
	end

	voxeldungeon.generator.saveDropLimits(player)
end)
