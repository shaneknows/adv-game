pico-8 cartridge // http://www.pico-8.com
version 30
__lua__
--get to the point
--by shaneknows
-- game loop

function _init()
	load_map()
	make_player()
	make_npcs()
end

function _update()
	if script_active then
		script_update()
	else
		move_player()
	end
	
	anim_npcs()
	anim_all(enemies)
	-- enemies
	if (rnd(100)>95) then
		spawn_enemy()
	end
end

function _draw()
 cls()
 map(0,0,0,0,128,128)
 spr(v.a_fr,v.x,v.y,1,1,v.flip)
 spr(npc1.a_fr,npc1.x,npc1.y,1,1,npc1.flip)
 spr(player.a_fr,player.x,player.y,1,1,player.flip)
	draw_all(enemies)


	if text then
		rectfill(2,107,125,125,0)
		print(text, 3,108, text_color)
	end
	if responses then
		local top = 101 - 6 * #responses
		rectfill(70, top,
		         125, 105, 0)
		for i=1, #responses do
			print(responses[i],
			      72, top + i*6-4,
			      i==ans and 7 or 5)
		end
	end
end

function reset_game()
	has_wheel=false
	has_key=false
end
-->8
--npcs
--tood: move to inventory
has_key=false
has_wheel=false
need_money=false
gold=0

