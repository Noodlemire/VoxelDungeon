--[[
entitycontrol
Copyright (C) 2019 Noodlemire

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 2.1 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library; if not, write to the Free Software
Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
--]]

entitycontrol = {}

entitycontrol.tracked_entities = {}
local entities = {}
local store = minetest.get_mod_storage()
local biggestID = {}

--[[
Description:
    Alters the properties of the given entity according to the given parameters
Parameters:
    name: The name of the entity to alter.
    redefinition: A list of changes to apply to the given entity. The exact changes can be anything except for its name and type.
Returns:
    Nothing
--]]
function entitycontrol.override_entity(name, redefinition)
    --Stores the current definition of the entity that has the given name
    local entity_to_override = minetest.registered_entities[name]

    --Throw an error if the redefinition tries to rename an entity
    if redefinition.name ~= nil then
		error("Attempt to redefine name of "..name.." to "..dump(redefinition.name), 2)
	end

    --Throw an error if the redefinition tries to turn an entity into something that is not an entity
	if redefinition.type ~= nil then
		error("Attempt to redefine type of "..name.." to "..dump(redefinition.type), 2)
	end

    --Throw an error if there is no entity is known by the given name
	if not entity_to_override then
		error("Attempt to override non-existent item "..name, 2)
	end

    --For each given redefinition,
	for i, v in pairs(redefinition) do
        --Set the index i of the entity to override to value v
		rawset(entity_to_override, i, v)
	end

    --Once the entity has been fully overridden, it can be placed back into minetest's list of registered entities in order to finalize the changes.
	minetest.registered_entities[name] = entity_to_override
end

--[[
Description: 
    Removes a type of entity from minetest so that it will never be spawned again
Parameters: 
    name: The name of the entity to remove
Returns:
    Nothing
--]]
function entitycontrol.unregister_entity(name)
	--Stores the current definition of the entity that has the given name
	local entity_to_unregister = minetest.registered_entities[name]

	--If this definition does not exist, neither does the entity.
	if not entity_to_unregister then
		--Say so in the debug.txt
		minetest.log("warning", "Item " ..name.." already does not exist, so it will not be unregistered.")
		--And leave since there's nothing to do.
		return
	end

	--Otherwise, empty out the registration of the name of the entity to unregister.
	minetest.registered_entities[name] = nil
end



function entitycontrol.isAlive(list, obj)
	if not obj then
		obj = list
		list = "default"
	end

	if type(obj) == "number" then
		obj = entitycontrol.get_entity(list, obj)
	end

	if obj == "unloaded" then return false end

	if obj and obj:get_pos() then return true end
end

local function directLineOfSight(a, b)
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

	for i = 1, #nodes do
		if nodes[i].node and minetest.registered_nodes[nodes[i].node.name].walkable then
			return false
		end
	end

	return true
end

function entitycontrol.getEntitiesInArea(list, pos, radius, xray)
	if xray == nil then
		xray = radius
		radius = pos
		pos = list
		list = "default"
	end

	local ents = {}

	for i = 1, entitycontrol.count_entities(list) do
		local ent = entitycontrol.get_entity(list, i)

		if entitycontrol.isAlive(list, i) then
			local box = minetest.registered_entities[ent:get_luaentity().name].collisionbox
			local floor = math.floor(box[2])
			local height = math.ceil(box[5])

			for i = floor, height do
				local checkpos = ent:get_pos()
				checkpos.y = checkpos.y + i

				if vector.distance(pos, checkpos) <= radius and (xray or directLineOfSight(pos, checkpos)) then
					table.insert(ents, ent)
					break
				end
			end
		end
	end

	return ents
end

function entitycontrol.getFirstEmptyIndex(list, index)
	if not index then
		if not list or type(list) == "string" then
			index = 1
		else
			index = list
		end

		list = "default"
	end

	local ent = entitycontrol.get_entity(list, index)

	if index > entitycontrol.count_entities(list) then
		return nil
	--elseif ent == "unloaded" or entitycontrol.isAlive(list, index) then
	elseif ent then
		return entitycontrol.getFirstEmptyIndex(list, index + 1)
	else
		return index
	end
end

