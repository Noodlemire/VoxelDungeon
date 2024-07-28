--[[
		Minetest-mod "Charcoal", A mod with charcoal lumps and blocks
		Copyright (C) 2021 J. A. Anders

		This program is free software; you can redistribute it and/or modify
		it under the terms of the GNU General Public License as published by
		the Free Software Foundation; version 3 of the License.

		This program is distributed in the hope that it will be useful,
		but WITHOUT ANY WARRANTY; without even the implied warranty of
		MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
		GNU General Public License for more details.

		You should have received a copy of the GNU General Public License
		along with this program; if not, write to the Free Software
		Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston,
		MA 02110-1301, USA.
]]

--
-- Mod Version 0.1
--

charcoal = {}

-- Get Translator
local S = minetest.get_translator("charcoal")
charcoal.get_translator = S
local S = charcoal.get_translator

-- Basic Charcoal
minetest.register_craftitem("charcoal:charcoal", {
  description = S("Charcoal Lump"),
  inventory_image = "charcoal_charcoal.png",
})

-- Charcoal Block
minetest.register_node("charcoal:charcoal_block", {
  description = S("Charcoal Block"),
  inventory_image = minetest.inventorycube("charcoal_charcoal_block.png"),
  tiles = {"charcoal_charcoal_block.png"},
  groups = {cracky=3, oddly_breakalbe_by_hand=1},
  sounds = default.node_sound_stone_defaults(),
})


-- Use Charcoal as fuel
minetest.register_craft({
  type = "fuel",
  recipe = "charcoal:charcoal",
  burntime = 30,
})

minetest.register_craft({
  type = "fuel",
  recipe = "charcoal:charcoal_block",
  burntime = 270,
})



-- Craft Charcoal
minetest.register_craft({
  type = "cooking",
  output = "charcoal:charcoal 2",
  recipe = "group:tree",
  cooktime = 8,
})

minetest.register_craft({
  type = "shaped",
  output = "charcoal:charcoal_block",
  recipe = {
    {"charcoal:charcoal","charcoal:charcoal","charcoal:charcoal"},
    {"charcoal:charcoal","charcoal:charcoal","charcoal:charcoal"},
    {"charcoal:charcoal","charcoal:charcoal","charcoal:charcoal"},
  },
})

minetest.register_craft({
  type = "shapeless",
  output = "charcoal:charcoal 9",
  recipe = {"charcoal:charcoal_block"}
})

-- Make torches from charcoal
minetest.register_craft({
  type = "shaped",
  output = "default:torch 2",
  recipe = {
    {"charcoal:charcoal"},
    {"default:stick"},
  },  
})

