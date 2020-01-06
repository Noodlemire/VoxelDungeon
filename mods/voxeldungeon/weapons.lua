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

voxeldungeon.weapons = {} --global variable



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

function voxeldungeon.weapons.updateDescription(weapon)
	local meta = weapon:get_meta()
	local level = meta:get_int("voxeldungeon:level")
	local augment = meta:get_string("voxeldungeon:augment")

	local def = weapon:get_definition()
	local tier = def._tier
	local info = def._info
	local dly = def.tool_capabilities.full_punch_interval
	local dur = def._durabilityMultiplier or 1

	local damage = getDamageOf(weapon)
	local strreq = voxeldungeon.tools.getStrengthRequirementOf(weapon)

	local dlyString = ""
	if dly > 1 then dlyString = "\n \nThis is a rather slow weapon."
	elseif dly < 1 then dlyString = "\n \nThis is a rather fast weapon."
	end

	local durString = ""
	if dur > 1 then durString = "\n \nThis is a rather durable weapon."
	elseif dur < 1 then durString = "\n \nThis is a rather fragile weapon."
	end

	local augString = ""
	if augment and augment ~= "" then 
		augString = "\n \nIt has been augmented to increase its "..augment.."."
	end

	local strTip = "\n \nHaving excess strength with this weapon will let you deal bonus damage with it, "..
			"while lacking strength will greatly reduce your attack speed."
	
	meta:set_string("description", voxeldungeon.utils.itemDescription(voxeldungeon.utils.itemShortDescription(weapon).."\n \n"..info.. 
								"\n \nThis tier-"..tier.." weapon deals "..damage.." damage and requires "..strreq..
								" points of strength to wield properly."..dlyString..durString..augString..strTip))
end

function voxeldungeon.weapons.on_use(itemstack, user, pointed_thing)
	if pointed_thing.type == "object" then
		local target = pointed_thing.ref
		local toolcap = itemstack:get_tool_capabilities()
		local strdiff = voxeldungeon.playerhandler.getSTR(user) - voxeldungeon.tools.getStrengthRequirementOf(itemstack)
		local augment = itemstack:get_meta():get_string("voxeldungeon:augment")
		local def = itemstack:get_definition()
		local wear = math.floor(65535 / (1000 / def._durabilityPerUse * def._durabilityMultiplier))

		toolcap.damage_groups = {fleshy = getDamageOf(itemstack) + math.floor(math.max(0, strdiff) / 2)}
		toolcap.full_punch_interval = toolcap.full_punch_interval * math.max(1, -strdiff + 1)

		if augment == "speed" then
			toolcap.full_punch_interval = toolcap.full_punch_interval * 0.667
			wear = voxeldungeon.utils.round(wear * 1.333)
		elseif augment == "durability" then
			toolcap.full_punch_interval = toolcap.full_punch_interval * 1.333
			wear = voxeldungeon.utils.round(wear * 0.667)
		end

		itemstack:add_wear(wear)

		return itemstack, toolcap
	end
end

local function register_weapon(name, def) --desc, tier, info, damage, delay, durability, tooltype)
	def._info = def._info or "!!!NO TEXT FOUND!!!"

	def._durabilityPerUse = (6 - def._tier)
	def._damageMultiplier = def._damageMultiplier or 1
	def._durabilityMultiplier = def._durabilityMultiplier or 1

	def.inventory_image = "voxeldungeon_tool_weapon_"..name..".png"

	def.tool_capabilities = {
		full_punch_interval = def._delay or 1,
		damage_groups = {fleshy = 0},
		max_drop_level = math.ceil(def._tier / 2),
		groupcaps = {},
	}

	if def._tooltype == "sword" then
		def.tool_capabilities.groupcaps.snappy = {
			times = {
				[1] = 3 - def._tier * 0.25, 
				[2] = 1.5 - def._tier * 0.1, 
				[3] = 0.4 - def._tier * 0.025
			},
			uses = 1000 / def._durabilityPerUse * def._durabilityMultiplier,
			maxlevel = math.ceil(def._tier / 2)
		}
	elseif def._tooltype == "axe" then
		def.tool_capabilities.groupcaps.choppy = {
			times = {
				[1] = 3 - def._tier * 0.25, 
				[2] = 1.5 - def._tier * 0.1, 
				[3] = 0.4 - def._tier * 0.025
			},
			1000 / def._durabilityPerUse * def._durabilityMultiplier,
			maxlevel = math.ceil(def._tier / 2)
		}
	end

	def.sound = {breaks = "default_tool_breaks"}
	def.groups = {weapon = 1, upgradable = 1}

	minetest.register_tool("voxeldungeon:weapon_"..name, def)
end

local function weaponify(name, tier, info, groups)
	groups.upgradable = groups.upgradable or 1
	groups.weapon = 1

	minetest.override_item(name, {
		groups = groups,

		tool_capabilities = 
		{
			full_punch_interval = 1,
			damage_groups = {fleshy = 0},
			max_drop_level = math.ceil(tier / 2),
			groupcaps = {
				snappy = {
					times = {
						[1] = 3 - tier * 0.25, 
						[2] = 1.5 - tier * 0.1, 
						[3] = 0.4 - tier * 0.025
					},
					uses = 1000 / (6 - tier), 
					maxlevel = math.ceil(tier / 2)
				},
			},
		},

		_info = info,
		_tier = tier,
		_damageMultiplier = 1,
		_durabilityPerUse = (6 - tier),
		_durabilityMultiplier = 1
	})
