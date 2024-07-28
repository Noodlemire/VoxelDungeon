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

voxeldungeon.particles = {}

local function randomVel()
	return voxeldungeon.utils.randomDecimal(-3/4, 3/4)
end



function voxeldungeon.particles.register_shape(name, def)
	def = def or {}
	def._radius = (def._radius or 1) * 0.125
	def._lifespan = def._lifespan or 1
	def._yscale = def._yscale or 1
	def._frames = def._frames or 1

	def.initial_properties = {
		physical = false,
		textures = {"voxeldungeon_particle_"..name..".png"},
		visual_size = 
		{
			x = def._radius, 
			y = def._radius * (def._yscale or 1)
		},
		collisionbox = {0, 0, 0, 0, 0, 0},
		visual = def._drawtype or "sprite",
		spritediv = {x = 1, y = def._frames},
		glow = -1,
		static_save = false,
	}

	def.on_step = function(self, dtime)
		local lifespan = self._lifespan or def._lifespan

		if def._transformation then def._transformation(self, lifespan) end
		if self._transformation then self._transformation(self, lifespan) end

		self._timer = self._timer + dtime

		if self._timer >= lifespan then
			if self.object:get_attach() then self.object:set_detach() end
			self.object:remove()
		end
	end

	def.on_activate = function(self)
		self._timer = 0

		self._animate = function(animspeed)
			self.object:set_sprite({x = 0, y = 0}, def._frames, animspeed, false)
		end

		self._resize = function(self, change)
			local base_size = self._radius or def._radius
			self.object:set_properties(
			{
				visual_size = 
				{
					x = base_size + self._timer * change, 
					y = base_size * (def._yscale or 1) + self._timer * change
				}
			})
		end

		self._set_size = function(self, newsize)
			self._radius = newsize * 0.125

			self.object:set_properties(
			{
				visual_size = 
				{
					x = self._radius,
					y = self._radius * (def._yscale or 1)
				}
			})
		end

		self._colorize = function(self, color)
			local r = voxeldungeon.utils.tohex(color.r)
			local g = voxeldungeon.utils.tohex(color.g)
			local b = voxeldungeon.utils.tohex(color.b)

			self.object:set_texture_mod("^[multiply:#"..r..g..b)
		end

		self._gradient = function(self, colors)
			local factor = self._timer / (self._lifespan or def._lifespan) + 1

			local segment = math.floor(factor)
			local cur = colors[segment]
			local nxt = colors[segment + 1] or colors[segment]

			local percent = factor - segment

			self:_colorize({
				r = cur.r + (nxt.r - cur.r) * percent,
				g = cur.g + (nxt.g - cur.g) * percent,
				b = cur.b + (nxt.b - cur.b) * percent,
			})
		end

		self._random_color = function(self, colors, inBetween)
			local color = voxeldungeon.utils.randomObject(colors)

			if inBetween then
				local blender = voxeldungeon.utils.randomObject(colors)
				local rand = voxeldungeon.utils.randomDecimal()

				color = 
				{
					r = color.r + (blender.r - color.r) * rand,
					g = color.g + (blender.g - color.g) * rand,
					b = color.b + (blender.b - color.b) * rand,
				}
			end

			self:_colorize(color)
		end

		self._motion = function(self, motions)
			local lifespan = self._lifespan or def._lifespan
			local vel = self.object:get_velocity()
			local acc = self.object:get_acceleration()

			if motions.random then
				vel = {
					x = randomVel(), 
					y = randomVel(), 
					z = randomVel(),
				}

				acc.x = vel.x
				if acc.x ~= 0 then acc.x = -acc.x / math.abs(acc.x) / lifespan / 2 end
				acc.y = vel.y
				if acc.y ~= 0 then acc.y = -acc.y / math.abs(acc.y) / lifespan / 2 end
				acc.z = vel.z
				if acc.z ~= 0 then acc.z = -acc.z / math.abs(acc.z) / lifespan / 2 end
			end

			if motions.explode then
				vel.y = vel.y + 1 * motions.explode
				acc.y = acc.y - 2 * motions.explode
			end

			if motions.implode then
				vel.y = vel.y - 1 * motions.implode
				acc.y = acc.y + 2 * motions.implode
			end

			if motions.up then
				acc.y = acc.y + 1 * motions.up
			end

			if motions.down then
				acc.y = acc.y - 1 * motions.down
			end

			if motions.angle then
				vel = vector.add(vel, vector.multiply(motions.angle, 3))
			end

			self.object:set_velocity(vel)
			self.object:set_acceleration(acc)
		end

		if def._on_activate then def._on_activate(self) end
	end

	minetest.register_entity("voxeldungeon:particle_"..name, def)
