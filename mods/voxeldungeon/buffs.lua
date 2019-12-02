--[[
Voxel Dungeon
Copyright (C) 2019 Noodlemire

Pixel Dungeon
Copyright (C) 2012-2015 Oleg Dolya

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>
--]]

voxeldungeon.buffs = {}

voxeldungeon.buffs.registered_buffs = {}

local player_buffs = {}
local entity_buffs = {}



function voxeldungeon.buffs.register_buff(name, desc, icn, attach, effect, detach, autoDec)
	voxeldungeon.buffs.registered_buffs[name] = 
	{
		description = desc,
		icon = icn,
		onattach = attach,
		doeffect = effect,
		ondetach = detach,
		autoDecrement = autoDec
	}
end

function voxeldungeon.buffs.attach_buff(name, target, duration)
	if voxeldungeon.buffs.registered_buffs[name] == nil then
		minetest.log("action", "[voxeldungeon] Attempt to apply nonexistent buff")
		return
	end

	local buff

	if target:is_player() then 
		buff = player_buffs[target:get_player_name()][name]

		if buff then
			buff.duration = math.max(buff.left(), duration)
			buff.elapsed = 0
			return buff
		end
	else
		local id = entitycontrol.get_entity_id(target)

		if not id then return end

		if entity_buffs[id] then
			buff = entity_buffs[id][name]
			if buff then
				buff.duration = math.max(buff.left(), duration)
				buff.elapsed = 0
				return buff
			end
		else
			entity_buffs[id] = {}
		end
	end

	buff = {}
	
	buff.target = target
	buff.duration = duration
	
	buff.onattach = voxeldungeon.buffs.registered_buffs[name].onattach or function() end
	buff.doeffect = voxeldungeon.buffs.registered_buffs[name].doeffect or function() end
	buff.ondetach = voxeldungeon.buffs.registered_buffs[name].ondetach or function() end

	buff.autoDecrement = voxeldungeon.buffs.registered_buffs[name].autoDecrement
	
	buff.elapsed = 0

	buff.action = function()
		if buff.left() > 0 and voxeldungeon.mobs.health(buff.target) > 0 then
			buff.doeffect(buff)
			if buff.autoDecrement then buff.elapsed = buff.elapsed + 1 end
			minetest.after(1, buff.action)
		else
			buff.ondetach(buff)
			if target:is_player() then
				player_buffs[target:get_player_name()][name] = nil
			elseif not entitycontrol.get_entity_id(target) then
				local dead_id = 0
				while dead_id do
					entity_buffs[dead_id] = nil
					dead_id = dead_id + 1
					dead_id = entitycontrol.getFirstEmptyIndex(dead_id)
				end
			else
				entity_buffs[entitycontrol.get_entity_id(target)][name] = nil
			end
		end
	end
	
	buff.detach = function()
		buff.elapsed = buff.duration
	end
	
	buff.left = function()
		return buff.duration - buff.elapsed
	end
	
	buff.onattach(buff)
	buff.action()

	if target:is_player() then
		player_buffs[target:get_player_name()][name] = buff
	else
		entity_buffs[entitycontrol.get_entity_id(target)][name] = buff
	end
	
	return buff
end

--TODO: make this method work with entities, too
function voxeldungeon.buffs.detach_buff(name, target)
	local playername = target:get_player_name()

	if target:is_player() and player_buffs[playername][name] then
		player_buffs[playername][name].elapsed = player_buffs[playername][name].duration
	end
end



voxeldungeon.buffs.register_buff("voxeldungeon:poison", "Poisoned", "voxeldungeon_buff_poisoned.png", nil,
	function(buff) 
		voxeldungeon.mobs.damage(buff.target, math.ceil(buff.left() / 3), "poison")
	end,
	nil, true)
	
voxeldungeon.buffs.register_buff("voxeldungeon:herbal_healing", "Herbal Healing", "voxeldungeon_buff_herbal_healing.png", 
	function(buff)
		buff.pos = buff.target:get_pos()
	end, 
	function(buff) 
		local p1 = buff.pos
		local p2 = buff.target:get_pos()
		if math.sqrt(math.pow(p1.x - p2.x, 2) + 
					math.pow(p1.y - p2.y, 2) +
					math.pow(p1.z - p2.z, 2)) > 1 then
			buff.detach()
		else
			buff.target:set_hp(buff.target:get_hp() + 1)
		end
	end,
	nil, true)



minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	player_buffs[name] = {}
end)
