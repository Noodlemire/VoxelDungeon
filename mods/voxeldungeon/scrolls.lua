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

local scroll_defs = 
{
	{
		name = "upgrade",
		desc = "Upgrade\n \nThis scroll will upgrade a single item, improving its quality. A wand will increase in power and in number of charges; a weapon will inflict more damage or find its mark more frequently; a suit of armor will deflect additional blows; the effect of a ring on its wearer will intensify. Weapons and armor will also require less strength to use, and any curses on the item will be lifted.",

		read = function(itemstack, user, pointed_thing)
			local itemname = itemstack:get_name()
			voxeldungeon.utils.take_item(user, itemstack)

			voxeldungeon.itemselector.showSelector(user, "Select an item to upgrade.", function(player, item)
				if item then
					voxeldungeon.tools.upgrade(item)
					voxeldungeon.glog.p("Your "..voxeldungeon.utils.itemShortDescription(item).." looks much better now.", player)
					return item
				else
					voxeldungeon.utils.return_item(user, itemname)
				end
			end)

			return itemstack
		end
	},
	{
		name = "identify",
		desc = "Identify",

		read = function(itemstack, user, pointed_thing)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "removecurse",
		desc = "Remove Curse",

		read = function(itemstack, user, pointed_thing)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "enchantment",
		desc = "Enchantment",

		read = function(itemstack, user, pointed_thing)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "terror",
		desc = "Terror\n \nA flash of red light will overwhelm all creatures in your field of view with terror, and they will turn and flee. An enemy can resist this effect at low health.",

		read = function(itemstack, user, pointed_thing)
			local terrRange = 50
			local mindVision = false
			if voxeldungeon.buffs.get_buff("voxeldungeon:mindvision", user) then
				terrRange = 100
				mindVision = true
			end

			local affected = entitycontrol.getEntitiesInArea("mobs", user:get_pos(), terrRange, mindVision)

			for _, mob in ipairs(affected) do
				voxeldungeon.buffs.attach_buff("voxeldungeon:terror", mob, 10, {obj = user:get_player_name()})
			end

			if #affected == 0 then
				voxeldungeon.glog.i("The scroll emits a brilliant flash of red light.", user)
			elseif #affected == 1 then
				local desc = affected[1]:get_luaentity().description or "!!!NO TEXT FOUND!!!"
				voxeldungeon.glog.i("The scroll emits a brilliant flash of red light and the "..desc.." flees!", user)
			else
				voxeldungeon.glog.i("The scroll emits a brilliant flash of red light and the monsters flee!", user)
			end

			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "rage",
		desc = "Rage\n \nWhen read aloud, this scroll will unleash a great roar that enrages nearby enemies, and draws some more distant enemies to the reader.",

		read = function(itemstack, user, pointed_thing)
			local pos = user:get_pos()

			local rageRange = 50
			local mindVision = false
			if voxeldungeon.buffs.get_buff("voxeldungeon:mindvision", user) then
				rageRange = 100
				mindVision = true
			end

			local affected = entitycontrol.getEntitiesInArea("mobs", pos, rageRange, mindVision)

			for _, mob in ipairs(affected) do
				voxeldungeon.buffs.attach_buff("voxeldungeon:amok", mob, 5)
			end

			if not mindVision then
				local affectedBeyond = entitycontrol.getEntitiesInArea("mobs", pos, 100, true)

				for _, mob in ipairs(affectedBeyond) do
					if not voxeldungeon.buffs.get_buff("voxeldungeon:amok", mob) then
						mobkit.hq_goto(mob:get_luaentity(), 10, pos)
					end
				end
			end

			voxeldungeon.glog.w("The scroll emits an enraging roar that echoes throughout the area!", user)

			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "magicmapping",
		desc = "Magic Mapping",

		read = function(itemstack, user, pointed_thing)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "lullaby",
		desc = "Lullaby",

		read = function(itemstack, user, pointed_thing)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "psionicblast",
		desc = "Psionic Blast\n \nThis scroll contains incredible destructive energy that can be channeled to destroy the minds of all nearby creatures. There is significant feedback however, and the reader will also be damaged, blinded, and weakened. The more targets the scroll hits, the less self-damage will be taken.",

		read = function(itemstack, user, pointed_thing)
			local pos = user:get_pos()
			local affected = 0

			local psiRange = 50
			local mindVision = false
			if voxeldungeon.buffs.get_buff("voxeldungeon:mindvision", user) then
				psiRange = 100
				mindVision = true
			end

			for _, mob in ipairs(entitycontrol.getEntitiesInArea("mobs", pos, psiRange, mindVision)) do
				local lua = mob:get_luaentity()

				voxeldungeon.mobs.damage(mob, voxeldungeon.utils.round(lua.max_hp / 2 + lua.hp / 2), "psionic blast")

				if lua.hp > 0 then
					voxeldungeon.buffs.attach_buff("voxeldungeon:blind", mob, 10)
				end

				affected = affected + 1
			end

			for _, plr in ipairs(voxeldungeon.utils.getPlayersInArea(pos, psiRange, mindVision)) do
				if plr:get_player_name() ~= user:get_player_name() then
					local HT = voxeldungeon.playerhandler.playerdata[plr:get_player_name()].HT

					voxeldungeon.mobs.damage(plr, voxeldungeon.utils.round(HT / 2 + plr:get_hp() / 4), "psionic blast")

					if plr:get_hp() > 0 then
						voxeldungeon.buffs.attach_buff("voxeldungeon:blind", plr, 10)
						voxeldungeon.buffs.attach_buff("voxeldungeon:weakness", plr, 100)
					end

					affected = affected + 1
				end
			end

			local HT = voxeldungeon.playerhandler.playerdata[user:get_player_name()].HT
			voxeldungeon.mobs.damage(user, voxeldungeon.utils.round(HT * 0.5 * math.pow(0.9, affected)), "psionic blast")

			if user:get_hp() > 0 then
				voxeldungeon.buffs.attach_buff("voxeldungeon:blind", user, 10)
				voxeldungeon.buffs.attach_buff("voxeldungeon:weakness", user, 100)
			end

			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "teleportation",
		desc = "Teleportation\n \nThe spell on this parchment instantly transports the reader to a random location up to 75 blocks away. It can be used to escape a dangerous situation, but an unlucky reader might find himself in an even more dangerous place.",

		read = function(itemstack, user, pointed_thing)
			voxeldungeon.utils.randomTeleport(user)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "mirrorimage",
		desc = "Mirror Image",

		read = function(itemstack, user, pointed_thing)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	},
	{
		name = "recharging",
		desc = "Recharging",

		read = function(itemstack, user, pointed_thing)
			return voxeldungeon.utils.take_item(user, itemstack)
		end
	}
}

