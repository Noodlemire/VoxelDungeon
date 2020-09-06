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



entitycontrol.registerTrackingList("mobs", {
	"voxeldungeon:rat", "voxeldungeon:albino", "voxeldungeon:scout", "voxeldungeon:crab", 
	"voxeldungeon:dirt_monster", "voxeldungeon:sand_monster", "voxeldungeon:tree_monster",

	"voxeldungeon:thief", "voxeldungeon:skeleton",
	"voxeldungeon:spider",

	"voxeldungeon:bee", "voxeldungeon:mimic", "voxeldungeon:sheep"
})



--mob utility functions

function voxeldungeon.mobs.health(mob)
	local obj = mob.object or mob
	local lua = mob:get_luaentity() or mob

	if lua.hp then
		return lua.hp
	elseif lua.health then
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

	if lua.hp then
		mobkit.hurt(lua, amount)
	else
		if lua.health then
			lua.health = orig_hp - amount
			lua:check_for_death({type = cause})
		end

		obj:set_hp(orig_hp - amount)
	end
end

function voxeldungeon.mobs.spawn_multiple(mob, pos, amount, range)
	pos = vector.round(pos)
	range = range or 1

	for a = -range, range do 
		for b = -range, range do 
			for c = -range, range do
				if a == -range or a == range or b == -range or b == range or c == -range or c == range then
					local offpos = vector.add(pos, {x=a, y=b, z=c})

					if math.random(3) == 1 and not voxeldungeon.utils.solid(offpos) and
							#voxeldungeon.utils.getLivingInArea(offpos, 0.5, true) == 0 then
						minetest.add_entity(offpos, mob)
						amount = amount - 1

						if amount <= 0 then
							return
						end
					end
				end
			end 
		end 
	end

	voxeldungeon.mobs.spawn_multiple(mob, pos, amount, range + 1)
end

local function register_mob(name, def)
	def.physical = true
	def.collide_with_objects = true
	def.visual = def.visual or "sprite"
	def.timeout = 0
	def.buoyancy = def.buoyancy or 0.75
	def.lung_capacity = def.lung_capacity or 10
	def.view_range = def.view_range or 10
	def.jump_height = def.jump_height or 1
	def.max_speed = def.max_speed or 4
	def.attack.range = 1.5
	def.attack.full_punch_interval = def.attack.full_punch_interval or 1
	def.armor = def.armor or 0

	def.on_step = function(self, dtime, moveresult)
		mobkit.stepfunc(self, dtime)
		if def._on_step then def._on_step(self, dtime, moveresult) end

		local pos = self.object:get_pos()
		if not pos then return end
		pos.y = pos.y + 0.5

		if #voxeldungeon.utils.getPlayersInArea(pos, 100) > 0 then
			local id = entitycontrol.get_entity_id("mobs", self) or "nil"
			local nametag = self.description

			if not self.groups or not self.groups.immortal then
				nametag = nametag..'\n'..self.hp.." / "..self.max_hp.." HP"
			end
