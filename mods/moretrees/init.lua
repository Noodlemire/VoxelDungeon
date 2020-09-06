-- More trees!  2013-04-07
--
-- This mod adds more types of trees to the game
--
-- Some of the node definitions and textures came from cisoun's conifers mod
-- and bas080's jungle trees mod.
--
-- Brought together into one mod and made L-systems compatible by Vanessa
-- Ezekowitz.
--
-- Firs and Jungle tree axioms/rules by Vanessa Dannenberg, with the
-- latter having been tweaked by RealBadAngel, most other axioms/rules written
-- by RealBadAngel.
--

moretrees = {}

minetest.override_item("default:sapling", {
	description = "Sapling"
})

minetest.override_item("default:tree", {
	description = "Tree"
})

minetest.override_item("default:wood", {
	description = "Wooden Planks"
})

minetest.override_item("default:leaves", {
	description = "Leaves"
})

minetest.override_item("default:fence_wood", {
	description = "Wooden Fence"
})

minetest.override_item("default:fence_rail_wood", {
	description = "Wooden Fence Rail"
})

if minetest.get_modpath("doors") then
	minetest.override_item("doors:gate_wood_closed", {
		description = "Wooden Fence Gate"
	})

	minetest.override_item("doors:gate_wood_open", {
		description = "Wooden Fence Gate"
	})
end


-- Read the default config file (and if necessary, copy it to the world folder).

local worldpath=minetest.get_worldpath()
local modpath=minetest.get_modpath("moretrees")

dofile(modpath.."/default_settings.txt")

if io.open(worldpath.."/moretrees_settings.txt","r") then
	io.close()
	dofile(worldpath.."/moretrees_settings.txt")
end


-- infinite stacks checking

if minetest.get_modpath("unified_inventory") or not
		minetest.settings:get_bool("creative_mode") then
	moretrees.expect_infinite_stacks = false
else
	moretrees.expect_infinite_stacks = true
end

-- tables, load other files

moretrees.cutting_tools = {
	"default:axe_bronze",
	"default:axe_diamond",
	"default:axe_mese",
	"default:axe_steel",
	"glooptest:axe_alatro",
	"glooptest:axe_arol",
	"moreores:axe_mithril",
	"moreores:axe_silver",
	"titanium:axe",
}

dofile(modpath.."/tree_models.lua")
dofile(modpath.."/node_defs.lua")
dofile(modpath.."/date_palm.lua")
dofile(modpath.."/cocos_palm.lua")
dofile(modpath.."/biome_defs.lua")
dofile(modpath.."/saplings.lua")
dofile(modpath.."/crafts.lua")

-- tree spawning setup

if moretrees.spawn_saplings then
	moretrees.spawn_beech_object = "moretrees:beech_sapling_ongen"
	moretrees.spawn_apple_tree_object = "moretrees:apple_tree_sapling_ongen"
	moretrees.spawn_oak_object = "moretrees:oak_sapling_ongen"
	moretrees.spawn_sequoia_object = "moretrees:sequoia_sapling_ongen"
	moretrees.spawn_palm_object = "moretrees:palm_sapling_ongen"
	moretrees.spawn_date_palm_object = "moretrees:date_palm_sapling_ongen"
	moretrees.spawn_cedar_object = "moretrees:cedar_sapling_ongen"
	moretrees.spawn_rubber_tree_object = "moretrees:rubber_tree_sapling_ongen"
	moretrees.spawn_willow_object = "moretrees:willow_sapling_ongen"
	moretrees.spawn_birch_object = "moretrees:birch_sapling_ongen"
	moretrees.spawn_spruce_object = "moretrees:spruce_sapling_ongen"
	moretrees.spawn_jungletree_object = "moretrees:jungletree_sapling_ongen"
	moretrees.spawn_fir_object = "moretrees:fir_sapling_ongen"
	moretrees.spawn_fir_snow_object = "snow:sapling_pine"
	moretrees.spawn_poplar_object = "moretrees:poplar_sapling_ongen"
	moretrees.spawn_poplar_small_object = "moretrees:poplar_small_sapling_ongen"
else
	moretrees.spawn_beech_object = moretrees.beech_model
	moretrees.spawn_apple_tree_object = moretrees.apple_tree_model
	moretrees.spawn_oak_object = moretrees.oak_model
	moretrees.spawn_sequoia_object = moretrees.sequoia_model
	moretrees.spawn_palm_object = moretrees.palm_model
	moretrees.spawn_date_palm_object = moretrees.date_palm_model
	moretrees.spawn_cedar_object = moretrees.cedar_model
	moretrees.spawn_rubber_tree_object = moretrees.rubber_tree_model
	moretrees.spawn_willow_object = moretrees.willow_model
	moretrees.spawn_birch_object = "moretrees.grow_birch"
	moretrees.spawn_spruce_object = "moretrees.grow_spruce"
	moretrees.spawn_jungletree_object = "moretrees.grow_jungletree"
	moretrees.spawn_fir_object = "moretrees.grow_fir"
	moretrees.spawn_fir_snow_object = "moretrees.grow_fir_snow"
	moretrees.spawn_poplar_object = moretrees.poplar_model
	moretrees.spawn_poplar_small_object = moretrees.poplar_small_model
