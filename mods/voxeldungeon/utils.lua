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

voxeldungeon.utils.NEIGHBORS8 = 
{
	{x = -1, y = -1, z = 0},
	{x = 0, y = -1, z = 0},
	{x = 1, y = -1, z = 0},
	{x = -1, y = 0, z = 0},
	{x = 1, y = 0, z = 0},
	{x = -1, y = 1, z = 0},
	{x = 0, y = 1, z = 0},
	{x = 1, y = 1, z = 0},
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

function voxeldungeon.utils.blastwave(pos, dir, level)
	local affected = voxeldungeon.utils.getLivingInArea(pos, 1.5, true)

	for _, obj in ipairs(affected) do
		local force = (level + 5) * 2
		local dmg = 2 + level

		if vector.distance(pos, obj:get_pos()) >= 0.5 then
			dir = vector.direction(pos, obj:get_pos())
			force = force / 2
			dmg = dmg / 2
		end

		if obj:is_player() then
			obj:add_player_velocity(vector.multiply(vector.normalize(dir), force))
		else
			obj:set_velocity(vector.multiply(vector.normalize(dir), force))
			mobkit.clear_queue_high(obj:get_luaentity())
		end

		voxeldungeon.mobs.damage(obj, dmg, "poison")
	end

	voxeldungeon.particles.blastwave(pos)
end

function voxeldungeon.utils.canDig(pos)
	local node = minetest.get_node_or_nil(pos)

	if node then
		local nodedef = minetest.registered_nodes[node.name]

		if minetest.get_item_group(node.name, "immortal") == 0 and nodedef.can_dig(pos) then
			return true
		end
	end
end

function voxeldungeon.utils.countTableEntries(table)
	local count = 0

	for _ in pairs(table) do
		count = count + 1
	end

	return count
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

function voxeldungeon.utils.directLineOfSight(a, b)
	local nodes = voxeldungeon.utils.findNodesInLine(a, b)

	for i = 1, #nodes do
		if voxeldungeon.utils.solid(nodes[i].pos) then
			return false
		end
	end

	return true
end

function voxeldungeon.utils.findNodesInLine(a, b)
	local steps = vector.distance(a, b)
	local nodes = {}

	for i = 0, steps do
		local c

		if steps > 0 then
			c = {
				x = a.x + (b.x - a.x) * (i / steps),
				y = a.y + (b.y - a.y) * (i / steps),
				z = a.z + (b.z - a.z) * (i / steps),
			}
		else
			c = a
		end

		table.insert(nodes, {pos = c, node = minetest.get_node_or_nil(c)})
	end

	return nodes
end

function voxeldungeon.utils.flammable(pos)
	return minetest.get_item_group(minetest.get_node(pos).name, "flammable") > 0
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

function voxeldungeon.utils.getLivingInArea(pos, radius, xray)
	local players = voxeldungeon.utils.getPlayersInArea(pos, radius, xray)
	local result = entitycontrol.getEntitiesInArea("mobs", pos, radius, xray)

	for _, p in ipairs(players) do
		table.insert(result, p)
	end

	return result
end

function voxeldungeon.utils.getPlayersInArea(pos, radius, xray)
	local players = {}

	for _, plr in pairs(minetest.get_connected_players()) do
		local plrpos = plr:get_pos()
		if plrpos then
			local plrpos2 = {x = plrpos.x, y = plrpos.y + 1, z = plrpos.z}

			if (vector.distance(pos, plrpos) <= radius or vector.distance(pos, plrpos2) <= radius) and 
					(xray or voxeldungeon.buffs.get_buff("voxeldungeon:mindvision", plr) 
					or voxeldungeon.utils.directLineOfSight(pos, plrpos) or voxeldungeon.utils.directLineOfSight(pos, plrpos2)) then
				table.insert(players, plr)
			end
		end
	end

	return players
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

	return result.." "
end

function voxeldungeon.utils.itemShortDescription(item)
	local level = item:get_meta():get_int("voxeldungeon:level")

	if minetest.get_item_group(item:get_name(), "upgradable") > 0 then
		local desc = minetest.registered_items[item:get_name()].description

		local lvlstr = ""
		if level > 0 then
			lvlstr = " +"..level
		end

		return desc..lvlstr
	else
		return voxeldungeon.utils.splitstring(item:get_description(), '\n')[1]
	end
end

function voxeldungeon.utils.on_punch_common(defender, attacker, time_from_last_punch, tool_capabilities, dir, damage)
	local para = voxeldungeon.buffs.get_buff("voxeldungeon:paralyzed", defender)
	local hp

	if defender:is_player() then
		hp = defender:get_hp()
	else
		hp = defender:get_luaentity().hp
	end

	if para and math.random(0, damage) >= math.random(0, hp) then
		para.detach()

		if defender:is_player() then
			voxeldungeon.glog.i("The pain snapped you out of paralysis!", defender)
		end

		if attacker:is_player() then
			local name

			if defender:is_player() then
				name = defender:get_player_name()
			else
				name = defender:get_luaentity().description
			end

			voxeldungeon.glog.i("The pain snapped "..name.." out of paralysis!", attacker)
		end
	end
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

	if upper < lower then upper, lower = voxeldungeon.utils.swap(upper, lower) end

	return lower + (math.random(0, 10000) / 10000) * (upper - lower)
end

function voxeldungeon.utils.randomObject(tbl, remove)
	if #tbl > 0 then
		if remove then
			return table.remove(tbl, math.random(#tbl))
		else
			return tbl[math.random(#tbl)]
		end
	end

	return nil
end

function voxeldungeon.utils.randomTeleport(obj)
	local range = 75
	local p = vector.round(obj:get_pos())
	local nonsolids = {}

	for a = -range, range, 2 do
		for b = -range, range, 2 do
			local testpos = {x = p.x + a, y = p.y, z = p.z + b}
			local testpos2 = {x = p.x + a, y = p.y + 1, z = p.z + b}
			local testpos3 = {x = p.x + a, y = p.y + 2, z = p.z + b}

			if not voxeldungeon.utils.solid(testpos) and not voxeldungeon.utils.solid(testpos2) and not voxeldungeon.utils.solid(testpos3) then 
				table.insert(nonsolids, testpos)
			end
		end
	end

	if #nonsolids > 0 then
		obj:set_pos(voxeldungeon.utils.randomObject(nonsolids))
			
		minetest.sound_play("voxeldungeon_teleport", 
		{
			pos = obj:get_pos(),
			gain = 1.0,
			max_hear_distance = 32,
		})

		if obj:is_player() then
			voxeldungeon.glog.i("Chose "..minetest.get_node(obj:get_pos()).name)
			voxeldungeon.glog.i("In the blink of an eye, you are teleported another location.", obj)
		end
	elseif obj:is_player() then
		voxeldungeon.glog.i("There's no enough space available for a teleportation.", obj)
	end
end

function voxeldungeon.utils.randomItem(invref, listname)
	listname = listname or "main"
	local items = {}

	for i = 1, invref:get_size(listname) do
		local stack = invref:get_stack(listname, i)

		if not stack:is_empty() then
			table.insert(items, stack)
		end
	end

	if #items > 0 then
		return items[math.random(#items)]
	else
		return nil
	end
end

function voxeldungeon.utils.removeSpaces(str)
	local words = voxeldungeon.utils.splitstring(str, ' ')
	local mashed = ""

	for _, w in ipairs(words) do
		mashed = mashed..w
	end

	return mashed
end

function voxeldungeon.utils.round(num, factor)
	if factor then
		return voxeldungeon.utils.round(num * factor) / factor
	else
		return math.floor(num + .5)
	end
end

function voxeldungeon.utils.shallowCloneTable(table)
	local clone = {}

	for k, v in pairs(table) do
		clone[k] = v
	end

	return clone
end

function voxeldungeon.utils.solid(pos)
	local node = minetest.get_node(pos)
	
	if not node or node.name == "ignore" then return true end
	
	local nodedef = minetest.registered_nodes[node.name]
	
	return (not nodedef or nodedef.walkable)
end

function voxeldungeon.utils.splitstring(input, sep)
        input = input or "!!!NO TEXT FOUND!!!"
	sep = sep or "%s"

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

function voxeldungeon.utils.tohex(byte)
	byte = voxeldungeon.utils.round(voxeldungeon.utils.gate(0, byte, 255))
	local hex = string.format("%x", byte)

	if string.len(hex) == 1 then
		return "0"..hex
	else
		return hex
	end
end

function voxeldungeon.utils.wet(pos)
	return minetest.get_item_group(minetest.get_node(pos).name, "water") > 0
end
