cannons.register_muni("tnt:tnt",{
	physical = false,
	timer=0,
	textures = {"tnt_top.png", "tnt_bottom.png", "tnt_side.png", "tnt_side.png", "tnt_side.png", "tnt_side.png"},
	lastpos={},
	damage=15,
	visual = "cube",
	visual_size = {x=0.5, y=0.5},
	range=1,
	gravity=10,
	velocity=20,
	collisionbox = {-0.25,-0.25,-0.25, 0.25,0.25,0.25},
	on_player_hit = function(self,pos,player)
		minetest.registered_nodes["tnt:tnt_burning"].on_timer(pos);
		self.object:remove()
	end,
	on_mob_hit = function(self,pos,mob)
		minetest.registered_nodes["tnt:tnt_burning"].on_timer(pos);
		self.object:remove()
	end,
	on_node_hit = function(self,pos,node)
		minetest.registered_nodes["tnt:tnt_burning"].on_timer(pos);
		self.object:remove()
	end,
})

cannons.register_gunpowder("tnt:gunpowder");