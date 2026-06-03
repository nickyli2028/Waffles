function _init()
	cartdata("fightbufferv1")
	cls()
	prev_t = time()
	
	music(1)

	if flr(rnd(100)) < 5 then
		game_state = 4
	end
	
	customer.tpe = flr(rnd(4)) + 1
	
	init_throwables()

	--menu: waffle, sweat tea, porkchop, steak, hashbrown, egg, toast
	for i = 1, 7 do
		local val = flr(rnd(10))
		customer.order[i][2] += val
	end
end

function _update60()
	ticks += 1
	if ticks == 60 then
		ticks = 1
	end
	if game_state == 0 then
		update_service()
	elseif game_state == 1 then
		update_talk()
	elseif game_state == 2 then
		update_fight()
	elseif game_state == 3 then
		update_gameover()
	elseif game_state == 5 then
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
	spr(40, 66, 40, 2, 2)
	spr(8, 80, 40, 2, 2)
	spr(12, 8, 40, 2, 4)
	spr(10, 24, 56, 2, 2)
	spr(10, 40, 56, 2, 2)

	if game_state == 0 then
		draw_service()
	elseif game_state == 1 then
		draw_talk()
	elseif game_state == 2 then
		draw_fight()
	elseif game_state == 3 then
		draw_gameover()
	elseif game_state == 4 then
		draw_closed()
	elseif game_state == 5 then
		if keyboard_active then
			picoboard()
		end
	elseif game_state == 6 then
		draw_menu()
	end
end

--draws player and customer
function drawPC()
	if customer.tpe == 2 then
		pal(2, 8)
		pal(1, 2)
	elseif customer.tpe == 3 then
		pal(2, 11)
		pal(1, 3)
	elseif customer.tpe == 4 then
		pal(2, 10)
		pal(1, 9)
	end
	spr(customer.spr, customer.x - 16, customer.y - 16, 4, 4, customer.dir == 1)
	spr(139 + customer.tpe, customer.x - 4, customer.y - 16, 1, 1)
	pal()
	palt(11, t)
	palt(0, f)
	spr(player.spr, player.x - 8, player.y - 12, 2, 3, player.dir == 0)
end