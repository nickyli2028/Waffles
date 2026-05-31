function tb_init(voice, string)
    reading = true
    tb = {
        str = string,
        voice = voice,
        i = 1,
        cur = 0,
        char = 0,
        x = 0,      -- screen left
        y = 100,    -- screen bottom
        w = 127,
        h = 27,
        col1 = 0,
        col2 = 10,
        col3 = 7,
    }
end
-- generates the typewriter effect and dialog skips
function tb_update()
    if tb.char < #tb.str[tb.i] then
        tb.cur += 0.5
        if tb.cur > 0.9 then
            tb.char += 1
            tb.cur = 0
            if (ord(tb.str[tb.i], tb.char) != 32) sfx(tb.voice)
        end
        if (btnp(5)) tb.char = #tb.str[tb.i]
    elseif btnp(5) then
        if #tb.str > tb.i then
            tb.i += 1
            tb.cur = 0
            tb.char = 0
        else
            reading = false
            if on_dialogue_done then on_dialogue_done() end
        end
    end
end
-- draws the actual text box
function tb_draw()
    if reading then
        local cam_offset_x = cam_x or 0
        local cam_offset_y = cam_y or 0
        rectfill(cam_offset_x + tb.x, cam_offset_y + tb.y, cam_offset_x + tb.x + tb.w, cam_offset_y + tb.y + tb.h, tb.col1)
        rect(cam_offset_x + tb.x, cam_offset_y + tb.y, cam_offset_x + tb.x + tb.w, cam_offset_y + tb.y + tb.h, tb.col2)
        print(sub(tb.str[tb.i], 1, tb.char), cam_offset_x + tb.x + 2, cam_offset_y + tb.y + 2, tb.col3)
    end
end

--standalone text box for the main menu
function tb_init_mm(voice, string)
    reading = true
    tb = {
        str = string,
        voice = voice,
        i = 1,
        cur = 0,
        char = 0,
        x = 2,
        y = 26,
        w = 121,
        h = 18,
        col1 = 0,
        col2 = 14,
        col3 = 7,
    }
end
function tb_update_mm()
    if tb.char < #tb.str[tb.i] then
        tb.cur += 0.5
        if tb.cur > 0.9 then
            tb.char += 1
            tb.cur = 0
        end
    else
        -- auto close after 120 frames (2 seconds) when done typing
        tb.cur += 1
        if tb.cur > 120 then
            reading = false
        end
    end
end