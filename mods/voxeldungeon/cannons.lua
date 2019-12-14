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

local function register_muni(name, desc, tex, tier)
	cannons.generate_and_register_ball_node("voxeldungeon:ball_"..name, 
	{
		description = desc,
		tiles = {tex},
		drawtype = "nodebox",
		paramtype = "light",
		paramtype2 = "facedir",
		groups = {cracky = 2},
		sounds = cannons.sound_defaults(),
		node_box = cannons.nodeboxes.ball,
	})

	cannons.register_muni("voxeldungeon:ball_"..name.."_stack_1", {
		physical = false,
		timer = 0,
		textures = {tex},
		lastpos = {},
		damage = 10 + 10 * tier,
		range = 2,
		gravity = math.ceil(10 / tier),
		velocity = 15 + 1 * tier,
		collisionbox = {-0.25, -0.25, -0.25, 0.25, 0.25, 0.25},

		on_player_hit = function(self,pos,player)
			local playername = player:get_player_name()

			player:punch(self.object, 1.0, {
				full_punch_interval = 1.0,
				damage_groups = {fleshy = self.damage},
				}, nil)

			self.object:remove()
			--minetest.chat_send_all(playername .." tried to catch a cannonball")
		end,

		on_mob_hit = function(self,pos,mob)
			mob:punch(self.object, 1.0, {
				full_punch_interval=1.0,
				damage_groups={fleshy=self.damage},
				}, nil)
			self.object:remove()
		end,

		on_node_hit = function(self,pos,node)
			cannons.nodehitparticles(pos,node)
			if node.name == "default:dirt_with_grass" then			
				minetest.env:set_node({x = pos.x, y = pos.y, z = pos.z}, {name = "default:dirt"})
				minetest.sound_play("cannons_hit",
					{pos = pos, gain = 1.0, max_hear_distance = 32,})
				self.object:remove()
			elseif node.name == "default:water_source" then
				minetest.sound_play("cannons_splash",
					{pos = pos, gain = 1.0, max_hear_distance = 32,})
				self.object:remove()
			else
				minetest.sound_play("cannons_hit",
					{pos = pos, gain = 1.0, max_hear_distance = 32,})
				self.object:remove()
			end
		end,
	})
end

register_muni("stone", "Stone Cannon Ball", "default_stone.png", 1)
register_muni("steel", "Steel Cannon Ball", "default_steel_block.png", 2)
register_muni("mese", "Mese Cannon Ball", "default_mese_block.png", 3)
register_muni("diamond", "Diamond Cannon Ball", "default_diamond_block.png", 4)
register_muni("demonite", "Demonite Cannon Ball", "voxeldungeon_tiles_demonite_block.png", 5)
