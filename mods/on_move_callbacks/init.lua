on_move_callbacks = {}

on_move_callbacks.lastpos = {}
on_move_callbacks.entitylastpos = {}

local function process(objs, pos)
	local nodename = minetest.get_node(pos).name
	local nodedef = minetest.registered_nodes[nodename]

	if nodedef and not nodedef.walkable and nodedef.on_step then
		nodedef.on_step(pos, objs)
	end

	local underpos = 
	{
		x = pos.x,
		y = pos.y - 1,
		z = pos.z
	}

	local undername = minetest.get_node(underpos).name
	local underdef = minetest.registered_nodes[undername]

	if underdef and underdef.walkable and underdef.on_step then
		underdef.on_step(underpos, objs)
	end
end

minetest.register_globalstep(function()
	local objs = {}
	for i = 1, entitycontrol.count_entities() do
		local ent = entitycontrol.get_entity(i)
		
		if ent and ent:get_pos() and not on_move_callbacks.entitylastpos[i] then
			on_move_callbacks.entitylastpos[i] = vector.round(ent:get_pos())
		elseif ent and ent:get_pos() then
			local new = vector.round(ent:get_pos())
		
			if not vector.equals(on_move_callbacks.entitylastpos[i], new) then
				on_move_callbacks.entitylastpos[i] = new
			
				if not objs[new] then
					objs[new] = {}
				end
				table.insert(objs[new], ent)
			end
		end
	end
	
	for _, v in ipairs(minetest.get_connected_players()) do
		local name = v:get_player_name()
		
		if not on_move_callbacks.lastpos[name] then
			on_move_callbacks.lastpos[name] = vector.round(v:get_pos())
		else
			local new = vector.round(v:get_pos())
		
			if not vector.equals(on_move_callbacks.lastpos[name], new) then
				on_move_callbacks.lastpos[name] = new
				if not objs[new] then
					objs[new] = {}
				end
				table.insert(objs[new], v)
			end
		end
	end
	
	for p, o in pairs(objs) do
		process(o, p)
	end
end)
