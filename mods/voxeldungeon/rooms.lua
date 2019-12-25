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

voxeldungeon.rooms = {}

local _ = {name = "air", param1 = 0}
local A = {name = "air", force_place = true}
local B = {name = "voxeldungeon:sewerbookshelf", force_place = true}
local C = {name = "voxeldungeon:dormant_chest", force_place = true}
local F = {name = "voxeldungeon:sewerfloor", force_place = true}
local G = {name = "voxeldungeon:foilage_sewers_tallgrass", force_place = true}
local Gt = {name = "voxeldungeon:foilage_sewers_tallgrass_top", force_place = true}
local Gf = {name = "voxeldungeon:sewergrass", force_place = true}
local L = {name = "default:water_source", force_place = true}
local P = {name = "voxeldungeon:sewerpedestal", force_place = true}
local S = {name = "voxeldungeon:sewerwood", force_place = true}
local W = {name = "voxeldungeon:sewerwall", force_place = true}

local function newRoom()
	local room = {}
	
	room.position = function(pos)
		room.pos = pos
		room.rect = 
		{
			north = pos.z + room.size.z,
			south = pos.z,
			east = pos.x + room.size.x,
			west = pos.x,
		}
	end

	room.set = function(other)
		
	end

	room.shift = function(a, b, c)
		room.pos = vector.add(room.pos, {x=a, y=b, z=c})
		room.rect.north = room.rect.north + c
		room.rect.south = room.rect.south + c
		room.rect.east = room.rect.east + a
		room.rect.west = room.rect.west + a
	end

	return room
end

function voxeldungeon.rooms.cube(sf)
	-- 4-10, 8-14, or 12-18, by default
	local sizefactor = (sf or math.random(1, 3)) * 4
	local s = {
		x = sizefactor + math.random(0, 6),
		y = 6,
		z = sizefactor + math.random(0, 6)
	}
	local d = {}

	local i = 1
	for c = 1, s.z do
		for b = 1, s.y do
			for a = 1, s.x do
				if a == 1 or b == 1 or c == 1 or a == s.x or b == s.y or c == s.z then
					d[i] = W
				elseif b == 2 then
					d[i] = F
				else
					d[i] = A
				end

				i = i + 1
			end
		end
	end

	local room = newRoom()
	room.size = s
	room.data = d
	return room
end

function voxeldungeon.rooms.empty(sf)
	-- 4-10, 8-14, or 12-18, by default
	local sizefactor = (sf or math.random(1, 3)) * 4
	local s = {
		x = sizefactor + math.random(0, 6),
		y = 6,
		z = sizefactor + math.random(0, 6)
	}
	local d = {}

	local i = 1
	for c = 1, s.z do
		for b = 1, s.y do
			for a = 1, s.x do
				d[i] = _

				i = i + 1
			end
		end
	end

	local room = newRoom()
	room.size = s
	room.data = d
	return room
end



--must-have rooms

function voxeldungeon.rooms.entrance()
	local room = voxeldungeon.rooms.cube(math.random(1, 3))
	local s = room.size
	local d = room.data

	local i = 1
	for c = 1, s.z do
		for b = 1, s.y do
			for a = 1, s.x do
				if b == s.y and a ~= 1 and a ~= s.x and c ~= 1 and c ~= s.z then
					d[i] = _
				end

				i = i + 1
			end
		end
	end

	return room
end

function voxeldungeon.rooms.exit()
	local room = voxeldungeon.rooms.cube(math.random(1, 3))
	local s = room.size
	local d = room.data

	local i = 1
	for c = 1, s.z do
		for b = 1, s.y do
			for a = 1, s.x do
				if b <= 2 and a ~= 1 and a ~= s.x and c ~= 1 and c ~= s.z then
					d[i] = _
				end

				i = i + 1
			end
		end
	end

	return room
end



