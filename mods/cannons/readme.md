# Welcome to the cannons mod #

cannons is a mod for the game minetest written by Kingarthurs Team
(Semmett9, eythen, and addi)

if you have some muni in the cannon and some gunpowder
you can shot the cannon if you punch it with a torch.

the cannonball will damage the other players.
if it wears armor the damage will be calculated.

## configure cannons ##

change the settings in your minetest.conf:

```conf
cannons_enable_explosion = "true"
cannons_enable_fire = "true"
```

thats all :-)

## Dependencies ##

* default
* bucket
* fire(optional)

## get cannons ##

relases are in the [donwloads Tab](https://bitbucket.org/kingarthursteam/cannons/downloads#tag-downloads)
swith there to tab 'Tags'

its also aviable as a git repo:

```bash
git clone https://kingarthursteam@bitbucket.org/kingarthursteam/canons.git
```

## Craft Rezieps ##

Bucket with salt:

![Bucket with salt salt](https://bitbucket.org/kingarthursteam/cannons/wiki/crafts/bucket_with_salt.png)

Salt (shapeless):

![salt](https://bitbucket.org/kingarthursteam/cannons/wiki/crafts/salt.png)

Gunpowder (schapeless):

![craft gunpowder](https://bitbucket.org/repo/bxGA9B/images/474788878-craft_gunpowder.gif)

cannons:

![cannon & bronce cannon](https://bitbucket.org/repo/bxGA9B/images/237489485-craft_cannon.gif)
Wooden stand:

![wooden stand](https://bitbucket.org/kingarthursteam/cannons/wiki/crafts/woden_stand.png)

Stone Stand:

![stone stand](https://bitbucket.org/kingarthursteam/cannons/wiki/crafts/stone_stand.png)

## Screenshots ##

![Cannon Tower](https://bitbucket.org/kingarthursteam/cannons/wiki/screenshots/screenshot_1531516.png)
![Cannon Tower 2](https://bitbucket.org/kingarthursteam/cannons/wiki/screenshots/screenshot_1849086.png)
![Cannon Tower 3](https://bitbucket.org/kingarthursteam/cannons/wiki/screenshots/screenshot_5781410.png)

## Create your own Cannonball ##

```lua

local ball_wood={
 physical = false,
 timer=0,
 textures = {"cannons_wood_bullet.png"},
 lastpos={},
 damage=20,
 range=1,
 gravity=10,
 velocity=40,
 name="cannons:wood_bullet",
 collisionbox = {-0.25,-0.25,-0.25, 0.25,0.25,0.25},
 on_player_hit = function(self,pos,player)
  local playername = player:get_player_name()
  player:punch(self.object, 1.0, {
   full_punch_interval=1.0,
   damage_groups={fleshy=self.damage},
   }, nil)
  self.object:remove()
  minetest.chat_send_all(playername .." tried to catch a cannonball")
 end,
 on_mob_hit = function(self,pos,mob)
  mob:punch(self.object, 1.0, {
   full_punch_interval=1.0,
   damage_groups={fleshy=self.damage},
   }, nil)
  self.object:remove()
 end,
 on_node_hit = function(self,pos,node)
  if node.name == "default:dirt_with_grass" then   
   minetest.env:set_node({x=pos.x, y=pos.y, z=pos.z},{name="default:dirt"})
   minetest.sound_play("cannons_hit",
    {pos = pos, gain = 1.0, max_hear_distance = 32,})
   self.object:remove()
  elseif node.name == "default:water_source" then
  minetest.sound_play("cannons_splash",
   {pos = pos, gain = 1.0, max_hear_distance = 32,})
   self.object:remove()
  else
  minetest.sound_play("cannons_hit",
   {pos = pos, gain = 1.0, max_hear_distance = 32,})
   self.object:remove()
  end
 end,

}
cannons.register_muni("cannons:ball_wood",ball_wood)
```

Have fun!
