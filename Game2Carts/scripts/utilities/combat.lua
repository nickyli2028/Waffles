function update_projectiles()
	for proj in all(projectiles) do
		if proj.dir == 0 then
			proj.x -= 1.5
		else
			proj.x += 1.5
		end
		if hit(proj) then
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
				if item.x < customer.x + 12
				and item.x > customer.x - 12 then
					customer.health -= .2
				end
			end
		end
	end
end

function hit(proj)
	if proj.tpe == 0 then
		if proj.dir == 0 then
			return proj.x > player.x - 5
						and proj.x < player.x + 5
						and proj.y > player.y - 11
						and proj.y < player.y + 12
		else
			return proj.x + 8 > player.x - 5
						and proj.x + 8 < player.x + 5
						and proj.y > player.y - 11
						and proj.y < player.y + 12
		end
	elseif proj.tpe == 1 then
		if proj.dir == 0 then
			return proj.x > customer.x - 8
						and proj.x < customer.x + 8
						and proj.y > customer.y - 16
						and proj.y < customer.y + 16
		else
			return proj.x + 8 > customer.x - 8
						and proj.x + 8 < customer.x + 8
						and proj.y > customer.y - 16
						and proj.y < customer.y + 16
		end
	end
end

function check_health()
	if player.health < 0 then
		player.health = 0
	elseif customer.health < 0 then
		customer.health = 0
	end
	if player.health == 0 or customer.health == 0 then
		game_state = 2
	end
end