end

if moretrees.enable_beech then
	biome_lib:register_generate_plant(moretrees.beech_biome, moretrees.spawn_beech_object)
end

if moretrees.enable_apple_tree then
	biome_lib:register_generate_plant(moretrees.apple_tree_biome, moretrees.spawn_apple_tree_object)
end

if moretrees.enable_oak then
	biome_lib:register_generate_plant(moretrees.oak_biome, moretrees.spawn_oak_object)
end

if moretrees.enable_sequoia then
	biome_lib:register_generate_plant(moretrees.sequoia_biome, moretrees.spawn_sequoia_object)
end

if moretrees.enable_palm then
	biome_lib:register_generate_plant(moretrees.palm_biome, moretrees.spawn_palm_object)
end

if moretrees.enable_date_palm then
	biome_lib:register_generate_plant(moretrees.date_palm_biome, moretrees.spawn_date_palm_object)
	biome_lib:register_generate_plant(moretrees.date_palm_biome_2, moretrees.spawn_date_palm_object)
end

if moretrees.enable_cedar then
	biome_lib:register_generate_plant(moretrees.cedar_biome, moretrees.spawn_cedar_object)
end

if moretrees.enable_rubber_tree then
	biome_lib:register_generate_plant(moretrees.rubber_tree_biome, moretrees.spawn_rubber_tree_object)
end

if moretrees.enable_willow then
	biome_lib:register_generate_plant(moretrees.willow_biome, moretrees.spawn_willow_object)
end

if moretrees.enable_birch then
	biome_lib:register_generate_plant(moretrees.birch_biome, moretrees.spawn_birch_object)
end

if moretrees.enable_spruce then
	biome_lib:register_generate_plant(moretrees.spruce_biome, moretrees.spawn_spruce_object)
end

if moretrees.enable_jungle_tree then
	biome_lib:register_generate_plant(moretrees.jungletree_biome, moretrees.spawn_jungletree_object)
end

if moretrees.enable_fir then
	biome_lib:register_generate_plant(moretrees.fir_biome, moretrees.spawn_fir_object)
	if minetest.get_modpath("snow") then
		biome_lib:register_generate_plant(moretrees.fir_biome_snow, moretrees.spawn_fir_snow_object)
	end
end

if moretrees.enable_poplar then
	biome_lib:register_generate_plant(moretrees.poplar_biome, moretrees.spawn_poplar_object)
	biome_lib:register_generate_plant(moretrees.poplar_biome_2, moretrees.spawn_poplar_object)
	biome_lib:register_generate_plant(moretrees.poplar_biome_3, moretrees.spawn_poplar_object)
	biome_lib:register_generate_plant(moretrees.poplar_small_biome, moretrees.spawn_poplar_small_object)
	biome_lib:register_generate_plant(moretrees.poplar_small_biome_2, moretrees.spawn_poplar_small_object)
end

-- Code to spawn a birch tree

function moretrees.grow_birch(pos)
	minetest.swap_node(pos, biome_lib.air)
	if math.random(1,2) == 1 then
		minetest.spawn_tree(pos, moretrees.birch_model1)
	else
		minetest.spawn_tree(pos, moretrees.birch_model2)
	end
end

-- Code to spawn a spruce tree

function moretrees.grow_spruce(pos)
	minetest.swap_node(pos, biome_lib.air)
	if math.random(1,2) == 1 then
		minetest.spawn_tree(pos, moretrees.spruce_model1)
	else
		minetest.spawn_tree(pos, moretrees.spruce_model2)
	end
end

-- Code to spawn jungle trees

moretrees.jt_axiom1 = "FFFA"
moretrees.jt_rules_a1 = "FFF[&&-FBf[&&&Ff]^^^Ff][&&+FBFf[&&&FFf]^^^Ff][&&---FBFf[&&&Ff]^^^Ff][&&+++FBFf[&&&Ff]^^^Ff]F/A"
moretrees.jt_rules_b1 = "[-Ff&f][+Ff&f]B"

moretrees.jt_axiom2 = "FFFFFA"
moretrees.jt_rules_a2 = "FFFFF[&&-FFFBF[&&&FFff]^^^FFf][&&+FFFBFF[&&&FFff]^^^FFf][&&---FFFBFF[&&&FFff]^^^FFf][&&+++FFFBFF[&&&FFff]^^^FFf]FF/A"
moretrees.jt_rules_b2 = "[-FFf&ff][+FFf&ff]B"

