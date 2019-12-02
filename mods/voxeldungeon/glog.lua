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

--Game Log, or chat functions
voxeldungeon.glog = {}

--i for info
function voxeldungeon.glog.i(message, player)
	if player then
		local playername = player
		if type(player) == "userdata" then
			playername = player:get_player_name()
		end
		
		minetest.chat_send_player(playername, message)
	else
		minetest.chat_send_all(message)
	end
end

--p for positive
function voxeldungeon.glog.p(message, player)
	voxeldungeon.glog.i(minetest.colorize("#00FF00", message), player)
end

--n for negative
function voxeldungeon.glog.n(message, player)
	voxeldungeon.glog.i(minetest.colorize("#FF0000", message), player)
end

--w for warning
function voxeldungeon.glog.w(message, player)
	voxeldungeon.glog.i(minetest.colorize("#FF8800", message), player)
end

--h for highlight
function voxeldungeon.glog.h(message, player)
	voxeldungeon.glog.i(minetest.colorize("#FFFF00", message), player)
end
