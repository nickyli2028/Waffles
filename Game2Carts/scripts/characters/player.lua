-- arcade-style physics constants
ARCADE_GRAVITY   = 900   -- px/s²  (strong snappy gravity)
ARCADE_JUMP_VEL  = -250  -- px/s   (initial jump speed, negative = up)
ARCADE_JUMP_DUR  = 0.18  -- s      (hold-jump window)
ARCADE_WALK_SPD  = 1     -- px/frame (direct positional, not velocity)
MAX_FALL_SPD     = 480   -- px/s   (terminal velocity cap)

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
  if btnp(4) and player.lift == false then  -- z = button index 4
		for item in all(throwables) do
			local reach = player.x + 8
			if player.dir == 0 then
				reach = player.x - 8
			end
			if player.lift == false then
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
end

function move()
	local dt = time() - prev_t
  -- clamp dt to avoid physics explosions on first frame / lag spikes
  dt = mid(dt, 0, 0.05)

	local dx = 0

  -- left / right
  if btn(0) then dx -= ARCADE_WALK_SPD end
  if btn(1) then dx += ARCADE_WALK_SPD end

  -- jump: only register press on ground; hold extends slightly
  if btnp(2) and player.canjump then
    player.jumping  = true
    player.canjump  = false
    player.vely     = ARCADE_JUMP_VEL
    player.jumpt    = ARCADE_JUMP_DUR
  end

  -- cut jump height early if button released (variable jump)
  if not btn(2) and player.jumping and player.vely < 0 then
    player.vely = player.vely * 0.75
		player.jumping = false
	end

  -- jump window countdown
	if player.jumping then
		player.jumpt -= dt
    	if player.jumpt <= 0 then
   		   player.jumping = false
   		 end
	end

  -- gravity — strong arcade feel
  player.vely += ARCADE_GRAVITY * dt
  -- cap fall speed
  if player.vely > MAX_FALL_SPD then player.vely = MAX_FALL_SPD end

  -- apply movement
	player.x += dx
	player.y += player.vely * dt
	
  -- facing direction
	if dx > 0 then
		player.dir = 1
	elseif dx < 0 then
		player.dir = 0
	end

  -- horizontal bounds
	if player.x < 12 then
		player.x = 12
	elseif player.x > 316 then
		player.x = 316
	end

  -- floor collision
  if player.y >= floor then
    player.y    = floor
	player.vely = 0
    player.jumping  = false
    player.canjump  = true
	end

	prev_t = time()
	
  -- camera follow (fight mode uses cam_coords)
	if player.x - cam_coords.x > 80 then
		cam_coords.x = player.x - 80
	elseif player.x - cam_coords.x < 20 then
		cam_coords.x = player.x - 20
	end
	
  if cam_coords.x < 0   then cam_coords.x = 0   end
  if cam_coords.x > 200 then cam_coords.x = 200  end
end
