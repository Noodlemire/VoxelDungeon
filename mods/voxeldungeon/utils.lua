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

voxeldungeon.utils = {}

local A = 180 / math.pi

voxeldungeon.utils.NEIGHBORS6 = 
{
	{x = 0, y = 0, z = -1},
	{x = 0, y = -1, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 1, y = 0, z = 0},
	{x = 0, y = 1, z = 0},
	{x = 0, y = 0, z = 1},
}

voxeldungeon.utils.NEIGHBORS7 = 
{
	{x = 0, y = 0, z = -1},
	{x = 0, y = -1, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = 0},
	{x = 1, y = 0, z = 0},
	{x = 0, y = 1, z = 0},
	{x = 0, y = 0, z = 1},
}

voxeldungeon.utils.NEIGHBORS9 = 
{
	{x = -1, y = -1, z = 0},
	{x = 0, y = -1, z = 0},
	{x = 1, y = -1, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = 0},
	{x = 1, y = 0, z = 0},
	{x = -1, y = 1, z = 0},
	{x = 0, y = 1, z = 0},
	{x = 1, y = 1, z = 0},
}

voxeldungeon.utils.NEIGHBORS26 = 
{
	{x = -1, y = -1, z = -1},
	{x = 0, y = -1, z = -1},
	{x = 1, y = -1, z = -1},
	{x = -1, y = 0, z = -1},
	{x = 0, y = 0, z = -1},
	{x = 1, y = 0, z = -1},
	{x = -1, y = 1, z = -1},
	{x = 0, y = 1, z = -1},
	{x = 1, y = 1, z = -1},
	{x = -1, y = -1, z = 0},
	{x = 0, y = -1, z = 0},
	{x = 1, y = -1, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 1, y = 0, z = 0},
	{x = -1, y = 1, z = 0},
	{x = 0, y = 1, z = 0},
	{x = 1, y = 1, z = 0},
	{x = -1, y = -1, z = 1},
	{x = 0, y = -1, z = 1},
	{x = 1, y = -1, z = 1},
	{x = -1, y = 0, z = 1},
	{x = 0, y = 0, z = 1},
	{x = 1, y = 0, z = 1},
	{x = -1, y = 1, z = 1},
	{x = 0, y = 1, z = 1},
	{x = 1, y = 1, z = 1},
}

voxeldungeon.utils.NEIGHBORS27 = 
{
	{x = -1, y = -1, z = -1},
	{x = 0, y = -1, z = -1},
	{x = 1, y = -1, z = -1},
	{x = -1, y = 0, z = -1},
	{x = 0, y = 0, z = -1},
	{x = 1, y = 0, z = -1},
	{x = -1, y = 1, z = -1},
	{x = 0, y = 1, z = -1},
	{x = 1, y = 1, z = -1},
	{x = -1, y = -1, z = 0},
	{x = 0, y = -1, z = 0},
	{x = 1, y = -1, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 0, y = 0, z = 0},
	{x = 1, y = 0, z = 0},
	{x = -1, y = 1, z = 0},
	{x = 0, y = 1, z = 0},
	{x = 1, y = 1, z = 0},
	{x = -1, y = -1, z = 1},
	{x = 0, y = -1, z = 1},
	{x = 1, y = -1, z = 1},
	{x = -1, y = 0, z = 1},
	{x = 0, y = 0, z = 1},
	{x = 1, y = 0, z = 1},
	{x = -1, y = 1, z = 1},
	{x = 0, y = 1, z = 1},
	{x = 1, y = 1, z = 1},
}



voxeldungeon.utils.surface_valid_ground = {"default:dirt_with_grass", "default:dirt_with_coniferous_litter", "default:dirt_with_rainforest_litter",
			"default:dirt_with_dry_grass", "default:dirt_with_snow", "default:dry_dirt", "default:dry_dirt_with_dry_grass",
			"default:sand", "default:silver_sand", "default:desert_sand", "default:snowblock"}
