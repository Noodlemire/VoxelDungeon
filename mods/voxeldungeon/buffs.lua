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



local hud_queue = {}

local function queue_hud(target)
	local pname = target:get_player_name()

	if not hud_queue[pname] then
		hud_queue[pname] = true

		local make_hud = function(player)
			local i = 0

			for _, buff in pairs(player_buffs[player:get_player_name()]) do
				player:hud_remove(buff.hud_image_id)
				player:hud_remove(buff.hud_text_id)

				if not buff.detached and buff.icon then
					buff.hud_image_id = player:hud_add({
						hud_elem_type = "image",
						text = buff.icon,

						scale = {x = 1, y = 1},
						position = {x = 0.01, y = 0.2},
						direction = 1,
						alignment = {x = 1, y = 0},
						offset = {x = 0, y = 20 * i - 1},
						z_index = 1
					})

					local t = buff.description or "!!!NO TEXT FOUND!!!"
					if buff.duration then
						t = t..": "..buff.left()
					end

					buff.hud_text_id = player:hud_add({
						hud_elem_type = "text",
						text = t,
						number = "0xFFFFFF",

						scale = {x = 200, y = 20},
						position = {x = 0.01, y = 0.2},
						direction = 1,
						alignment = {x = 1, y = 0},
						offset = {x = 20, y = 20 * i},
						z_index = 1
					})

					i = i + 1
				end
			end

			hud_queue[player:get_player_name()] = false
		end

		minetest.after(0.1, make_hud, target)
	end
end



function voxeldungeon.buffs.register_buff(name, def)
	voxeldungeon.buffs.registered_buffs[name] = def
end

function voxeldungeon.buffs.attach_buff(name, target, duration, customdata)
	if voxeldungeon.buffs.registered_buffs[name] == nil then
		minetest.log("warning", "[voxeldungeon] Attempt to apply nonexistent buff")
		return
	end

	if voxeldungeon.buffs.registered_buffs[name].autoDecrement and not duration then
		minetest.log("warning", "[voxeldungeon] Attempt to apply an auto-decrementing buff without a given duration.")
		return
	end

	if not target then return nil end
	if target.object then target = target.object end

	local buff

	if target:is_player() then 
		buff = player_buffs[target:get_player_name()][name]

		if buff then
			if duration and buff.left() ~= duration then
				buff.duration = math.max(buff.left(), duration)

				local t = buff.description or "!!!NO TEXT FOUND!!!"
				t = t..": "..buff.left()
				buff.target:hud_change(buff.hud_text_id, "text", t)
			end

			buff.on_attach(buff, false)

			return buff
		end
	else
		local id = entitycontrol.get_entity_id("mobs", target)

		if not id then return end

		if entity_buffs[id] then
			buff = entity_buffs[id][name]
			if buff then
				if duration then
					buff.duration = math.max(buff.left(), duration)
				end

				buff.on_attach(buff, false)

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

	buff.customdata = customdata or {}

	buff.action = function()
		if type(buff.id) == "number" and entitycontrol.get_entity("mobs", buff.id) == "unloaded" then return end

		if not buff.detached and buff.left() > 0 and voxeldungeon.mobs.health(buff.target) > 0 and 
				(buff.target:is_player() or entitycontrol.isAlive("mobs", buff.target)) then
			buff.do_effect(buff)

			if buff.detached then return end

			if buff.autoDecrement then 
				buff.duration = buff.duration - 1
			end

			if buff.target:is_player() then
				if duration then
					local t = buff.description or "!!!NO TEXT FOUND!!!"
					t = t..": "..buff.left()
					buff.target:hud_change(buff.hud_text_id, "text", t)
				end
			end

			minetest.after(1, buff.action)

			if buff.target:is_player() then
				voxeldungeon.storage.put(name.."_"..buff.target:get_player_name(), buff.left())
			else
				voxeldungeon.storage.put(name.."_"..entitycontrol.get_entity_id("mobs", buff.target), buff.left())
			end
		elseif not buff.detached then
			buff.detach()
		end
	end
	
	buff.detach = function()
		buff.on_detach(buff)
		buff.detached = true

		if buff.target:is_player() then
			buff.target:hud_remove(buff.hud_image_id)
			buff.target:hud_remove(buff.hud_text_id)
			queue_hud(buff.target)

			player_buffs[buff.id][name] = nil
		elseif not entitycontrol.get_entity_id("mobs", buff.target) then
			local dead_id = 0
			while dead_id do
				entity_buffs[dead_id] = nil
				dead_id = dead_id + 1
				dead_id = entitycontrol.getFirstEmptyIndex("mobs", dead_id)
			end
		else
			entity_buffs[buff.id][name] = nil
		end

		voxeldungeon.storage.del(name.."_"..buff.id)
	end
	
	buff.left = function()
		if not duration then return nil end

		local left = buff.duration

		return left
	end

	if buff.target:is_player() then
		buff.id = buff.target:get_player_name()
		player_buffs[buff.id][name] = buff
	else
		buff.id = entitycontrol.get_entity_id("mobs", buff.target)
		entity_buffs[buff.id][name] = buff
	end

	if buff.target:is_player() then
		queue_hud(buff.target)
	end
	
	buff.on_attach(buff, true)
	if buff.detached then return end
	minetest.after(1, buff.action)
	
	return buff
