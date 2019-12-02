--adds charcoal craftitem
minetest.register_craftitem('charcoal:charcoal', {
	description = 'Charcoal',
	inventory_image = 'charcoal_charcoal.png',
	groups = {coal=1},
	stack_max = 99,
})

minetest.register_craftitem('charcoal:charcoal_block', {
        description = 'Charcoal Block',
        inventory_image = 'charcoal_charcoal_block_icon.png',
        groups = {coal=1},
        stack_max = 99,
})

--Initial creation
minetest.register_craft({
	type = 'cooking',
	output = 'charcoal:charcoal',
	recipe = 'group:tree',
})

--Into a block
minetest.register_craft({
        output = 'charcoal:charcoal_block',
        recipe = {
                    {'charcoal:charcoal', 'charcoal:charcoal', 'charcoal:charcoal'},
                    {'charcoal:charcoal', 'charcoal:charcoal', 'charcoal:charcoal'},
                    {'charcoal:charcoal', 'charcoal:charcoal', 'charcoal:charcoal'},
                }
})

--The block node
minetest.register_node('charcoal:charcoal_block', {
	description = 'Charcoal Block',
	tiles = {'charcoal_charcoal_block.png'},
	groups = {cracky=1},
	stack_max = 99,
})

--as fuel
minetest.register_craft({
	type = 'fuel',
	recipe = 'charcoal:charcoal',
	burntime = 40,
})

minetest.register_craft({
	type = 'fuel',
	recipe = 'charcoal:charcoal_block',
	burntime = 370,
})

--in torches
minetest.register_craft({
	output = 'default:torch 4',
	recipe = {
			{'charcoal:charcoal'},
			{'default:stick'},
		}
})

--reversing block
minetest.register_craft({
	output = 'charcoal:charcoal 9',
	recipe = {
			{'charcoal:charcoal_block'},
		 }
})