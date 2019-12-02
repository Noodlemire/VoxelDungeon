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

voxeldungeon.override = {} --global override variable

--[[
Description:
    Overrides the on_dig event of the given node in such a way that it adds the provided function to on_dig, without deleting the old on_dig method
Parameters:
    nodename: The internal name of the node that will be overridden
    new_on_dig: The name of the function that will be called in addition to nodename's usual on_dig event
Returns: 
    Nothing
--]]
function voxeldungeon.override.add_dig_event(nodename, new_on_dig)
    --Store the old on_dig event for later use
    local old_on_dig = minetest.registered_nodes[nodename].on_dig
    --Create a function that calls both the old and new on_dig methods
    local master_on_dig = function(pos, node, player)
        --Call the old on_dig function if there is one set
        if old_on_dig ~= nil then 
            old_on_dig(pos, node, player)
        end

        --Then, call the new on_punch method
        new_on_dig(pos, node, player)
    end

    --Override the given node with the combination of old and new on_dig functions
    minetest.override_item(nodename, {on_dig = master_on_dig})
end

--[[
Description:
    Overrides the after_place_node event of the given node in such a way that it adds the provided function to after_place_node, without deleting the old after_place_node method
Parameters:
    nodename: The internal name of the node that will be overridden
    new_after_place: The name of the function that will be called in addition to nodename's usual after_place_node event
Returns: 
    Nothing
--]]
function voxeldungeon.override.add_after_place_event(nodename, new_after_place)
    --Store the old after_place_node event for later use
    local old_after_place = minetest.registered_nodes[nodename].after_place_node
    --Create a function that calls both the old and new after_place_node methods
    local master_after_place = function(pos, itemstack, placer, pointed_thing)
        --Call the old after_place_node function if there is one set
        if old_after_place ~= nil then 
            old_after_place(pos, itemstack, placer, pointed_thing)
        end

        --Then, call the new on_punch method
        new_after_place(pos, itemstack, placer, pointed_thing)
    end

    --Override the given node with the combination of old and new after_place_node functions
    minetest.override_item(nodename, {after_place_node = master_after_place})
end

--[[
Description:
    Overrides the on_punch event of the given node in such a way that it adds the provided function to on_punch, without deleting the old on_punch method
Parameters:
    nodename: The internal name of the node that will be overridden
    new_on_punch: The name of the function that will be called in addition to nodename's usual on_punch event
Returns: 
    Nothing
--]]
function voxeldungeon.override.add_punch_event(nodename, new_on_punch)
    --Store the old on_punch event for later use
    local old_on_punch = minetest.registered_nodes[nodename].on_punch
    --Create a function that calls both the old and new on_punch methods
    local master_on_punch = function(pos, node, player, pointed_thing)
        --Call the old on_punch function if there is one set
        if old_on_punch ~= nil then 
            old_on_punch(pos, node, player, pointed_thing)
        end

        --Then, call the new on_punch method
        new_on_punch(pos, node, player, pointed_thing)
    end

    --Override the given node with the combination of old and new on_punch functions
    minetest.override_item(nodename, {on_punch = master_on_punch})
end



--[[
Description:
    Overrides the on_dig, after_place_node, and on_punch events of all registered nodes in such a way that it adds the provided function to on_dig, on_place and on_punch, without deleting any old methods
Parameters:
    new_on_event: The name of the function that will be called in addition whenever a node is punched, placed, or dug up
Returns: 
    Nothing
--]]
function voxeldungeon.override.register_add_on_digplacepunchnode(new_on_event)
    --For every registered node,
    for nodename, nodereal in pairs(minetest.registered_nodes) do
        --Add the given new_on_event to each node's on_dig, after_place_node, and on_punch events
        voxeldungeon.override.add_dig_event(nodename, new_on_event)
        voxeldungeon.override.add_after_place_event(nodename, new_on_event)
        voxeldungeon.override.add_punch_event(nodename, new_on_event)
    end
end
