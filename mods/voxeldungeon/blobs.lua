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
local MAX_CYCLE_SIZE = 100

local function expandUpon(posses, spreadCondition)
	local newposses = voxeldungeon.smartVectorTable()

	for i = 1, posses.size() do
		local p = posses.getVector(i)
		local a = posses.getValue(i)

		if a > 0 then
			for _, n in pairs(voxeldungeon.utils.NEIGHBORS7) do
				local newpos = vector.add(p, n)
				local posval = posses.get(newpos) or 0

				if spreadCondition(newpos) or minetest.get_node(p).name == "ignore" then
					newposses.set(newpos, posval)
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

	blob.timer = voxeldungeon.storage.getNum(name.."_timer") or TIMESCALE
	blob.queue = voxeldungeon.storage.getNum(name.."_queue") or 1
		
	blob.on_step = function(dtime)
		voxeldungeon.storage.put(name.."_timer", blob.timer)

		if blob.timer > 0 then
			blob.timer = blob.timer - dtime
			return
		end
		
		blob.timer = TIMESCALE

		if blob.posses.size() > 0 then
			blob:evolve()

			if blob.effectTerr then
				for i = 1, blob.posses.size() do
					blob:effectTerr(blob.posses.getVector(i), blob.posses.getValue(i))
				end
			end

			if blob.effectObj then
				for _, player in ipairs(minetest.get_connected_players()) do
					if not voxeldungeon.buffs.get_buff("voxeldungeon:gasimmunity", player) then
						local pos = vector.round(player:get_pos())
						local val = blob.posses.get(pos) or 0

						if val > 0 then
							blob:effectObj(pos, val, player)
						end
					end
				end

				for e = 1, entitycontrol.count_entities() do
					local entity = entitycontrol.get_entity(e)

					if entitycontrol.isAlive(e) and not voxeldungeon.buffs.get_buff("voxeldungeon:gasimmunity", entity) then
						local pos = vector.round(entity:get_pos())
						local val = blob.posses.get(pos) or 0

						if val > 0 then
							blob:effectObj(pos, val, entity)
						end
					end
				end
			end
		end

		voxeldungeon.storage.put(name.."_posses", minetest.serialize(blob.posses.table))
		voxeldungeon.storage.put(name.."_queue", blob.queue)
	end

	blob.evolve = blob.evolve or function(blob)
		local offload = expandUpon(blob.posses, blob.spreadCondition)

		local cycleSize = math.min(MAX_CYCLE_SIZE, offload.size())

		for i = blob.queue, blob.queue + offload.size() - 1 do
			local p = offload.getVector(i)

			if p then
				if minetest.get_node(p).name ~= "ignore" then
					if blob.spreadCondition(p) then
						local count = 1
						local sum = blob.posses.getValue(i) or 0

						for _, n in pairs(voxeldungeon.utils.NEIGHBORS6) do
							local neighbor = vector.add(p, n)

							if blob.spreadCondition(neighbor) then
								sum = sum + (blob.posses.get(neighbor) or 0)
								count = count + 1
							end
						end

						local value = 0
						if sum >= count then
							value = math.floor(sum / count) - 1
						end

						offload.set(p, value)
					else
						offload.del(p)
					end
				else
					local value = blob.posses.get(p) or 0
					offload.set(p, value)
				end
			end
		end

		for i = offload.size(), 1, -1 do
			if offload.getValue(i) == 0 then
				offload.del(offload.getVector(i))
			end
		end

		blob.posses = offload

		blob.queue = blob.queue + MAX_CYCLE_SIZE

		if blob.queue > offload.size() then
			blob.queue = 1
		end
	end

	blob.seed = function(pos, amount)
		blob.posses.set(pos, amount)
	end

	blob.clear = function(pos)
		local cur = blob.posses.get(pos)

		if cur then
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

function voxeldungeon.blobs.get(name, pos)
	return voxeldungeon.blobs.registered_blobs[name].posses.get(vector.round(pos)) or 0
end



voxeldungeon.blobs.register("corrosivegas", {
	spreadCondition = function(pos)
		return not voxeldungeon.utils.solid(pos)
	end, 

	effectTerr = function(blob, pos, amount)
		if voxeldungeon.utils.randomDecimal(blob.posses.size() / (blob.posses.size() + 2)) <= 1/3 then
			voxeldungeon.particles.corrosion(pos)
		end
	end,

	effectObj = function(blob, pos, amount, obj)
		voxeldungeon.buffs.attach_buff("voxeldungeon:corrosion", obj, 2, {dmg = math.floor(amount / 25)})
	end
})

