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

voxeldungeon.projectiles = {}



function voxeldungeon.projectiles.register(name, entdef)
	local on_step = entdef._on_step or function() end
	local hit_node = entdef._on_hit_node or function() end
	local hit_obj = entdef._on_hit_obj or function() end

	entdef.initial_properties = {
		visual = "sprite",
		pointable = false,
		textures = {entdef._texture or "blank.png"},
		static_save = false,
		spritediv = {x = 1, y = entdef._frames or 1},
		visual_size = 
		{
			x = entdef._size or 1, 
			y = entdef._size or 1
		},
	}

	entdef.on_step = function(self, dtime)
		local pos = self.object:get_pos()

		on_step(self, dtime)
		if not self.object then return end

		local oldtime = self.timer or 0
		self.timer = oldtime + dtime
		local rate = 15
		if self._trail and math.floor(rate * oldtime) ~= math.floor(rate * self.timer) then
			voxeldungeon.particles.burst(self._trail, self.object:get_pos(), 1)
		end

		if self.timer > 30 then
			self.object:remove()
		elseif entdef._stop_terrain and voxeldungeon.utils.solid(vector.add(pos, vector.normalize(self.object:get_velocity()))) then
			hit_node(self, minetest.get_node_or_nil(pos))
			self.object:remove()
		elseif entdef._stop_objects then
			local targets = voxeldungeon.utils.getLivingInArea(pos, 1, true)

			if #targets > 0 then
				local closest = targets[1]

				for i = 2, #targets do
					if vector.distance(pos, targets[i]:get_pos()) < vector.distance(pos, closest:get_pos()) then
						closest = targets[i]
					end
				end

				hit_obj(self, closest)
				self.object:remove()
			end
		end
	end

	minetest.register_entity("voxeldungeon:projectile_"..name, entdef)
end

function voxeldungeon.projectiles.shoot(name, pos, dir, customdata)
	local offset = vector.multiply(dir, 2)

	local projectile = minetest.add_entity(vector.add(pos, offset), "voxeldungeon:projectile_"..name)
	projectile:set_velocity(vector.multiply(offset, 8))
	projectile:get_luaentity().customdata = customdata
end



voxeldungeon.projectiles.register("blastwave", {
	_texture = "voxeldungeon_particle_dot.png^[multiply:#9E8F75",
	_size = 0.125,
	_trail = voxeldungeon.particles.blastwave_trail, 

	_stop_terrain = true,
	_stop_objects = true,

	_on_hit_node = function(self, node)
		voxeldungeon.utils.blastwave(self.object:get_pos(), self.object:get_velocity(), self.customdata.lvl)
	end,

	_on_hit_obj = function(self, target)
		voxeldungeon.utils.blastwave(target:get_pos(), self.object:get_velocity(), self.customdata.lvl)
	end
})

voxeldungeon.projectiles.register("corrosive", {
	_texture = "voxeldungeon_particle_dot.png^[multiply:#B28035",
	_size = 0.125,
	_trail = voxeldungeon.particles.corrosive_trail, 

	_stop_terrain = true,
	_stop_objects = true,

	_on_step = function(self)
		if voxeldungeon.utils.solid(vector.add(self.object:get_pos(), vector.normalize(self.object:get_velocity()))) then
			voxeldungeon.blobs.seed("corrosivegas", self.object:get_pos(), 150 + 50 * self.customdata.lvl)
			self.object:remove()
		end
	end,

	_on_hit_obj = function(self, target)
		voxeldungeon.blobs.seed("corrosivegas", target:get_pos(), 150 + 50 * self.customdata.lvl)
	end
})

voxeldungeon.projectiles.register("flock", {
	_texture = "voxeldungeon_particle_puff.png^[multiply:#B3B0A1",
	_size = 0.5,
	_frames = 12,
	_trail = voxeldungeon.particles.flock_trail,

	_stop_terrain = true,
	_stop_objects = true,

	on_activate = function(self)
		self.object:set_sprite({x = 0, y = 0}, 12, 0.2, false)
	end,

	_on_step = function(self)
		if voxeldungeon.utils.solid(vector.add(self.object:get_pos(), vector.normalize(self.object:get_velocity()))) then
			voxeldungeon.mobs.spawn_multiple("voxeldungeon:sheep", self.object:get_pos(), self.customdata.lvl)
			self.object:remove()
		end
	end,

	_on_hit_obj = function(self, target)
		voxeldungeon.mobs.spawn_multiple("voxeldungeon:sheep", target:get_pos(), self.customdata.lvl)
	end
})

voxeldungeon.projectiles.register("magicmissile", {
	_texture = "voxeldungeon_particle_dot.png",
	_size = 0.125,
	_trail = voxeldungeon.particles.magic_trail, 

	_stop_terrain = true,
	_stop_objects = true,

	_on_hit_obj = function(self, target)
		local dmg = self.customdata.dmg

		if dmg then
			voxeldungeon.mobs.damage(target, dmg, "magic missile")
		end
	end
})

voxeldungeon.projectiles.register("vampire", {
	_texture = "voxeldungeon_particle_dot.png^[multiply:#A00000",
	_size = 0.125,
	_trail = voxeldungeon.particles.vampire_trail, 

	_stop_terrain = true,
	_stop_objects = true,

	_on_hit_obj = function(self, target)
		local dmg = self.customdata.dmg
		local user = minetest.get_player_by_name(self.customdata.username)

		if dmg and user then
			if not target:get_luaentity().undead then
				local h = math.min(math.floor(d / 2), voxeldungeon.mobs.health(target))
				user:set_hp(user:get_hp() + h)
			end

			voxeldungeon.mobs.damage(target, dmg, "vampirism")
		end
	end
})
