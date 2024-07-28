cannons = {}
cannons.MODPATH = minetest.get_modpath(minetest.get_current_modname())

dofile(cannons.MODPATH .."/functions.lua")
dofile(cannons.MODPATH .."/items.lua")
dofile(cannons.MODPATH .."/cannonballs.lua")

if minetest.get_modpath("tnt") then
	minetest.log("info","TNT mod is aviable. registering some TNT stuff")
	dofile(cannons.MODPATH .."/tnt.lua")
end

--if minetest.get_modpath("locks") then
--	minetest.log("warning","locks mod enabled. dont execute locks.lua because this is an unstable beta version!")
	--dofile(cannons.MODPATH .."/locks.lua")--if the locks mod is installed execute this file
--end
if minetest.get_modpath("moreores") then
minetest.log("info","moreores mod enabled. execute moreores.lua")
	dofile(cannons.MODPATH .."/moreores.lua")--if the moreores mod is installed execute this file
end
minetest.log("info", "[MOD]"..minetest.get_current_modname().." -- loaded from "..minetest.get_modpath(minetest.get_current_modname()))