moretrees.ct_rules_a1 = "FF[FF][&&-FBF][&&+FBF][&&---FBF][&&+++FBF]F/A"
moretrees.ct_rules_b1 = "[-FBf][+FBf]"

moretrees.ct_rules_a2 = "FF[FF][&&-FBF][&&+FBF][&&---FBF][&&+++FBF]F/A"
moretrees.ct_rules_b2 = "[-fB][+fB]"

function moretrees.grow_jungletree(pos)
	local r1 = math.random(2)
	local r2 = math.random(3)
	if r1 == 1 then
		moretrees.jungletree_model.leaves2 = "moretrees:jungletree_leaves_red"
	else
		moretrees.jungletree_model.leaves2 = "moretrees:jungletree_leaves_yellow"
	end
	moretrees.jungletree_model.leaves2_chance = math.random(25, 75)

	if r2 == 1 then
		moretrees.jungletree_model.trunk_type = "single"
		moretrees.jungletree_model.iterations = 2
		moretrees.jungletree_model.axiom = moretrees.jt_axiom1
		moretrees.jungletree_model.rules_a = moretrees.jt_rules_a1
		moretrees.jungletree_model.rules_b = moretrees.jt_rules_b1
	elseif r2 == 2 then
		moretrees.jungletree_model.trunk_type = "double"
		moretrees.jungletree_model.iterations = 4
		moretrees.jungletree_model.axiom = moretrees.jt_axiom2
		moretrees.jungletree_model.rules_a = moretrees.jt_rules_a2
		moretrees.jungletree_model.rules_b = moretrees.jt_rules_b2
	elseif r2 == 3 then
		moretrees.jungletree_model.trunk_type = "crossed"
		moretrees.jungletree_model.iterations = 4
		moretrees.jungletree_model.axiom = moretrees.jt_axiom2
		moretrees.jungletree_model.rules_a = moretrees.jt_rules_a2
		moretrees.jungletree_model.rules_b = moretrees.jt_rules_b2
	end

	minetest.swap_node(pos, biome_lib.air)
	local leaves = minetest.find_nodes_in_area({x = pos.x-1, y = pos.y, z = pos.z-1}, {x = pos.x+1, y = pos.y+10, z = pos.z+1}, "default:leaves")
	for leaf in ipairs(leaves) do
			minetest.swap_node(leaves[leaf], biome_lib.air)
	end
	minetest.spawn_tree(pos, moretrees.jungletree_model)
end

-- code to spawn fir trees

function moretrees.grow_fir(pos)
	if math.random(2) == 1 then
		moretrees.fir_model.leaves="moretrees:fir_leaves"
	else
		moretrees.fir_model.leaves="moretrees:fir_leaves_bright"
	end
	if math.random(2) == 1 then
		moretrees.fir_model.rules_a = moretrees.ct_rules_a1
		moretrees.fir_model.rules_b = moretrees.ct_rules_b1
	else
		moretrees.fir_model.rules_a = moretrees.ct_rules_a2
		moretrees.fir_model.rules_b = moretrees.ct_rules_b2
	end

	moretrees.fir_model.iterations = 7
	moretrees.fir_model.random_level = 5

	minetest.swap_node(pos, biome_lib.air)
	local leaves = minetest.find_nodes_in_area({x = pos.x, y = pos.y, z = pos.z}, {x = pos.x, y = pos.y+5, z = pos.z}, "default:leaves")
	for leaf in ipairs(leaves) do
		minetest.swap_node(leaves[leaf], biome_lib.air)
	end
	minetest.spawn_tree(pos,moretrees.fir_model)
end

-- same thing, but a smaller version that grows only in snow biomes

function moretrees.grow_fir_snow(pos)
	if math.random(2) == 1 then
		moretrees.fir_model.leaves="moretrees:fir_leaves"
	else
		moretrees.fir_model.leaves="moretrees:fir_leaves_bright"
	end
	if math.random(2) == 1 then
		moretrees.fir_model.rules_a = moretrees.ct_rules_a1
		moretrees.fir_model.rules_b = moretrees.ct_rules_b1
	else
		moretrees.fir_model.rules_a = moretrees.ct_rules_a2
		moretrees.fir_model.rules_b = moretrees.ct_rules_b2
	end

	moretrees.fir_model.iterations = 2
	moretrees.fir_model.random_level = 2

	minetest.swap_node(pos, biome_lib.air)
	local leaves = minetest.find_nodes_in_area({x = pos.x, y = pos.y, z = pos.z}, {x = pos.x, y = pos.y+5, z = pos.z}, "default:leaves")
	for leaf in ipairs(leaves) do
			minetest.swap_node(leaves[leaf], biome_lib.air)
	end
	minetest.spawn_tree(pos,moretrees.fir_model)
end

print("[Moretrees] Loaded (2013-02-11)")
