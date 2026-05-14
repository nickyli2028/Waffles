MAX_PROJECTILES = 6
PROJ_SIZE = 12

function update_projectiles()
	for proj in all(projectiles) do
		if proj.dir == 0 then
			proj.x -= 1.5
		else
			proj.x += 1.5
		end
		-- off-screen cull (keeps things clean and counts under cap)
    if proj.x < cam_coords.x - 32 or proj.x > cam_coords.x + 160 then
      del(projectiles, proj)
	elseif hit(proj) then
			if proj.tpe == 0 then
				player.health -= .2
			elseif proj.tpe == 1 then
				customer.health -= .02
			end
			del(projectiles, proj)
		end
	end
end

function update_throwables()
	for item in all(throwables) do
		if item.lift == true then
			player.action_time = 2
			if player.dir == 0 then
				item.x = player.x
			else
				item.x = player.x - 8
			end
			item.y = player.y - 27
		end
		if item.air then
			if item.airdir == 1 then
				item.x += 1
			else
				item.x -= 1
			end
			item.y = item.airy + .008 * (item.x - item.airx - 10)^2
			if item.y > 56 then
				item.air = false
				item.y = 56
        if item.x > 320 then item.x = 304 end
        if item.x < 0   then item.x = 0   end
				if item.x < customer.x + 12
				and item.x > customer.x - 12 then
					customer.health -= .2
				end
			end
		end
	end
end

function hit(proj)
  local pw = (proj.w or PROJ_SIZE) / 2
  local ph = (proj.h or PROJ_SIZE) / 2

	if proj.tpe == 0 then
    -- enemy projectile → hits player
    local cx = proj.x + pw   -- leading edge centre
    if proj.dir == 1 then cx = proj.x + pw end
    return cx > player.x - 5
        and cx < player.x + 5
        and proj.y + ph/2 > player.y - 11
        and proj.y - ph/2 < player.y + 12

	elseif proj.tpe == 1 then
    -- player projectile → hits customer
    local cx = proj.x + pw
    return cx > customer.x - 8
        and cx < customer.x + 8
        and proj.y + ph/2 > customer.y - 16
        and proj.y - ph/2 < customer.y + 16
	end
end

-- punch collision
-- called from fight.lua when the player presses the punch button
-- returns true and applies damage if the punch lands
function try_punch()
  if not punch() then return false end
  customer.health -= 0.07
  -- small hitstop flash: flash enemy sprite for 2 frames
  customer.hit_flash = 2
  return true
end

-- call once per frame to tick down the flash timer
function update_hit_flash()
  if customer.hit_flash and customer.hit_flash > 0 then
    customer.hit_flash -= 1
  end
end

-- health clamping / win condition
function check_health()
  if player.health   < 0 then player.health   = 0 end
  if customer.health < 0 then customer.health = 0 end
	if player.health == 0 or customer.health == 0 then
		game_state = 3
	end
end