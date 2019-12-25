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

local registered_particles = {}
local registered_factories = {}

local function randomVel()
	return math.random(-1/3, 1/3)
end

function voxeldungeon.particles.register_particle(name, radius, lifespan, gravity, initialize, transformation, drawtype, yscale, frames)
	local scale = radius * 0.125
	frames = frames or 1
	minetest.register_entity("voxeldungeon:particle_"..name, 
	{
		_timer = 0,
		
		initial_properties = {
			physical = false,
			textures = {"voxeldungeon_particle_"..name..".png"},
			visual_size = 
			{
				x = scale, 
				y = scale * (yscale or 1)
			},
			collisionbox = {0, 0, 0, 0, 0, 0},
			visual = drawtype or "sprite",
			spritediv = {x = 1, y = frames}
		},
		
		on_activate = function(self, staticdata)
			local obj = self.object

			obj:setvelocity(
			{
				x = randomVel(), 
				y = randomVel(), 
				z = randomVel(),
			})

			local v = obj:get_velocity()
			local ax = v.x
			if ax ~= 0 then ax = -ax / math.abs(ax) / lifespan / 2 end
			local ay = v.y
			if ay ~= 0 then ay = -ay / math.abs(ay) / lifespan / 2 end
			local az = v.z
			if az ~= 0 then az = -az / math.abs(az) / lifespan / 2 end

			obj:setacceleration({x=ax, y=ay+gravity, z=az})
			obj:setyaw(math.random(0,359)/180*math.pi)

			if initialize then initialize(self) end
		end,
		
		on_step = function(self, dtime)
			if transformation then transformation(self, lifespan) end

			self._timer = self._timer+dtime
			if self._timer >= lifespan then
				self.object:remove()
			end
		end,
		
		resize = function(self, change)
			self.object:set_properties(
			{
				visual_size = 
				{
					x = scale + self._timer * change, 
					y = scale * (yscale or 1) + self._timer * change
				}
			})
		end,
	})
end



voxeldungeon.particles.register_particle("flame", 8, 0.8, 1, 
	function(self)
		local gbyte = math.random(155, 222)
		local ghex = voxeldungeon.utils.tohex(gbyte)
		self.object:settexturemod("^[colorize:#FF"..ghex.."00")
	end,

	function(self, lifespan)
		self.resize(self, -0.125)
	end
)

voxeldungeon.particles.register_particle("grass", 1, 1.2, 1, nil, function(self, lifespan)
	self.resize(self, -0.075)
end)

voxeldungeon.particles.register_particle("paralytic", 8, 3, 0, 
	function(self)
		self.object:set_sprite({x = 0, y = 0}, 12, voxeldungeon.utils.randomDecimal(0.4, 0.3), false)
	end,

	function(self, lifespan)
		self.resize(self, 0.25)
	end, "sprite", 1, 12
)

voxeldungeon.particles.register_particle("poison", 1, 0.6, -1, nil, function(self, lifespan)
	local timer = self._timer
	
	local sbyte = 150 + (lifespan - timer) / lifespan * 100
	local shex = voxeldungeon.utils.tohex(sbyte)
	local ebyte = 125 + timer / lifespan * 100
	local ehex = voxeldungeon.utils.tohex(ebyte)
	
	self.object:settexturemod("^[colorize:#"..shex..ehex..shex)
	self.resize(self, 0.125)
end)

voxeldungeon.particles.register_particle("shaft", 2, 1.2, 0, nil, nil, "upright_sprite", 8)

voxeldungeon.particles.register_particle("toxic", 8, 3, 0, 
	function(self)
		self.object:set_sprite({x = 0, y = 0}, 12, voxeldungeon.utils.randomDecimal(0.4, 0.3), false)
	end,

	function(self, lifespan)
		self.resize(self, 0.25)
	end, "sprite", 1, 12
)



function voxeldungeon.particles.burst(name, pos, amount)
	pos = vector.add(pos, 
	{
		x = voxeldungeon.utils.randomDecimal(0.25, -0.25),
		y = voxeldungeon.utils.randomDecimal(0.25, -0.25),
		z = voxeldungeon.utils.randomDecimal(0.25, -0.25),
	})

	for i = 1, amount do
		minetest.env:add_entity(pos, "voxeldungeon:particle_"..name)
	end
end

function voxeldungeon.particles.factory(name, pos, duration, interval)
	voxeldungeon.particles.burst(name, pos, 1)
	if duration > 0 then
		minetest.after(interval, voxeldungeon.particles.factory, name, pos, duration - 1, interval)
	end
end
