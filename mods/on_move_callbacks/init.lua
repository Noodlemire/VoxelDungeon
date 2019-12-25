on_move_callbacks = {}

on_move_callbacks.playerlastpos = {}
on_move_callbacks.entitylastpos = {}

local function processOn(obj, pos)
	local nodename = minetest.get_node(pos).name
	local nodedef = minetest.registered_nodes[nodename]

	if nodedef and not nodedef.walkable and nodedef._on_move_on then
		nodedef._on_move_on(pos, obj)
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
		underdef._on_move_on(underpos, obj)
	end
end

local function processOff(obj, pos)
	local nodename = minetest.get_node(pos).name
	local nodedef = minetest.registered_nodes[nodename]

	if nodedef and not nodedef.walkable and nodedef._on_move_off then
		nodedef._on_move_off(pos, obj)
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
		underdef._on_move_off(underpos, obj)
	end
end

minetest.register_globalstep(function()
	for i = 1, entitycontrol.count_entities() do
		local ent = entitycontrol.get_entity(i)
		
		if entitycontrol.isAlive(i) then
			local pos = vector.round(ent:get_pos())

			local collisionbox = minetest.registered_entities[ent:get_luaentity().name].collisionbox or {[2] = 0}

			pos.y = pos.y + collisionbox[2]

			if not on_move_callbacks.entitylastpos[i] then
				on_move_callbacks.entitylastpos[i] = pos
				
				processOn(ent, pos)
			else
				local new = pos
			
				if on_move_callbacks.entitylastpos[i] and not vector.equals(on_move_callbacks.entitylastpos[i], new) then
					processOff(ent, on_move_callbacks.entitylastpos[i])
					on_move_callbacks.entitylastpos[i] = new
					processOn(ent, new)
				end
			end
		else
			if on_move_callbacks.entitylastpos[i] then
				processOff(ent, on_move_callbacks.entitylastpos[i])
				on_move_callbacks.entitylastpos[i] = nil
			end
		end
	end
	
	for _, p in ipairs(minetest.get_connected_players()) do
		local name = p:get_player_name()
		
		if not on_move_callbacks.playerlastpos[name] then
			on_move_callbacks.playerlastpos[name] = vector.round(p:get_pos())
			processOn(p, p:get_pos())
		else
			local new = vector.round(p:get_pos())
		
			if not vector.equals(on_move_callbacks.playerlastpos[name], new) then
				processOff(p, on_move_callbacks.playerlastpos[name])
				on_move_callbacks.playerlastpos[name] = new
				processOn(p, new)
			end
		end
	end
end)
