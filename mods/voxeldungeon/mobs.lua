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

voxeldungeon.mobs = {}



function voxeldungeon.mobs.health(mob)
	local obj = mob.object or mob
	local lua = mob:get_luaentity() or mob

	if lua.health then
		obj:set_hp(lua.health)
		return lua.health
	else
		return obj:get_hp()
	end
end

function voxeldungeon.mobs.damage(mob, amount, cause)
	local obj = mob.object or mob
	local lua = mob:get_luaentity() or mob
	local orig_hp = voxeldungeon.mobs.health(mob)

	obj:set_hp(orig_hp - amount)
	if lua.health then
		lua.health = orig_hp - amount
		lua:check_for_death({type = cause})
	end
end



--sewers/surface

--rat: 8 hp, damage = 3, armor = 1 (albino: 15 hp, bleed)
mobs:register_mob("voxeldungeon:rat", {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	pathfinding = true,
	reach = 2,
	damage = 3,
	hp_min = 8,
	hp_max = 8,
	armor = 100,
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
	visual = "sprite",
	textures = {"voxeldungeon_icon_mob_rat.png"},
	makes_footstep_sound = true,
	walk_velocity = 1.9,
	run_velocity = 3.8,
	jump = true,
	floats = 1,
	view_range = 10,
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	lifetimer = 20000,
})
mobs:register_egg("voxeldungeon:rat", "Marsupial Rat", "voxeldungeon_icon_mob_rat.png", 1)

--scout: 12 hp, damage = 4, armor = 2, drop = gold
mobs:register_mob("voxeldungeon:scout", {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	pathfinding = true,
	reach = 2,
	damage = 4,
	hp_min = 12,
	hp_max = 12,
	armor = 98,
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
	visual = "sprite",
	textures = {"voxeldungeon_icon_mob_scout.png"},
	makes_footstep_sound = true,
	walk_velocity = 1.9,
	run_velocity = 3.8,
	jump = true,
	floats = 1,
	view_range = 10,
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	lifetimer = 20000,
	drops = {{name = "voxeldungeon:gold", chance = 2, min = 30, max = 120}}
})
mobs:register_egg("voxeldungeon:scout", "Gnoll Scout", "voxeldungeon_icon_mob_scout.png", 1)

--crab: 15 hp, damage = 5, armor = 4, moveSpeed = 2, drop = meat
mobs:register_mob("voxeldungeon:crab", {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	pathfinding = true,
	reach = 2,
	damage = 5,
	hp_min = 15,
	hp_max = 15,
	armor = 96,
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
	visual = "sprite",
	textures = {"voxeldungeon_icon_mob_crab.png"},
	makes_footstep_sound = true,
	walk_velocity = 3.8,
	run_velocity = 7.6,
	jump = true,
	floats = 1,
	view_range = 10,
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	lifetimer = 20000,
	drops = {{name = "voxeldungeon:mystery_meat", chance = 6, min = 1, max = 1}}
})
mobs:register_egg("voxeldungeon:crab", "Sewer Crab", "voxeldungeon_icon_mob_crab.png", 1)

entitycontrol.override_entity("mobs_monster:dirt_monster", {
	hp_max = 10,
	hp_min = 10,

	damage = 2,

	walk_velocity = 1.9,
	run_velocity = 3.8,

	lifetimer = 20000,

	mesh = "mobs_stone_monster.b3d",
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 1.3, 0.4},
})

entitycontrol.override_entity("mobs_monster:sand_monster", {
	hp_max = 12,
	hp_min = 12,

	damage = 1,

	walk_velocity = 3,
	run_velocity = 5.5,

	lifetimer = 20000,

	mesh = "mobs_sand_monster.b3d",
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 1.3, 0.4},
})

entitycontrol.override_entity("mobs_monster:tree_monster", {
	hp_max = 12,
	hp_min = 12,

	damage = 2,

	walk_velocity = 1.9,
	run_velocity = 3.8,

	lifetimer = 20000,

	mesh = "mobs_stone_monster.b3d",
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 1.4, 0.4},
})



--prisons

--thief: 20 hp, damage = 4, armor = 3, attackSpeed = 2, steals, drops gold while running (bandit: blinds when stealing)

--swarm: 80 hp, damage = 2, armor = 0, flies, splits in half when hit, drop = potion of healing

--skeleton: 25 hp, damage = 6, armor = 5, bone explosion on death, drop = weapon

--shaman: 18 hp, damage = 4, armor = 4, lightning ranged attack with 7 magic damage, drop = scroll

entitycontrol.override_entity("mobs_monster:spider", {
	hp_max = 20,
	hp_min = 20,

	damage = 5,

	walk_velocity = 1.9,
	run_velocity = 3.8,

	lifetimer = 20000,
})



