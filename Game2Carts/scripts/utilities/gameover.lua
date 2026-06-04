function update_gameover()
end

function draw_gameover()
	rectfill(cam_coords.x, 80, cam_coords.x + 128, 128, 0)
	rect(cam_coords.x, 80, cam_coords.x + 127, 127, 10)
	if player.health == 0 then
		print("you lost!", cam_coords.x + 5, 85, 7)
	elseif customer.health == 0 then
		player.spr = 70
		customer.spr = 136
		drawPC()
		print("you won!", cam_coords.x + 5, 85, 7)
	end
	print("corporate will hear about", cam_coords.x + 5, 95, 7)
	print("this")
end