end

voxeldungeon.particles.register_shape("dot")

voxeldungeon.particles.register_shape("blaze", {
	_lifespan = 1.1,
	_frames = 12,
	_radius = 12,

	_on_activate = function(self)
		self.object:set_sprite({x = 0, y = 0}, 12, voxeldungeon.utils.randomDecimal(0.05, 0.1), false)
	end
})

voxeldungeon.particles.register_shape("gas", {
	_lifespan = 3,
	_frames = 12,
	_radius = 8,

	_on_activate = function(self)
		self.object:set_sprite({x = 0, y = 0}, 12, voxeldungeon.utils.randomDecimal(0.3, 0.5), false)
	end,

	_transformation = function(self, lifespan)
		self:_resize(0.25)
	end
})

voxeldungeon.particles.register_shape("puff", {
	_lifespan = 1.2, 
	_frames = 12, 
	_radius = 4,

	_on_activate = function(self)
		self.object:set_sprite({x = 0, y = 0}, 12, voxeldungeon.utils.randomDecimal(0.05, 0.2), false)
	end
})

voxeldungeon.particles.register_shape("shaft", {
	_lifespan = 1.2,
	_radius = 2,
	_yscale = 8,
	_drawtype = "upright_sprite"
})

voxeldungeon.particles.register_shape("wave", {
	_lifespan = 0.225, 
	_frames = 5, 
	_radius = 24,

	_on_activate = function(self)
		self.object:set_sprite({x = 0, y = 0}, 24, 0.05, false)
	end
})



function voxeldungeon.particles.blastwave(pos)
	local particle = minetest.add_entity(pos, "voxeldungeon:particle_wave")

	if particle then
		particle = particle:get_luaentity()

		particle:_colorize({r = 158, g = 143, b = 117})
	end

	return particle
end

function voxeldungeon.particles.blastwave_trail(pos)
	local particle = minetest.add_entity(pos, "voxeldungeon:particle_dot")

	if particle then
		particle = particle:get_luaentity()

		particle._lifespan = 0.6

		particle:_colorize({r = 158, g = 143, b = 117})
		particle:_motion({random = true})

		particle._transformation = function(self, lifespan)
			self:_resize(0.25)
		end
	end

	return particle
end

function voxeldungeon.particles.blood(pos, customdata)
	local color = customdata.color or {r = 204, g = 0, b = 0}

	local particle = minetest.add_entity(pos, "voxeldungeon:particle_dot")

	if particle then
		particle = particle:get_luaentity()

		particle:_set_size(1.5)
		particle:_colorize(color)
		particle:_motion({random = true, explode = 3, angle = customdata.angle})

		particle._transformation = function(self, lifespan)
			self:_resize(-0.1)
		end
	end

	return particle
end

function voxeldungeon.particles.corrosion(pos)
	local particle = minetest.add_entity(pos, "voxeldungeon:particle_gas")

	if particle then
		particle = particle:get_luaentity()

		particle:_random_color({{r = 128, g = 128, b = 128}, {r = 178, g = 128, b = 53}}, true)
		particle:_motion({random = true})
	end

	return particle
end

function voxeldungeon.particles.corrosive_trail(pos)
	local particle = minetest.add_entity(pos, "voxeldungeon:particle_dot")

	if particle then
		particle = particle:get_luaentity()

		particle._lifespan = 0.6

		particle:_random_color({{r = 128, g = 128, b = 128}, {r = 178, g = 128, b = 53}}, true)
		particle:_motion({random = true})

		particle._transformation = function(self, lifespan)
			self:_resize(0.25)
		end
	end

	return particle
end

