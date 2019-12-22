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

local function expandUpon(posses, spreadCondition)
	local newposses = voxeldungeon.smartVectorTable()

	for i = 1, posses.size() do
		local p = posses.getVector(i)
		local a = posses.getValue(i)

		if a > 0 then
			for _, n in pairs(voxeldungeon.utils.NEIGHBORS7) do
				local newpos = vector.add(p, n)
				if spreadCondition(newpos) or minetest.get_node(p).name == "ignore" then
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

--spreadCondition, evolve, effectTerr, effectObj
function voxeldungeon.blobs.register(name, def)
	name = "voxeldungeon:blob_"..name

	voxeldungeon.blobs.registered_blobs[name] = def
	local blob = voxeldungeon.blobs.registered_blobs[name]

	blob.posses = voxeldungeon.smartVectorTable()
	local possesString = voxeldungeon.storage.getStr(name.."_posses")
	if possesString then
		blob.posses.table = minetest.deserialize(possesString)
	end

	blob.volume = voxeldungeon.storage.getNum(name.."_volume") or 0

	blob.timer = voxeldungeon.storage.getNum(name.."_timer") or TIMESCALE
		
	blob.on_step = function(dtime)
		voxeldungeon.storage.put(name.."_timer", blob.timer)

		if blob.timer > 0 then
			blob.timer = blob.timer - dtime
			return
		end
		
		blob.timer = TIMESCALE

		if blob.volume > 0 then
			blob.volume = 0

			blob.evolve()

			if blob.effectTerr then
				for i = 1, blob.posses.size() do
					blob.effectTerr(blob, blob.posses.getVector(i), blob.posses.getValue(i))
				end
			end

			if blob.effectObj then
				for _, player in ipairs(minetest.get_connected_players()) do
					if not voxeldungeon.buffs.get_buff("voxeldungeon:gasimmunity", player) then
						local pos = vector.round(player:get_pos())
						local val = blob.posses.get(pos) or 0

						if val > 0 then
							blob.effectObj(blob, pos, val, player)
						end
					end
				end

				for e = 1, entitycontrol.count_entities() do
					local entity = entitycontrol.get_entity(e)

					if entitycontrol.isAlive(e) and not voxeldungeon.buffs.get_buff("voxeldungeon:gasimmunity", entity) then
						local pos = vector.round(entity:get_pos())
						local val = blob.posses.get(pos) or 0

						if val > 0 then
							blob.effectObj(blob, pos, val, entity)
						end
					end
				end
			end
		end

		voxeldungeon.storage.put(name.."_posses", minetest.serialize(blob.posses.table))
		voxeldungeon.storage.put(name.."_volume", blob.volume)
	end

	blob.evolve = blob.evolve or function()
		local offload = expandUpon(blob.posses, blob.spreadCondition)

		for i = 1, offload.size() do
			local p = offload.getVector(i)

			if minetest.get_node(p).name ~= "ignore" then
				if blob.spreadCondition(p) then
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

					offload.set(p, value)
					blob.volume = blob.volume + value
				else
					offload.del(p)
				end
			else
				local value = blob.posses.get(p) or 0
				offload.set(p, value)
				blob.volume = blob.volume + value
			end
		end

		blob.posses = offload
	end

	blob.seed = function(pos, amount)
		blob.volume = blob.volume + amount
		blob.posses.set(pos, amount)
	end

	blob.clear = function(pos)
		local cur = blob.posses.get(pos)

		if cur then
			blob.volume = blob.volume - cur
			blob.posses.del(pos)
		end
	end

	minetest.register_globalstep(blob.on_step)
end

function voxeldungeon.blobs.seed(name, pos, amount)
	name = "voxeldungeon:blob_"..name
	pos = vector.round(pos)

	voxeldungeon.blobs.registered_blobs[name].seed(pos, amount)
end

function voxeldungeon.blobs.clear(names, pos)
	if type(names) == "string" then
		names = {names}
	end

	pos = vector.round(pos)

	for _, name in ipairs(names) do
		voxeldungeon.blobs.registered_blobs[name].clear(pos)
	end
end


--[[
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
)--]]

voxeldungeon.blobs.register("toxicgas", {
	spreadCondition = function(pos)
		return not voxeldungeon.utils.solid(pos)
	end, 

	effectTerr = function(blob, pos, amount)
		if voxeldungeon.utils.randomDecimal(blob.posses.size() / (blob.posses.size() + 2)) <= 1/3 then
			voxeldungeon.particles.burst("toxic", pos, 1)
		end
	end,

	effectObj = function(blob, pos, amount, obj)
		voxeldungeon.mobs.damage(obj, voxeldungeon.utils.getChapter(pos), "toxic gas")
	end
})
