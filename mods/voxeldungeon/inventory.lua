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

local function build_player_inventory(player, action, inventory_info)
	local fs = "size[12,12]"..
		default.gui_bg..
		default.gui_bg_img..
		default.gui_slots..
		"list[current_player;craft;4,1;3,3;]"..
		"list[current_player;craftpreview;8,2;1,1;]"..
		"image[7,2;1,1;gui_furnace_arrow_bg.png^[transformR270]"..
		"listring[current_player;main]"..
		"listring[current_player;craft]"
		
	--Build item slots
	for i = 0, 31 do
		local scale = 1.5
		local x = (i % 8) * scale + .25
		local y = math.floor(i / 8) * scale * 1.1 + 6
		
		if i < 8 then
			y = y - .5
		end
		
		fs = fs.."list[current_player;main;"..x..","..y..";1,1;"..i.."]"
		
		--Add extra icons for items that use them
		local item = player:get_inventory():get_stack("main", i)
		local iconname = item:get_definition()._cornerLR
		if iconname then
			x = x - .75
			y = y + .75

			fs = fs.."image["..x..","..y..";.4375,.4375;"..iconname.."]"
		end
	end
	
	return fs
end

minetest.register_on_joinplayer(function(player)
	player:set_inventory_formspec(build_player_inventory(player))
end)

minetest.register_on_player_receive_fields(function(player)
	player:set_inventory_formspec(build_player_inventory(player))
end)

minetest.register_on_player_inventory_action(function(player)
	local fs = build_player_inventory(player)
	
	player:set_inventory_formspec(fs)
	minetest.show_formspec(player:get_player_name(), "", fs)
end)
