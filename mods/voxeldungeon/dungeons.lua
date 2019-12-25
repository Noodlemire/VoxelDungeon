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

voxeldungeon.dungeons = {}

local A = 180 / math.pi

local curveOffset = 0
local curveIntensity = 1
local curveExponent = 0



local function pathTunnelChances()
	return {1, 3, 1}
end

local function branchTunnelChances()
	return {2, 2, 1}
end

local function curveEquation(x)
	return math.pow(4, 2 * curveExponent) *
		math.pow((x % 0.5) - 0.25, 2 * curveExponent + 1) +
		0.25 + 0.5 * math.floor(2 * x)
end

local function getTargetAngle(percentAlong)
	percentAlong = percentAlong + curveOffset
	return 360 * (curveIntensity * curveEquation(percentAlong)
			+ (1-curveIntensity) * percentAlong
			- curveOffset)
end

local function findFreeSpace(start, collision, maxSize)
	local space = 
	{
		north = start.z + maxSize,
		south = start.z - maxSize,
		east = start.x + maxSize,
		west = start.x - maxSize,
	}

	local colliding = voxeldungeon.utils.shallowCloneTable(collision)

	repeat
		for i = #colliding, 1, -1 do
			local room = colliding[i]

			if math.max(space.west, room.rect.west) >= math.min(space.east, room.rect.east) or
					math.max(space.south, room.rect.south) >= math.min(space.north, room.rect.north) then
				table.remove(colliding, i)
			end
		end

		local closestRoom
		local closestDiff
		local closestID
		local inside = true
		local curDiff = 0
		for id, curRoom in ipairs(colliding) do
			if start.x < curRoom.rect.west then
				inside = false
				curDiff = curDiff + curRoom.rect.west - start.x
			elseif start.x > curRoom.rect.east then
				inside = false
				curDiff = curDiff + start.x - curRoom.rect.east
			end

			if start.z < curRoom.rect.south then
				inside = false
				curDiff = curDiff + curRoom.rect.south - start.z
			elseif start.z > curRoom.rect.north then
				inside = false
				curDiff = curDiff + start.z - curRoom.rect.north
			end

			--if inside then minetest.log("error: could not escape room") return end

			if not closestDiff or curDiff < closestDiff then
				closestRoom = curRoom
				closestDiff = curDiff
				closestID = id
			end
		end

		if closestRoom then
			local wDiff = math.huge
			local lDiff = math.huge

			if closestRoom.rect.west >= start.x then
				wDiff = (space.west - closestRoom.rect.east) * (space.north - space.south + 1)
			elseif closestRoom.rect.east <= start.x then
				wDiff = (closestRoom.rect.west - space.east) * (space.north - space.south + 1)
			end

			if closestRoom.rect.south >= start.z then
				lDiff = (space.south - closestRoom.rect.north) * (space.east - space.west + 1)
			elseif closestRoom.rect.north <= start.z then
				lDiff = (closestRoom.rect.south - space.north) * (space.east - space.west + 1)
			end

			if wDiff < lDiff or (wDiff == lDiff and math.random(3) == 1) then
				if closestRoom.rect.west >= start.x and closestRoom.rect.west < space.east then
					space.east = closestRoom.rect.west
				end
				if closestRoom.rect.east <= start.x and closestRoom.rect.east > space.west then
					space.west = closestRoom.rect.east
				end
			else
				if closestRoom.rect.south >= start.z and closestRoom.rect.south < space.north then
					space.north = closestRoom.rect.south
				end
				if closestRoom.rect.north <= start.z and closestRoom.rect.north > space.south then
					space.south = closestRoom.rect.north
				end
			end

			table.remove(colliding, closestID)
		else
			colliding = {}
		end
	until (#colliding == 0)

	return space
end

local function placeRoom(startpos, collision, prevRoom, nextRoom, angle)
	angle = angle % 360
	if angle < 0 then
		angle = angle + 360
	end

	local prevCenter = {x = (prevRoom.rect.east + prevRoom.rect.west) / 2, z = (prevRoom.rect.north + prevRoom.rect.south) / 2}
	local m = math.tan(angle / A + math.pi / 2)
	local b = prevCenter.z - m * prevCenter.x

	local start
	local dir
	if math.abs(m) >= 1 then
		if angle < 90 or angle > 270 then
			dir = "north"
			start = {x = voxeldungeon.utils.round(prevRoom.rect.north - b) / m, z = prevRoom.rect.north}
		else
			dir = "south"
			start = {x = voxeldungeon.utils.round(prevRoom.rect.south - b) / m, z = prevRoom.rect.south}
		end
	else
		if angle < 180 then
			dir = "west"
			start = {x = prevRoom.rect.west, z = voxeldungeon.utils.round(m * prevRoom.rect.west + b)}
		else
			dir = "east"
			start = {x = prevRoom.rect.east, z = voxeldungeon.utils.round(m * prevRoom.rect.east + b)}
		end
	end

	if dir == "north" or dir == "south" then
		start.x = voxeldungeon.utils.gate(prevRoom.rect.west + 1, start.x, prevRoom.rect.east - 1)
	else
		start.z = voxeldungeon.utils.gate(prevRoom.rect.south + 1, start.z, prevRoom.rect.north - 1)
	end

	local space = findFreeSpace(start, collision, math.max(nextRoom.size.x, nextRoom.size.z))
	if not space then minetest.log("error: no space found") return end

	local targetCenter = {}
	if dir == "south" then
		targetCenter.z = prevRoom.rect.south - (nextRoom.size.z - 1) / 2
		targetCenter.x = (targetCenter.z - b) / m
		nextRoom.position({x = voxeldungeon.utils.round(targetCenter.x - (nextRoom.size.x - 1) / 2),
				y = startpos.y, z = prevRoom.rect.south - (nextRoom.size.z - 1)})
	elseif dir == "north" then
		targetCenter.z = prevRoom.rect.north + (nextRoom.size.z - 1) / 2
		targetCenter.x = (targetCenter.z - b) / m
		nextRoom.position({x = voxeldungeon.utils.round(targetCenter.x - (nextRoom.size.x - 1) / 2), 
				y = startpos.y, z = prevRoom.rect.north})
	elseif dir == "east" then
		targetCenter.x = prevRoom.rect.east + (nextRoom.size.x - 1) / 2
		targetCenter.z = m * (targetCenter.x + b)
		nextRoom.position({x = prevRoom.rect.east, y = startpos.y, 
				z = voxeldungeon.utils.round(targetCenter.z - (nextRoom.size.z - 1) / 2)})
	elseif dir == "west" then
		targetCenter.x = prevRoom.rect.west - (nextRoom.size.x - 1) / 2
		targetCenter.z = m * (targetCenter.x + b)
		nextRoom.position({x = prevRoom.rect.west - (nextRoom.size.x - 1), y = startpos.y, 
				z = voxeldungeon.utils.round(targetCenter.z - (nextRoom.size.z - 1) / 2)})
	end

	if dir == "north" or dir == "south" then
		if nextRoom.rect.east < prevRoom.rect.west + 2 then
			nextRoom.shift(prevRoom.rect.west - nextRoom.rect.east + 2, 0, 0)
		elseif nextRoom.rect.east - 2 < prevRoom.rect.west then
			nextRoom.shift(prevRoom.rect.east - 2 - nextRoom.rect.west, 0, 0)
		end

		if nextRoom.rect.east > space.east then
			nextRoom.shift(space.east - nextRoom.rect.east, 0, 0)
		elseif nextRoom.rect.west < space.west then
			nextRoom.shift(space.west - nextRoom.rect.west, 0, 0)
		end
	else
		if nextRoom.rect.north < prevRoom.rect.south + 2 then
			nextRoom.shift(0, 0, prevRoom.rect.south - nextRoom.rect.north + 2)
		elseif nextRoom.rect.north - 2 < prevRoom.rect.south then
			nextRoom.shift(0, 0, prevRoom.rect.north - 2 - nextRoom.rect.south)
		end

		if nextRoom.rect.north > space.north then
			nextRoom.shift(0, 0, space.north - nextRoom.rect.north)
		elseif nextRoom.rect.south < space.south then
			nextRoom.shift(0, 0, space.south - nextRoom.rect.south)
		end
	end

	return voxeldungeon.utils.angleBetweenPoints(prevRoom.pos.x, prevRoom.pos.z, nextRoom.pos.x, nextRoom.pos.z)
end



function voxeldungeon.dungeons.newLevel(startpos, sizefactor)
	local filled = 0
	local allRooms = {}

	repeat
		local newroom = voxeldungeon.rooms.createNew()
		table.insert(allRooms, newroom)
		filled = filled + newroom.size.x * newroom.size.z
	until (filled >= sizefactor)

	local entrance = voxeldungeon.rooms.entrance()
	entrance.position(vector.round(startpos))
	local loop = {entrance}
	local placedRooms = {entrance}
	local roomsOnLoop = math.random(math.ceil(#allRooms / 3), math.ceil(#allRooms * 2 / 3))
	local startAngle = math.random(1, 360)

	local pathTunnels = pathTunnelChances()
	for i = 1, roomsOnLoop + 1 do
		if i > 1 then
			table.insert(loop, allRooms[i+1])
		end

		local tunnels = voxeldungeon.utils.randomChances(pathTunnels)
		if not tunnels then
			pathTunnels = pathTunnelChances()
			tunnels = voxeldungeon.utils.randomChances(pathTunnels)
		end
		pathTunnels[tunnels] = pathTunnels[tunnels] - 1

		for j = 1, tunnels do
			local tunnelSpace = voxeldungeon.rooms.empty()
			tunnelSpace.tunnelPlaceholder = true
			table.insert(loop, tunnelSpace)
		end
	end

	table.insert(loop, math.ceil(#loop/2), voxeldungeon.rooms.exit())

	local prev = entrance
	local targetAngle
	for i = 2, #loop do
		local nxt = loop[i]
		targetAngle = startAngle + getTargetAngle(i / #loop)

		if placeRoom(startpos, placedRooms, prev, nxt, targetAngle) then
			table.insert(placedRooms, nxt)
			prev = nxt
		else
			minetest.log("Error: room failed to place")
			return placedRooms
		end
	end

	local tunnels = {}
	for i = 2, #placedRooms - 1 do
		if placedRooms[i].tunnelPlaceholder then
			local oldpos = placedRooms[i].pos
			local oldsize = placedRooms[i].size

			local p1 = vector.subtract(placedRooms[i].pos, placedRooms[i - 1].pos)
			local p2 = vector.subtract(placedRooms[i].pos, placedRooms[i + 1].pos)

			local tunnel = voxeldungeon.rooms.tunnel(p1, p2)
			tunnel.position({
				x = oldpos.x + (oldsize.x - placedRooms[i].size.x),
				y = oldpos.y,
				z = oldpos.z + (oldsize.z - placedRooms[i].size.z),
			})

			table.insert(tunnels, tunnel)
		end
	end

	for _, t in ipairs(tunnels) do
		table.insert(placedRooms, 1, t)
	end

	--[[
	local p1
	local p2
	for _, v in ipairs(placedRooms) do
		if not p1 then
			p1 = v.size
			p2 = v.size
		else
			p1.x = math.min(p1.x, v.size.x)
			p1.y = math.min(p1.y, v.size.y)
			p1.z = math.min(p1.z, v.size.z)
			p2.x = math.max(p2.x, v.size.x)
			p2.y = math.max(p2.y, v.size.y)
			p2.z = math.max(p2.z, v.size.z)
		end
	end
	--]]

	return placedRooms
end

function voxeldungeon.dungeons.placeLevel(level)
	for _, r in ipairs(level) do
		minetest.place_schematic(r.pos, r, "0", nil, true)
	end
end

minetest.register_chatcommand("testdungeon", {
	params = "",
	description = "Create a test dungeon",
	privs = {},
	func = function(name, param)
		voxeldungeon.dungeons.placeLevel(voxeldungeon.dungeons.newLevel(minetest.get_player_by_name(name):get_pos(), 32 * 32))
	end,
})