voxeldungeon.utils.any_valid_ground = {"default:stone", "voxeldungeon:sewerstone", "voxeldungeon:sewerfloor", "voxeldungeon:sewerwall", 
			"voxeldungeon:prisonstone", "voxeldungeon:prisonfloor", "voxeldungeon:prisonwall", 
			"voxeldungeon:cavestone", "voxeldungeon:cavefloor", "voxeldungeon:cavewall", 
			"voxeldungeon:citystone", "voxeldungeon:cityfloor", "voxeldungeon:citywall", 
			"voxeldungeon:hallstone", "voxeldungeon:hallfloor", "voxeldungeon:hallwall"}
voxeldungeon.utils.sewers_valid_ground = {"default:stone", "voxeldungeon:sewerstone", "voxeldungeon:sewerfloor", "voxeldungeon:sewerwall"}
voxeldungeon.utils.prisons_valid_ground = {"voxeldungeon:prisonstone", "voxeldungeon:prisonfloor", "voxeldungeon:prisonwall"}
voxeldungeon.utils.caves_valid_ground = {"voxeldungeon:cavestone", "voxeldungeon:cavefloor", "voxeldungeon:cavewall"}
voxeldungeon.utils.cities_valid_ground = {"voxeldungeon:citystone", "voxeldungeon:cityfloor", "voxeldungeon:citywall"}
voxeldungeon.utils.halls_valid_ground = {"voxeldungeon:hallstone", "voxeldungeon:hallfloor", "voxeldungeon:hallwall"}



function voxeldungeon.utils.angleBetweenPoints(x1, x2, y1, y2)
	local m = (y2 - x2)/(x2 - x1)
	local angle = A * (math.atan(m) + math.pi/2)

	if x1 > x2 then angle = angle - 180 end

	return angle
end

function voxeldungeon.utils.countTableEntries(table)
	local count = 0

	for _ in pairs(table) do
		count = count + 1
	end

	return count
end

function voxeldungeon.utils.cubesIntersect(v1a, v1b, v2a, v2b)
	if v1a.x > v1b.x then v1a.x, v1b.x = voxeldungeon.utils.swap(v1a.x, v1b.x) end
	if v1a.y > v1b.y then v1a.y, v1b.y = voxeldungeon.utils.swap(v1a.y, v1b.y) end
	if v1a.z > v1b.z then v1a.z, v1b.z = voxeldungeon.utils.swap(v1a.z, v1b.z) end
	if v2a.x > v2b.x then v2a.x, v2b.x = voxeldungeon.utils.swap(v2a.x, v2b.x) end
	if v2a.y > v2b.y then v2a.y, v2b.y = voxeldungeon.utils.swap(v2a.y, v2b.y) end
	if v2a.z > v2b.z then v2a.z, v2b.z = voxeldungeon.utils.swap(v2a.z, v2b.z) end

	local comparisons = 
	{
		v1b.x <= v2a.x,
		v1b.y <= v2a.y,
		v1b.z <= v2a.z,
		v1a.x >= v2b.x,
		v1a.y >= v2b.y,
		v1a.z >= v2b.z,
	}

	local overlaps = 0
	for _, v in ipairs(comparisons) do
		if v then
			overlaps = overlaps + 1
		end
	end

	return overlaps >= 3
end

function voxeldungeon.utils.deepCloneTable(obj)
	local clone

	if type(obj) == "table" then
		clone = {}

		for k, v in next, obj, nil do
			clone[voxeldungeon.utils.deepCloneTable(k)] = voxeldungeon.utils.deepCloneTable(v)
		end
	else
		clone = obj
	end

	return clone
end

function voxeldungeon.utils.gate(min, val, max)
	if min and val and val < min then
		return min
	elseif val and max and val > max then
		return max
	else
		return val
	end
end

