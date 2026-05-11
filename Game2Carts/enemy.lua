function cust_move()
	--customer backs away if player too close
	if customer.x - player.x < 40 and customer.dir == 0 then
		customer.x += .2
	elseif customer.x - player.x > -40 and customer.dir == 1 then
		customer.x -= .2
	end
	
	if customer.x > 200 then
		customer.x = 200
	elseif customer.x < 50 then
		customer.x = 50
	end
	
	--customer always faces player
	if (customer.x - player.x) > 0 then
		customer.dir = 0
	elseif (customer.x - player.x) < 0 then
		customer.dir = 1
	end
	
	if ticks % 30 == 0 and rnd(100) < 50 then
		local proj = {
			dir = customer.dir,
			x = customer.x - 16,
			y = customer.y - 3,
			tpe = 0
			}
		if proj.dir == 1 then
			proj.x = customer.x + 8
		end
		add(projectiles, proj)
	end
end