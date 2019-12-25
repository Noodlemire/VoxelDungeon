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



--any tiered items

local function getStrengthRequirementOf(tierItem)
	local level = tierItem:get_meta():get_int("voxeldungeon:level")
	local tier = tierItem:get_definition()._tier

	--strength requirement decreases at +1, +3, +6, +10, etc.
	return 8 + 2 * tier - math.floor(math.floor(math.sqrt(8 * level + 1) - 1) / 2)
end

function voxeldungeon.tools.setLevelOf(tierItem, level)
	tierItem:get_meta():set_int("voxeldungeon:level", level)

	if minetest.get_item_group(tierItem:get_name(), "weapon") > 0 then
		voxeldungeon.tools.updateDescriptionWeapon(tierItem)
	else
		voxeldungeon.tools.updateDescriptionArmor(tierItem)
	end
end

function voxeldungeon.tools.upgrade(tierItem)
	local level = tierItem:get_meta():get_int("voxeldungeon:level")
	voxeldungeon.tools.setLevelOf(tierItem, level + 1)
	tierItem:set_wear(0)
end



--armor

local function getDefenseOf(armor)
	local level = armor:get_meta():get_int("voxeldungeon:level")

	local def = armor:get_definition()
	local tier = def._tier

	return tier + tier * level
end

function voxeldungeon.tools.updateDescriptionArmor(armor)
	local meta = armor:get_meta()
	local level = meta:get_int("voxeldungeon:level")

	local def = armor:get_definition()
	local tier = def._tier
	local desc = def.description
	local info = def._info

	local defense = getDefenseOf(armor)
	local strreq = getStrengthRequirementOf(armor)

	local strTip = "\n \nBe careful about equipping armor without enough strength, your movement speed will decrease."
	
	meta:set_string("description", voxeldungeon.utils.itemDescription(voxeldungeon.utils.itemShortDescription(armor).."\n \n"..info.. 
								"\n \nThis tier-"..tier.." armor blocks "..defense.." damage and requires "..strreq..
								" points of strength to wear properly."..strTip))
end

function voxeldungeon.tools.updateStrdiffArmor(player)
	local playername = player:get_player_name()
	local armor_inv = minetest.get_inventory({type="detached", name=playername.."_armor"})
	if not armor_inv then return end
	local armor = armor_inv:get_stack("armor", 1)

	player_monoids.speed:del_change(player, "voxeldungeon:armor_strreq_penalty")

	if not armor:is_empty() then
		local strdiff = voxeldungeon.playerhandler.getSTR(player) - getStrengthRequirementOf(armor)

		if strdiff < 0 then
			player_monoids.speed:add_change(player, 1 / (-strdiff + 1), "voxeldungeon:armor_strreq_penalty")
		end
	end
end

function voxeldungeon.tools.register_armor(name, desc, tier, info)
	info = info or "!!!NO TEXT FOUND!!!"

	armor:register_armor("voxeldungeon:armor_"..name, {
		description = desc,
		inventory_image = "voxeldungeon_tool_armor_"..name..".png",

		armor_groups = {fleshy = 0},

		groups = {armor_torso=1, upgradable = 1},

		_info = info,
		_tier = tier,
		_durabilityPerUse = (6 - tier),

		on_equip = function(player, index, itemstack)
			local strdiff = voxeldungeon.playerhandler.getSTR(player) - getStrengthRequirementOf(itemstack)

			if strdiff < 0 then
				player_monoids.speed:add_change(player, 1 / (-strdiff + 1), "voxeldungeon:armor_strreq_penalty")
			end
		end,

		on_unequip = function(player, index, itemstack)
			player_monoids.speed:del_change(player, "voxeldungeon:armor_strreq_penalty")
		end,
	})
end



voxeldungeon.tools.register_armor("cloth", "Cloth Armor", 1, "This lightweight armor offers basic protection.")
voxeldungeon.tools.register_armor("cactus", "Cactus Armor", 1, "A rather unconventional type of armor, which offers more discomfort than it does defense.")
voxeldungeon.tools.register_armor("wood", "Wood Armor", 1, "Constructed from wooden planks, this boxy clothing will offer a small level of protection against monster attacks.")

voxeldungeon.tools.register_armor("leather", "Leather Armor", 2, "Armor made from tanned monster hide. Not as light as cloth armor but provides better protection.")
voxeldungeon.tools.register_armor("steel", "Steel Armor", 2, "A set of solid steel armor, albiet a thin one with no padding. While it won't compare to professionally made plate armor, it does offer decent protection.")