function voxeldungeon.utils.getChapter(pos)
	if not pos or not pos.y then return end

	local chapter = math.ceil(pos.y / -300)

	return voxeldungeon.utils.gate(1, chapter, 5)
end

function voxeldungeon.utils.getDepth(pos)
	if not pos or not pos.y then return end

	local depth = math.ceil(pos.y / -60)

	return voxeldungeon.utils.gate(0, depth, 25)
end

function voxeldungeon.utils.itemDescription(desc)
	local lines = voxeldungeon.utils.splitstring(desc, '\n')
	local result = ""

	for i = 1, #lines do
		if string.len(lines[i] or "") > 40 then
			local longline = lines[i]
			local words = voxeldungeon.utils.splitstring(longline)
			local charcount = 0

			for w = 1, #words do
				result = result..words[w]..' '
				charcount = charcount + string.len(words[w])

				if charcount >= 40 or w == #words then
					result = result..'\n'
					charcount = 0
				end
			end
		else
			result = result..(lines[i] or "")..'\n'
		end
	end

	return string.sub(result, 1, string.len(result)-1)
end

function voxeldungeon.utils.randomChances(chanceTable)
	local sum = voxeldungeon.utils.sumChances(chanceTable)
	if sum == 0 then return end
	
	local selection = math.floor(math.random(1, sum))
	local current = 0
	
	for obj, chance in pairs(chanceTable) do
		current = current + chance
		if current >= selection then
			return obj
		end
	end
end

function voxeldungeon.utils.randomDecimal(upper, lower)
	upper = upper or 1
	lower = lower or 0

	return lower + (math.random(0, 10000) / 10000) * (upper - lower)
end

function voxeldungeon.utils.randomteleport(obj)
	for try = 1, 10 do
		local p = obj:get_pos()
	
		local testpos = 
		{
			x = p.x + math.random(-100, 100),
			y = p.y + 0.5,
			z = p.z + math.random(-100, 100)
		}
		
		if not minetest.registered_nodes[minetest.get_node(testpos).name].walkable then 
			obj:set_pos(testpos)
			
			minetest.sound_play("voxeldungeon_teleport", 
			{
				pos = obj:get_pos(),
				gain = 1.0,
				max_hear_distance = 32,
			})
			return 
		end
	end
end

function voxeldungeon.utils.round(num)
	return math.floor(num + .5)
end

function voxeldungeon.utils.shallowCloneTable(table)
	local clone = {}

	for k, v in pairs(table) do
		clone[k] = v
	end

	return clone
end

function voxeldungeon.utils.solid(pos)
	pos = vector.round(pos)

	local node = minetest.get_node_or_nil(pos)
	
	if not node then return true end
	
	local nodedef = minetest.registered_nodes[node.name]
	
	return (node.name ~= "air" and nodedef and nodedef.walkable)
end

function voxeldungeon.utils.splitstring(input, sep)
        if not sep then
                sep = "%s"
        end

        local t = {}
        for str in string.gmatch(input, "([^"..sep.."]+)") do
                table.insert(t, str)
        end

        return t
end

function voxeldungeon.utils.sumChances(chanceTable)
	local sum = 0
	for _, chance in pairs(chanceTable) do
		sum = sum + chance
	end
	return sum
end

function voxeldungeon.utils.swap(a, b)
	return b, a
end

function voxeldungeon.utils.tableContains(table, obj)
	for _, v in pairs(table) do
		if v == obj then
			return true
		end
	end

	return false
end

function voxeldungeon.utils.take_item(player, itemstack)
	if not minetest.settings:get_bool("creative_mode") then
		itemstack:take_item()
	end

	return itemstack
end

function voxeldungeon.utils.return_item(player, itemstack)
	if not minetest.settings:get_bool("creative_mode") then
		player:get_inventory():add_item("main", itemstack)
	end

	return itemstack
end

function voxeldungeon.utils.tohex(decimal)
	return string.format("%x", decimal)
end
