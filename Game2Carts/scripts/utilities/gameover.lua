function update_gameover()
end

function draw_gameover()
	rectfill(cam_coords.x, 80, cam_coords.x + 128, 128, 0)
	rect(cam_coords.x, 80, cam_coords.x + 127, 127, 10)
	if player.health == 0 then
		print("you lost!", cam_coords.x + 5, 85, 7)
	elseif customer.health == 0 then
		spr(70, player.x - 8, player.y - 12, 2, 3, player.dir == 0)
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
		spr(136, customer.x - 16, customer.y - 16, 4, 4, customer.dir == 1)
		spr(139 + customer.tpe, customer.x - 4, customer.y - 16, 1, 1)
		pal()
		palt(11, t)
		palt(0, f)
		print("you won!", cam_coords.x + 5, 85, 7)
	end
	print("corporate will hear about", cam_coords.x + 5, 95, 7)
	print("this")
end