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

voxeldungeon.mobkit = {}

local function chooseEnemy(self)
	local view = self.view_range
	if voxeldungeon.buffs.get_buff("voxeldungeon:blind", self.object) then
		view = 2
	end

	if not self.alignment or voxeldungeon.buffs.get_buff("voxeldungeon:amok", self) then --Don't care, attack anything
		local objs = voxeldungeon.utils.getPlayersInArea(self.object:get_pos(), view)
		local mobs = entitycontrol.getEntitiesInArea("mobs", self.object:get_pos(), view, false)

		for _, mob in ipairs(mobs) do
			if entitycontrol.get_entity_id("mobs", self) ~= entitycontrol.get_entity_id("mobs", mob) then
				table.insert(objs, mob)
			end
		end

		return voxeldungeon.utils.randomObject(objs)
	elseif self.alignment == "evil" then
		local players = voxeldungeon.utils.getPlayersInArea(self.object:get_pos(), view)
			
		return voxeldungeon.utils.randomObject(players)
	end
end

function voxeldungeon.mobkit.runfrom(self, other)
	if self and other then
		mobkit.hq_runfrom(self, 20, other)
		mobkit.remember(self, "fleeing", true)
	end
end

function voxeldungeon.mobkit.punch_hunt(self, prty, tgtobj)
	local func = function(self)
		if not mobkit.is_alive(tgtobj) then return true end

		if mobkit.is_queue_empty_low(self) and self.isonground then
			local pos = mobkit.get_stand_pos(self)
			local opos = tgtobj:get_pos()
			local dist = vector.distance(pos,opos)

			if dist > self.view_range then
				return true
			elseif dist > self.attack.range then
				mobkit.goto_next_waypoint(self,opos)
			else
				voxeldungeon.mobkit.punch_attack(self, prty+1, tgtobj)					
			end
		end
	end

	mobkit.queue_high(self, func, prty)
end

function voxeldungeon.mobkit.punch_attack(self, prty, tgtobj)
	local func = function(self)
		if not mobkit.is_alive(tgtobj) then return true end

		if mobkit.is_queue_empty_low(self) then
			local pos = mobkit.get_stand_pos(self)
			local tpos = mobkit.get_stand_pos(tgtobj)
			local dist = vector.distance(pos,tpos)

			if dist > self.attack.range then 
				return true
			else
				mobkit.lq_turn2pos(self,tpos)

				local height = tgtobj:is_player() and 0.35 or tgtobj:get_luaentity().height*0.6

				if tpos.y+height>pos.y then 
					tgtobj:punch(self.object,1,self.attack)
				else
					mobkit.lq_dumbwalk(self,mobkit.pos_shift(tpos,{x=random()-0.5,z=random()-0.5}))
				end
			end
		end
	end

	mobkit.queue_high(self, func, prty)
end

function voxeldungeon.mobkit.HPChecks(self)
	if self.hp <= 0 then
		local drops = {}

		if not mobkit.recall(self, "died") then
			local def = minetest.registered_entities[self.name]

			if def._drops then
				for _, drop in ipairs(def._drops) do
					if voxeldungeon.utils.randomDecimal() < drop.chance then
						local dropname = drop.name
						local itemdrop = ItemStack({name = dropname, count = math.random(drop.min, drop.max)})

						if type(dropname) == "function" then
							itemdrop = dropname(voxeldungeon.utils.getChapter(self.object:get_pos()))
						end

						--minetest.add_item(self.object:get_pos(), itemdrop)
						table.insert(drops, itemdrop:to_string())
					end
				end
			end

			if def._on_death then
				def._on_death(self)
			end
		end

		mobkit.remember(self, "died", true)

		mobkit.clear_queue_high(self)
		mobkit.hq_die(self)

		return drops
	end
end

function voxeldungeon.mobkit.landBrain(self)
	-- vitals should be checked every step
	mobkit.vitals(self)

	local drops = voxeldungeon.mobkit.HPChecks(self)
	if drops then
		for _, item in ipairs(drops) do
			minetest.add_item(self.object:get_pos(), ItemStack(item))
		end

		return 
	end

	if (self.groups and self.groups.does_nothing) or (self.paralysis and self.paralysis > 0) then return end

	--decision making needn't happen every engine step
	if mobkit.timer(self,1) then 
		local prty = mobkit.get_queue_priority(self)
		
		if prty < 20 and self.isinliquid then
			mobkit.hq_liquid_recovery(self,20)
			return
		end
		
		local pos=self.object:get_pos()
		
		-- hunt
		if prty < 10 then
			local enemy = chooseEnemy(self)

			if enemy then 
				local hunt = self._huntfunc or mobkit.hq_hunt
				hunt(self, 10, enemy)
			end
		end
		
		-- fool around
		if mobkit.is_queue_empty_high(self) then
			mobkit.hq_roam(self,0)
		end
	end
end
