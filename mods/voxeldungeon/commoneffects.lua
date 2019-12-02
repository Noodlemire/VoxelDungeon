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

--A set of methods commonly caused by a variety of mechanics

function voxeldungeon.randomteleport(obj)
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