local function insertEntity(list, obj)
	if not obj then
		obj = list
		list = "default"
	end

	local i = entitycontrol.getFirstEmptyIndex(list) or entitycontrol.count_entities(list) + 1

	biggestID[list] = math.max(biggestID[list] or 0, i)

	entities[list][i] = obj
	return i
end

function entitycontrol.count_entities(list)
	list = list or "default"

	return biggestID[list] or 0
end

function entitycontrol.is_entity_tracked(list, name)
	if not name then
		name = list
		list = "default"
	end

	for _, e in ipairs(entitycontrol.tracked_entities[list]) do
		if e == name then
			return true
		end
	end

	return false
end

--Try to find an entity at the given index.
function entitycontrol.get_entity(list, index)
	if not index then
		index = list
		list = "default"
	end

	return entities[list][index]
end

--Either find id of requested entity or make a new spot, requires the actual object
function entitycontrol.get_entity_id(list, entity)
	if not entity then
		entity = list
		list = "default"
	end

	if not entity.entitycontrol_id --[[and pcall(entity:get_luaentity())--]] then
		entity = entity:get_luaentity()
	end

	if not entity or not entity.entitycontrol_id then return nil end

	return entity.entitycontrol_id[list]
end

function entitycontrol.registerTrackingList(name, entityList)
	entitycontrol.tracked_entities[name] = entityList
	entities[name] = {}
end

local filePath = minetest.get_modpath(minetest.get_current_modname()).."/config.txt"
local file = io.open(filePath, "r")
if file then
	local defaultList = {}

	-- read all contents of file into a table of strings
	for line in file:lines() do
		if line:len() > 0 and line:sub(1, 1) ~= '#' then
			table.insert(defaultList, line)
		end
	end

	entitycontrol.registerTrackingList("default", defaultList)

	io.close()
else
	entitycontrol.registerTrackingList(defaultList, {})
end



local function splitstring(input, sep)
        if not sep then
                sep = "%s"
        end

        local t = {}
        for str in string.gmatch(input, "([^"..sep.."]+)") do
                table.insert(t, str)
        end

        return t
end

minetest.register_on_mods_loaded(function()
	for list, ents in pairs(entitycontrol.tracked_entities) do
		for _, e in ipairs(ents) do
			if e and minetest.registered_entities[e] then
				local ent = minetest.registered_entities[e]
				local super_on_activate = ent.on_activate
				local super_get_staticdata = ent.get_staticdata
				local super_on_death = ent.on_death

				entitycontrol.override_entity(e, 
				{
					on_activate = function(self, staticdata, dtime_s)
						super_on_activate(self, staticdata, dtime_s)

						local data = minetest.deserialize(staticdata)

						if data and data.entitycontrol_id then

							local id = data.entitycontrol_id[list]
								
							entities[list][id] = self.object
							--store:set_string(list.."_"..id, "")
							biggestID[list] = math.max(biggestID[list] or 0, id)
							store:set_string(list.."_"..id, "taken")
						else
							local id = insertEntity(list, self.object)

							if not self.entitycontrol_id then self.entitycontrol_id = {} end
							self.entitycontrol_id[list] = id
						end
					end,

					get_staticdata = function(self)
						local data = minetest.deserialize(super_get_staticdata(self))

						if self.entitycontrol_id then
							data.entitycontrol_id = self.entitycontrol_id

							--[[for list, id in pairs(data.entitycontrol_id) do
								entities[list][id] = "unloaded"
								store:set_string(list.."_"..id, "unloaded")
							end--]]
						end

						return minetest.serialize(data)
					end,

					on_death = function(self, killer)
						store:set_string(list.."_"..self.entitycontrol_id[list], "")

						entities[list][entitycontrol.get_entity_id(list, self)] = nil
						super_on_death(self, killer)
					end
				})
			end
		end
	end

	local table = store:to_table()["fields"]

	for k, _ in pairs(table) do
		local split = splitstring(k, "_")
		local list = split[1]
		local id = tonumber(split[2])

		biggestID[list] = math.max(biggestID[list] or 0, id)

		entities[list][id] = entities[list][id] or "unloaded"
	end
end)