end

function voxeldungeon.buffs.detach_buff(name, target)
	if not target then return nil end
	if target.object then target = target.object end

	if target:is_player() then
		local playername = target:get_player_name()

		if player_buffs[playername][name] then
			player_buffs[playername][name].detach()
		end
	else 
		local eID = entitycontrol.get_entity_id("mobs", target)

		if eID then
			local eBuff = entity_buffs[eID]

			if eBuff and eBuff[name] then
				eBuff[name].detach()
			end
		end
	end
end

function voxeldungeon.buffs.get_buff(name, target)
	if not target or target == "unloaded" then return nil end
	if target.object then target = target.object end

	if target:is_player() then
		return player_buffs[target:get_player_name()][name]
	else
		local eID = entitycontrol.get_entity_id("mobs", target)
		if not eID then return nil end

		local ebuffs = entity_buffs[eID]
		if not ebuffs then return nil end

		return ebuffs[name]
	end
end



voxeldungeon.buffs.register_buff("voxeldungeon:amok", {
	description = "Amok", 
	icon = "voxeldungeon_buff_amok.png",
	autoDecrement = true,

	--See mobkit.lua/chooseEnemy

	on_attach = function(buff)
		mobkit.clear_queue_high(buff.target:get_luaentity())
	end
})

voxeldungeon.buffs.register_buff("voxeldungeon:bleeding", {
	description = "Bleeding", 
	icon = "voxeldungeon_buff_bleeding.png",

	on_attach = function(buff, first) 
		if first and buff.target:is_player() then
			voxeldungeon.glog.w("You are bleeding!", buff.target)
		end
	end,

	do_effect = function(buff)
		voxeldungeon.mobs.damage(buff.target, buff.left(), "bleeding")
		buff.duration = buff.duration - math.random(0, math.ceil(buff.left() / 2))
	end
})

voxeldungeon.buffs.register_buff("voxeldungeon:blind", {
	description = "Blindness", 
	icon = "voxeldungeon_buff_blind.png",
	autoDecrement = true,

	--See mobkit.lua/chooseEnemy

	on_attach = function(buff, first) 
		if first and buff.target:is_player() then
			voxeldungeon.glog.w("You are blinded!", buff.target)

			if not buff.blind_hud_id then
				buff.blind_hud_id = buff.target:hud_add({
					hud_elem_type = "image",
					position = { x=0.5, y=0.5 },
					scale = { x=-100, y=-100 },
					text = "voxeldungeon_overlay_blind.png",
					z_index = 0
				})
			end
		else
			mobkit.clear_queue_high(buff.target:get_luaentity())
		end
	end,

	on_detach = function(buff)
		buff.target:hud_remove(buff.blind_hud_id)
	end
})

voxeldungeon.buffs.register_buff("voxeldungeon:crippled", {
	description = "Crippled", 
	icon = "voxeldungeon_buff_crippled.png",
	autoDecrement = true,

	on_attach = function(buff, first) 
		if not first then return end

		if buff.target:is_player() then
			voxeldungeon.glog.w("You are crippled!", buff.target)
			player_monoids.speed:add_change(buff.target, 0.5, "voxeldungeon:crippled")
		else
			buff.target:get_luaentity().max_speed = buff.target:get_luaentity().max_speed / 2
		end
	end,

	on_detach = function(buff) 
		if buff.target:is_player() then
			player_monoids.speed:del_change(buff.target, "voxeldungeon:crippled")
		elseif entitycontrol.isAlive("mobs", buff.target) then
			buff.target:get_luaentity().max_speed = buff.target:get_luaentity().max_speed * 2
		end
	end
})

