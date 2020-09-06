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

voxeldungeon.wands = {}

local ZAPS_TO_KNOW = 10
local wear = math.floor(65535 / 200)
local timer = 0

local wand_defs = 
{
	{
		name = "avalanche",
		def = {
			desc = "Avalance",

			zap = function(itemstack, user, pointed_thing)
				
			end
		}
	},
	{
		name = "blastwave",
		def = {	
			desc = "Blast Wave",

			info = function(wand, unidentified)
				local dmgtext = "only deals "..(wand:get_meta():get_int("voxeldungeon:level") + 2).." damage"

				if unidentified then 
					dmgtext = "typically only deals 2 damage"
				end

				return "This wand shoots a bolt which violently detonates at a target location. Although the force of this blast "
					..dmgtext..", it can send most enemies flying."
			end,

			zap = function(itemstack, user, pointed_thing)
				local level = itemstack:get_meta():get_int("voxeldungeon:level")
				local dir = user:get_look_dir()

				if pointed_thing.type == "object" then
					voxeldungeon.utils.blastwave(pointed_thing.ref:get_pos(), dir, level)
				elseif pointed_thing.type == "node" then
					voxeldungeon.utils.blastwave(pointed_thing.under, dir, level)
				else
					local pos = user:get_pos()
					pos.y = pos.y + 1.5

					voxeldungeon.projectiles.shoot("blastwave", pos, dir, {lvl = level})
				end
			end
		}
	},
	{
		name = "corrosion",
		def = {
			desc = "Corrosion",

			info = function()
				return "This wand shoots a bolt which explodes into a cloud of highly corrosive gas at a targeted location. Anything caught inside this cloud will take continual damage, increasing with time."
			end,

			zap = function(itemstack, user, pointed_thing)
				local level = itemstack:get_meta():get_int("voxeldungeon:level")

				if pointed_thing.type == "object" then
					voxeldungeon.blobs.seed("corrosivegas", pointed_thing.ref:get_pos(), 150 + 50 * level)
				elseif pointed_thing.type == "node" then
					voxeldungeon.blobs.seed("corrosivegas", pointed_thing.above, 150 + 50 * level)
				else
					local pos = user:get_pos()
					pos.y = pos.y + 1.5

					voxeldungeon.projectiles.shoot("corrosive", pos, user:get_look_dir(), {lvl = level})
				end
			end
		}
	},
	{
		name = "disintegration",
		def = {
			desc = "Disintegration",

			info = function(wand, unidentified)
				local dmgtext = "deals "..(5 + wand:get_meta():get_int("voxeldungeon:level") * 2).." damage"

				if unidentified then 
					dmgtext = "typically deals 5 damage"
				end

				return "This wand shoots a beam that pierces any obstacle, and will go farther the more it is upgraded. The beam "..dmgtext..", and will also deal bonus damage for each enemy and wall it penetrates."
			end,

			zap = function(itemstack, user, pointed_thing)
				local level = itemstack:get_meta():get_int("voxeldungeon:level")
				local range = 4 + level * 2
				local basedmg = 5 + level * 2

				local solids = 0

				local a = user:get_pos()
				a.y = a.y + 1.5
				local b = vector.add(a, vector.multiply(user:get_look_dir(), range))
				local laser = voxeldungeon.utils.findNodesInLine(a, b)

				for i = 1, #laser do
					local pos = laser[i].pos
					local node = laser[i].node

					if node and minetest.get_item_group(node.name, "flammable") > 0 and voxeldungeon.utils.canDig(pos) then
						solids = solids + 1
						minetest.remove_node(pos)
						minetest.punch_node(pos)
						minetest.place_node(pos, {name = "voxeldungeon:embers"})
					elseif voxeldungeon.utils.solid(pos) then
						solids = solids + 1
					end

					for _, obj in ipairs(voxeldungeon.utils.getLivingInArea(pos, 0.5, true)) do
						if not obj:is_player() or obj:get_player_name() ~= user:get_player_name() then
							voxeldungeon.mobs.damage(obj, basedmg + solids * 2, "disintegration")
							solids = solids + 1
						end
					end
				end
			end
		}
	},
	{
		name = "fireblast",
		def = {
			desc = "Fireblast",

			zap = function(itemstack, user, pointed_thing)
				
			end
		}
	},
	{
		name = "flock",
		def = {
			desc = "Flock",
			_baseCharges = 1,

			info = function(wand, unidentified)
				local amounttext = "up to "..(2 + wand:get_meta():get_int("voxeldungeon:level")).." magic sheep"

				if unidentified then 
					amounttext = "typically up to 2 magic sheep"
				end

				return "A flick of this wand uses its remaining charge to summon a flock of "..amounttext..", creating a temporary impenetrable obstacle. After a period of time, these sheep will all simultanously explode. Its power is derived from the amount of charges it can use in a single zap."
			end,

			zap = function(itemstack, user, pointed_thing)
				local meta = itemstack:get_meta()
				local level = 1 + meta:get_int("voxeldungeon:charge")
				meta:set_int("voxeldungeon:charge", 0)

				if pointed_thing.type == "object" then
					voxeldungeon.mobs.spawn_multiple("voxeldungeon:sheep", pointed_thing.ref:get_pos(), level)
				elseif pointed_thing.type == "node" then
					voxeldungeon.mobs.spawn_multiple("voxeldungeon:sheep", pointed_thing.above, level)
				else
					local pos = user:get_pos()
					pos.y = pos.y + 1.5

					voxeldungeon.projectiles.shoot("flock", pos, user:get_look_dir(), {lvl = level})
				end
			end
		}
	},
	{
		name = "frost",
		def = {
			desc = "Frost",

			zap = function(itemstack, user, pointed_thing)
				
			end
		}
	},
	{
		name = "lightning",
		def = {
			desc = "Lightning",

			zap = function(itemstack, user, pointed_thing)
				
			end
		}
	},
	{
		name = "magicmissile",
		def = {
			desc = "Magic Missile",
			_baseCharges = 3,

			info = function(wand, unidentified)
				local dmg = 6 + wand:get_meta():get_int("voxeldungeon:level")

				local dmgtext = "deals "..(6 + wand:get_meta():get_int("voxeldungeon:level")).." damage"

				if unidentified then 
					dmgtext = "typically deals 6 damage"
				end

				return "This fairly plain wand launches missiles of pure magical energy. While not as strong as other wands, it makes up for it somewhat with more available charges.\n \nEach bolt from this wand "..dmgtext..", and has no additional effects."
			end,

			zap = function(itemstack, user, pointed_thing)
				local d = 6 + itemstack:get_meta():get_int("voxeldungeon:level")

				if pointed_thing.type == "object" then
					voxeldungeon.mobs.damage(pointed_thing.ref, d, "magic missile")
				else
					local pos = user:get_pos()
					pos.y = pos.y + 1.5

					voxeldungeon.projectiles.shoot("magicmissile", pos, user:get_look_dir(), {dmg = d})
				end
			end
		}
	},
	{
		name = "prismaticlight",
		def = {
			desc = "Prismatic Light",

			info = function(wand, unidentified)
				local dmgtext = "deals "..(3 + wand:get_meta():get_int("voxeldungeon:level") * 2).." damage"

				if unidentified then 
					dmgtext = "typically deals 3 damage"
				end

				return "This wand shoots rays of light which cut through the thickest of darkness, revealing hidden areas and traps. The beam can blind enemies, and "..dmgtext..". Demonic and undead foes will burn in the bright light of the wand, taking bonus damage."
			end,

			zap = function(itemstack, user, pointed_thing)
				local level = itemstack:get_meta():get_int("voxeldungeon:level")

				local a = user:get_pos()
				a.y = a.y + 1.5
				local range = 1.5
				local b
				local targets

				repeat
					range = range + 1
					b = vector.add(a, vector.multiply(user:get_look_dir(), range))
					targets = voxeldungeon.utils.getLivingInArea(b, 0.5, true)
				until (voxeldungeon.utils.solid(b) or #targets > 0)

				range = range + 1
				b = vector.add(a, vector.multiply(user:get_look_dir(), range))

				local laser = voxeldungeon.utils.findNodesInLine(a, b)

				for i = 1, #laser do
					local pos = laser[i].pos
					local node = laser[i].node

					if node then
						node.name = nodeglow.node_to_glow(node.name)

						minetest.swap_node(pos, node)

						local hidden = minetest.find_nodes_in_area(vector.add(pos, -4), vector.add(pos, 4), "group:hidden")

						for _, n in ipairs(hidden) do
							minetest.registered_nodes[minetest.get_node(n).name].on_punch(n, nil, user)
						end
					end
				end

				for _, obj in ipairs(targets) do
					if not obj:is_player() or obj:get_player_name() ~= user:get_player_name() then
						local dmg = 3 + level * 2

						if not obj:is_player() and obj:get_luaentity().undead then
							dmg = voxeldungeon.utils.round(dmg * 1.3)
							voxeldungeon.particles.factory(voxeldungeon.particles.evil_be_gone, obj:get_pos(), 1, 0.1)
						end

						voxeldungeon.mobs.damage(obj, dmg, "prismatic light")
						if voxeldungeon.mobs.health(obj) > 0 and math.random(6 + level) >= 4 then
							voxeldungeon.buffs.attach_buff("voxeldungeon:blind", obj, math.floor(2 + level / 3))
						end
					end
				end

				minetest.after(0.333, function()
					for i = 1, #laser do
						local pos = laser[i].pos
						local node = laser[i].node

						if node then
							node.name = nodeglow.node_from_glow(node.name)

							minetest.swap_node(pos, node)
						end
					end
				end)
			end
		}
	},
	{
		name = "regrowth",
		def = {
			desc = "Regrowth",

			zap = function(itemstack, user, pointed_thing)
				
			end
		}
	},
	{
		name = "vampirism",
		def = {
			desc = "Vampirism",
			_baseCharges = 1,

			info = function(wand, unidentified)
				local dmg = 4 + wand:get_meta():get_int("voxeldungeon:level")
				local dmgtext = "deals "..dmg.." damage and will give you up to "..math.floor(dmg / 2).." HP."

				if unidentified then 
					dmgtext = "typically deals 4 damage and will usually give you up to 2 HP."
				end

				return "This wand will allow you to steal life energy from living creatures to restore your own health. However, using it against undead creatures will just harm them.\n \nEach bolt from this wand "..dmgtext
			end,

			zap = function(itemstack, user, pointed_thing)
				local d = 4 + itemstack:get_meta():get_int("voxeldungeon:level")

				if pointed_thing.type == "object" then
					if not pointed_thing.ref:get_luaentity().undead then
						local h = math.min(math.floor(d / 2), voxeldungeon.mobs.health(pointed_thing.ref))
						user:set_hp(user:get_hp() + h)
					end

					voxeldungeon.mobs.damage(pointed_thing.ref, d, "vampirism")
				else
					local pos = user:get_pos()
					pos.y = pos.y + 1.5

					voxeldungeon.projectiles.shoot("vampire", pos, user:get_look_dir(), {dmg = d, username = user:get_player_name()})
				end
			end
		}
	},
}

local woods = {"acacia", "aspen", "beech", "birch", "cedar", "date palm", "oak", "pine", "poplar", "sequoia", "spruce", "willow"}



function voxeldungeon.wands.getMaxCharge(wand)
	local base = wand:get_definition()._baseCharges
	local level = wand:get_meta():get_int("voxeldungeon:level")

	return base + level
end

function voxeldungeon.wands.getCurCharge(wand)
	return wand:get_meta():get_int("voxeldungeon:charge")
end

function voxeldungeon.wands.fullRecharge(wand)
	local meta = wand:get_meta()
	meta:set_int("voxeldungeon:charge", voxeldungeon.wands.getMaxCharge(wand))
end

function voxeldungeon.wands.isLevelKnown(wand)
	return wand:get_meta():get_int("voxeldungeon:levelKnown") >= ZAPS_TO_KNOW
end

function voxeldungeon.wands.isIdentified(wand)
	return voxeldungeon.wands.isLevelKnown(wand)
end

function voxeldungeon.wands.identify(wand)
	wand:get_meta():set_int("voxeldungeon:levelKnown", ZAPS_TO_KNOW)
	voxeldungeon.wands.updateDescription(wand)
end

function voxeldungeon.wands.updateDescription(wand)
	local meta = wand:get_meta()
	local level = meta:get_int("voxeldungeon:level")
	local levelKnown = voxeldungeon.wands.isLevelKnown(wand)

	local def = wand:get_definition()
	local info = def._getInfo(wand, not levelKnown)

	local chargeString = " (?/?)"

	if levelKnown then
		chargeString = " ("..voxeldungeon.wands.getCurCharge(wand)..'/'..voxeldungeon.wands.getMaxCharge(wand)..")"
	end
	
	meta:set_string("description", voxeldungeon.utils.itemDescription(voxeldungeon.utils.itemShortDescription(wand)..chargeString.."\n \n"
		..info.."\n \nRight click while holding a wand to zap with it."))
end

minetest.register_globalstep(function(dtime)
	for _, plr in pairs(minetest.get_connected_players()) do
		local inv = plr:get_inventory()

		for i = 1, inv:get_size("main") do
			local item = inv:get_stack("main", i)

			if not item:is_empty() and minetest.get_item_group(item:get_name(), "wand") > 0 then
				local meta = item:get_meta()
				local lastTime = meta:get_float("voxeldungeon:lasttime")
				local curCh = voxeldungeon.wands.getCurCharge(item)
				local maxCh = voxeldungeon.wands.getMaxCharge(item)

				local timeToCharge = 10 + 20 * math.pow(0.875, maxCh - curCh)

				if voxeldungeon.buffs.get_buff("voxeldungeon:recharging", plr) then
					timeToCharge = timeToCharge / 10
				end

				if lastTime > timer then
					meta:set_float("voxeldungeon:lasttime", timer)
					inv:set_stack("main", i, item)
				elseif curCh < maxCh and lastTime + timeToCharge <= timer then
					meta:set_int("voxeldungeon:charge", curCh + 1)
					meta:set_float("voxeldungeon:lasttime", timer)

					voxeldungeon.wands.updateDescription(item)

					inv:set_stack("main", i, item)
				end
			end
		end
	end

	timer = timer + dtime
end)



local function register_wand(name, wood, def)
	local do_zap = function(itemstack, user, pointed_thing)
		local charge = voxeldungeon.wands.getCurCharge(itemstack)

		if charge > 0 then
			def.zap(itemstack, user, pointed_thing)
			itemstack:add_wear(wear)

			local meta = itemstack:get_meta()
			local levelKnown = meta:get_int("voxeldungeon:levelKnown")
			local old = meta:get_int("voxeldungeon:charge")
			meta:set_int("voxeldungeon:charge", math.max(old - 1, 0))
			voxeldungeon.wands.updateDescription(itemstack)

			if old == voxeldungeon.wands.getMaxCharge(itemstack) then
				meta:set_float("voxeldungeon:lasttime", timer)
			end

			if levelKnown < ZAPS_TO_KNOW then
				levelKnown = levelKnown + 1
				meta:set_int("voxeldungeon:levelKnown", levelKnown)

				if levelKnown == ZAPS_TO_KNOW then
					voxeldungeon.wands.updateDescription(itemstack)
					voxeldungeon.glog.i("You are now familiar with your "..voxeldungeon.utils.itemShortDescription(itemstack)..".", user)
				end
			end
		else
			voxeldungeon.glog.w("The wand fizzles; it must be out of charges for now.", user)
		end

		return itemstack
	end

	local ns_wood = voxeldungeon.utils.removeSpaces(wood)

	local info = def.info
	if not info or type(info) == "string" then
		local str = info
		info = function() 
			return str or "!!!NO TEXT FOUND!!!"
		end
	end

	def.description = "Wand of "..def.desc
	def.inventory_image = "voxeldungeon_tool_wand_"..ns_wood..".png"
	def._getInfo = info

	def.groups = {wand = 1, upgradable = 1}

	def._baseCharges = def._baseCharges or 2

	def.on_place = do_zap
	def.on_secondary_use = do_zap

	minetest.register_tool("voxeldungeon:wand_"..name, def)
end

local loadWood = voxeldungeon.storage.getBool("loadedWands")
for k, v in ipairs(wand_defs) do
	local wood
	local woodKey = v.name.."_wood"

	if loadWood then
		wood = voxeldungeon.storage.getStr(woodKey)
	else
		wood = table.remove(woods, math.random(#woods))
		voxeldungeon.storage.put(woodKey, wood)
	end

	register_wand(v.name, wood, v.def)--v.desc, v.info, wood, v.zap)
end
voxeldungeon.storage.put("loadedWands", true)
