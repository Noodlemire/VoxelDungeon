--++++++++++++++++++++++++++++++++++++
--+ Craft Items                      +
--++++++++++++++++++++++++++++++++++++

minetest.register_craftitem("cannons:gunpowder", {
	groups = {gunpowder=1},
	description = "Gunpowder",
	inventory_image = "cannons_gunpowder.png"
})
cannons.register_gunpowder("cannons:gunpowder");

minetest.register_craftitem("cannons:salt", {
	description = "Salt",
	inventory_image = "cannons_salt.png"
})

minetest.register_craftitem("cannons:bucket_salt", {
	description = "Bucket with salt",
	inventory_image = "cannons_bucket_salt.png",
	stack_max = 300
})


--++++++++++++++++++++++++++++++++++++
--+ crafts                           +
--++++++++++++++++++++++++++++++++++++

minetest.register_craft({
    type = "shapeless",
	output = 'cannons:salt 12',
	recipe = {
		"cannons:bucket_salt"
	},
	replacements = {
		{"cannons:bucket_salt", "bucket:bucket_empty"}
	}
})

minetest.register_craft({
	type = "cooking",
	output = 'cannons:bucket_salt',
	recipe = 'bucket:bucket_water',
	cooktime = 15
})

minetest.register_craft({
	type = "shapeless",
	output = 'cannons:gunpowder',
	recipe = {
		"default:coal_lump", "default:mese_crystal", "cannons:salt"
	},
})


-- new crafts --

minetest.register_craft({
	output = "cannons:cannon_steel",
	recipe = {
		{"default:steelblock", "default:steelblock", "default:steelblock"},
		{"cannons:gunpowder", "default:mese_block", ""},
		{"default:steelblock", "default:steelblock", "default:steelblock"}
	},
})

minetest.register_craft({
	output = "cannons:cannon_bronze",
	recipe = {
		{"default:bronzeblock", "default:bronzeblock", "default:bronzeblock"},
		{"cannons:gunpowder", "default:mese_block", ""},
		{"default:bronzeblock", "default:bronzeblock", "default:bronzeblock"}
	},
})

--minetest.register_craft({
--	output = 'cannons:stand',
--	recipe = {
--		{"default:wood", "", "default:wood"},
--		{"default:wood", "default:steelblock", "default:cobble"},
--		{"default:wood", "default:wood", "default:cobble"}
--	},
--})

minetest.register_craft({
	output = 'cannons:wood_stand',
	recipe = {
		{"default:wood", "", "default:wood"},
		{"default:wood", "default:steelblock", "default:wood"},
		{"default:wood", "default:wood", "default:wood"}
	},
})



minetest.register_craft({
	output = 'cannons:ball_wood 5',
	recipe = {
		{"","default:wood",""},
		{"default:wood","default:wood","default:wood"},
		{"","default:wood",""},
	},
})

minetest.register_craft({
	output = 'cannons:ball_stone',
	recipe = {
		{"default:stone"},
	},
})

minetest.register_craft({
	output = 'cannons:ball_steel 2',
	recipe = {
		{"", "default:steel_ingot",""},
		{"default:steel_ingot","default:steel_ingot","default:steel_ingot"},
		{"", "default:steel_ingot",""},
	},
})

if minetest.settings:get_bool("cannons_enable_explosion") then
minetest.register_craft({
	output = 'cannons:ball_exploding 2',
	recipe = {
		{"","default:mese",""},
		{"default:mese","cannons:gunpowder","default:mese"},
		{"","default:mese",""},
	},
})
end

if minetest.settings:get_bool("cannons_enable_fire") then
minetest.register_craft({
	output = 'cannons:ball_fire 2',
	recipe = {
		{"","default:wood",""},
		{"default:wood","default:torch","default:wood"},
		{"","default:wood",""},
	},
})
end
--++++++++++++++++++++++++++++++++++++
--+ cannon stuff                     +
--++++++++++++++++++++++++++++++++++++