voxeldungeon.buffs.register_buff("voxeldungeon:frozen", {
	description = "Frozen", 
	icon = "voxeldungeon_buff_frozen.png",
	autoDecrement = true,

	on_attach = function(buff, first)
		buff.hp = voxeldungeon.mobs.health(buff.target)

		if not first then return end

		if buff.target:is_player() then
			voxeldungeon.glog.w("You've been frozen solid!", buff.target)
			player_monoids.speed:add_change(buff.target, 0, "voxeldungeon:paralyzed")
			player_monoids.jump:add_change(buff.target, 0, "voxeldungeon:paralyzed")

			voxeldungeon.playerhandler.paralyze(buff.target)
		else
			local lua = buff.target:get_luaentity()
			lua.paralysis = (lua.paralysis or 0) + 1
			mobkit.clear_queue_high(lua)
			buff.target:set_texture_mod("^voxeldungeon_overlay_frozen.png")
		end

		local key = "voxeldungeon:frozen_"..buff.id.."_init"
		if voxeldungeon.storage.getBool(key) then
			return
		else
			voxeldungeon.storage.put(key, true)
		end

		if buff.target:is_player() then
			local freezables = {}
			local inv = buff.target:get_inventory()

			for i = 1, inv:get_size("main") do
				local item = inv:get_stack("main", i)

				if not item:is_empty() and minetest.get_item_group(item:get_name(), "freezable") > 0 then
					table.insert(freezables, {list = "main", index = i, frozen = item})
				end
			end

			for i = 1, inv:get_size("craft") do
				local item = inv:get_stack("craft", i)

				if not item:is_empty() and minetest.get_item_group(item:get_name(), "freezable") > 0 then
					table.insert(freezables, {list = "craft", index = i, frozen = item})
				end
			end

			for i = 1, inv:get_size("craftresult") do
				local item = inv:get_stack("craftresult", i)

				if not item:is_empty() and minetest.get_item_group(item:get_name(), "freezable") > 0 then
					table.insert(freezables, {list = "craftresult", index = i, frozen = item})
				end
			end

			if #freezables > 0 then
				local frozen = voxeldungeon.utils.randomObject(freezables)

				voxeldungeon.glog.i("Your "..voxeldungeon.utils.itemShortDescription(frozen.frozen).." freezes!", buff.target)

				local on_freeze = minetest.registered_items[frozen.frozen:get_name()].on_freeze
				if on_freeze then
					on_freeze(buff.target, buff.target:get_pos())
				end

				voxeldungeon.utils.take_item(buff.target, frozen.frozen)
				inv:set_stack(frozen.list, frozen.index, frozen.frozen)
			end
		else
			local lua = buff.target:get_luaentity()
			local itemstring = mobkit.recall(lua, "stolen")

			if lua.name == "voxeldungeon:thief" and itemstring then
				local item = ItemStack(itemstring)

				if  minetest.get_item_group(item:get_name(), "freezable") > 0 then
					mobkit.forget(lua, "stolen")

					local on_freeze = minetest.registered_items[item:get_name()].on_freeze
					if on_freeze then
						on_freeze(buff.target, buff.target:get_pos())
					end
				end
			end
		end
	end,

	do_effect = function(buff)
		local hp = voxeldungeon.mobs.health(buff.target)

		if buff.hp > hp then
			buff.detach()
		elseif buff.hp < hp then
			buff.hp = hp
		end
	end,

	on_detach = function(buff)
		if buff.target:is_player() then
			player_monoids.speed:del_change(buff.target, "voxeldungeon:paralyzed")
			player_monoids.jump:del_change(buff.target, "voxeldungeon:paralyzed")
			
			voxeldungeon.playerhandler.deparalyze(buff.target)
		else
			local lua = buff.target:get_luaentity()

			if lua and minetest then
				lua.paralysis = lua.paralysis - 1
			end

			buff.target:set_texture_mod("^blank.png")
		end

		voxeldungeon.storage.del("voxeldungeon:frozen_"..buff.id.."_init")
	end
})

