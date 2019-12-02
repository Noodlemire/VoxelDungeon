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

voxeldungeon.blobs = {}
--voxeldungeon.blobs.blob_instances = {}
voxeldungeon.blobs.registered_blobs = {}

local TIMESCALE = 2

local function expandUpon(posses, spreadcondition)
	local newposses = voxeldungeon.smartVectorTable()

	for i = 1, posses.size() do
		local p = posses.getVector(i)
		local a = posses.getValue(i)

		for _, n in pairs(voxeldungeon.utils.NEIGHBORS7) do
			local newpos = vector.add(p, n)
			if spreadcondition(newpos) then
				if not posses.get(newpos) and not newposses.get(newpos) then
					newposses.set(newpos, 0)
				elseif posses.get(newpos) then
					newposses.set(newpos, posses.get(newpos))
				end
			end
		end
	end

	return newposses
end

function voxeldungeon.blobs.register(nme, spreadcondition, effect)
	local name = "voxeldungeon:blob_"..nme

	minetest.register_entity(name,
	{
		physical = false,
		--textures = {"voxeldungeon_blank.png"},
		collisionbox = {0, 0, 0, 0, 0, 0},
		
		posses = voxeldungeon.smartVectorTable(),
		offload = voxeldungeon.smartVectorTable(),
		volume = 1000,
		offvolume = 1000,
		timer = TIMESCALE,
		
		on_activate = function(self)
		end,
		
		on_step = function(self, dtime)
			if self.timer > 0 then
				self.timer = self.timer - dtime
				return
			end
			
			self.timer = TIMESCALE

			if self.volume > 0 then
				self.volume = 0

				self._evolve(self)

				local temp = self.offload
				self.offload = self.posses
				self.posses = temp

				self.offvolume = self.volume
			else
				self.object:remove()
				return
			end
		end,

		_evolve = function(self)
			if not self.posses.get(self.object:get_pos()) then return end

			if self.offvolume / self.posses.size() >= 5 then
				self.posses = expandUpon(self.posses, spreadcondition)
			end

			for i = 1, self.posses.size() do
				local p = self.posses.getVector(i)
				local a = self.posses.getValue(i)

				if spreadcondition(p) then
					local count = 1
					local sum = a or 0

					for _, n in pairs(voxeldungeon.utils.NEIGHBORS6) do
						local neighbor = vector.add(p, n)
						if not voxeldungeon.utils.solid(neighbor) then
							sum = sum + (self.posses.get(neighbor) or 0)
							count = count + 1
						end
					end

					local value = 0
					if sum >= count then
						value = math.floor(sum / count) - 1
					end

					self.offload.set(p, value)
					self.volume = self.volume + value
					effect(p, value)
				else
					self.offload.del(p)
				end
			end
		end,

		_seed = function(self, amount)
			self.volume = amount
			self.offvolume = self.volume
			self.posses.set(self.object:get_pos(), self.volume)
		end,
	})
	
	voxeldungeon.blobs.registered_blobs[name] = minetest.registered_entities[name]
end

function voxeldungeon.blobs.seed(nme, pos, amount)
	local name = "voxeldungeon:blob_"..nme
	pos = vector.round(pos)
	local obj = minetest.add_entity(pos, name)

	if obj then
		local blob = obj:get_luaentity()
		blob._seed(blob, amount)
	end
end

voxeldungeon.blobs.register("toxicgas", function(pos)
	return not voxeldungeon.utils.solid(pos)
end, function(pos, amount)
	local objs = minetest.get_objects_inside_radius(pos, 1)
	for _, obj in pairs(objs) do
		obj:set_hp(obj:get_hp() - 1)
	end
	
	if math.random(5) == 1 then
		voxeldungeon.particles.burst("toxic", pos, 1)
	end
end)