--[[
			for b, _ in pairs(voxeldungeon.buffs.registered_buffs) do
				local buff = voxeldungeon.buffs.get_buff(b, self)

				if buff then
					nametag = nametag..'\n'..b..": "..buff.left()
				end
			end
--]]
			self.object:set_nametag_attributes({color = "#FFFFFF", text = nametag})
		else
			self.object:set_nametag_attributes({color = "#FFFFFF", text = ""})
		end
	end

	def.on_activate = function(self, staticdata, dtime_s)
		mobkit.actfunc(self, staticdata, dtime_s)
		if def._on_activate then def._on_activate(self, staticdata, dtime_s) end

		if self.hp <= 0 then
			self.object:remove()
			return
		end

		minetest.after(1, function()
			for b, _ in pairs(voxeldungeon.buffs.registered_buffs) do
				local id = entitycontrol.get_entity_id("mobs", self)

				if id then
					local num = voxeldungeon.storage.getNum(b.."_"..id)

					if num and num > 0 then
						voxeldungeon.buffs.attach_buff(b, self, num)
					end
				end
			end
		end)
	end

	def.get_staticdata = mobkit.statfunc

	def.brainfunc = def.brainfunc or voxeldungeon.mobkit.landBrain

	def.on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if (self.groups and self.groups.immortal) or voxeldungeon.playerhandler.isParalyzed(puncher) then return end

		if mobkit.is_alive(self) then
			if puncher:is_player() then
				local weapon = puncher:get_wielded_item()
				time_from_last_punch = voxeldungeon.playerhandler.getTimeFromLastPunch(puncher)

				if minetest.get_item_group(weapon:get_name(), "weapon") > 0 then
					weapon, tool_capabilities = voxeldungeon.weapons.on_use(weapon, puncher, self.object, time_from_last_punch)
					minetest.after(0, function() puncher:set_wielded_item(weapon) end)
				end
			end

			local damage = voxeldungeon.utils.round(math.max(0, (tool_capabilities.damage_groups.fleshy or 1) 
				* math.min(1, time_from_last_punch / (tool_capabilities.full_punch_interval or 1))
				- self.armor))
			
			mobkit.hurt(self, damage)

			voxeldungeon.utils.on_punch_common(self.object, puncher, time_from_last_punch, tool_capabilities, dir, damage)

			if self.paralysis == 0 then
				local hvel = vector.multiply(vector.normalize({x=dir.x,y=0,z=dir.z}),4)
				self.object:set_velocity({x=hvel.x,y=2,z=hvel.z})
			end

			--if attacked while not running away, or taken to low enough health, get revenge
			if not mobkit.recall(self, "fleeing") or self.hp / self.max_hp <= 0.25 then
				if mobkit.recall(self, "fleeing") then
					mobkit.forget(self, "fleeing")
					voxeldungeon.buffs.detach_buff("voxeldungeon:terror", self)
				end

				mobkit.clear_queue_high(self)
				mobkit.hq_hunt(self, 10, puncher)
			end

			if def._on_punch then def._on_punch(self, puncher, time_from_last_punch, tool_capabilities, dir) end

			voxeldungeon.particles.burst(voxeldungeon.particles.blood, self.object:get_pos(), 5, {
				color = def._blood, 
				angle = vector.direction(puncher:get_pos(), self.object:get_pos())
			})
		end
	end

	def.on_rightclick = function(self, clicker)
		local item = clicker:get_wielded_item()
		if item and not item:is_empty() then
			local rc = minetest.registered_items[item:get_name()].on_secondary_use

			if rc then
				rc(item, clicker, {type="object", ref=self.object})
			end
		end
	end

	def.on_blast = def.on_blast or function(self, damage)
		mobkit.hurt(self, damage)
		local drops = voxeldungeon.mobkit.HPChecks(self) or {}

		return false, true, drops
	end

	minetest.register_entity("voxeldungeon:"..name, def)
end



--sewers/surface

--rat: 8 hp, damage = 3, armor = 1 (albino: 15 hp, bleed)
register_mob("rat", {
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
	textures = {"voxeldungeon_icon_mob_rat.png"},

	description = "marsupial rat",
	alignment = "evil",
	max_hp = 8,
	attack = {damage_groups = {fleshy = 3}},

	_on_activate = function(self, staticdata, dtime_s)
		if not mobkit.recall(self, "init") and math.random(30) == 1 then
			minetest.add_entity(self.object:get_pos(), "voxeldungeon:albino")
			self.object:remove()
		else
			mobkit.remember(self, "init", true)
		end
	end
})
mobs:register_egg("voxeldungeon:rat", "Marsupial Rat", "voxeldungeon_icon_mob_rat.png", 1)

register_mob("albino", {
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
	textures = {"voxeldungeon_icon_mob_albino.png"},

	description = "albino rat",
	alignment = "evil",
	max_hp = 15,
	attack = {damage_groups = {fleshy = 3}},

	_attackProc = function(self, target, damage)
		if math.random(3) == 1 then
			voxeldungeon.buffs.attach_buff("voxeldungeon:bleeding", target, damage)
		end

		return damage
	end
})
mobs:register_egg("voxeldungeon:albino", "Albino Rat", "voxeldungeon_icon_mob_albino.png", 1)

--scout: 12 hp, damage = 4, armor = 2, drop = gold
register_mob("scout", {
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
	textures = {"voxeldungeon_icon_mob_scout.png"},

	description = "gnoll scout",
	alignment = "evil",
	max_hp = 12,
	attack = {damage_groups = {fleshy = 4}},
	armor = 1,
	_drops = {{name = "voxeldungeon:gold", chance = 0.5, min = 30, max = 120}}
})
mobs:register_egg("voxeldungeon:scout", "Gnoll Scout", "voxeldungeon_icon_mob_scout.png", 1)

