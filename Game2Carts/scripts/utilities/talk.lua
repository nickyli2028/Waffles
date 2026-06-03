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
            "customer: are you even\nlistening to me?",
            "customer: let me talk\nto your manager."
        }
    },
	bench_npc = {
        voice = 0,
        lines = {
            "termie: i prefer pancakes."
        }
    },
    gregg_phillips = {
        voice = 0,
        lines = {
            "gregg phillips:\nteleporting is no fun",
            "(dev note: gregg\nphillips is the director\nof fema"
            "he claimed to have\nbeen teleported to a\nwaffle house by god"
        }
    },
	trenchcoat = {
    voice = 0,
    lines = {
        "★⬇🅾✽♪: sup.",
        "want to hear something fun?",
    },
    on_done = function()
        start_choice({"yes", "no"}, function(pick)
            if pick == 1 then
                start_dialogue("trenchcoat_yes")
            else
                start_dialogue("trenchcoat_no")
            end
        end)
    end
    },
    trenchcoat_yes = {
        voice = 0,
        lines = {"★⬇🅾✽♪: i knew\nyou would."},
    },
    trenchcoat_no = {
        voice = 0,
        lines = {"★⬇🅾✽♪: lame."},
    },
    diner = {
        voice = 0,
        lines = {
            "WHERES MY FOOD!!!"
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

choice_active = false
choice_options = {}
choice_selected = 0
on_choice = nil

function start_choice(options, callback)
    choice_active = true
    choice_options = options
    choice_selected = 0
    on_choice = callback
end

function update_choice()
    if not choice_active then return end
    if btnp(2) then choice_selected = max(0, choice_selected - 1) end
    if btnp(3) then choice_selected = min(#choice_options - 1, choice_selected + 1) end
    if btnp(4) then
        choice_active = false
        if on_choice then on_choice(choice_selected + 1) end
    end
end

function draw_choice()
    if not choice_active then return end
    local cam_offset_x = cam_x or 0
    local cam_offset_y = cam_y or 0
    rectfill(cam_offset_x + 0, cam_offset_y + 100, cam_offset_x + 127, cam_offset_y + 127, 0)
    rect(cam_offset_x + 0, cam_offset_y + 100, cam_offset_x + 127, cam_offset_y + 127, 10)
    for i, opt in ipairs(choice_options) do
        local y = cam_offset_y + 102 + (i-1) * 9
        print(opt, cam_offset_x + 10, y, 7)
        if choice_selected == i - 1 then
            print(">", cam_offset_x + 3, y, 9)
        end
    end
end

function say_random()
    local line = player_lines_mm[flr(rnd(#player_lines_mm))+1]
    tb_init_mm(0, {line})
end

function start_dialogue(character)
    local d = dialogues[character]
    on_dialogue_done = d.on_done
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