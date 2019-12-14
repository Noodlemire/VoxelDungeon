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



function voxeldungeon.buffs.register_buff(name, def)
	voxeldungeon.buffs.registered_buffs[name] = def
	--[[{
		description = desc,
		icon = icn,
		onattach = attach,
		doeffect = effect,
		ondetach = detach,
		autoDecrement = autoDec
	}--]]
end

function voxeldungeon.buffs.attach_buff(name, target, duration)
	if voxeldungeon.buffs.registered_buffs[name] == nil then
		minetest.log("warning", "[voxeldungeon] Attempt to apply nonexistent buff")
		return
	end

	if voxeldungeon.buffs.registered_buffs[name].autoDecrement and not duration then
		minetest.log("warning", "[voxeldungeon] Attempt to apply an auto-decrementing buff without a given duration.")
		return
	end

	local buff

	if target:is_player() then 
		buff = player_buffs[target:get_player_name()][name]

		if buff then
			if duration then
				buff.duration = math.max(buff.left(), duration)
				buff.elapsed = 0
			end

			return buff
		end
	else
		local id = entitycontrol.get_entity_id(target)

		if not id then return end

		if entity_buffs[id] then
			buff = entity_buffs[id][name]
			if buff then
				if duration then
					buff.duration = math.max(buff.left(), duration)
					buff.elapsed = 0
				end

				return buff
			end
		else
			entity_buffs[id] = {}
		end
	end

	buff = voxeldungeon.utils.shallowCloneTable(voxeldungeon.buffs.registered_buffs[name])
	
	buff.target = target
	buff.duration = duration
	
	buff.on_attach = voxeldungeon.buffs.registered_buffs[name].on_attach or function() end
	buff.do_effect = voxeldungeon.buffs.registered_buffs[name].do_effect or function() end
	buff.on_detach = voxeldungeon.buffs.registered_buffs[name].on_detach or function() end
	
	buff.elapsed = 0

	buff.action = function()
		if not buff.detached and buff.left() > 0 and voxeldungeon.mobs.health(buff.target) > 0 then
			buff.do_effect(buff)

			if buff.autoDecrement then 
				buff.elapsed = buff.elapsed + 1 
			end

			if buff.target:is_player() and duration then
				local t = buff.description or "!!!NO TEXT FOUND!!!"
				t = t..": "..buff.left(true)
				buff.target:hud_change(buff.hud_text_id, "text", t)
			end

			minetest.after(1, buff.action)
		else
			buff.detach()
		end
	end
	
	buff.detach = function()
		buff.on_detach(buff)
		buff.detached = true

		if target:is_player() then
			player_buffs[target:get_player_name()][name] = nil
			target:hud_remove(buff.hud_image_id)
			target:hud_remove(buff.hud_text_id)
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
	
	buff.left = function(displaying)
		if not duration then return nil end

		local left = buff.duration - buff.elapsed

		if displaying then
			left = left + 1
		end

		return left
	end
	
	buff.on_attach(buff)
	buff.action()

	if target:is_player() then
		player_buffs[target:get_player_name()][name] = buff

		local i = voxeldungeon.utils.countTableEntries(player_buffs[target:get_player_name()]) - 1

		if buff.icon then
			buff.hud_image_id = target:hud_add({
				hud_elem_type = "image",
				text = buff.icon,

				scale = {x = 1, y = 1},
				position = {x = 0.01, y = 0.2},
				direction = 1,
				alignment = {x = 1, y = 0},
				offset = {x = 0, y = 20 * i - 1}
			})

			local t = buff.description or "!!!NO TEXT FOUND!!!"
			if duration then
				t = t..": "..buff.left(true)
			end

			buff.hud_text_id = target:hud_add({
				hud_elem_type = "text",
				text = t,
				number = "0xFFFFFF",

				scale = {x = 200, y = 20},
				position = {x = 0.01, y = 0.2},
				direction = 1,
				alignment = {x = 1, y = 0},
				offset = {x = 20, y = 20 * i}
			})
		end
	else
		entity_buffs[entitycontrol.get_entity_id(target)][name] = buff
	end
	
	return buff
end

--TODO: make this method work with entities, too
function voxeldungeon.buffs.detach_buff(name, target)
	local playername = target:get_player_name()

	if target:is_player() and player_buffs[playername][name] then
		player_buffs[playername][name].detach()
	end
end



voxeldungeon.buffs.register_buff("voxeldungeon:bleeding", {
	description = "Bleeding", 
	icon = "voxeldungeon_buff_bleeding.png",

	do_effect = function(buff) 
		voxeldungeon.mobs.damage(buff.target, buff.left(), "bleeding")
		buff.elapsed = buff.elapsed + math.random(0, math.ceil(buff.left() / 2))
	end
})

voxeldungeon.buffs.register_buff("voxeldungeon:crippled", {
	description = "Crippled", 
	icon = "voxeldungeon_buff_crippled.png",
	autoDecrement = true,

	on_attach = function(buff) 
		if buff.target:is_player() then
			player_monoids.speed:add_change(buff.target, 0.5, "voxeldungeon:crippled")
		end
	end,

	on_detach = function(buff) 
		if buff.target:is_player() then
			player_monoids.speed:del_change(buff.target, "voxeldungeon:crippled")
		end
	end
})
	
voxeldungeon.buffs.register_buff("voxeldungeon:herbal_healing", {
	description = "Herbal Healing", 
	icon = "voxeldungeon_buff_herbal_healing.png", 
	autoDecrement = true,

	on_attach = function(buff)
		buff.pos = buff.target:get_pos()
	end, 

	do_effect = function(buff) 
		local p1 = buff.pos
		local p2 = buff.target:get_pos()
		if math.sqrt(math.pow(p1.x - p2.x, 2) + 
					math.pow(p1.y - p2.y, 2) +
					math.pow(p1.z - p2.z, 2)) > 1 then
			buff.detach()
		else
			buff.target:set_hp(buff.target:get_hp() + 1)
		end
	end
})

voxeldungeon.buffs.register_buff("voxeldungeon:poison", {
	description = "Poisoned", 
	icon = "voxeldungeon_buff_poisoned.png",
	autoDecrement = true,

	do_effect = function(buff) 
		voxeldungeon.mobs.damage(buff.target, math.ceil(buff.left() / 3), "poison")
	end
})

voxeldungeon.buffs.register_buff("voxeldungeon:rooted", {
	description = "Rooted", 
	icon = "voxeldungeon_buff_rooted.png",
	autoDecrement = true,

	on_attach = function(buff) 
		if buff.target:is_player() then
			player_monoids.speed:add_change(buff.target, 0, "voxeldungeon:rooted")
			player_monoids.jump:add_change(buff.target, 0, "voxeldungeon:rooted")

			voxeldungeon.playerhandler.halt(buff.target)
		end
	end,

	on_detach = function(buff) 
		if buff.target:is_player() then
			player_monoids.speed:del_change(buff.target, "voxeldungeon:rooted")
			player_monoids.jump:del_change(buff.target, "voxeldungeon:rooted")
		end
	end
})



minetest.register_on_joinplayer(function(player)
	local name = player:get_player_name()
	player_buffs[name] = {}
end)
