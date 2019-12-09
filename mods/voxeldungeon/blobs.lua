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
voxeldungeon.blobs.registered_blobs = {}

local TIMESCALE = 1

local function expandUpon(posses, spreadcondition)
	local newposses = voxeldungeon.smartVectorTable()

	for i = 1, posses.size() do
		local p = posses.getVector(i)
		local a = posses.getValue(i)

		if a > 0 then
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
	end

	return newposses
end

function voxeldungeon.blobs.register(name, spreadcondition, effect)
	name = "voxeldungeon:blob_"..name

	voxeldungeon.blobs.registered_blobs[name] = {}
	local blob = voxeldungeon.blobs.registered_blobs[name]

	blob.posses = voxeldungeon.smartVectorTable()
	blob.offload = voxeldungeon.smartVectorTable()
	blob.volume = 0
	blob.timer = TIMESCALE
		
	blob.on_step = function(dtime)
		if blob.timer > 0 then
			blob.timer = blob.timer - dtime
			return
		end
		
		blob.timer = TIMESCALE

		if blob.volume > 0 then
			blob.volume = 0

			blob.evolve()

			local temp = blob.offload
			blob.offload = blob.posses
			blob.posses = temp

			for i = 1, blob.posses.size() do
				local p = blob.posses.getVector(i)
				local v = blob.posses.getValue(i)

				local objs = {}

				for _, player in ipairs(minetest.get_connected_players()) do
					local pos = vector.round(player:get_pos())

					if vector.equals(pos, p) then
						table.insert(objs, player)
					end
				end

				for e = 1, entitycontrol.count_entities() do
					local entity = entitycontrol.get_entity(e)

					if entitycontrol.isAlive(e) then
						local pos = vector.round(entity:get_pos())

						if vector.equals(pos, p) then
							table.insert(objs, entity)
						end
					end
				end

				effect(blob, p, v, objs)
			end
		end
	end

	blob.evolve = function()
		blob.offload = expandUpon(blob.posses, spreadcondition)

		for i = 1, blob.offload.size() do
			local p = blob.offload.getVector(i)

			if spreadcondition(p) then
				local count = 1
				local sum = blob.posses.getValue(i) or 0

				for _, n in pairs(voxeldungeon.utils.NEIGHBORS6) do
					local neighbor = vector.add(p, n)
					if not voxeldungeon.utils.solid(neighbor) then
						sum = sum + (blob.posses.get(neighbor) or 0)
						count = count + 1
					end
				end

				local value = 0
				if sum >= count then
					value = math.floor(sum / count) - 1
				end

				blob.offload.set(p, value)
				blob.volume = blob.volume + value
			else
				blob.offload.del(p)
			end
		end
	end

	blob.seed = function(pos, amount)
		blob.volume = blob.volume + amount
		blob.posses.set(pos, amount)
	end

	minetest.register_globalstep(blob.on_step)
end

function voxeldungeon.blobs.seed(name, pos, amount)
	name = "voxeldungeon:blob_"..name
	pos = vector.round(pos)

	voxeldungeon.blobs.registered_blobs[name].seed(pos, amount)
end



voxeldungeon.blobs.register("fire", 
	function(pos)
		local node = minetest.get_node_or_nil(pos)
		return true--node and minetest.get_item_group(node.name, "flammable") >= 1
	end, 

	function(blob, pos, amount, objs)
		for _, obj in ipairs(objs) do
			if obj:is_player() then
				obj:set_hp(obj:get_hp() - 2)
			else
				voxeldungeon.mobs.damage(obj, 2, "fire")
			end
		end
		
		voxeldungeon.particles.factory("flame", pos, 1, TIMESCALE)
	end
)

voxeldungeon.blobs.register("toxicgas", 
	function(pos)
		return not voxeldungeon.utils.solid(pos)
	end, 

	function(blob, pos, amount, objs)
		for _, obj in ipairs(objs) do
			if obj:is_player() then
				obj:set_hp(obj:get_hp() - voxeldungeon.utils.getChapter(pos))
			else
				voxeldungeon.mobs.damage(obj, voxeldungeon.utils.getChapter(pos), "toxic gas")
			end
		end
		
		if voxeldungeon.utils.randomDecimal(blob.posses.size() / (blob.posses.size() + 2)) <= 1/3 then
			voxeldungeon.particles.burst("toxic", pos, 1)
		end
	end
)