end



--Tier 0

weaponify("default:sword_wood", 0, "Little more than a stick carved into the shape of a sword, it's more often used for training "..
							"rather than combat.\n \nUnlike most other weapons, it is too weak to hold upgrades or magic.", 
							{sword = 1, upgradable = 0})



--Tier 1

register_weapon("shortsword", {
	description = "Short Sword",
	_info = "It is indeed quite short, being just a few inches longer than a dagger.",

	_tier = 1,
	_tooltype = "sword",
})

register_weapon("knuckleduster", {
	description = "Knuckleduster",
	_info = "A piece of iron shaped to fit around the knuckles.",

	_tier = 1,
	_delay = 0.667,
	_damageMultiplier = 0.5,
})

register_weapon("dagger", {
	description = "Dagger",
	_info = "A simple iron dagger with a well worn wooden handle.",

	_tier = 1,
	_damageMultiplier = 0.8,
	_durabilityMultiplier = 1.5,
	_tooltype = "sword",
})

weaponify("default:sword_stone", 1, "A sturdy but somewhat dull blade of stone.", {sword = 1})



--Tier 2

register_weapon("quarterstaff", {
	description = "Quarterstaff",
	_info = "A staff of hardwood, its ends are shod with iron.",

	_tier = 2,
})

register_weapon("spear", {
	description = "Spear",
	_info = "A slender wooden rod tipped with sharpened iron.",

	_tier = 2,
	_delay = 1.333,
	_damageMultiplier = 1.5,
})

register_weapon("handaxe", {
	description = "Hand Axe",
	_info = "A light axe, most commonly used for felling trees. The wide blade works well against foes as well.",

	_tier = 2,
	_damageMultiplier = 0.8,
	_durabilityMultiplier = 1.5,
	_tooltype = "axe",
})

weaponify("default:sword_steel", 2, "A hand-crafted blade of solid steel. It isn't the best sword ever made, but it's yours.", {sword = 1})



--Tier 3

register_weapon("sword", {
	description = "Sword",
	_info = "A nicely balanced sword. Not too large, but still notably longer than a shortsword.",

	_tier = 3,
	_tooltype = "sword",
})

register_weapon("scimitar", {
	description = "Scimitar",
	_info = "A thick curved blade. Its shape allows for faster, yet less powerful attacks.",

	_tier = 3,
	_delay = 0.8,
	_damageMultiplier = 0.75,
	_tooltype = "sword",
})

register_weapon("mace", {
	description = "Mace",
	_info = "The iron head of this weapon inflicts substantial damage.",

	_tier = 3,
	_damageMultiplier = 0.8,
	_durabilityMultiplier = 1.5,
})

weaponify("default:sword_mese", 3, "A crystalline sword forged from mese, complete with a fine (if uneven) cutting edge.", {sword = 1})



--Tier 4

register_weapon("longsword", {
	description = "Long Sword",
	_info = "This sword's long, razor-sharp blade shines reassuringly, though its size does make it quite heavy.",

	_tier = 4,
	_tooltype = "sword",
})

register_weapon("stonegauntlet", {
	description = "Stone Guantlet",
	_info = "This massive gauntlet is made of golden fabric with heavy magical stone layered on top. The fabric tightens around you, making the thick stone plates almost like a second skin. Swinging such a heavy weapon requires strength, but adds tremendous force to your blows.",

	_tier = 4,
	_delay = 0.667,
	_damageMultiplier = 0.5,
})

register_weapon("battleaxe", {
	description = "Battle Axe",
	_info = "The enormous steel head of this battle axe puts considerable heft behind each stroke.",

	_tier = 4,
	_damageMultiplier = 0.8,
	_durabilityMultiplier = 1.5,
	_tooltype = "axe",
})

weaponify("default:sword_diamond", 4, "A medium-sized weapon made from pure diamond, ready-made to deal heavy damage to your foes.", {sword = 1})



--Tier 5

register_weapon("greatsword", {
	description = "Great Sword",
	_info = "This towering blade inflicts heavy damage by investing its heft into every swing.",

	_tier = 5,
	_tooltype = "sword",
})

register_weapon("glaive", {
	description = "Glaive",
	_info = "A polearm consisting of a sword blade on the end of a pole.",

	_tier = 5,
	_delay = 1.333,
	_damageMultiplier = 1.5,
})

register_weapon("warhammer", {
	description = "Warhammer",
	_info = "Few creatures can withstand the crushing blow of this towering mass of lead and steel, but it takes great strength to use effectively.",

	_tier = 5,
	_damageMultiplier = 0.8,
	_durabilityMultiplier = 1.5,
})

register_weapon("sword_demonite", {
	description = "Demonite Sword",
	_info = "A deceptively heavy blade carved from shadowy demonite. Despite its size, it has the potential to become one of the finest blades ever crafted.",

	_tier = 5,
	_tooltype = "sword",
})