function voxeldungeon.particles.evil_be_gone(pos)
	local colorfunc = function(self)
		self:_gradient({{r = 51, g = 0, b = 34}, {r = 0, g = 0, b = 0}})
	end

	pos = vector.add(pos, 
	{
		x = voxeldungeon.utils.randomDecimal(0.15, -0.15),
		y = voxeldungeon.utils.randomDecimal(0.15, -0.15),
		z = voxeldungeon.utils.randomDecimal(0.15, -0.15),
	})

	local particle = minetest.add_entity(pos, "voxeldungeon:particle_dot")

	if particle then
		particle = particle:get_luaentity()

		particle:_set_size(2)
		colorfunc(particle)
		particle:_motion({random = true, up = 3})

		particle._transformation = function(self, lifespan)
			self:_resize(-0.2)
			colorfunc(self)
		end
	end

	return particle
end

function voxeldungeon.particles.fire(pos)
	local particle = minetest.add_entity(pos, "voxeldungeon:particle_blaze")

	if particle then
		particle = particle:get_luaentity()

		particle:_random_color({{r = 230, g = 230, b = 0}, {r = 230, g = 120, b = 0}}, true)
	end

	return particle
end

function voxeldungeon.particles.flock(pos)
	pos = vector.add(pos, 
	{
		x = voxeldungeon.utils.randomDecimal(0.5, -0.5),
		y = voxeldungeon.utils.randomDecimal(0.5, -0.5),
		z = voxeldungeon.utils.randomDecimal(0.5, -0.5),
	})

	local particle = minetest.add_entity(pos, "voxeldungeon:particle_puff")

	if particle then
		particle = particle:get_luaentity()

		particle._lifespan = 0.6

		particle:_colorize({r = 179, g = 176, b = 161})
		particle:_motion({up = 2})
	end

	return particle
end

function voxeldungeon.particles.flock_trail(pos)
	local particle = minetest.add_entity(pos, "voxeldungeon:particle_dot")

	if particle then
		particle = particle:get_luaentity()

		particle._lifespan = 0.6

		particle:_set_size(3)
		particle:_colorize({r = 179, g = 176, b = 161})
		particle:_motion({random = true})

		particle._transformation = function(self, lifespan)
			self:_resize(-0.25)
		end
	end

	return particle
end

function voxeldungeon.particles.grass(pos, customdata)
	local particle = minetest.add_entity(pos, "voxeldungeon:particle_dot")

	if particle then
		local color = {r = 57, g = 94, b = 48}

		if customdata.chapter == "prisons" then
			color = {r = 103, g = 147, b = 61}
		elseif customdata.chapter == "caves" then
			color = {r = 140, g = 155, b = 82}
		elseif customdata.chapter == "cities" then
			color = {r = 104, g = 146, b = 76}
		elseif customdata.chapter == "halls" then
			color = {r = 153, g = 76, b = 0}
		end

		particle = particle:get_luaentity()

		particle._lifespan = 1.2

		particle:_colorize(color)
		particle:_motion({random = true, implode = 1})

		particle._transformation = function(self, lifespan)
			self:_resize(-0.075)
		end
	end

	return particle
end

function voxeldungeon.particles.levitation(pos)
	pos = vector.add(pos, 
	{
		x = voxeldungeon.utils.randomDecimal(0.5, -0.5),
		y = 0,
		z = voxeldungeon.utils.randomDecimal(0.5, -0.5),
	})

	local particle = minetest.add_entity(pos, "voxeldungeon:particle_gas")

	if particle then
		particle = particle:get_luaentity()

		particle._lifespan = 0.6
		particle._radius = 0.4

		particle:_motion({down = 5})

		particle._animate(0.075)
	end

	return particle
end

function voxeldungeon.particles.light(pos)
	pos = vector.add(pos, 
	{
		x = voxeldungeon.utils.randomDecimal(0.5, -0.5),
		y = voxeldungeon.utils.randomDecimal(0.5, -0.5),
		z = voxeldungeon.utils.randomDecimal(0.5, -0.5),
	})

	local particle = minetest.add_entity(pos, "voxeldungeon:particle_shaft")

	if particle then
		particle = particle:get_luaentity()

		particle:_motion({random = true})

		particle.object:set_velocity(vector.divide(particle.object:get_velocity(), 2))
	end

	return particle
end

function voxeldungeon.particles.magic_trail(pos)
	local particle = minetest.add_entity(pos, "voxeldungeon:particle_dot")

	if particle then
		particle = particle:get_luaentity()

		particle._lifespan = 0.6

		particle:_random_color({{r = 255, g = 255, b = 255}, {r = 200, g = 255, b = 255}}, true)
		particle:_motion({random = true})

		particle._transformation = function(self, lifespan)
			self:_resize(0.25)
		end
	end

	return particle