voxeldungeon.buffs.register_buff("voxeldungeon:gasimmunity", {
	description = "Immune to Gases", 
	icon = "voxeldungeon_buff_gasimmunity.png",
	autoDecrement = true,

	on_attach = function(buff, first) 
		if first and buff.target:is_player() then
			voxeldungeon.glog.h("A protective film envelops you!", buff.target)
		end
	end,

	--See voxeldungeon.blobs.register
})

voxeldungeon.buffs.register_buff("voxeldungeon:haste", {
	description = "Haste", 
	icon = "voxeldungeon_buff_fast.png^[multiply:#FFFF00",
	autoDecrement = true,

	on_attach = function(buff, first) 
		if not first then return end

		if buff.target:is_player() then
			voxeldungeon.glog.h("You feel energetic!", buff.target)
			player_monoids.speed:add_change(buff.target, 3, "voxeldungeon:haste")
		else
			buff.target:get_luaentity().max_speed = buff.target:get_luaentity().max_speed * 3
		end
	end,

	on_detach = function(buff) 
		if buff.target:is_player() then
			player_monoids.speed:del_change(buff.target, "voxeldungeon:haste")
		elseif entitycontrol.isAlive("mobs", buff.target) then
			buff.target:get_luaentity().max_speed = buff.target:get_luaentity().max_speed / 3
		end
	end
})

voxeldungeon.buffs.register_buff("voxeldungeon:herbal_armor", {
	description = "Herbal Armor",
	icon = "voxeldungeon_buff_herbal_armor.png",

	--see tools.lua/minetest.register_on_punchplayer

	on_attach = function(buff)
		buff.pos = buff.target:get_pos()
	end, 

	do_effect = function(buff)
		if vector.distance(buff.pos, buff.target:get_pos()) > 1 then
			buff.detach()
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
		if vector.distance(buff.pos, buff.target:get_pos()) > 1 then
			buff.detach()
		else
			buff.target:set_hp(buff.target:get_hp() + 1)
		end
	end
})

voxeldungeon.buffs.register_buff("voxeldungeon:levitating", {
	description = "Levitation", 
	icon = "voxeldungeon_buff_levitation.png",
	autoDecrement = true,

	on_attach = function(buff, first) 
		voxeldungeon.buffs.detach_buff("voxeldungeon:rooted", buff.target)
		if first and buff.target:is_player() then
			voxeldungeon.glog.i("You float into the air!", buff.target)
			player_monoids.gravity:add_change(buff.target, 0, "voxeldungeon:levitating")
		end
	end,

	on_detach = function(buff)
		if buff.target:is_player() then
			player_monoids.gravity:del_change(buff.target, "voxeldungeon:levitating")
		end
	end
})

voxeldungeon.buffs.register_buff("voxeldungeon:mindvision", {
	description = "Mind Vision", 
	icon = "voxeldungeon_buff_mindvision.png",
	autoDecrement = true,

	--See voxeldungeon.utils.getPlayersInArea

	on_attach = function(buff, first) 
		if first and buff.target:is_player() then
			voxeldungeon.glog.i("You can somehow feel the presense of other creatures' minds!", buff.target)
		end
	end,
})

voxeldungeon.buffs.register_buff("voxeldungeon:paralyzed", {
	description = "Paralyzed", 
	icon = "voxeldungeon_buff_paralysis.png",
	autoDecrement = true,

	on_attach = function(buff, first)
		if not first then return end

		if buff.target:is_player() then
			voxeldungeon.glog.w("You are paralyzed!", buff.target)
			player_monoids.speed:add_change(buff.target, 0, "voxeldungeon:paralyzed")
			player_monoids.jump:add_change(buff.target, 0, "voxeldungeon:paralyzed")

			voxeldungeon.playerhandler.paralyze(buff.target)
		else
			local lua = buff.target:get_luaentity()
			lua.paralysis = (lua.paralysis or 0) + 1
			mobkit.clear_queue_high(lua)
		end
	end,

	on_detach = function(buff) 
		if buff.target:is_player() then
			player_monoids.speed:del_change(buff.target, "voxeldungeon:paralyzed")
			player_monoids.jump:del_change(buff.target, "voxeldungeon:paralyzed")
			
			voxeldungeon.playerhandler.deparalyze(buff.target)
		else
			local lua = buff.target:get_luaentity()
			lua.paralysis = lua.paralysis - 1
		end
	end
})

