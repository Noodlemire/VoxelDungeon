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

function voxeldungeon.particles.register_particle(name, radius, lifespan, gravity, transformation, drawtype, yscale)
	local scale = radius * 0.125
	minetest.register_entity("voxeldungeon:particle_"..name, 
	{
		physical = false,
		timer = 0,
		
		textures = {"voxeldungeon_particle_"..name..".png"},
		visual_size = 
		{
			x = scale, 
			y = scale * (yscale or 1)
		},
		collisionbox = {0, 0, 0, 0, 0, 0},
		visual = drawtype or "sprite",
		
		on_activate = function(self, staticdata)
			local obj = self.object
			obj:setvelocity(
			{
				x=(math.random(0,60)-30)/45, 
				y=(math.random(0,60)-30)/45, 
				z=(math.random(0,60)-30)/45
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
		end,
		
		on_step = function(self, dtime)
			transformation(self, lifespan)

			self.timer = self.timer+dtime
			if self.timer >= lifespan then
				self.object:remove()
			end
		end,
		
		resize = function(self, change)
			self.object:set_properties(
			{
				visual_size = 
				{
					x = scale + self.timer * change, 
					y = scale * (yscale or 1) + self.timer * change
				}
			})
		end,
	})
end



voxeldungeon.particles.register_particle("poison", 1, 0.6, -1, function(self, lifespan)
	local timer = self.timer
	
	local sbyte = 150 + (lifespan - timer) / lifespan * 100
	local shex = voxeldungeon.utils.tohex(sbyte)
	local ebyte = 125 + timer / lifespan * 100
	local ehex = voxeldungeon.utils.tohex(ebyte)
	
	self.object:settexturemod("^[colorize:#"..shex..ehex..shex)
	self.resize(self, 0.125)
end)

voxeldungeon.particles.register_particle("grass", 1, 1.2, 1, function(self, lifespan)
	self.resize(self, -0.075)
end)

voxeldungeon.particles.register_particle("shaft", 2, 1.2, 0, function(self, lifespan) end, "upright_sprite", 8)

voxeldungeon.particles.register_particle("toxic", 8, 3, 0, function(self, lifespan)
	self.resize(self, 0.05)
end)



function voxeldungeon.particles.burst(name, pos, amount)
	pos = vector.add(pos, 
	{
		x = math.random(-0.5, 0.5),
		y = math.random(-0.5, 0.5),
		z = math.random(-0.5, 0.5),
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