voxeldungeon.tools.register_armor("mail", "Mail Armor", 3, "Interlocking metal links make for a tough but flexible suit of armor.")
voxeldungeon.tools.register_armor("mese", "Mese Armor", 3, "A bright golden suit of sturdy armor, the material strong enough to take a beating so that you won't have to.")

voxeldungeon.tools.register_armor("scale", "Scale Armor", 4, "Metal scales are sewn onto a leather vest create a flexible, yet protective armor.")
voxeldungeon.tools.register_armor("diamond", "Diamond Armor", 4, "Finely cut diamond armor ready to take on even the toughest of foes, as long as they're the kind that won't think to strike at just the right angle to cut the suit in half.")

voxeldungeon.tools.register_armor("plate", "Plate Armor", 5, "Enormous plates of metal are joined together into a suit that provides unmatched "..
								"protection to any adventurer strong enough to bear its staggering weight.")
voxeldungeon.tools.register_armor("demonite", "Demonite Armor", 5, "A set of armor created out of pure demonite, one of the world's strongest and heaviest materials.")



--weapons

local function getDamageOf(weapon)
	local level = weapon:get_meta():get_int("voxeldungeon:level")

	local def = weapon:get_definition()
	local tier = def._tier
	local mult = def._damageMultiplier

	return voxeldungeon.utils.round(mult * (3 + 2 * tier + tier * level))
end

local function durabilityPerHitWith(weapon)
	local level = weapon:get_meta():get_int("voxeldungeon:level")

	return 1 - level / (level + 2)
end

function voxeldungeon.tools.updateDescriptionWeapon(weapon)
	local meta = weapon:get_meta()
	local level = meta:get_int("voxeldungeon:level")

	local def = weapon:get_definition()
	local tier = def._tier
	local desc = def.description
	local info = def._info
	local dly = def.tool_capabilities.full_punch_interval
	local dur = def._durabilityMultiplier or 1

	local damage = getDamageOf(weapon)
	local strreq = getStrengthRequirementOf(weapon)

	local dlyString = ""
	if dly > 1 then dlyString = "\n \nThis is a rather slow weapon."
	elseif dly < 1 then dlyString = "\n \nThis is a rather fast weapon."
	end

	local durString = ""
	if dur > 1 then durString = "\n \nThis is a rather durable weapon."
	elseif dur < 1 then durString = "\n \nThis is a rather fragile weapon."
	end

	local strTip = "\n \nHaving excess strength with this weapon will let you deal bonus damage with it, "..
			"while lacking strength will greatly reduce your attack speed."
	
	meta:set_string("description", voxeldungeon.utils.itemDescription(voxeldungeon.utils.itemShortDescription(weapon).."\n \n"..info.. 
								"\n \nThis tier-"..tier.." weapon deals "..damage.." damage and requires "..strreq..
								" points of strength to wield properly."..dlyString..durString..strTip))
end

local function weapon_on_use(itemstack, user, pointed_thing)
	if pointed_thing.type == "object" then
		local target = pointed_thing.ref
		local toolcap = itemstack:get_tool_capabilities()
		local strdiff = voxeldungeon.playerhandler.getSTR(user) - getStrengthRequirementOf(itemstack)

		toolcap.damage_groups = {fleshy = getDamageOf(itemstack) + math.max(0, strdiff)}
		toolcap.full_punch_interval = toolcap.full_punch_interval * math.max(1, -strdiff + 1)

		target:punch(user, voxeldungeon.playerhandler.getTimeFromLastPunch(user), toolcap)

		local def = itemstack:get_definition()
		local wear = math.floor(65535 / (1000 / def._durabilityPerUse * def._durabilityMultiplier))
		itemstack:add_wear(wear)
		return itemstack
	end
end

function voxeldungeon.tools.register_weapon(name, desc, tier, info, damage, delay, durability)
	damage = damage or 1
	delay = delay or 1
	durability = durability or 1
	info = info or "!!!NO TEXT FOUND!!!"

	minetest.register_tool("voxeldungeon:weapon_"..name, {
		description = desc,
		inventory_image = "voxeldungeon_tool_weapon_"..name..".png",

		tool_capabilities = 
		{
			full_punch_interval = delay
		}, 

		sound = {breaks = "default_tool_breaks"},
		groups = {weapon = 1, upgradable = 1},

		_info = info,
		_tier = tier,
		_damageMultiplier = damage,
		_durabilityPerUse = (6 - tier),
		_durabilityMultiplier = durability,

		on_use = weapon_on_use,
	})
end

