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



function entitycontrol.isAlive(index)
	local ent = entitycontrol.get_entity(index)

	if ent and ent:get_pos() then return true end
end

function entitycontrol.getFirstEmptyIndex(index)
	index = index or 1
	local ent = entitycontrol.get_entity(index)

	if index > entitycontrol.count_entities() then
		return nil
	elseif entitycontrol.isAlive(index) then
		return entitycontrol.getFirstEmptyIndex(index + 1)
	else
		return index
	end
end

local function insertEntity(obj)
	local i = entitycontrol.getFirstEmptyIndex() or entitycontrol.count_entities() + 1

	entities[i] = obj
	return i
end

function entitycontrol.count_entities()
	return #entities
end

function entitycontrol.is_entity_tracked(name)
	for _, e in ipairs(entitycontrol.tracked_entities) do
		if e == name then
			return true
		end
	end

	return false
end

--Try to find an entity at the given index.
function entitycontrol.get_entity(index)
	return entities[index]
end

--Either find id of requested entity or make a new spot, requires the actual object
function entitycontrol.get_entity_id(entity)
	local id = (entity:get_luaentity() or entity).entitycontrol_id
	return id
end

local filePath = minetest.get_modpath(minetest.get_current_modname()).."/config.txt"
local file = io.open(filePath, "r")
if file then
	-- read all contents of file into a table of strings
	for line in file:lines() do
		if line:len() > 0 and line:sub(1, 1) ~= '#' then
			table.insert(entitycontrol.tracked_entities, line)
		end
	end
	
	minetest.after(0, function()
		for _, e in ipairs(entitycontrol.tracked_entities) do
			if e and minetest.registered_entities[e] then
				local ent = minetest.registered_entities[e]
				local super_on_activate = ent.on_activate
				local super_on_death = ent.on_death

				entitycontrol.override_entity(e, 
				{
					on_activate = function(self, staticdata, dtime_s)
						super_on_activate(self, staticdata, dtime_s)
						local id = insertEntity(self.object)
						self.entitycontrol_id = id
					end,

					on_death = function(self, killer)
						entities[entitycontrol.get_entity_id(self)] = nil
						super_on_death(self, killer)
					end
				})
			end
		end
	end)
end
