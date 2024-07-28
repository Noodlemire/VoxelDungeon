--mithril cannon
minetest.register_node("cannons:cannon_mithril", {
	description = "mithril cannon",
	stack_max = 1,
	tiles = {"cannons_mithril_top.png","cannons_mithril_side.png"},
	drawtype = "mesh",
	selection_box = cannons.nodeboxes.cannon,
	collision_box = cannons.nodeboxes.cannon,
	mesh = "cannon.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=1,cannon=1},
	sounds = cannons.sound_defaults(),
	on_punch = cannons.punched,
	mesecons = cannons.supportMesecons,
	on_construct = cannons.on_construct,
	can_dig = cannons.can_dig,
	allow_metadata_inventory_put = cannons.allow_metadata_inventory_put,	
	allow_metadata_inventory_move = cannons.allow_metadata_inventory_move,	
	on_metadata_inventory_put = cannons.inventory_modified,	
	on_metadata_inventory_take = cannons.inventory_modified,	
	on_metadata_inventory_move = cannons.inventory_modified,	
})

--wood stand with mithril cannon
minetest.register_node("cannons:wood_stand_with_cannon_mithril", {
	description = "wooden stand with mithril cannon",
	cannons ={stand="cannons:wood_stand",cannon="cannons:cannon_mithril"},
	stack_max = 0,
	tiles = {"cannons_mithril_top.png","cannons_mithril_side.png","default_wood.png","default_wood.png^cannons_rim.png"},
	mesh = "cannonstand_cannon.obj",
	selection_box = cannons.nodeboxes.cannon,
	collision_box = cannons.nodeboxes.cannon,
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=2,cannonstand=1},
	sounds = cannons.sound_defaults(),
	on_punch = cannons.punched,
	mesecons = cannons.supportMesecons,
	on_construct = cannons.on_construct,
	can_dig = cannons.can_dig,
	on_dig = cannons.dug,
	allow_metadata_inventory_put = cannons.allow_metadata_inventory_put,	
	allow_metadata_inventory_move = cannons.allow_metadata_inventory_move,	
	on_metadata_inventory_put = cannons.inventory_modified,	
	on_metadata_inventory_take = cannons.inventory_modified,	
	on_metadata_inventory_move = cannons.inventory_modified,		
})	
--ship_stand with mithril cannon
minetest.register_node("cannons:ship_stand_with_cannon_mithril", {
	description = "ship stand with mithril cannon",
	cannons ={stand="cannons:ship_stand",cannon="cannons:cannon_mithril"},
	stack_max = 0,
	tiles = {"cannons_mithril_top.png","cannons_mithril_side.png","cannons_steel_top.png","default_wood.png","default_wood.png^cannons_rim.png"},
	mesh = "ship_cannonstand_cannon.obj",
	selection_box = cannons.nodeboxes.cannon,
	collision_box = cannons.nodeboxes.cannon,
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=2,cannonstand=1},
	sounds = cannons.sound_defaults(),
	on_punch = cannons.punched,
	mesecons = cannons.supportMesecons,
	on_construct = cannons.on_construct,
	can_dig = cannons.can_dig,
	on_dig = cannons.dug,
	allow_metadata_inventory_put = cannons.allow_metadata_inventory_put,	
	allow_metadata_inventory_move = cannons.allow_metadata_inventory_move,	
	on_metadata_inventory_put = cannons.inventory_modified,	
	on_metadata_inventory_take = cannons.inventory_modified,	
	on_metadata_inventory_move = cannons.inventory_modified,	
})
--craft reziep mithrill cannon
minetest.register_craft({
	output = "cannons:cannon_mithril",
	recipe = {
		{"moreores:mithril_block", "moreores:mithril_block", "moreores:mithril_block"},
		{"cannons:gunpowder", "default:mese_block", ""},
		{"moreores:mithril_block", "moreores:mithril_block", "moreores:mithril_block"}
	},
})

--mithrill ball
cannons.generate_and_register_ball_node("cannons:ball_mithril", {
	description = "Cannon Ball mithril",
	stack_max = 9,
	tiles = {"cannons_mithril_top.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=2},
	sounds = cannons.sound_defaults(),
	node_box = cannons.nodeboxes.ball,
})

minetest.register_craft({
	output = 'cannons:ball_mithril',
	recipe = {
		{"moreores:mithril_block"}
	},
})


--mithril ball
cannons.register_muni("cannons:ball_mithril_stack_1",{
	physical = false,
	timer=0,
	textures = {"cannons_ball_mithril.png"},
	lastpos={},
	damage=60,
	range=3,
	gravity=5,
	velocity=45,
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