voxeldungeon.blobs.register("fire", { 
	spreadCondition = function(pos)
		local node = minetest.get_node(pos)
		local near_fire = false

		for _, offset in ipairs(voxeldungeon.utils.NEIGHBORS7) do
			local pos_o = vector.add(pos, offset)
			local node_o = minetest.get_node(pos_o)

			if minetest.get_item_group(node_o.name, "water") > 0 then 
				return false 
			elseif voxeldungeon.blobs.get("voxeldungeon:blob_fire", pos_o) > 0 and minetest.get_item_group(node_o.name, "flammable") > 0 then 
				near_fire = true 
			end
		end

		if near_fire then return true end

		return voxeldungeon.blobs.get("voxeldungeon:blob_fire", pos) > 0 or minetest.get_item_group(node.name, "flammable") > 0
	end,

	evolve = function(blob)
		local offload = expandUpon(blob.posses, blob.spreadCondition)

		local cycleSize = math.min(MAX_CYCLE_SIZE, offload.size())

		for i = blob.queue, blob.queue + offload.size() - 1 do
			local p = offload.getVector(i)

			if p then
				if minetest.get_node(p).name ~= "ignore" then
					if blob.spreadCondition(p) then
						local value = voxeldungeon.blobs.get("voxeldungeon:blob_fire", p) - 1

						if value == 0 then
							local node = minetest.get_node_or_nil(p)
							if node and minetest.get_item_group(node.name, "flammable") >= 1 then
								local on_burn = minetest.registered_nodes[node.name].on_burn

								if on_burn then 
									on_burn(p)
								else
									minetest.remove_node(p)
									minetest.punch_node(p)
									minetest.place_node(p, {name = "voxeldungeon:embers"})
								end
							end

							offload.del(p)
						else
							if value < 0 then 
								value = 2
							end

							offload.set(p, value)
						end		
					else
						offload.del(p)
					end
				else
					local value = blob.posses.get(p) or 0
					offload.set(p, value)
					cycleSize = cycleSize + 1
				end
			end
		end

		for i = offload.size(), 1, -1 do
			if offload.getValue(i) == 0 then
				offload.del(offload.getVector(i))
			end
		end

		blob.posses = offload

		blob.queue = blob.queue + MAX_CYCLE_SIZE

		if blob.queue > offload.size() then
			blob.queue = 1
		end
	end,

	effectTerr = function(blob, pos, amount, objs)
		voxeldungeon.particles.fire(pos)
	end,

	effectObj = function(blob, pos, amount, obj)
		voxeldungeon.buffs.attach_buff("voxeldungeon:burning", obj, 8)
	end
})

voxeldungeon.blobs.register("paralyticgas", {
	spreadCondition = function(pos)
		return not voxeldungeon.utils.solid(pos) and voxeldungeon.blobs.get("voxeldungeon:blob_toxicgas", pos) == 0
	end, 

	effectTerr = function(blob, pos, amount)
		if voxeldungeon.utils.randomDecimal(blob.posses.size() / (blob.posses.size() + 2)) <= 1/3 then
			voxeldungeon.particles.paralytic(pos)
		end
	end,

	effectObj = function(blob, pos, amount, obj)
		voxeldungeon.buffs.attach_buff("voxeldungeon:paralyzed", obj, 10)
	end
})

voxeldungeon.blobs.register("toxicgas", {
	spreadCondition = function(pos)
		return not voxeldungeon.utils.solid(pos) and voxeldungeon.blobs.get("voxeldungeon:blob_paralyticgas", pos) == 0
	end, 

	effectTerr = function(blob, pos, amount)
		if voxeldungeon.utils.randomDecimal(blob.posses.size() / (blob.posses.size() + 2)) <= 1/3 then
			voxeldungeon.particles.toxic(pos)
		end
	end,

	effectObj = function(blob, pos, amount, obj)
		voxeldungeon.mobs.damage(obj, voxeldungeon.utils.getChapter(pos), "toxic gas")
	end
})
