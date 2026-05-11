function _init()
	cls()
	prev_t = time()
	
	music(1)
	
	local rndtpe = rnd(100)
	
	if rndtpe < 25 then
		customer.tpe = 1
	elseif rndtpe < 50 then
		customer.tpe = 2
	elseif rndtpe < 75 then
		customer.tpe = 3
	else
		customer.tpe = 4
	end
	
	for i = 0, 9 do
		local item = {
			x = 0,
			y = 56,
			tpe = 1,
			lifted = false,
			air = false,
			airx = 0,
			airy = 0,
			dir = 0
		}
		if i == 0 then
			item.x = 137
			item.tpe = 0
		elseif i == 1 then
			item.x = 192
		elseif i == 2 then
			item.x = 240
		elseif i == 3 then
			item.x = 288
		else
			item.tpe = 2
			if i == 4 then
				item.x = 176
			elseif i == 5 then
				item.x = 208
				item.dir = 1
			elseif i == 6 then
				item.x = 224
			elseif i == 7 then
				item.x = 256
				item.dir = 1
			elseif i == 8 then
				item.x = 272
			else
				item.x = 304
				item.dir = 1
			end
		end
		add(throwables, item)
	end
end

function _update60()
	ticks += 1
	if ticks == 60 then
		ticks = 1
	end
	if game_state == 0 then
		update_talk()
	elseif game_state == 1 then
		update_fight()
	elseif game_state == 2 then
		update_gameover()
	elseif game_state == 4 then
		update_menu()
	end
end

function _draw()
	palt(11, t)
	palt(0, f)
	cls(11)
	map(0, 0, 0, 0, 40, 16)
	camera(cam_coords.x, cam_coords.y)
	
	rectfill(122, 56, 131, 58, 6)
	
	for item in all(throwables) do
		if item.tpe == 0 then
			spr(1, item.x, item.y, 1, 1)
			spr(18, item.x, item.y + 8, 1, 1)
		elseif item.tpe == 1 then
			spr(32, item.x, item.y, 2, 2)
		else
			spr(20, item.x, item.y - 8, 2, 3, item.dir == 1)
		end
	end
	if game_state == 0 then
		draw_talk()
	elseif game_state == 1 then
		draw_fight()
	elseif game_state == 2 then
		draw_gameover()
	elseif game_state == 3 then
		if keyboard_active then
			picoboard()
		end
	elseif game_state == 4 then
		draw_menu()
	end
end