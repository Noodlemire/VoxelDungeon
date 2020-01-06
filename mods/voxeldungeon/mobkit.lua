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
--[[
function voxeldungeon.mobkit.skyBrain(self)
	-- vitals should be checked every step
	mobkit.vitals(self)

	local doReturn = voxeldungeon.mobkit.HPChecks(self)
	if doReturn then return end

	--decision making needn't happen every engine step
	if mobkit.timer(self,1) then 
		local prty = mobkit.get_queue_priority(self)
		
		--[[
		-- hunt
		if prty < 20 then
			local enemy = chooseEnemy(self)

			if enemy then 
				local hunt = self._huntfunc or mobkit.hq_hunt
				hunt(self, 10, enemy)
			end
		end
		
		-- fool around
		if mobkit.is_queue_empty_high(self) then
			voxeldungeon.mobkit.fly_roam(self, 0)
		end
	end
end

function voxeldungeon.mobkit.fly_roam(self, prty)
	local func = function(self)
		if mobkit.is_queue_empty_low(self) then
			local tpos = vector.add(self.object:get_pos(), voxeldungeon.utils.NEIGHBORS8[math.random(8)])
			mobkit.dumbstep(self, 5, tpos, 0.3)
		end
	end
	mobkit.queue_high(self,func,prty)
end

function voxeldungeon.mobkit.hq_climb(self,prty)
	local func = function(self)
		if mobkit.timer(self,5) then
			local pos = self.object:get_pos()
			local pos2 = mobkit.pos_translate2d(pos,self.object:get_yaw(),5)
			pos2.y = pos2.y - 15
			local height = mobkit.get_terrain_height(pos2,32)
			if not height or pos.y-max(height,1)>24 then 
				minetest.chat_send_all('glide')
				voxeldungeon.mobkit.hq_glide(self,prty)
				return true
			end
		end
		if mobkit.timer(self,15) then mobkit.clear_queue_low(self) end
		if mobkit.is_queue_empty_low(self) then voxeldungeon.mobkit.lq_fly_pitch(self,0.6,8,(random(2)-1.5)*30,1) end 
	end
	mobkit.queue_high(self,func,prty)
end

function voxeldungeon.mobkit.hq_glide(self,prty)
	local func = function(self)
		if mobkit.timer(self,5) then
			local pos = self.object:get_pos()
			pos2 = mobkit.pos_translate2d(pos,self.object:get_yaw(),5)
			pos2.y = pos2.y - 15
			local height = mobkit.get_terrain_height(pos2,32)
			if height and pos.y-max(height,1)<18 then 
				minetest.chat_send_all('climb')
				voxeldungeon.mobkit.hq_climb(self,prty)
				return true
			end
		end	
	if mobkit.timer(self,15) then mobkit.clear_queue_low(self) end
	if mobkit.is_queue_empty_low(self) then voxeldungeon.mobkit.lq_fly_pitch(self,0.6,-4,(random(2)-1.5)*30,0) end
	end
	mobkit.queue_high(self,func,prty)
end

local function pitchroll2pitchyaw(aoa,roll)
	if roll == 0.0 then return aoa,0 end 
	-- assumed vector x=0,y=0,z=1
	local p1 = tan(aoa)
	local y = cos(roll)*p1
	local x = sqrt(p1^2-y^2)
	local pitch = atan(y)
	local yaw=atan(x)*math.sign(roll)
	return pitch,yaw
end

function voxeldungeon.mobkit.lq_fly_aoa(self,lift,aoa,roll,acc,anim)
	aoa=rad(aoa)
	roll=rad(roll)
	local hpitch = 0
	local hyaw = 0
	local caoa = 0
	local laoa = nil
	local croll=roll
	local lroll = nil 
	local lastrot = nil
	local init = true
	local func=function(self)
		local rotation=self.object:get_rotation()
		local vel = self.object:get_velocity()	
		local vrot = mobkit.dir_to_rot(vel,lastrot)
		lastrot = vrot
		if init then
			if anim then mobkit.animate(self,anim) end
			init = false	
		end
		
		local accel=self.object:get_acceleration()
		
				-- gradual changes
		if abs(roll-rotation.z) > 0.5*self.dtime then
			croll = rotation.z+0.5*self.dtime*math.sign(roll-rotation.z)
		end		
		
		if 	croll~=lroll then 
			hpitch,hyaw = pitchroll2pitchyaw(aoa,croll)
			lroll = croll
		end
		
		local hrot = {x=vrot.x+hpitch,y=vrot.y-hyaw,z=croll}
		self.object:set_rotation(hrot)
		local hdir = mobkit.rot_to_dir(hrot)
		local cross = vector.cross(vel,hdir)
		local lift_dir = vector.normalize(vector.cross(cross,hdir))	
		
		local daoa = deg(aoa)
		local lift_coefficient = 0.24*abs(daoa)*(1/(0.025*daoa+1))^4*math.sign(aoa)	-- homegrown formula
		local lift_val = lift*vector.length(vel)^2*lift_coefficient
		
		local lift_acc = vector.multiply(lift_dir,lift_val)
		lift_acc=vector.add(vector.multiply(minetest.yaw_to_dir(rotation.y),acc),lift_acc)

		self.object:set_acceleration(vector.add(accel,lift_acc))
	end
	mobkit.queue_low(self,func)
end

function voxeldungeon.mobkit.lq_fly_pitch(self,lift,pitch,roll,acc,anim)
	pitch = rad(pitch)
	roll=rad(roll)
	local cpitch = pitch
	local croll = roll
	local hpitch = 0
	local hyaw = 0
	local lpitch = nil
	local lroll = nil 
	local lastrot = nil
	local init = true
	local func=function(self)
		if init then
			if anim then mobkit.animate(self,anim) end
			init = false	
		end
		local rotation=self.object:get_rotation()
		local accel=self.object:get_acceleration()
		local vel = self.object:get_velocity()	
		local speed = vector.length(vel)
		local vdir = vector.normalize(vel)
		local vrot = mobkit.dir_to_rot(vel,lastrot)
		lastrot = vrot
		
		-- gradual changes
		if abs(roll-rotation.z) > 0.5*self.dtime then
			croll = rotation.z+0.5*self.dtime*math.sign(roll-rotation.z)
		end		
		if abs(pitch-rotation.x) > 0.5*self.dtime then
			cpitch = rotation.x+0.5*self.dtime*math.sign(pitch-rotation.x)
		end
		
		if cpitch~=lpitch or croll~=lroll then 
			hpitch,hyaw = pitchroll2pitchyaw(cpitch,croll)
			lpitch = cpitch lroll = croll
		end
		
		local aoa = deg(-vrot.x+cpitch)							-- angle of attack
		local hrot = {x=hpitch, y=vrot.y-hyaw, z=croll}			-- hull rotation
		self.object:set_rotation(hrot)
		local hdir = mobkit.rot_to_dir(hrot)					-- hull dir
		
		local cross = vector.cross(hdir,vel)					
		local lift_dir = vector.normalize(vector.cross(hdir,cross))
		
		local lift_coefficient = 0.24*abs(aoa)*(1/(0.025*aoa+1))^4	-- homegrown formula
		local lift_val = mobkit.minmax(lift*speed^2*lift_coefficient,speed/self.dtime)
		
		local lift_acc = vector.multiply(lift_dir,lift_val)
		lift_acc=vector.add(vector.multiply(minetest.yaw_to_dir(rotation.y),acc),lift_acc)
		accel=vector.add(accel,lift_acc)
		accel=vector.add(accel,vector.multiply(vdir,-speed*speed*0.02))	-- drag
		accel=vector.add(accel,vector.multiply(hdir,acc))				-- propeller

		self.object:set_acceleration(accel)
--if mobkit.timer(self,2) then minetest.chat_send_all('aoa: '.. aoa ..' spd '.. speed ..' hgt:'.. self.object:get_pos().y) end
	end
	mobkit.queue_low(self,func)
end
--]]
