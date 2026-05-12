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
				game_state = 2
				starting_fight = true
				music(27)
			else
				game_state = 3
			end
		end
	end
end

function draw_talk()
	drawPC()
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