local runes = {"sowilo", "odal", "tiwaz", "naudiz", "gyfu", "yngvi", "berkanan", "raido", "isaz", "mannaz", "laguz", "kaunan"}



local function register_scroll(name, desc, rune, use)
	minetest.register_craftitem("voxeldungeon:scroll_"..name,
	{
		description = voxeldungeon.utils.itemDescription("Scroll of "..desc.."\n \nLeft click while holding a scroll to read it."),
		inventory_image = "voxeldungeon_item_scroll_"..rune..".png",
		_cornerLR = "voxeldungeon_icon_scroll_"..name..".png",
		on_use = function(itemstack, user, pointed_thing)
			if false and voxeldungeon.buffs.get_buff("voxeldungeon:blind", user) then
				voxeldungeon.glog.w("You can't read a scroll while blinded.", user)
				return
			end

			return use(itemstack, user, pointed_thing)
		end
	})
end

local loadRunes = voxeldungeon.storage.getBool("loadedScrolls")
for k, v in ipairs(scroll_defs) do
	local rune
	local runeKey = v.name.."_rune"

	if loadRunes then
		rune = voxeldungeon.storage.getStr(runeKey)
	else
		rune = table.remove(runes, math.random(#runes))
		voxeldungeon.storage.put(runeKey, rune)
	end

	register_scroll(v.name, v.desc, rune, v.read)
end
voxeldungeon.storage.put("loadedScrolls", true)
