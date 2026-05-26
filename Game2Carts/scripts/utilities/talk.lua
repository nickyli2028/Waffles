-- Character Dialog bank
dialogues = {
    new_day = {
        voice = 0,
        lines = {
            "can't wait for the day to end."
        }
    },
    customer = {
        voice = 0,
        lines = {
            "customer: i asked for a\ncheeseburger with no cheese.",
            "customer: are you even\nlistening to me?"
        }
    },
	bench_npc = {
        voice = 0,
        lines = {
            "termie: i prefer pancakes."
        }
    },
	trenchcoat = {
        voice = 0,
        lines = {
            "★✽⬇️🅾️☉✽♪: sup."
        }
    },
}

player_lines_mm = {
    "i really need this job.",
    "my feet are killing me.",
    "just smile and nod.",
    "i should've called in sick.",
    "only 4 more hours to go.",
	"i heard the people who made \nthis game are pretty chill.",
    "fuck my chud life.",
	"is mcdonny hiring?",
	"i want to check out mccoy's\nmansion.",
	"did i mention mccoy's mansion.",
	"the legend 27 lowkey buns.",
	"the narwal bacons at midnight.",
	"shoutout my buddy steve.",
	"the quit button looks really\ncool..."
}

function say_random()
    local line = player_lines_mm[flr(rnd(#player_lines_mm))+1]
    tb_init_mm(0, {line})
end

function start_dialogue(character)
    local d = dialogues[character]
    tb_init(d.voice, d.lines)
end

function init_talk()
    dialogue = 0
    option = 0
    reading = false
    start_dialogue("customer")
    reading = true
end

function update_talk()
    if dialogue == 0 then
        tb_update()
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
    if dialogue == 0 then
        tb_draw()
    elseif dialogue == 1 then
        rectfill(80, 80, 208, 128, 0)
        rect(80, 80, 207, 127, 10)
        print("fight", 95, 85, 7)
        print("okay", 95, 93, 7)
        if option == 0 then
            print("◆", 85, 85, 7)
        else
            print("◆", 85, 93, 7)
        end
    end
end