--crab: 15 hp, damage = 5, armor = 4, moveSpeed = 2, drop = meat
register_mob("crab", {
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
	textures = {"voxeldungeon_icon_mob_crab.png"},

	description = "sewer crab",
	alignment = "evil",
	max_hp = 15,
	attack = {damage_groups = {fleshy = 5}},
	armor = 2,
	max_speed = 8,
	_drops = {{name = "voxeldungeon:mystery_meat", chance = 0.167, min = 1, max = 1}}
})
mobs:register_egg("voxeldungeon:crab", "Sewer Crab", "voxeldungeon_icon_mob_crab.png", 1)

register_mob("dirt_monster", {
	visual = "mesh",
	mesh = "mobs_stone_monster.b3d",
	collisionbox = {-0.4, -1, -0.4, 0.4, 0.8, 0.4},
	textures = {"mobs_dirt_monster.png"},
	_blood = {r = 47, g = 33, b = 0},

	description = "dirt monster",
	alignment = "evil",
	max_hp = 10,
	attack = {damage_groups = {fleshy = 2}},
	_drops = {{name = "default:dirt", chance = 0.667, min = 1, max = 2}},

	animation = {
		["stand"] = {range = {x = 0, y = 14}, speed = 15, loop = true},
		["walk"] = {range = {x = 15, y = 38}, speed = 100, loop = true},
		["punch"] = {range = {x = 40, y = 63}, speed = 15, loop = false},
	},
	sounds = {["charge"] = "mobs_dirtmonster"}
})
mobs:register_egg("voxeldungeon:dirt_monster", "Dirt Monster", "default_dirt.png", 1)

register_mob("sand_monster", {
	visual = "mesh",
	mesh = "mobs_sand_monster.b3d",
	collisionbox = {-0.4, -1, -0.4, 0.4, 0.8, 0.4},
	textures = {"mobs_sand_monster.png"},
	_blood = {r = 232, g = 201, b = 108},

	description = "sand monster",
	alignment = "evil",
	max_hp = 12,
	attack = {damage_groups = {fleshy = 2}},
	_drops = {{name = "default:desert_sand", chance = 1, min = 3, max = 5}},

	animation = {
		["stand"] = {range = {x = 0, y = 39}, speed = 15, loop = true},
		["walk"] = {range = {x = 41, y = 72}, speed = 100, loop = true},
		["punch"] = {range = {x = 74, y = 105}, speed = 15, loop = false},
	},
	sounds = {["charge"] = "mobs_sandmonster"}
})
mobs:register_egg("voxeldungeon:sand_monster", "Sand Monster", "default_desert_sand.png", 1)

register_mob("tree_monster", {
	visual = "mesh",
	mesh = "mobs_tree_monster.b3d",
	collisionbox = {-0.4, -1, -0.4, 0.4, 0.8, 0.4},
	textures = {"mobs_tree_monster.png"},
	_blood = {r = 234, g = 208, b = 156},

	description = "tree monster",
	alignment = "evil",
	max_hp = 12,
	attack = {damage_groups = {fleshy = 2}},
	_drops = {
		{name = "default:stick", chance = 0.667, min = 1, max = 2},
		{name = "default:sapling", chance = 0.333, min = 1, max = 2},
		{name = "default:junglesapling", chance = 0.167, min = 1, max = 2},
		{name = "default:apple", chance = 0.25, min = 1, max = 2},
	},

	animation = {
		["stand"] = {range = {x = 0, y = 24}, speed = 15, loop = true},
		["walk"] = {range = {x = 25, y = 47}, speed = 100, loop = true},
		["punch"] = {range = {x = 48, y = 62}, speed = 15, loop = false},
	},
	sounds = {["charge"] = "mobs_treemonster"}
})
mobs:register_egg("voxeldungeon:tree_monster", "Tree Monster", "default_wood.png", 1)



--prisons

