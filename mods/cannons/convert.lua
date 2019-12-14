minetest.register_abm({
	nodenames = {"cannons:cannon","cannons:bronze_canon","cannons:mithril_cannon"},
	--neighbors = {"cannons:stand","cannons.stand_wood"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local stand_pos = {x= pos.x,y= pos.y-1,z=pos.z}
		local stand = minetest.get_node(stand_pos)
		if stand.name == "cannons:stand" or stand.name == "cannons:stand_wood" then -- cannon stand with cannon
			if stand.name == "cannons:stand" then
				minetest.set_node(stand_pos, {name = "default:cobble"})--replace stand with cobblestone
			else
				minetest.set_node(stand_pos, {name = "default:wood"})--replace stand with cobblestone
			end
			if node.name == "cannons:cannon" then 
				node.name = "cannons:wood_stand_with_cannon_steel"
			elseif node.name == "cannons:bronze_canon" then
				node.name = "cannons:wood_stand_with_cannon_bronze"
			elseif node.name == "cannons:mithril_cannon" then
				node.name = "cannons:wood_stand_with_cannon_mithril"
			--else if node.name == "cannons:bronze_canon" then
			--	node.name = "cannons:wood_stand_with_bronze_cannon"
			else --dont know what else can happen, but "Der Teufel ist ein Eichhörnchen"
				node.name = "air"
			end
			
			minetest.swap_node(pos, node)
			
		else --else its a single or disabled cannon
			print("zweite if")
			if node.name == "cannons:cannon" then 
				node.name = "cannons:cannon_steel"
			elseif node.name == "cannons:canon_bronze" then
				node.name = "cannons:bronze_cannon"
			elseif node.name == "cannons:cannon_mithril" then
				node.name = "cannons:cannon_mithril"
			--else if node.name == "cannons:placeholder" then
			--	node.name = "cannons:wood_stand_with_placeholder_cannon"
			else --dont know what else can happen, but "Der Teufel ist ein Eichhörnchen"
				node.name = "air"
			end
			minetest.swap_node(pos, node)
		end
	end,
})
--abm to convert single cannonstands
minetest.register_abm({
	nodenames = {"cannons:stand","cannons:stand_wood"},
	interval = 1.0,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local above_pos = {x= pos.x,y= pos.y+1,z=pos.z}
		local above = minetest.get_node(above_pos)
		--if above the  stand a cannon...
		if above.name == "cannons:cannon" or above.name == "cannons:bronze_canon" or above.name == "cannons:mithril_cannon" then 
			--do nothing, let the first abm do all
		elseif above.name == "air" then
			minetest.set_node(above_pos, {name = "cannons:wood_stand"})
		else
			--replace single stands with a full block, and place the stand above it
			if node.name == "cannons:stand" then
				minetest.set_node(pos, {name = "default:cobble"})--replace stand with cobblestone
				
			else
				minetest.set_node(pos, {name = "default:wood"})--replace stand with cobblestone
			end
		end
		
	end,
})
