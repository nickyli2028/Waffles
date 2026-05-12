g = {x=0,y=149.2}
floor = 60

player = {}
player.x = 111
player.y = 60
player.w = 8
player.h = 12
player.spr = 64
player.dir = 1
player.inv = {{"waffle", 0}, {"sweat tea", 0}, {"porkchop", 0}, {"steak", 0}, {"hashbrown", 0}, {"egg", 0}, {"toast", 0}}
player.health = 1.0
player.lift = false
player.throw = false
player.punch = false
player.action_time = 0

customer = {}
customer.x = 240
customer.y = 56
customer.w = 16
customer.h = 16
customer.tpe = 0
customer.spr = 128
customer.dir = 0
customer.health = 1.0
customer.order = {{"waffle", 0}, {"sweat tea", 0}, {"porkchop", 0}, {"steak", 0}, {"hashbrown", 0}, {"egg", 0}, {"toast", 0}}

cam_coords = {x = 80, y = 0}

game_state = 0
--[[game states
	0: service
	1: talking
	2: customer fighting
	3: game over
	4: closed
	5: keyboard
    6: main menu
	]]
dialogue = -1
option = 0
starting_fight = false

projectiles = {}
throwables = {}

musicon = false

ticks = 0

--player movement speed
player.accel = 40
player.vely = 0.3
player.jumpvel = {x=0,y=-100}
player.jumping = false
player.jumpdur = 0.8
player.jumpt = 0
player.canjump = false
player.radius = 9

prev_t = 0

--menu.lua
 cy=1
 mbutts={}
 menu_active = false

--keyboard.lua 
x=18
y=88

keyboard_active = false
keyboard_result = ""
keyboard_callback = nil

key = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z"," ","1","2","3","4","5","6","7","8","9","0","-","/",":",";","(",")","$","&","@","'",".",",","?","!","<",">"," "}
txtstr = {}
pr = 0
blk=0
numstate=0
keypos={x=0,y=0}
dspos={x=0,y=0}