npcs={}
function make_npcs()
	v={}
	v.x=4*8
	v.y=2*8
	v.script=function()
		if need_money then
			say([[oh 1 gold? here]])
			gold+=5
			announce([[received 1 gold]])
			need_money=false
		end
	
		if has_wheel then
			ask([[give wheel?]], "yes", "no")
			if ans==1 then
				say [[thank you so much!]]
				ask([[♥you win♥, play again?]],
					"yes", "no")
				if ans==1 then
					reset_game()
					_init()
				end
			end			
		else
			say [[
				my tire broke off my wagon,
				could you please help!]]
		end
	end
	
	npc1={}	
	npc1.x=13*8
	npc1.y=13*8
	npc1.script=function()
		if gold >= 1 then
			ask([[give gold?]],"yes","no")
			if ans==1 then
				gold-=1
				if ans==1 then
					say [[thanks it's in my shop.
			 		take this key]]
						has_key=true
						announce [[received: shop key]]
				end
			end
		elseif has_key then
			say([[my shop is just up there]])
		else
			ask([[can i help you?]],
			"wheel?",
			"no")
			if ans==1 then
				say [[yes i have a wheel.
				 that'll be 1 gold]]
				need_money=true
			else
				say [[very well, have a good one]]			
			end
		end
	end
	
	door={}
	door.x=11*8
	door.y=2*8
	door.script=function()
		if has_key then
			ask([[use key?]],
				"yes", "no")
			if ans==1 then
				say[[door unlocked!]]
				announce[[received wheel!]]
				has_wheel=true
			end
		else
			say[[locked!]]
		end
	end
	
	npcs[1]=v
	npcs[2]=npc1
	npcs[3]=door
end

function anim_npcs()
	 anim(v,32,3,10)
	 anim(npc1,16,4,5)
end
-->8
--player
function make_player()
	player = {}
	player.speed=1
	player.x=2*8
	player.y=13*8
	player.cm=true--collide map
	player.cw=true--collide with world
	--direction player is facing
	--(tile in front)
	player.fx=player.x
	player.fy=player.y+8
end

function move_player()
	move(player)
	if(btn(0))then
		player.fx=player.x-8
		player.fy=player.y
	 anim(player,6,3,10,true)
	end
	if(btn(1))then
		player.fx=player.x+8
		player.fy=player.y
	 anim(player,6,3,10)
	end
	if(btn(2))then		
		player.fx=player.x
		player.fy=player.y-8
	 anim(player,3,3,10)
	end
	if(btn(3))then
		player.fx=player.x
		player.fy=player.y+8
	 anim(player,0,3,10)
	end
	if(btnp(5))then
		foreach(npcs, check_npc)
	end
end

-->8
--animation
--object, starting frame, num frames
--anim speed, flip
function anim(o,sf,nf,sp,fl)
	if (not o.a_ct) o.a_ct=0
	if (not o.a_st) o.a_st=0
	
	o.a_ct+=1
	
	if (o.a_ct%(30/sp)==0)then
		o.a_st+=1
		if (o.a_st==nf) o.a_st=0
	end
	o.flip=fl
	o.a_fr=sf+o.a_st
end

function anim_all(group)
	for i in all(group)do
		anim(i,i.sprite,i.num_frames,
			i.anim_speed,i.fl)
	end
end

--draws collection of things
function draw_all(group)
	for i in all(group)do
		 spr(i.a_fr,i.x,i.y,i.height,i.width,i.flip)
	end
end
-->8
--map code
function load_map()
	w=128
	h=128
end

function cmap(o)
	local ct=false
	local cb=false
	
	--if colliding with map tiles
	if(o.cm) then
		local x1=o.x/8
		local y1=o.y/8
		local x2=(o.x+7)/8
		local y2=(o.y+7)/8
		local a=fget(mget(x1,y1),0)
		local b=fget(mget(x1,y2),0)
		local c=fget(mget(x2,y2),0)
		local d=fget(mget(x2,y1),0)
		ct = a or b or c or d
	end
	
	--if colliding with world
	if(o.cw) then
     cb=(o.x<0 or o.x+8>w or
         o.y<0 or o.y+8>h)
	end
	
	return ct or cb
end
-->8
--movement
function move(o)
	local lx=o.x --last x
	local ly=o.y --last y
	
	if(btn(0)) o.x-=o.speed
 if(btn(1)) o.x+=o.speed
 if(btn(2)) o.y-=o.speed
 if(btn(3)) o.y+=o.speed
	
	-- collision, revert movement
	if(cmap(o)) o.x=lx o.y=ly
end
-->8
--dialouge

-- scripting variables
-------------------------------
text = nil
text_color = 7
responses = nil
ans = 1
routine = nil
script_active = false

--initiate a script
function script_run(func)
	routine=cocreate(function()
		script_active=true
		func()
		script_active=false
	end)
	coresume(routine)
end

function script_update()
	coresume(routine)
end

--script commands
--------------------------
function reveal_text(str)
	text=""
	for i=1, #str do
		text = sub(str,1,i)
		yield()
	end
end

function say(str)
	reveal_text(str)
	repeat
	 -- every time we call yield()
	 -- we're saying "that's all
	 -- for now, come back here
	 -- next frame"
		yield()
	until btnp(5)
	text = nil
end

function announce(str)
	text = str
	text_color = 12
	repeat
		yield()
	until btnp(5)
	text = nil
	text_color = 7
end

function ask(str, ...)
	reveal_text(str)
	responses = {...}
	ans = 1
	repeat
		yield()
		if btnp(2) and ans > 1 then
			ans -= 1
		elseif btnp(3) and ans < #responses then
			ans += 1
		end
	until btnp(5)
	text = nil
	responses = nil
end

-- execute multiple script
--  functions at once.
-- the main script resumes once
--  all functions are complete
function simultaneously(...)
	local routines = {}
	for f in all{...} do
		add(routines, cocreate(f))
	end
	repeat
		yield()
		local complete = true
		for c in all(routines) do
			if coresume(c) then
			 complete = false
			end
		end
	until complete
end

function player_in_range(x, y)
	local px,py = player.fx, player.fy
	return (px <=x+4 and
				 				px >=x-4	and
 								py <=y+4 and
				 				py >=y-4)
end

--attempt to run a script
--if player is near npc
function check_npc(npc)
	if player_in_range(npc.x, npc.y) then
		if npc.script then
			script_run(npc.script)
		end
	end
end
-->8
--enemies
enemies={}

function spawn_enemy()
	--only allow 10 enemy at a time
	for i=0,10 do
		if (enemies[i]==nil) then
			enemies[i] = make_enemy(i)
			break
		end
	end
end

function make_enemy()
	--bat
	return {
		x=flr(rnd(128)),
		y=flr(rnd(128))-1,
		hp=1,
		sprite=128,
		height=1,
		width=1,
		num_frames=2,
		anim_speed=3,
		fl=false
	}
end
__gfx__
00666660006666600066666000666660006666600066666000066000000660000006600000000000000000000000000000000000000000000000000000000000
06636366066363660663636606666666066666660666666600666600006666000066660000000000000000000000000000000000000000000000000000000000
063a6a36063a6a36063a6a3606666666066666660666666600663a0000663a0000663a0000000000000000000000000000000000000000000000000000000000
00633360006333600063336000666660006666600066666000666600006666000066660000000000000000000000000000000000000000000000000000000000
00055500000555000005550000055500000555000005550000055500000555000005550000000000000000000000000000000000000000000000000000000000
00344430000344300034430000344430003444000004443000043400000443000004430000000000000000000000000000000000000000000000000000000000
00011100000113000003110000011100000111000001110000011100000111000001110000000000000000000000000000000000000000000000000000000000
00030300000300000000030000030300000003000003000000003000000300300030030000000000000000000000000000000000000000000000000000000000
00ddd00000ddd00000ddd00000ddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
64fcf00000fcf00000fcf00000fcf000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
64ffff0000ffff0000ffff0000ffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
08999000009990000099906600999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
02999000009190000099124400919000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999000009290000099900000929000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111000001460000011100000146000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00505000005460000050500000546000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111110011111100111111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01711710017117100171171000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07b77b7007b77b7007b77b7000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07777770077777700777777000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
07222200002222000022227000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222270072222700722220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00dddd0000dddd0000dddd0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00400400004004000040040000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b33bbbbbbbbbbbbbbb5555bbbbbb5bbbbbbbb3333333bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb555555bb
bbb3bbb3bbbbbbbbb555655bbbb53bbbbbb33333333333bbbbbbbbbbbbbbbbbbbbbbbbbbbb77777f777777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb555555bb
b3bb3b3bbbbbbbbbb5555655bbb3333bbb3b33533337333bbb244994944445bbbbbbbbbbb77777f777777f777bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb6666bbb
bb3bb3bbbbbbbbbbb5555565bb3333bbb333b333bb33733bb21255594955554bbbbbbbbb57777f777777f777777bbbbbbbbbbbbbbbbbb44444bbbbbbb5556bbb
3bb3b3bbbbbbbbbbb5555555b335b335b33335b33b333333b22144444444444bbbbbbbb55777f777777f7777755bbbbbbbbbbbbbbbb44499a444bbbbb6666bbb
b3b3bb3bbbbbbbbb35555555353b5b33333333333333b3333222445544999443bbbbbbb65777777777f77777565bbbbbbbbbbbbbb444a499a49444bbb5565bbb
b3b3b3bbbbbbbbbb33555555b333b33333bb3b3333b3bb33b32545444444443bbbbbbbb7422227777f777775565bbbbbbbbbbbb44494a499a444a444b6666bbb
bbbbbbbbbbbbbbbbbb355553355533b3335bbbbb3bb33333bbb33333333333bbbbbbbb444444422277777775665bbbbbbbbbb44494949499a494949446555bbb
111111111111111111555511b3bb3b3b533355553333b333bbb77bbb00000000bbbbb4444444444422277776665bbbbbbbb4449494a49499a494449496666bbb
11111c11111111111555655155333553b53333333333b335bb7577bb00000000bbbbb445544444554442277766bbbbbbb444944494449499a494a494945564bb
1111c1c11111111115555655bb5555bbbb5533333333335bbb7757bb00000000bbbbb444555544455444422266bbbbbb449494a4949494aaa494a44494449444
11c111111111111115555565bb4555bbbbb55355555355bbbb4775bb00000000bbbbbb44444555445544444277bbbbbb949494944494444444449494a4a49494
1c1c11111111111115555555bb4454bbbbbb534545535bbbbb4454bb00000000bbbbb44544444444444445442bbbbbbb44944494a44422222224449444944494
1111111111111111c5555555bb4445bbbbbbbb45545bbbbbbb4445bb00000000bbbbb45454bb4444444445444bbbbbbb949494944422111111122444a4949494
1111c11111111111cc55555cbb5445bbbbbbb4454454bbbbbb5445bb00000000bbbbb44544bbbbbb44444444bbbbbbbb94449444221111222111122444949444
111c1c11111111111cccccc1b545445bbbbbb5554455bbbbb545445b00000000bbbbbb444bbbbbbbbb444444bbbbbbbb94944422112222222222211224449494
55555555666666660000000000000000000000000000000000000000000000000000000000000000000000000000000094442211222222444222222112244494
66666666666666560000000000000000000000000000000000000000000000000000000000000000000000000000000044221122222444444444421221122444
55555556665666660000000000000000000000000000000000000000000000000000000000000000000000000000000022112222244444444444111222211222
55555556666666660000000000000000000000000000000000000000000000000000000000000000000000000000000011222444444444444444444444222111
66666666666666660000000000000000000000000000000000000000000000000000000000000000000000000000000022144114444444111444444411442222
65555555656666560000000000000000000000000000000000000000000000000000000000000000000000000000000022241111444441111144444111144222
65555555666666660000000000000000000000000000000000000000000000000000000000000000000000000000000022242222411441111144444222244112
6666666666656666000000000000000000000000000000000000000000000000000000000000000000000000000000002114444444441111a114444444441222
44444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000022211144444411119114444444414222
55555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055244114444411111114441444444225
44445444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555555555555555555555555555555
55555555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000055555553555555555555555555555555
454444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbb355535555555553555bbbb3bbb
555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbb3b3bb3bb55555553bbbbbbb3bbbb
444444450000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbb3bbb3b3bbbbb33b3bbbb3b3bbbb
555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bbbbbbbbbb3bbbbbbbb3bbbbbb3bbbbb
00100100001001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00111100101111010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01211210112112110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
01111110001111000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
11011011000110000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00022000002222000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00222200000220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000101010101010101010101010101010101000000010001010101010101010100000000000000000000000101010100000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
444548494a4b434351434c4d4e4f4445006a6a6a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
545558595a5b535351535c5d5e5f5455006a6a6a6a6a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
434141414141415051516c6d6e6f4043006a6a6a6a6a6a6a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
534141414140415251527c7d7e7f4053006a6a006a6a6a6a0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
43404040404040707070404040404043006a6a6a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5340404040404070707041404040405300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4340404040404050525140404040404300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5340404040404051515140404040405300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4445404040414151505141414141414300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5455404041414151515241414141415300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
4340404042414151515241414141414300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
5340404041414150515141414141415300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44414040404141515051414141414143007f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
53414141414141505151404647415653007f7f6a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
43434343434343515051434343434343437f7f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
53535353535353525252535353535353537f0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000004600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
