--++++++++++++++++++++++++++++++++++++
--+ Meseball                         +
--++++++++++++++++++++++++++++++++++++
local exploding={
	physical = false,
	timer=0,
	textures = {"default_mese_block.png","default_mese_block.png","default_mese_block.png","default_mese_block.png","default_mese_block.png","default_mese_block.png"},
	lastpos={},
	damage=15,
	visual = "cube",
	visual_size = {x=0.5, y=0.5},
	range=1,
	gravity=10,
	velocity=30,
	collisionbox = {-0.25,-0.25,-0.25, 0.25,0.25,0.25},
	on_player_hit = function(self,pos,player)
		local playername = player:get_player_name()
		player:punch(self.object, 1.0, {
			full_punch_interval=1.0,
			damage_groups={fleshy=self.damage},
			}, nil)
		self.object:remove()
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
		cannons.destroy({x=pos.x, y=pos.y, z=pos.z},self.range)
		minetest.sound_play("cannons_shot",
			{pos = pos, gain = 1.0, max_hear_distance = 32,})
		self.object:remove()
	end,

}
if minetest.settings:get_bool("cannons_enable_explosion") then
	cannons.register_muni("cannons:ball_exploding_stack_1",exploding)
end
local fire={
	physical = false,
	timer=0,
	textures = {"default_tree.png","default_tree.png","default_tree.png","default_tree.png","default_tree.png","default_tree.png"},
	lastpos={},
	damage=10,
	visual = "cube",
	visual_size = {x=0.5, y=0.5},
	range=2,
	gravity=8,
	velocity=35,
	collisionbox = {-0.25,-0.25,-0.25, 0.25,0.25,0.25},
	on_player_hit = function(self,pos,player)
		local playername = player:get_player_name()
		player:punch(self.object, 1.0, {
			full_punch_interval=1.0,
			damage_groups={fleshy=self.damage},
			}, nil)
		self.object:remove()
	end,
	on_mob_hit = function(self,pos,mob)
		self.object:remove()
	end,
	on_node_hit = function(self,pos,node)
		cannons.nodehitparticles(pos,node)
		pos = self.lastpos
		minetest.env:set_node({x=pos.x, y=pos.y, z=pos.z},{name="fire:basic_flame"})
		minetest.sound_play("default_break_glass",
			{pos = pos, gain = 1.0, max_hear_distance = 32,})
		self.object:remove()
	end,

}
if minetest.settings:get_bool("cannons_enable_fire") then
	cannons.register_muni("cannons:ball_fire_stack_1",fire)
end

--++++++++++++++++++++++++++++++++++++
--+ Wooden Cannon ball                +
--++++++++++++++++++++++++++++++++++++

cannons.register_muni("cannons:ball_wood_stack_1",{
	physical = false,
	timer=0,
	textures = {"cannons_wood_bullet.png"},
	lastpos={},
	damage=20,
	range=1,
	gravity=10,
	velocity=40,
	collisionbox = {-0.25,-0.25,-0.25, 0.25,0.25,0.25},
	on_player_hit = function(self,pos,player)
		local playername = player:get_player_name()
		player:punch(self.object, 1.0, {
			full_punch_interval=1.0,
			damage_groups={fleshy=self.damage},
			}, nil)
		self.object:remove()
		minetest.chat_send_all(playername .." tried to catch a cannonball")
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
			minetest.env:set_node({x=pos.x, y=pos.y, z=pos.z},{name="default:dirt"})
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

--++++++++++++++++++++++++++++++++++++
--+ Stone Cannon ball                +
--++++++++++++++++++++++++++++++++++++

cannons.register_muni("cannons:ball_stone_stack_1",{
	physical = false,
	timer=0,
	textures = {"cannons_bullet.png"},
	lastpos={},
	damage=20,
	range=2,
	gravity=10,
	velocity=40,
	collisionbox = {-0.25,-0.25,-0.25, 0.25,0.25,0.25},
	on_player_hit = function(self,pos,player)
		local playername = player:get_player_name()
		player:punch(self.object, 1.0, {
			full_punch_interval=1.0,
			damage_groups={fleshy=self.damage},
			}, nil)
		self.object:remove()
		minetest.chat_send_all(playername .." tried to catch a cannonball")
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
			minetest.env:set_node({x=pos.x, y=pos.y, z=pos.z},{name="default:dirt"})
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

--++++++++++++++++++++++++++++++++++++
--+ Steel Cannon ball                +
--++++++++++++++++++++++++++++++++++++

cannons.register_muni("cannons:ball_steel_stack_1",{
	physical = false,
	timer=0,
	textures = {"cannons_bullet_iron.png"},
	lastpos={},
	damage=30,
	range=2,
	gravity=5,
	velocity=50,
	collisionbox = {-0.25,-0.25,-0.25, 0.25,0.25,0.25},
	on_player_hit = function(self,pos,player)
		local playername = player:get_player_name()
		player:punch(self.object, 1.0, {
			full_punch_interval=1.0,
			damage_groups={fleshy=self.damage},
			}, nil)
		self.object:remove()
		minetest.chat_send_all(playername .." tried to catch a canonball")
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
			minetest.env:set_node({x=pos.x, y=pos.y, z=pos.z},{name="default:dirt"})
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