end

function voxeldungeon.particles.paralytic(pos)
	local particle = minetest.add_entity(pos, "voxeldungeon:particle_gas")

	if particle then
		particle = particle:get_luaentity()

		particle:_colorize({r = 255, g = 255, b = 0})
		particle:_motion({random = true})

		particle._transformation = function(self, lifespan)
			self:_resize(0.25)
		end
	end

	return particle
end

function voxeldungeon.particles.poison(pos)
	local particle = minetest.add_entity(pos, "voxeldungeon:particle_dot")

	local colorfunc = function(self)
		self:_gradient({{r = 250, g = 25, b = 250}, {r = 50, g = 225, b = 50}})
	end

	if particle then
		particle = particle:get_luaentity()

		colorfunc(particle)
		particle:_motion({random = true, explode = 1})

		particle._transformation = function(self, lifespan)
			self:_resize(0.125)
			colorfunc(self)
		end
	end

	return particle
end

function voxeldungeon.particles.splash(pos, customdata)
	local particle = minetest.add_entity(pos, "voxeldungeon:particle_dot")

	if particle then
		local color = {r = 25, g = 25, b = 25}

		if customdata.color == "amber" then
			color = {r = 255, g = 140, b = 9}
		elseif customdata.color == "azure" then
			color = {r = 0, g = 62, b = 255}
		elseif customdata.color == "bistre" then
			color = {r = 107, g = 54, b = 6}
		elseif customdata.color == "charcoal" then
			color = {r = 62, g = 62, b = 62}
		elseif customdata.color == "crimson" then
			color = {r = 255, g = 0, b = 38}
		elseif customdata.color == "golden" then
			color = {r = 217, g = 172, b = 0}
		elseif customdata.color == "indigo" then
			color = {r = 122, g = 0, b = 184}
		elseif customdata.color == "ivory" then
			color = {r = 246, g = 236, b = 218}
		elseif customdata.color == "jade" then
			color = {r = 0, g = 180, b = 62}
		elseif customdata.color == "magenta" then
			color = {r = 238, g = 0, b = 156}
		elseif customdata.color == "silver" then
			color = {r = 143, g = 154, b = 154}
		elseif customdata.color == "turquoise" then
			color = {r = 0, g = 196, b = 232}
		end

		particle = particle:get_luaentity()

		particle._lifespan = 1.2

		particle:_set_size(2)
		particle:_colorize(color)
		particle:_motion({random = true, explode = 3})

		particle._transformation = function(self, lifespan)
			self:_resize(-0.175)
		end
	end

	return particle
end

function voxeldungeon.particles.toxic(pos)
	local particle = minetest.add_entity(pos, "voxeldungeon:particle_gas")

	if particle then
		particle = particle:get_luaentity()

		particle:_colorize({r = 0, g = 255, b = 0})
		particle:_motion({random = true})

		particle._transformation = function(self, lifespan)
			self:_resize(0.25)
		end
	end

	return particle
end

function voxeldungeon.particles.vampire_trail(pos)
	local particle = minetest.add_entity(pos, "voxeldungeon:particle_dot")

	if particle then
		particle = particle:get_luaentity()

		particle._lifespan = 0.6

		particle:_random_color({{r = 0, g = 0, b = 0}, {r = 160, g = 0, b = 0}, {r = 255, g = 55, b = 55}}, false)
		particle:_motion({random = true})

		particle._transformation = function(self, lifespan)
			self:_resize(0.25)
		end
	end

	return particle
end



function voxeldungeon.particles.burst(func, pos, amount, customdata)
	for i = 1, amount do
		func(pos, customdata or {})
	end
end

function voxeldungeon.particles.emitter(func, target, duration, customdata)
	local particle = func(target:get_pos(), customdata or {})

	particle.object:set_attach(target, "", {x = 0, y = 8, z = 0}, {x = 0, y = 0, z = 0}, true)
	particle._lifespan = duration
end

function voxeldungeon.particles.factory(func, target, duration, interval, customdata)
	func(target.get_pos and target:get_pos() or target, customdata or {})

	if duration > 0 then
		minetest.after(interval, voxeldungeon.particles.factory, func, target, duration - interval, interval, customdata)
	end
end