--thief: 20 hp, damage = 4, armor = 3, attackSpeed = 2, steals, drops gold while running (bandit: blinds when stealing)
register_mob("thief", {
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
	textures = {"voxeldungeon_icon_mob_thief.png"},

	description = "crazy thief",
	alignment = "evil",
	max_hp = 20,
	attack = {damage_groups = {fleshy = 4}},
	armor = 1,
	undead = true,

	_steal = function(self, player) 
		local item = voxeldungeon.utils.randomItem(player:get_inventory())

		if item then
			voxeldungeon.glog.w("The crazy thief stole "..voxeldungeon.utils.itemShortDescription(item).." from you!")
			voxeldungeon.utils.take_item(player, item)

			item:set_count(1)
			mobkit.remember(self, "stolen", item:to_string())

			return true
		else
			return false
		end
	end,

	_attackProc = function(self, target, damage)
		local def = minetest.registered_entities[self.name]

		if not mobkit.recall(self, "stolen") and target:is_player() and self._steal(self, target) then
			voxeldungeon.mobkit.runfrom(self, target)
		end

		return damage
	end,

	_on_punch = function(self, puncher, time_from_last_punch, tool_capabilities, dir)
		if mobkit.recall(self, "fleeing") then
			minetest.add_item(self.object:get_pos(), ItemStack("voxeldungeon:gold"))
		end
	end,

	_on_death = function(self)
		local item = mobkit.recall(self, "stolen")
		if item then
			minetest.add_item(self.object:get_pos(), ItemStack(item))
		end
	end
})
mobs:register_egg("voxeldungeon:thief", "Crazy Thief", "voxeldungeon_icon_mob_thief.png", 1)

--swarm: 80 hp, damage = 2, armor = 0, flies, splits in half when hit, drop = potion of healing

--skeleton: 25 hp, damage = 6, armor = 5, bone explosion on death, drop = weapon
register_mob("skeleton", {
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
	textures = {"voxeldungeon_icon_mob_skeleton.png"},
	_blood = {r = 206, g = 206, b = 206},

	description = "skeleton",
	alignment = "evil",
	max_hp = 25,
	attack = {damage_groups = {fleshy = 6}},
	armor = 3,
	_drops = {{name = voxeldungeon.generator.randomWeapon, chance = 0.167, min = 1, max = 1}},
	undead = true,

	_on_death = function(self)
		local pos = self.object:get_pos()

		local ents = entitycontrol.getEntitiesInArea("mobs", pos, 1.5, false)
		for _, ent in ipairs(ents) do
			voxeldungeon.mobs.damage(ent, 6, "bone explosion")
		end

		local players = voxeldungeon.utils.getPlayersInArea(pos, 1.5)
		for _, plr in ipairs(players) do
			voxeldungeon.mobs.damage(plr, 6, "bone explosion")
		end
	end,
})
mobs:register_egg("voxeldungeon:skeleton", "Skeleton", "voxeldungeon_icon_mob_skeleton.png", 1)

--shaman: 18 hp, damage = 4, armor = 4, lightning ranged attack with 7 magic damage, drop = scroll

register_mob("spider", {
	collisionbox = {-0.8, -0.5, -0.8, 0.8, 0, 0.8},
	visual = "mesh",
	mesh = "mobs_spider.b3d",
	collisionbox = {-0.4, -1, -0.4, 0.4, 0.8, 0.4},
	textures = {"mobs_spider_grey.png"},

	description = "spider",
	alignment = "evil",
	max_hp = 20,
	attack = {damage_groups = {fleshy = 5}},
	_drops = {{name = "farming:string", chance = 0.667, min = 1, max = 2}},

	animation = {
		["stand"] = {range = {x = 0, y = 0}, speed = 15, loop = true},
		["walk"] = {range = {x = 1, y = 21}, speed = 100, loop = true},
		["punch"] = {range = {x = 25, y = 45}, speed = 15, loop = false},
	},
	sounds = {["charge"] = "mobs_spider"}
})
mobs:register_egg("voxeldungeon:spider", "Spider", "mobs_cobweb.png", 1)



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

register_mob("bee", {
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
	textures = {"voxeldungeon_icon_mob_bee.png"},

	description = "golden bee",
	max_hp = 1,
	attack = {damage_groups = {fleshy = 1}},

	--brainfunc = voxeldungeon.mobkit.flyBrain,

	_on_activate = function(self, staticdata, dtime_s)
		local level = voxeldungeon.utils.getDepth(self.object:get_pos())
		local HT = (2 + level) * 4

		self.max_hp = HT

		if not mobkit.recall(self, "init") then
			self.hp = HT
			mobkit.remember(self, "init", true)
		end

		self.attack.damage_groups.fleshy = math.floor(HT / 7)
	end,
})

