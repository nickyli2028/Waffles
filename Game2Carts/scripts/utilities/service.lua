function update_service()
	service_move()
	if customer.x > 154 then
		customer.x -= .5
	end

	if customer.x - player.x < 50 then
		if dialogue == #player.inv + 1 then
			if btnp(⬆️) or btnp(⬇️) then
				option += 1
				option %= 2
			end
			if btnp(❎) then
				if option == 1 then
					game_state = 2
					starting_fight = true
					music(27)
				else
					dialogue = -1
				end
			end
		elseif btnp(❎) then
			dialogue += 1
			if dialogue > 0 then
				while dialogue <= #customer.order and customer.order[dialogue][2] == 0 do
					dialogue += 1
				end
			end
			if dialogue > #player.inv + 1 then
				dialogue = -1
			end
		elseif dialogue == -1 then
			service_move()
		end
	else
		service_move()
	end

end

function service_move()
	local dx = 0
	if btn(➡️) then
		dx += .5
	end
	if btn(⬅️) then
		dx -= .5
	end
	if dx < 0 then
		player.dir = 0
	elseif dx > 0 then
		player.dir = 1
	end

	player.x += dx

	if player.x < 12 then
		player.x = 12
	elseif player.x > 116 then
		player.x = 116
	end

	if player.x < 100 then
		if cam_coords.x > 0 then
			cam_coords.x -= 2
		end
	else
		if cam_coords.x < 80 then
			cam_coords.x += 2
		end
	end
end

function draw_service()
	drawPC()
	rectfill(cam_coords.x, 104, cam_coords.x + 128, 128, 0)
	if dialogue == -1 then
		spr(194, cam_coords.x, cam_coords.y + 104, 2, 2)
		spr(224, cam_coords.x + 16, cam_coords.y + 104, 2, 2)
		spr(192, cam_coords.x + 32, cam_coords.y + 104, 2, 2)
		pal(4, 15)
		spr(192, cam_coords.x + 48, cam_coords.y + 104, 2, 2)
		pal()
		palt(11, t)
		spr(198, cam_coords.x + 64, cam_coords.y + 104, 2, 2)
		spr(228, cam_coords.x + 80, cam_coords.y + 104, 2, 2)
		spr(226, cam_coords.x + 96, cam_coords.y + 104, 2, 2)
		for i = 1, #player.inv do
			print(player.inv[i][2], cam_coords.x + (i * 16) - 5, cam_coords.y + 114, 5)
		end

		if customer.x - player.x < 50 then
			print("talk with ❎", 155, 120, 7)
		end
	else
		rectfill(80, 80, 208, 128, 0)
		rect(80, 80, 207, 127, 10)
		if dialogue == 0 then
			print("customer: i want... uhhh...", 85, 85, 7)
			print("continue with ❎", 140, 120)
		else
			if dialogue < #customer.order + 1 then
				if customer.order[dialogue][2] > 1 then
					print("customer: " .. customer.order[dialogue][2] .. " " .. customer.order[dialogue][1] .. "s", 85, 85, 7)
				else
					print("customer: " .. customer.order[dialogue][2] .. " " .. customer.order[dialogue][1], 85, 85, 7)
				end
				print("continue with ❎", 140, 120)
			else
				print("coming right up", 95, 85, 7)
				print("no", 95, 93)
				if option == 0 then
					print("◆", 85, 85, 7)
				else
					print("◆", 85, 93, 7)
				end
			end
		end
	end
end