--caves

--brute: 40 hp, damage = 13, armor = 8, becomes enraged at 25% health and deals 25 damage, drop = gold (shielded: armor = 16)

--bat: 30 hp, damage = 9, armor = 4, heals after each attack, flies, moveSpeed = 2, drop = potion of healing

--spinner: 50 hp, damage = 14, armor = 6, may poison and flee with a web trail after each attack, drop = meat

entitycontrol.override_entity("mobs_monster:mese_monster", {
	hp_max = 28,
	hp_min = 28,

	damage = 6,

	walk_velocity = 1.9,
	run_velocity = 5,

	lifetimer = 20000,

	mesh = "zmobs_mese_monster.x",
	collisionbox = {-0.5, -0.5, -0.5, 0.5, 1.5, 0.5},
})

entitycontrol.override_entity("mobs_monster:mese_arrow", {
	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 12},
		}, nil)
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {fleshy = 12},
		}, nil)
	end,
})

entitycontrol.override_entity("mobs_monster:stone_monster", {
	hp_max = 34,
	hp_min = 34,

	damage = 10,

	walk_velocity = 1.9,
	run_velocity = 3,

	lifetimer = 20000,

	mesh = "mobs_stone_monster.b3d",
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 1.4, 0.4},
})



--cities

--monk: 70 hp, damage = 14, armor = 2, attackSpeed = 2, may force player to drop help item after each attack, drop = ration (senior: paralyzes on hit also)

--warlock: 70 hp, damage = 16, armor = 8, uses ranged shadow bolt attack that weakens its target and deals 15 magic damage, drop = potion

--elemental: 65 hp, damage = 18, armor = 5, flies, weakness to cold and water, may ignite players after each attack

--golem: 85 hp, damage = 30, armor = 12, attackSpeed = 0.667

entitycontrol.override_entity("mobs_monster:oerkki", {
	hp_max = 81,
	hp_min = 81,

	damage = 15,

	walk_velocity = 1.9,
	run_velocity = 3.8,

	runaway = false,

	lifetimer = 20000,

	mesh = "mobs_oerkki.b3d",
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 1.4, 0.4},
})

entitycontrol.override_entity("mobs_monster:lava_flan", {
	hp_max = 72,
	hp_min = 72,

	damage = 16,

	walk_velocity = 1,
	run_velocity = 2,

	lifetimer = 20000,

	mesh = "zmobs_lava_flan.x",
	collisionbox = {-0.5, -0.5, -0.5, 0.5, 1.5, 0.5},
})



--halls

--eye: 100 hp, damage = 25, armor = 10, flies, sometimes charges up for a "deathgaze" laser attack that deals 50 magic damage, drop = dew

--succubus: 80 hp, damage = 20, armor = 10, can teleport, may charm players after each attack, drop = scroll of lullaby

--scorpio: 95 hp, damage = 26, armor = 16, only uses ranged attacks, always runs if its target is in melee range, drops meat or potions of healing

entitycontrol.override_entity("mobs_monster:dungeon_master", {
	hp_max = 95,
	hp_min = 95,

	damage = 26,

	walk_velocity = 1.9,
	run_velocity = 3.8,

	lifetimer = 20000,

	mesh = "mobs_dungeon_master.b3d",
	collisionbox = {-0.7, -0.5, -0.7, 0.7, 2.1, 0.7},
})

entitycontrol.override_entity("mobs_monster:fireball", {
	-- if player has a good weapon with 50+ damage it can deflect fireball
	on_punch = function(self, hitter, tflp, tool_capabilities, dir)

		if hitter and hitter:is_player() and tool_capabilities and dir then

			local damage = tool_capabilities.damage_groups and
				tool_capabilities.damage_groups.fleshy or 1

			local tmp = tflp / (tool_capabilities.full_punch_interval or 1.4)

			if damage > 50 and tmp < 4 then

				self.object:set_velocity({
					x = dir.x * self.velocity,
					y = dir.y * self.velocity,
					z = dir.z * self.velocity,
				})
			end
		end
	end,

	-- direct hit, no fire... just plenty of pain
	hit_player = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {magic = 28},
		}, nil)
	end,

	hit_mob = function(self, player)
		player:punch(self.object, 1.0, {
			full_punch_interval = 1.0,
			damage_groups = {magic = 28},
		}, nil)
	end,
})



--special mobs, with abnormal spawn conditions

