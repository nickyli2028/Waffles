function punch()
	if player.dir == 0 then
		return player.x - 8 < customer.x + 8
					and player.x - 8 > customer.x - 8
					and player.y < customer.y + 10
					and player.y > customer.y - 16
	else
		return player.x + 8 < customer.x + 8
					and player.x + 8 > customer.x - 8
					and player.y < customer.y + 10
					and player.y > customer.y - 16
	end
end

function pickup()
	if btnp(❎) and player.lift == false then
		for item in all(throwables) do
			local reach = player.x + 8
			if player.dir == 0 then
				reach = player.x - 8
			end
			if item.tpe == 0 then
				if reach < item.x + 8
					and reach > item.x
					and player.y < item.y + 8
					and player.y > item.y - 16 then
					item.lift = true
					player.lift = true
					player.action_time = 0
				end
			else
				if reach < item.x + 16
					and reach > item.x
					and player.y < item.y + 8
					and player.y > item.y - 16 then
					item.lift = true
					player.lift = true
					player.action_time = 0
				end
			end
		end
	end
end

function move()
	local dt = time() - prev_t
	local dx = 0

	--player movement
	if btn(0) then
		dx -= 1
	end

	if btn(1) then
		dx += 1
	end

	if btn(2) and player.canjump then
		player.jumping = true
		player.canjump = false
		player.vely = player.jumpvel.y
		player.jumpt = player.jumpdur
	end

	--jumping
	if player.jumpt - dt < 0 then
		player.jumping = false
	end

	if player.jumping then
		-- player.vely = player.jumpvel.y * dt
		player.jumpt -= dt
	end

	--gravity
	player.vely += g.y * dt

	player.x += dx
	player.y += player.vely * dt
	
	if dx > 0 then
		player.dir = 1
	elseif dx < 0 then
		player.dir = 0
	end

	if player.x < -76 then
		player.x = -76
	elseif player.x > 312 then
		player.x = 312
	end

	if player.y > floor then
		player.y = floor
		player.vely = 0
		player.jumping = false
		player.canjump = true
	end

	prev_t = time()
	
	if player.x - cam_coords.x > 80 then
		cam_coords.x = player.x - 80
	elseif player.x - cam_coords.x < 20 then
		cam_coords.x = player.x - 20
	end
	
	if cam_coords.x < -80 then
		cam_coords.x = -80
	elseif cam_coords.x > 192 then
		cam_coords.x = 192
	end

end