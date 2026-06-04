-- tutorial.lua

local _pages = {
    {
        title="top_down",
        lines={
            "arrows - move",
            "x (quick press) - skip dialog",
            "x (hold down) - check points"
            "z - interact",
        },
        sprite=1
    },
    {
        title="fighting",
        lines={
            "left & right - left and right movement",
            "up - jump",
            "z - throw table",
            "x - projectile",
        },
    },
    {
        title="fries",
        lines={
            "",
        },
    },
    {
        title="coffee",
        lines={
            "left and right to move the catcher!",
        },
    },
    {
        title="ttt",
        lines={
            "score 3 in a row to win!!",
        },
    },
}

local _page = 0
local _on_done = nil
tutorial_active = false

function start_tutorial(on_done)
    _page = 0
    _on_done = on_done
    tutorial_active = true
end

function tutorial_update()
    if not tutorial_active then return end
    if btnp(4) or btnp(5) then
        _page += 1
        if _page >= #_pages then
            tutorial_active = false
            if _on_done then _on_done() end
        end
    end
end

function tutorial_draw()
    if not tutorial_active then return end
    local p = _pages[_page + 1]

    rectfill(8, 8, 120, 120, 0)
    rect(8, 8, 120, 120, 7)
    rectfill(8, 8, 120, 18, 8)
    print(p.title, 12, 11, 7)

    for i, line in ipairs(p.lines) do
        print(line, 14, 18 + i*9, 6)
    end

    local indicator = _page+1 .."/".. #_pages
    print(indicator, 10, 112, 5)
    if _page + 1 < #_pages then
        print("x - next", 72, 112, 6)
    else
        print("x - done", 72, 112, 10)
    end
end