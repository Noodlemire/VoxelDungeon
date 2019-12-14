--++++++++++++++++++++++++++++++++++++
--+ shared locked cannon             +
--++++++++++++++++++++++++++++++++++++


minetest.register_node("cannons:shared_locked_cannon", {
		description = "locked shareable Cannon",
	stack_max = 1,
	tiles = {"cannon_cannon_top.png","cannon_cannon_top.png","cannon_cannon_side.png","cannon_cannon_side.png","cannon_cannon_top.png^cannons_rim.png","cannon_cannon_side.png"},
	drawtype = "nodebox",
	paramtype = "light",
	paramtype2 = "facedir",
	groups = {cracky=1},
	sounds = cannons.sound_defaults(),
	node_box = cannons.nodeboxes.cannon,
	on_place = cannons.on_place,
	on_punch = cannons.punched,
	on_receive_fields = function(pos, formname, fields, sender)
			locks:lock_handle_input( pos, formname, fields, sender );
	end,
	after_place_node = function(pos, placer)
			locks:lock_set_owner( pos, placer, "empty locked shareable cannon" );
	end,
	--no mesecons support for this type of cannon!
	--mesecons = {effector = { 
	--	rules = cannons.rules,
	--	action_on = cannons.meseconsfire,
	--	}
	--},
	on_construct = cannons.on_construct_locks,
	can_dig = function(pos,player)
		local meta = minetest.get_meta(pos);
		local inv = meta:get_inventory()
		if not inv:is_empty("gunpowder") then
			return false
		elseif not inv:is_empty("muni") then
			return false
		else
			return locks:lock_allow_dig( pos, player )
		end
	end,
	allow_metadata_inventory_put = cannons.allow_metadata_inventory_put,
	
	allow_metadata_inventory_move = cannons.allow_metadata_inventory_move,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if( not( locks:lock_allow_use( pos, player ))) then
		   return 0;
		end
		return stack:get_count()
	end,
	
	on_metadata_inventory_put = cannons.inventory_modified,	
	on_metadata_inventory_take = cannons.inventory_modified,	
	on_metadata_inventory_move = cannons.inventory_modified,
	
})


minetest.register_craft({
   output = 'cannons:shared_locked_cannon',
   recipe = {
      {'group:cannon', 'locks:lock',},
   },
})