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

voxeldungeon.playerhandler = {}

voxeldungeon.playerhandler.playerdata = {} --data that gets saved
voxeldungeon.playerhandler.tempdata = {} --data that gets reset once the player leaves

local startingPlayerStats =
{
	HT = 20,
	STR = 10,
}

minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	voxeldungeon.playerhandler.playerdata[name] = {}

	local keyHT = name.."_HT"
	local keySTR = name.."_STR"

	local playerHT = voxeldungeon.storage.getNum(keyHT)
	local playerSTR = voxeldungeon.storage.getNum(keySTR)

	if playerHT then
		voxeldungeon.playerhandler.playerdata[name].HT = playerHT
		player:set_properties({hp_max = playerHT})
	else
		voxeldungeon.playerhandler.playerdata[name].HT = startingPlayerStats.HT
		voxeldungeon.storage.put(keyHT, startingPlayerStats.HT)
	end

	if playerSTR then
		voxeldungeon.playerhandler.playerdata[name].STR = playerSTR
	else
		voxeldungeon.playerhandler.playerdata[name].STR = startingPlayerStats.STR
		voxeldungeon.storage.put(keySTR, startingPlayerStats.STR)
	end

	voxeldungeon.playerhandler.tempdata[name] = 
	{
		time_from_last_punch = 0
	}
end)

local function leaveplayer(player)
	local name = player:get_player_name()

	local keyHT = name.."_HT"
	local keySTR = name.."_STR"

	voxeldungeon.storage.put(keyHT, voxeldungeon.playerhandler.playerdata[name].HT)
	voxeldungeon.storage.put(keySTR, voxeldungeon.playerhandler.playerdata[name].STR)
end

minetest.register_on_leaveplayer(function(player)
	leaveplayer(player)
end)

minetest.register_on_shutdown(function()
	for _, v in pairs(minetest.get_connected_players()) do
		leaveplayer(v)
	end
end)

function voxeldungeon.playerhandler.setHT(player, amount, fullheal)
	local prev = voxeldungeon.playerhandler.playerdata[player:get_player_name()].HT
	player:set_properties({hp_max = amount})
	voxeldungeon.playerhandler.playerdata[player:get_player_name()].HT = amount

	if fullheal or amount < prev then
		player:set_hp(amount)
	end
end

function voxeldungeon.playerhandler.changeHT(player, change, heal)
	voxeldungeon.playerhandler.setHT(player, voxeldungeon.playerhandler.playerdata[player:get_player_name()].HT + change, false)
	player:set_hp(player:get_hp() + change)
end

function voxeldungeon.playerhandler.setSTR(player, amount)
	voxeldungeon.playerhandler.playerdata[player:get_player_name()].STR = amount
end

function voxeldungeon.playerhandler.changeSTR(player, change)
	voxeldungeon.playerhandler.setSTR(player, voxeldungeon.playerhandler.playerdata[player:get_player_name()].STR + change)
end

function voxeldungeon.playerhandler.getSTR(player)
	local STR = voxeldungeon.playerhandler.playerdata[player:get_player_name()].STR

	if voxeldungeon.buffs.get_buff("voxeldungeon:weakness", player) then
		STR = STR - 2
	end

	return STR
end

minetest.register_chatcommand("mystats", {
	params = "",
	description = "View your stats like max hp, strength, etc.",
	privs = {},

	func = function(name)
		local data = voxeldungeon.playerhandler.playerdata[name]
		voxeldungeon.glog.i("Max HP = "..data.HT..", STR = "..data.STR, name)
	end
})



--Player punch time handling
minetest.register_globalstep(function(dtime)
	for _, player in pairs(minetest.get_connected_players()) do
		local name = player:get_player_name()
		voxeldungeon.playerhandler.tempdata[name].time_from_last_punch = voxeldungeon.playerhandler.tempdata[name].time_from_last_punch + dtime
	end
end)

function voxeldungeon.playerhandler.getTimeFromLastPunch(player)
	local name = player:get_player_name()
	local time = voxeldungeon.playerhandler.tempdata[name].time_from_last_punch

	voxeldungeon.playerhandler.tempdata[name].time_from_last_punch = 0

	return time
end



--Stop a player in place, while allowing gravity and fall damage to still occur.
minetest.register_entity("voxeldungeon:stop_player", {
	initial_properties = {
		physical = true,
		collide_with_objects = false,
		pointable = false,
		--is_visible = false,
		collisionbox = {-0.1, 0.0, -0.1, 0.1, 0.2, 0.1}
	}
})

function voxeldungeon.playerhandler.halt(player)
	local obj = minetest.add_entity(player:get_pos(), "voxeldungeon:stop_player")

	player:set_attach(obj, "", {x = 0, y = 1, z = 0}, {x = 0, y = 0, z = 0})

	minetest.after(0.1, function()
		player:set_detach()
		obj:remove()
	end)
end



--Give Initial Stuff
minetest.register_on_newplayer(function(player)
	local inv = player:get_inventory()

	inv:add_item("main", ItemStack("voxeldungeon:ration"))

	local armor = ItemStack("voxeldungeon:armor_cloth")
	voxeldungeon.tools.updateDescriptionArmor(armor)
	inv:add_item("main", armor)
end)
