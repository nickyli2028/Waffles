function update_talk()
	if dialogue == 0 then
		if btnp(❎) then
			dialogue = 1
		end
	elseif dialogue == 1 then
		if btnp(⬆️) or btnp(⬇️) then
			option += 1
			option %= 2
		end
		if btnp(❎) then
			if option == 0 then
				game_state = 1
				starting_fight = true
				music(27)
			else
				game_state = 2
			end
		end
	end
end

function draw_talk()
	spr(64, player.x - 8, player.y - 12, 2, 3)
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
	spr(128, customer.x - 16, customer.y - 16, 4, 4)
	spr(139 + customer.tpe, customer.x - 4, customer.y - 16, 1, 1)
	pal()
	palt(11, t)
	palt(0, f)
	rectfill(80, 80, 208, 128, 0)
	rect(80, 80, 207, 127, 10)
	if dialogue == 0 then
		print("customer: i asked for a", 85, 85, 7)
		print("cheeseburger with no cheese")
		print("continue with ❎", 140, 120) 
	else
		print("fight", 95, 85, 7)
		print("okay", 95, 93)
		if option == 0 then
			print("◆", 85, 85, 7)
		else
			print("◆", 85, 93, 7)
		end
	end
end