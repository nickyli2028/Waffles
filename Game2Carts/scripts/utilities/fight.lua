function update_fight()
	if starting_fight then
		start_fight()
	else
		player.spr = 66
		move()
		cust_move()
    update_hit_flash()

    -- ── attack inputs 
    if btnp(4) and player.action_time == 0 and player.lift == false then
      -- z: punch or pick up
			pickup()
			if player.lift == true then
				player.punch = false
				player.throw = false
				player.action_time = 15
			else
				player.punch = true
				player.action_time = 15
                try_punch()   -- handles hit check + damage internally
				end

    elseif btnp(5) and (player.action_time == 0 or player.lift == true) then
      -- x: throw held item, or fire a ranged shot
      if player.lift == true then
				for item in all(throwables) do
    				if item.lift == true then
						item.lift    = false
						item.air     = true
						item.airx    = item.x
						item.airy    = item.y
						item.airdir  = player.dir
						player.lift  = false
						player.throw = true
    					player.action_time = 15
    				end
    			end
			else
        -- enforce cap before spawning a new projectile
        local count = 0
        for _ in all(projectiles) do count += 1 end
        if count < MAX_PROJECTILES then
				player.throw = true
				player.action_time = 15
				local proj = {
            dir  = player.dir,
            x    = player.x - 12,
            y    = player.y - 4,
            tpe  = 1,
            w    = PROJ_SIZE,
            h    = PROJ_SIZE,
				}
				if proj.dir == 1 then
					proj.x = player.x + 7
				end
				add(projectiles, proj)
			end
		end
    end

		update_projectiles()
		update_throwables()
		check_health()
	end
end

function start_fight()
	if player.x < 122 then
		player.x += .3
		player.y = (player.x-117)*(player.x-117) + 18
		customer.x += .5
		cam_coords.x += .3
		if player.x < 114 then
			player.spr = 76
		elseif player.x < 120 then
			player.spr = 78
		else
			player.spr = 66
		end
	elseif player.x < 149 then
		player.spr = 66
		player.x += .4
		player.y = .24*(player.x-135)*(player.x-135) + 12
		customer.spr = 132
		customer.x += .5
		cam_coords.x += .4
		if player.x < 125 then
			player.spr = 66
		elseif player.x < 138 then
			player.spr = 76
		elseif player.x < 145 then
			player.spr = 78
		else
			player.spr = 66
		end
	else
		player.y = 60
		starting_fight = false
	end
end

function draw_fight()
	if player.action_time > 0 or player.lift == true then
		if player.punch == true or player.throw == true then
			player.spr = 68
			player.action_time -= 1
		elseif player.lift == true then
			player.spr = 70
		end
	else
		player.punch = false
        player.lift  = false
	end
	drawPC()
	rectfill(cam_coords.x, 104, cam_coords.x + 128, 128, 5)
	
	--player health
	spr(64, cam_coords.x + 2, 105, 2, 2)
	rect(cam_coords.x + 17, 110, cam_coords.x + 59, 115, 6)
	rectfill(cam_coords.x + 18, 111, cam_coords.x + 18 + (40 * player.health), 114, 8)
	
	--customer health
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
  -- hit flash: briefly invert enemy colours
  if customer.hit_flash and customer.hit_flash > 0 then
    pal(2, 7) pal(1, 7)
  end

	spr(133, cam_coords.x + 111, 105, 2, 2)
	spr(139 + customer.tpe, cam_coords.x + 115, 105, 1, 1)
	pset(cam_coords.x + 126, 120, 5)
	pset(cam_coords.x + 127, 120, 5)
	pal()
	palt(11, t)
	palt(0, f)
	rect(cam_coords.x + 65, 110, cam_coords.x + 107, 115, 6)
	rectfill(cam_coords.x + 66, 111, cam_coords.x + 66 + (40 * customer.health), 114, 8)
	
	--draw bullets
	for proj in all(projectiles) do
		if proj.tpe == 0 then
			sspr(0, 8, 8, 8, proj.x, proj.y - (PROJ_SIZE - 8), PROJ_SIZE, PROJ_SIZE, proj.dir == 1)
		elseif proj.tpe == 1 then
			sspr(8,8, 8, 8, proj.x, proj.y - (PROJ_SIZE - 8), PROJ_SIZE, PROJ_SIZE, proj.dir == 1)
		end
	end

  -- show cap warning in debug builds
  if DEBUG then
    local count = 0
    for _ in all(projectiles) do count += 1 end
    print("proj:"..count.."/"..MAX_PROJECTILES, cam_coords.x+2, 96, 7)
  end
end