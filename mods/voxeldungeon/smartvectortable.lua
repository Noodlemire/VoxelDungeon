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

function voxeldungeon.smartVectorTable()
	local svt = {}

	svt.table = {}

	svt.set = function(keyVect, value)
		if not keyVect or not value then return end

		for _, v in ipairs(svt.table) do
			if vector.equals(keyVect, v.k) then
				v.v = value
				return
			end
		end

		table.insert(svt.table, {k = keyVect, v = value})
	end

	svt.del = function(keyVect)
		for i, v in ipairs(svt.table) do
			if vector.equals(keyVect, v.k) then
				table.remove(svt.table, i)
				return
			end
		end
	end

	svt.get = function(keyVect)
		for _, v in ipairs(svt.table) do
			if vector.equals(keyVect, v.k) then
				return v.v
			end
		end

		return nil
	end

	svt.getVector = function(i)
		return svt.table[i].k
	end

	svt.getValue = function(i)
		return svt.table[i].v
	end

	svt.size = function()
		return #svt.table
	end

	--[[
	svt.iterator = function()
		local function SVTiterate(i)
			i = i + 1
			if i > #svt.table then
				return nil, nil
			else
				return svt.table[i].k, svt.table[i].v
			end
		end

		return SVTiterate, 0
	end
	]]

	return svt
end
