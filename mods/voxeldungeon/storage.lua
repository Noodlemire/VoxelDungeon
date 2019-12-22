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

voxeldungeon.storage = {}

local store = minetest.get_mod_storage()

function voxeldungeon.storage.put(key, val)
	local t = type(val)

	if t == "string" then
		store:set_string(key, val)
	elseif t == "number" then
		store:set_float(key, val)
	elseif val == true then
		store:set_int(key, 1)
	elseif not val then
		store:set_string(key, "")
	else
		minetest.log("error", "Attempt to put val of type "..t.." into key "..key)
	end
end

function voxeldungeon.storage.getStr(key)
	if not store:contains(key) then return nil end

	return store:get_string(key)
end

function voxeldungeon.storage.getNum(key)
	if not store:contains(key) then return nil end

	return store:get_float(key)
end

function voxeldungeon.storage.getBool(key)
	return store:contains(key)
end

function voxeldungeon.storage.del(key)
	voxeldungeon.storage.put(key)
end
