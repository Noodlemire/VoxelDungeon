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

voxeldungeon.itemselector = {}

local stored_callbacks = {}

local function tileToString(tile)
	if not tile then return end

	if type(tile) == "string" then
		return tile
	else
		return tile.name
	end
end

function voxeldungeon.itemselector.showSelector(player, label, callback)
	local fs = "size[8,5]label[0,0;"..label.."]"
	local inv = player:get_inventory()
	local playername = player:get_player_name()

	for i = 1, inv:get_size("main") do
		local x = (i - 1) % 8
		local y = math.floor((i - 1) / 8) + 1
		local item = inv:get_stack("main", i)

		if item:is_empty() then
			fs = fs.."image["..x..","..y..";1,1;voxeldungeon_ui_itemslot.png]"
		elseif minetest.get_item_group(item:get_name(), "upgradable") > 0 then
			fs = fs.."item_image_button["..x..","..y..";1,1;"..item:get_name()..";slot_button_"..i..";]"..
				"tooltip[slot_button_"..i..";"..voxeldungeon.utils.itemShortDescription(item).."]"
		else
			local tiles = item:get_definition().tiles
			local image = item:get_definition().inventory_image

			if not image or image == "" then
				local t2 = tileToString(tiles[3]) or tileToString(tiles[2])
				local t3 = tileToString(tiles[6]) or t2
				image = minetest.inventorycube(tileToString(tiles[1]), t3, t2)
			end

			fs = fs.."image["..x..","..y..";1,1;voxeldungeon_ui_itemslot.png]"..
				"image["..x..","..y..";1,1;"..image.."^voxeldungeon_overlay_greyout.png]"
		end
	end

	local armor_inv = minetest.get_inventory({type="detached", name=playername.."_armor"})
	local armor = armor_inv:get_stack("armor", 1)

	if armor:is_empty() then
		fs = fs.."image[7,0;1,1;voxeldungeon_ui_itemslot.png]"
	else
		fs = fs.."item_image_button[7,0;1,1;"..armor:get_name()..";slot_button_a;]"..
				"tooltip[slot_button_a;"..voxeldungeon.utils.itemShortDescription(armor).."]"
	end

	stored_callbacks[playername] = callback

	minetest.show_formspec(playername, "voxeldungeon:itemselector", fs)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	--minetest.log("player received field from "..formname)
	if formname == "voxeldungeon:itemselector" then
		local playername = player:get_player_name()

		if fields["quit"] then
			stored_callbacks[playername](player)
		else
			local inv = player:get_inventory()

			for i = 1, inv:get_size("main") do
				if fields["slot_button_"..i] then
					local change = stored_callbacks[playername](player, inv:get_stack("main", i))
					inv:set_stack("main", i, change)
					break
				end
			end

			if fields["slot_button_a"] then
				local armor_inv = minetest.get_inventory({type="detached", name=playername.."_armor"})

				local change = stored_callbacks[playername](player, armor_inv:get_stack("armor", 1))
				armor_inv:set_stack("armor", 1, change)

				voxeldungeon.tools.updateStrdiffArmor(player)
			end
		end

		stored_callbacks[playername] = nil
		minetest.close_formspec(playername, formname)
	end
end)