--steel cannon
minetest.register_node("cannons:cannon_steel", {
	description = "steel cannon",
	stack_max = 1,
	--tiles = {"cannon_cannon_top.png","cannon_cannon_top.png","cannon_cannon_side.png","cannon_cannon_side.png","cannon_cannon_top.png^cannons_rim.png","cannon_cannon_side.png"},
	tiles = {"cannons_steel_top.png","cannons_steel_side.png"},
	drawtype = "mesh",
	selection_box = cannons.nodeboxes.cannon,
	collision_box = cannons.nodeboxes.cannon,
	mesh = "cannon.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=1,cannon=1},
	sounds = cannons.sound_defaults(),
	--node_box = cannons.nodeboxes.cannon,
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

--bronze cannon
minetest.register_node("cannons:cannon_bronze", {
	description = "bronze cannon",
	stack_max = 1,
	--tiles = {"cannon_cannon_top.png","cannon_cannon_top.png","cannon_cannon_side.png","cannon_cannon_side.png","cannon_cannon_top.png^cannons_rim.png","cannon_cannon_side.png"},
	tiles = {"cannons_bronze_top.png","cannons_bronze_side.png"},
	drawtype = "mesh",
	selection_box = cannons.nodeboxes.cannon,
	collision_box = cannons.nodeboxes.cannon,
	mesh = "cannon.obj",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=1,cannon=1},
	sounds = cannons.sound_defaults(),
	--node_box = cannons.nodeboxes.cannon,
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

minetest.register_node("cannons:wood_stand", {
	description = "Wooden cannon stand",
	stack_max = 9,
	--tiles = side								other
	tiles = {"default_wood.png^cannons_rim.png","default_wood.png"},
	selection_box = cannons.nodeboxes.stand,
	collision_box = cannons.nodeboxes.stand,
	mesh = "cannonstand.obj",
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy=2,cannonstand=1},
	sounds = default.node_sound_wood_defaults(),
	on_rightclick = cannons.stand_on_rightclick
})

minetest.register_node("cannons:ship_stand", {
	description = "Wooden cannon stand",
	stack_max = 9,
	--tiles = wheel					material			side
	tiles = {"cannons_steel_top.png","default_wood.png","default_wood.png^cannons_rim.png"},
	selection_box = cannons.nodeboxes.stand,
	collision_box = cannons.nodeboxes.stand,
	mesh = "ship_cannonstand.obj",
	drawtype = "mesh",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {choppy=2,cannonstand=1},
	sounds = default.node_sound_wood_defaults(),
	on_rightclick = cannons.stand_on_rightclick
})
--wooden stand with steel cannon
--in German: Holzständer mit Stahkanone
minetest.register_node("cannons:wood_stand_with_cannon_steel", {
	description = "wooden stand with steel cannon",
	cannons ={stand="cannons:wood_stand",cannon="cannons:cannon_steel"},
	stack_max = 0,
	tiles = {"cannons_steel_top.png","cannons_steel_side.png","default_wood.png","default_wood.png^cannons_rim.png","cannons_steel_top.png"},
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

minetest.register_node("cannons:ship_stand_with_cannon_steel", {
	description = "ship stand with steel cannon",
	cannons ={stand="cannons:ship_stand",cannon="cannons:cannon_steel"},
	stack_max = 0,
	tiles = {"cannons_steel_top.png","cannons_steel_side.png","cannons_steel_top.png","default_wood.png","default_wood.png^cannons_rim.png"},
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

minetest.register_node("cannons:ship_stand_with_cannon_bronze", {
	description = "ship stand with bronze cannon",
	cannons ={stand="cannons:ship_stand",cannon="cannons:cannon_bronze"},
	stack_max = 0,
	tiles = {"cannons_bronze_top.png","cannons_bronze_side.png","cannons_steel_top.png","default_wood.png","default_wood.png^cannons_rim.png"},
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
--wooden stand with bronze cannon --
--in German: Holzständer mit Bronzekanone
minetest.register_node("cannons:wood_stand_with_cannon_bronze", {
	description = "wooden stand with bronze cannon",
	cannons ={stand="cannons:wood_stand",cannon="cannons:cannon_bronze"},
	stack_max = 0,
	tiles = {"cannons_bronze_top.png","cannons_bronze_side.png","default_wood.png","default_wood.png^cannons_rim.png","cannons_steel_top.png"},
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

--++++++++++++++++++++++++++++++++++++
--+ cannon balls                     +
--++++++++++++++++++++++++++++++++++++

--wood ball
cannons.generate_and_register_ball_node("cannons:ball_wood", {
	description = "Cannon Ball Wood",
	stack_max = 99,
	tiles = {"default_wood.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=2},
	sounds = default.node_sound_wood_defaults(),
	node_box = cannons.nodeboxes.ball,
})

--stone ball
cannons.generate_and_register_ball_node("cannons:ball_stone", {
	description = "Cannon Ball Stone",
	stack_max = 99,
	tiles = {"default_stone.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=2},
	sounds = default.node_sound_stone_defaults(),
	node_box = cannons.nodeboxes.ball,
})

--steel ball
cannons.generate_and_register_ball_node("cannons:ball_steel", {
	description = "Cannon Ball Steel",
	stack_max = 99,
	tiles = {"cannons_steel_top.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=2},
	--diggable = false,
	sounds = cannons.sound_defaults(),
})

--explosion cannon ball
if minetest.settings:get_bool("cannons_enable_explosion") then
cannons.generate_and_register_ball_node("cannons:ball_exploding", {
	description = "Exploding Cannon Ball",
	stack_max = 99,
	tiles = {"default_mese_block.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=2},
	sounds = default.node_sound_wood_defaults(),
})
end

--fire cannon ball
if minetest.settings:get_bool("cannons_enable_fire")  then
cannons.generate_and_register_ball_node("cannons:ball_fire", {
	description = "Burning Cannon Ball",
	stack_max = 99,
	tiles = {"default_tree.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=2},
	sounds = default.node_sound_wood_defaults(),
	node_box = cannons.nodeboxes.ball,
})
end	