register_mob("mimic", {
	collisionbox = {-0.4, -0.5, -0.4, 0.4, 0.5, 0.4},
	textures = {"voxeldungeon_icon_mob_mimic.png"},

	description = "mimic",
	alignment = "evil",
	max_hp = 1,
	attack = {damage_groups = {fleshy = 1}},

	_on_activate = function(self, staticdata, dtime_s)
		local level = voxeldungeon.utils.getDepth(self.object:get_pos())
		local HT = (3 + level) * 4

		self.max_hp = HT

		if not mobkit.recall(self, "init") then
			self.hp = HT
			mobkit.remember(self, "init", true)
		end

		self.attack.damage_groups.fleshy = math.floor(HT / 7)
	end,

	_on_death = function(self)
		local pos = self.object:get_pos()
		local tier = voxeldungeon.utils.getChapter(pos)

		for i = 1, math.random(6, 12) do
			minetest.add_item(pos, voxeldungeon.generator.random(tier))
		end
	end
})
mobs:register_egg("voxeldungeon:mimic", "Mimic", "voxeldungeon_node_chest_icon.png", 1)

register_mob("sheep", {
	collisionbox = {-0.5, -0.5, -0.5, 0.5, 0.5, 0.5},
	textures = {"voxeldungeon_icon_mob_sheep.png"},

	description = "magic sheep",
	max_hp = 1,
	attack = {damage_groups = {fleshy = 0}},
	groups = {immortal = 1, does_nothing = 1},

	_on_activate = function(self)
		voxeldungeon.particles.burst(voxeldungeon.particles.flock, self.object:get_pos(), 3)
	end,

	_on_step = function(self, dtime)
		local timer = mobkit.recall(self, "timer") or 10
		timer = timer - dtime
		mobkit.remember(self, "timer", timer)

		if timer <= 0 then
			self.object:remove()

			tnt.boom(self.object:get_pos(), {
				radius = 2,
				damage_radius = 3
			})
		end
	end,

	on_blast = function(self, damage)
		self.object:remove()

		tnt.boom(self.object:get_pos(), {
			radius = 2,
			damage_radius = 3
		})

		return nil, nil, {}
	end
})
mobs:register_egg("voxeldungeon:sheep", "Sheep", "voxeldungeon_icon_mob_sheep.png", 1)



--The setting "mobs_spawn" is set to false not because mobs don't spawn, 
--but because the following method is used to spawn them instead of what mobs_redo provides.

local function register_spawning(depth, valid_ground, mobTable)
	minetest.register_abm({
		label = "spawning_"..(depth or "anywhere"),
		nodenames = valid_ground,
		interval = 30,
		chance = 3000,
		catch_up = false,

		action = function(pos, node, active_object_count, active_object_count_wider)
			--do not spawn if too many entities in area
			if active_object_count_wider >= 30 then
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

			--don't spawn in liquids
			if minetest.get_item_group(node.name, "liquid") > 0 then
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

			--mobs cannot spawn in protected areas
			if minetest.is_protected(pos, "") then
				return
			end

			minetest.add_entity(pos, mobName)
		end
	})
end

register_spawning(nil, voxeldungeon.utils.surface_valid_ground, {
	["voxeldungeon:dirt_monster"] = 5,
	["voxeldungeon:sand_monster"] = 3,
	["voxeldungeon:tree_monster"] = 3,
	["voxeldungeon:rat"] = 1,
})

register_spawning(1, voxeldungeon.utils.sewers_valid_ground, {
	["voxeldungeon:dirt_monster"] = 2,
	["voxeldungeon:sand_monster"] = 1,
	["voxeldungeon:rat"] = 10,
})

register_spawning(3, voxeldungeon.utils.sewers_valid_ground, {
	["voxeldungeon:sand_monster"] = 1,
	["voxeldungeon:rat"] = 5,
	["voxeldungeon:scout"] = 6,
})

register_spawning(5, voxeldungeon.utils.sewers_valid_ground, {
	["voxeldungeon:rat"] = 2,
	["voxeldungeon:scout"] = 6,
	["voxeldungeon:crab"] = 9,
	["voxeldungeon:thief"] = 1,
	["voxeldungeon:skeleton"] = 1,
})

register_spawning(6, voxeldungeon.utils.prisons_valid_ground, {
	["voxeldungeon:thief"] = 3,
	["voxeldungeon:skeleton"] = 9,
	["voxeldungeon:spider"] = 6,
})

register_spawning(8, voxeldungeon.utils.prisons_valid_ground, {
	["voxeldungeon:thief"] = 5,
	["voxeldungeon:skeleton"] = 6,
	["voxeldungeon:spider"] = 5,
})

register_spawning(10, voxeldungeon.utils.prisons_valid_ground, {
	["voxeldungeon:thief"] = 6,
	["voxeldungeon:skeleton"] = 5,
	["voxeldungeon:spider"] = 1,
})