function voxeldungeon.tools.weaponify(name, tier, info, groups)
	groups.upgradable = groups.upgradable or 1
	groups.weapon = 1

	minetest.override_item(name, {
		groups = groups,

		tool_capabilities = 
		{
			full_punch_interval = 1
		},

		_info = info,
		_tier = tier,
		_damageMultiplier = 1,
		_durabilityPerUse = (6 - tier),
		_durabilityMultiplier = 1,

		on_use = weapon_on_use,
	})
end



voxeldungeon.tools.weaponify("default:sword_wood", 0, "Little more than a stick carved into the shape of a sword, it's more often used for training "..
							"rather than combat.\n \nUnlike most other weapons, it is too weak to hold upgrades or magic.", 
							{sword = 1, upgradable = 0})

voxeldungeon.tools.register_weapon("shortsword", "Short Sword", 1, "It is indeed quite short, being just a few inches longer than a dagger.")
voxeldungeon.tools.register_weapon("knuckleduster", "Knuckleduster", 1, "A piece of iron shaped to fit around the knuckles.", 0.667, 0.5)
voxeldungeon.tools.register_weapon("dagger", "Dagger", 1, "A simple iron dagger with a well worn wooden handle.", 0.8, 1, 1.5)
voxeldungeon.tools.weaponify("default:sword_stone", 1, "A sturdy but somewhat dull blade of stone.", {sword = 1})

voxeldungeon.tools.register_weapon("quarterstaff", "Quarterstaff", 2, "A staff of hardwood, its ends are shod with iron.")
voxeldungeon.tools.register_weapon("spear", "Spear", 2, "A slender wooden rod tipped with sharpened iron.", 1.333, 1.5)
voxeldungeon.tools.register_weapon("handaxe", "Hand Axe", 2, "A light axe, most commonly used for felling trees. The wide blade works well against "..
								"foes as well.", 0.8, 1, 1.5)
voxeldungeon.tools.weaponify("default:sword_steel", 2, "A hand-crafted blade of solid steel. It isn't the best sword ever made, but it's yours.", 
							{sword = 1})

voxeldungeon.tools.register_weapon("sword", "Sword", 3, "A nicely balanced sword. Not too large, but still notably longer than a shortsword.")
voxeldungeon.tools.register_weapon("scimitar", "Scimitar", 3, "	A thick curved blade. Its shape allows for faster, yet less powerful attacks.", 0.8, 0.75)
voxeldungeon.tools.register_weapon("mace", "Mace", 3, "The iron head of this weapon inflicts substantial damage.", 0.8, 1, 1.5)
voxeldungeon.tools.weaponify("default:sword_mese", 3, "A crystalline sword forged from mese, complete with a fine (if uneven) cutting edge.", {sword = 1})

voxeldungeon.tools.register_weapon("longsword", "Long Sword", 4, "This sword's long razor-sharp steel blade shines reassuringly, though its size does make it quite heavy.")
voxeldungeon.tools.register_weapon("stonegauntlet", "Stone Gauntlet", 4, "This massive gauntlet is made of golden fabric with heavy magical stone "..
									"layered on top. The fabric tightens around you, making the thick stone plates "..
									"almost like a second skin. Swinging such a heavy weapon requires strength, "..
									"but adds tremendous force to your blows.", 0.667, 0.5)
voxeldungeon.tools.register_weapon("battleaxe", "Battle Axe", 4, "The enormous steel head of this battle axe puts considerable heft behind each stroke.", 0.8, 1, 1.5)
voxeldungeon.tools.weaponify("default:sword_diamond", 4, "A medium-sized weapon made from pure diamond, ready-made to deal heavy damage to your foes.", 
							{sword = 1})

voxeldungeon.tools.register_weapon("greatsword", "Great Sword", 5, "This towering blade inflicts heavy damage by investing its heft into every swing.")
voxeldungeon.tools.register_weapon("glaive", "Glaive", 5, "A polearm consisting of a sword blade on the end of a pole.", 1.333, 1.5)
voxeldungeon.tools.register_weapon("warhammer", "Warhammer", 5, "Few creatures can withstand the crushing blow of this towering mass of lead and steel, "..
								"but it takes great strength to use effectively.", 0.8, 1, 1.5)
voxeldungeon.tools.register_weapon("sword_demonite", "Demonite Sword", 5, "A deceptively heavy blade carved from shadowy demonite. Despite its size, "..
									"it has the potential to become one of the finest blades ever crafted.")



minetest.register_on_craft(function(itemstack)
	if minetest.get_item_group(itemstack:get_name(), "weapon") > 0 then
		voxeldungeon.tools.updateDescriptionWeapon(itemstack)
		return itemstack
	elseif minetest.get_item_group(itemstack:get_name(), "armor_torso") > 0 then 
		voxeldungeon.tools.updateDescriptionArmor(itemstack)
		return itemstack
	end
end)