voxeldungeon.buffs.register_buff("voxeldungeon:poison", {
	description = "Poisoned", 
	icon = "voxeldungeon_buff_poisoned.png",
	autoDecrement = true,

	on_attach = function(buff, first) 
		if first and buff.target:is_player() then
			voxeldungeon.glog.w("You are poisoned!", buff.target)
		end
	end,

	do_effect = function(buff) 
		voxeldungeon.mobs.damage(buff.target, math.ceil(buff.left() / 3), "poison")
	end
})

voxeldungeon.buffs.register_buff("voxeldungeon:rooted", {
	description = "Rooted", 
	icon = "voxeldungeon_buff_rooted.png",
	autoDecrement = true,

	on_attach = function(buff, first) 
		if not first then return end

		if buff.target:is_player() and not voxeldungeon.buffs.get_buff("voxeldungeon:levitating", buff.target) then
			voxeldungeon.glog.w("You are rooted!", buff.target)
			player_monoids.speed:add_change(buff.target, 0, "voxeldungeon:rooted")
			player_monoids.jump:add_change(buff.target, 0, "voxeldungeon:rooted")

			voxeldungeon.playerhandler.halt(buff.target)
		else
			buff.detach()
		end
	end,

	on_detach = function(buff) 
		if buff.target:is_player() then
			player_monoids.speed:del_change(buff.target, "voxeldungeon:rooted")
			player_monoids.jump:del_change(buff.target, "voxeldungeon:rooted")
		end
	end
})

voxeldungeon.buffs.register_buff("voxeldungeon:terror", {
	description = "Terrified", 
	icon = "voxeldungeon_buff_terror.png",
	autoDecrement = true,

	--See mobs.lua/register_mob/on_punch

	on_attach = function(buff)
		if buff.target:is_player() then return end

		local key = "voxeldungeon:terror_"..buff.id.."_obj"

		if buff.customdata.obj then
			voxeldungeon.storage.put(key, buff.customdata.obj)
			return
		end

		local obj = voxeldungeon.storage.getStr(key)

		if obj then
			buff.customdata.obj = obj
		else
			buff.detach()
		end

		voxeldungeon.mobkit.runfrom(buff.target:get_luaentity(), minetest.get_player_by_name(buff.customdata.obj))
	end,

	do_effect = function(buff)
		voxeldungeon.mobkit.runfrom(buff.target:get_luaentity(), minetest.get_player_by_name(buff.customdata.obj))
	end,

	on_detach = function(buff)
		if not buff.target:is_player() then
			voxeldungeon.storage.del("voxeldungeon:terror_"..buff.id.."_obj")

			if entitycontrol.isAlive("mobs", buff.target) then
				mobkit.clear_queue_high(buff.target:get_luaentity())
			end
		end
	end,
})

voxeldungeon.buffs.register_buff("voxeldungeon:weakness", {
	description = "Weakened", 
	icon = "voxeldungeon_buff_weakness.png",
	autoDecrement = true,

	--See voxeldungeon.playerhandler.getSTR

	on_attach = function(buff, first) 
		if first and buff.target:is_player() then
			voxeldungeon.glog.w("You feel weakened!", buff.target)
			voxeldungeon.tools.updateStrdiffArmor(buff.target)
		end
	end,

	on_detach = function(buff)
		if buff.target:is_player() then
			voxeldungeon.tools.updateStrdiffArmor(buff.target)
		end
	end
})



minetest.register_on_joinplayer(function(player)
	local plrname = player:get_player_name()
	player_buffs[plrname] = {}

	for b, _ in pairs(voxeldungeon.buffs.registered_buffs) do
		local num = voxeldungeon.storage.getNum(b.."_"..plrname)

		if num and num > 0 then
			voxeldungeon.buffs.attach_buff(b, player, num)
		end
	end
end)

minetest.register_on_dieplayer(function(player)
	for _, buff in pairs(player_buffs[player:get_player_name()]) do
		buff.detach()
	end
end)
