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

voxeldungeon = {} --global variable

math.randomseed(os.time())

--Short for modpath, this stores this really long but automatic modpath get
local mp = minetest.get_modpath(minetest.get_current_modname())..'/'
voxeldungeon.wp = minetest.get_worldpath()..'/'

--Load library files
dofile(mp.."utils.lua")
dofile(mp.."override.lua")
dofile(mp.."glog.lua")
dofile(mp.."storage.lua")
dofile(mp.."playerhandler.lua")
dofile(mp.."itemselector.lua")
dofile(mp.."generator.lua")
dofile(mp.."mobkit.lua")

--Load gameplay files
--dofile(mp.."inventory.lua")
dofile(mp.."particles.lua")
dofile(mp.."buffs.lua")
dofile(mp.."blobs.lua")
dofile(mp.."projectiles.lua")
dofile(mp.."mobs.lua")
dofile(mp.."nodes.lua")
dofile(mp.."items.lua")
dofile(mp.."potions.lua")
dofile(mp.."scrolls.lua")
dofile(mp.."plants.lua")
dofile(mp.."tools.lua")
dofile(mp.."armor.lua")
dofile(mp.."wands.lua")
dofile(mp.."weapons.lua")
dofile(mp.."repair.lua")
dofile(mp.."hunger.lua")
dofile(mp.."cannons.lua")
dofile(mp.."crafting.lua")

--Load world generation files
dofile(mp.."rooms.lua")
dofile(mp.."dungeons.lua")
dofile(mp.."mapgen.lua")

--Unregistration files
dofile(mp.."trashbin.lua")

minetest.register_node("voxeldungeon:rat_model", {
	description = "Rat Model Test",

	groups = {oddly_breakable_by_hand = 1},

	paramtype = "light",
	sunlight_propogates = true,

	drawtype = "mesh",
	mesh = "voxelmodel.obj",
	tiles = {{name = "voxeldungeon_mob_rat_attack.png", animation = {type = "sheet_2d", frames_w = 5, frames_h = 1, frame_length = 0.1}}},
	inventory_image = "voxeldungeon_icon_mob_rat.png",
	wield_image = "voxeldungeon_icon_mob_rat.png",
})