--Pathways
--
function voxeldungeon.rooms.tunnel(startpos, endpos)
	local midpos
	if math.random(2) == 1 then
		midpos = {
			x = startpos.x,
			z = endpos.z
		}
	else
		midpos = {
			x = endpos.x,
			z = startpos.z
		}
	end

	if startpos.x < 0 or endpos.x < 0 then
		local x = -math.min(startpos.x, endpos.x) + 1

		startpos.x = startpos.x + x
		midpos.x = midpos.x + x
		endpos.x = endpos.x + x
	end

	if startpos.z < 0 or endpos.z < 0 then
		local z = -math.min(startpos.z, endpos.z) + 1

		startpos.z = startpos.z + z
		midpos.z = midpos.z + z
		endpos.z = endpos.z + z
	end

	

	local s = 
	{
		x = math.abs(startpos.x) + math.abs(endpos.x),
		y = 6,
		z = math.abs(startpos.z) + math.abs(endpos.z),
	}
	local d = {}

	local i = 1
	for c = 1, s.z do
		for b = 1, s.y do
			for a = 1, s.x do
				if (a >= startpos.x and a <= midpos.x and c >= startpos.z and c <= midpos.z) or 
						(a <= startpos.x and a >= midpos.x and c <= startpos.z and c >= midpos.z) or 
						(a >= midpos.x and a <= endpos.x and c >= midpos.z and c <= endpos.z) or 
						(a <= midpos.x and a >= endpos.x and c <= midpos.z and c >= endpos.z) then
					if b == 1 or b == s.y then
						d[i] = W
					elseif b == 2 then
						d[i] = F
					else
						d[i] = A
					end
				else
					d[i] = _
				end

				i = i + 1
			end
		end
	end

	local room = newRoom()
	room.size = s
	room.data = d
	return room
end
--]]


--standard rooms

function voxeldungeon.rooms.aquarium()
	local room = voxeldungeon.rooms.cube(math.random(2, 3))
	local s = room.size
	local d = room.data

	local i = 1
	for c = 1, s.z do
		for b = 1, s.y do
			for a = 1, s.x do

				if b == 2 and a > 2 and a < s.x-1 and c > 2 and c < s.z-1 then
					if a == 3 or a == s.x-2 or c == 3 or c == s.z-2 then
						d[i] = S
					else
						d[i] = L
					end
				end

				i = i + 1
			end
		end
	end

	return room
end

function voxeldungeon.rooms.portager()
	local room = voxeldungeon.rooms.cube()
	local s = room.size
	local d = room.data

	local i = 1
	for c = 1, s.z do
		for b = 1, s.y do
			for a = 1, s.x do
				if a ~= 1 and a ~= s.x and b ~= 1 and b ~= s.y and c ~= 1 and c ~= s.z then
					if b == 2 then
						if a % 2 == 0 then
							d[i] = F
						else
							d[i] = S
						end
					elseif b == 3 and a % 2 == 0 then
						d[i] = G
					elseif b == 4 and a % 2 == 0 then
						d[i] = Gt
					end
				end

				i = i + 1
			end
		end
	end

	return room
end

function voxeldungeon.rooms.ring()
	local room = voxeldungeon.rooms.cube(math.random(2, 3))
	local s = room.size
	local d = room.data

	local i = 1
	for c = 1, s.z do
		for b = 1, s.y do
			for a = 1, s.x do
				if a >= s.x * 3 / 7 and a <= s.x * 5 / 7 and c >= s.z * 3 / 7 and c <= s.z * 5 / 7 then
					d[i] = W
				end

				i = i + 1
			end
		end
	end

	return room
end

function voxeldungeon.rooms.study()
	local room = voxeldungeon.rooms.cube(2)
	local s = room.size
	local d = room.data

	local i = 1
	for c = 1, s.z do
		for b = 1, s.y do
			for a = 1, s.x do
				if a ~= 1 and a ~= s.x and b ~= 1 and b ~= s.y and c ~= 1 and c ~= s.z then
					if b == 2 then
						d[i] = S
					elseif a == 2 or c == 2 or a == s.x-1 or c == s.z-1 then
						d[i] = B
					elseif a == math.ceil(s.x/2) and c == math.ceil(s.z/2) then
						if b == 3 then
							d[i] = P
						elseif b == 4 and math.random(3) == 1 then
							d[i] = C
						end
					end
				end

				i = i + 1
			end
		end
	end

	return room
end

local regularRooms = {voxeldungeon.rooms.cube, voxeldungeon.rooms.aquarium, voxeldungeon.rooms.portager, voxeldungeon.rooms.ring, voxeldungeon.rooms.study}

function voxeldungeon.rooms.createNew()
	return regularRooms[math.random(#regularRooms)]()
end

minetest.register_chatcommand("testroom", {
	params = "",
	description = "Create a test room",
	privs = {},
	func = function(name, param)
		local room = voxeldungeon.rooms.createNew()

		minetest.place_schematic(minetest.get_player_by_name(name):get_pos(), room, "random", 
			{--[[replacements; ["old_name"] = "convert_to"]]}, true, "place_center_x, place_center_y, place_center_z")
		return true, "Test Room Created. Enjoy."
	end
})