mobs:register_mob("voxeldungeon:bee", {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	pathfinding = true,
	reach = 2,
	damage = 1,
	hp_min = 1,
	hp_max = 1,
	armor = 100,
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
	visual = "sprite",
	textures = {"voxeldungeon_icon_mob_bee.png"},
	makes_footstep_sound = true,
	walk_velocity = 1.9,
	run_velocity = 3.8,
	jump = true,
	floats = 1,
	view_range = 10,
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	lifetimer = 20000,
	fly = true,
	attack_monsters = true,
	attack_animals = true,
	attack_npcs = true,
	attack_players = true,
	attack_chance = 0,

	on_spawn = function(self)
		local pos = self.object:get_pos()
		local level = voxeldungeon.utils.getDepth(pos)
		local HT = (2 + level) * 4

		self.hp_max = HT
		self.health = HT

		self.damage = math.floor(HT) / 7

		--self.home = pos

		self.object:set_properties(self)

		return true
	end,
})

mobs:register_mob("voxeldungeon:mimic", {
	type = "monster",
	passive = false,
	attack_type = "dogfight",
	pathfinding = true,
	reach = 2,
	damage = 1,
	hp_min = 1,
	hp_max = 1,
	armor = 100,
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
	visual = "sprite",
	textures = {"voxeldungeon_icon_mob_mimic.png"},
	makes_footstep_sound = true,
	walk_velocity = 1.9,
	run_velocity = 3.8,
	jump = true,
	view_range = 10,
	water_damage = 0,
	lava_damage = 4,
	light_damage = 0,
	lifetimer = 20000,

	on_spawn = function(self)
		local level = voxeldungeon.utils.getDepth(self.object:get_pos())
		local HT = (3 + level) * 4

		self.hp_max = HT
		self.health = HT

		self.damage = math.floor(HT) / 7

		self.object:set_properties(self)

		return true
	end,

	on_die = function(self, pos)
		self.object:remove()
		local tier = voxeldungeon.utils.getChapter(pos)

		for i = 1, math.random(6, 12) do
			minetest.add_item(pos, voxeldungeon.generator.random(tier))
		end
	end,
})
mobs:register_egg("voxeldungeon:mimic", "Mimic", "voxeldungeon_node_chest_icon.png", 1)



--The setting "mobs_spawn" is set to false not because mobs don't spawn, 
--but because the following method is used to spawn them instead of what mobs_redo provides.

local function register_spawning(depth, valid_ground, mobTable)
	minetest.register_abm({
		label = "spawning_"..(depth or "anywhere"),
		nodenames = valid_ground,
		interval = 30,
		chance = 2500,
		catch_up = false,

		action = function(pos, node, active_object_count, active_object_count_wider)
			--do not spawn if too many entities in area
			if active_object_count_wider >= 50 then
				return
			end

			--spawn above node
			pos.y = pos.y + 1.5

			--ensure that spawning occurs at the correct depth
			local curDepth = voxeldungeon.utils.getDepth(pos)
			if depth ~= nil and (curDepth < depth - 1 or curDepth > depth + 1) then
				return
			end

			--only spawn in dark areas
			local light = minetest.get_node_light(pos)
			if not light or light > 7 then
				return
			end

			--only spawn away from player
			local objs = minetest.get_objects_inside_radius(pos, 10)
			for n = 1, #objs do
				if objs[n]:is_player() then
					return
				end
			end

			local mobName = voxeldungeon.utils.randomChances(mobTable)

			--do we have enough height clearance to spawn mob?
			local ent = minetest.registered_entities[mobName]
			local height = math.max(1, math.ceil((ent.collisionbox[5] or 0.25) - (ent.collisionbox[2] or -0.25) - 1))
			for n = 0, height do
				local pos2 = {x = pos.x, y = pos.y + n, z = pos.z}
				if voxeldungeon.utils.solid(pos2) then
					return
				end
			end

			--mobs cannot spawn in protected areas when enabled
			if not spawn_protected and minetest.is_protected(pos, "") then
				return
			end

			minetest.add_entity(pos, mobName)
		end
	})
end

register_spawning(nil, voxeldungeon.utils.surface_valid_ground, {
	["mobs_monster:dirt_monster"] = 5,
	["mobs_monster:sand_monster"] = 3,
	["mobs_monster:tree_monster"] = 3,
	["voxeldungeon:rat"] = 1
})

register_spawning(1, voxeldungeon.utils.sewers_valid_ground, {
	["mobs_monster:dirt_monster"] = 2,
	["mobs_monster:sand_monster"] = 1,
	["voxeldungeon:rat"] = 10,
})

register_spawning(3, voxeldungeon.utils.sewers_valid_ground, {
	["mobs_monster:dirt_monster"] = 1,
	["voxeldungeon:rat"] = 5,
	["voxeldungeon:scout"] = 6,
})

register_spawning(5, voxeldungeon.utils.sewers_valid_ground, {
	["voxeldungeon:rat"] = 1,
	["voxeldungeon:scout"] = 2,
	["voxeldungeon:crab"] = 3,
})
