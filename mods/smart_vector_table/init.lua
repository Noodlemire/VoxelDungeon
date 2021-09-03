--[[
Smart Vector Table
Copyright (C) 2019-2021 Noodlemire

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

smart_vector_table = {}

local vector_equals = vector and vector.equals or function(a, b)
	return a.x == b.x and a.y == b.y and a.z == b.z
end

local function lessThan(a, b)
	if a.x < b.x then
		return true
	elseif a.x == b.x then
		if a.y < b.y then
			return true
		elseif a.y == b.y then
			if a.z < b.z then
				return true
			end
		end
	end

	return false
end

local function binaryInsert(svt, obj, left, right)
	left = left or 1
	right = right or svt.size()

	if left <= right then
		local mid = math.floor((left + right) / 2)
		local midv = svt.getVector(mid)

		if vector_equals(obj.k, midv) then
			svt.table[mid] = obj
		elseif lessThan(obj.k, midv) then
			return binaryInsert(svt, obj, left, mid - 1)
		else 
			return binaryInsert(svt, obj, mid + 1, right)
		end
	else
		left = math.min(left, svt.size())
		if lessThan(svt.getVector(left), obj.k) then
			left = left + 1
		end

		table.insert(svt.table, left, obj)
	end
end

function smart_vector_table.new()
	local svt = {}

	svt.table = {}

	svt.set = function(keyVect, value)
		if svt.size() > 0 then
			local index = svt.getIndex(keyVect)

			if index then
				svt.table[index].v = value
				return
			end
		end

		local obj = {k = keyVect, v = value}

		if svt.size() == 0 then
			svt.table[1] = obj
		elseif svt.size() == 1 then
			if lessThan(obj.k, svt.getVector(1)) then
				table.insert(svt.table, 1, obj)
			else
				svt.table[2] = obj
			end
		else
			binaryInsert(svt, obj)
		end
	end

	svt.del = function(keyVect)
		table.remove(svt.table, svt.getIndex(keyVect))
	end

	svt.get = function(keyVect, left, right)
		left = left or 1
		right = right or svt.size()

		if left <= right then
			local mid = math.floor((left + right) / 2)
			local midv = svt.getVector(mid)

			if vector_equals(keyVect, midv) then
				return svt.getValue(mid)
			elseif lessThan(keyVect, midv) then
				return svt.get(keyVect, left, mid - 1)
			else 
				return svt.get(keyVect, mid + 1, right)
			end
		end
	end

	svt.getIndex = function(keyVect, left, right)
		left = left or 1
		right = right or svt.size()

		if left <= right then
			local mid = math.floor((left + right) / 2)
			local midv = svt.getVector(mid)

			if vector_equals(keyVect, midv) then
				return mid
			elseif lessThan(keyVect, midv) then
				return svt.getIndex(keyVect, left, mid - 1)
			else 
				return svt.getIndex(keyVect, mid + 1, right)
			end
		end
	end

	svt.getVector = function(i)
		if not svt.table[i] then return end
		return svt.table[i].k
	end

	svt.getValue = function(i)
		if not svt.table[i] then return end
		return svt.table[i].v
	end

	svt.size = function()
		return #svt.table
	end

	svt.add = function(keyVect, value)
		local old = svt.get(keyVect) or 0
		svt.set(keyVect, old + value)
	end

	svt.combineWith = function(other)
		for i = 1, other.size() do
			local k = other.getVector(i)
			local v = other.getValue(i)

			local old = svt.get(k) or 0

			svt.set(k, old + v)
		end
	end

	return setmetatable({}, {
		__index = svt,

		__newindex = function()
			error("You cannot directly modify values in a SmartVectorTable. Please use the existing functions instead.")
		end,

		__metatable = false
	})
end
