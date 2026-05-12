-- loader.lua
-- ex; load_sprites(sheet #, file name)
function load_sprites(sheet, name)
    if sheet == 2 then
        reload(0x1000, 0x1000, 0x0800, name..".p8")
    elseif sheet == 3 then
        reload(0x1800, 0x1800, 0x0800, name..".p8")
    else
        print("error: only sheets 2 or 3 allowed, or incorrect file name")
    end
end

function load_music(name)
    reload(0x3100, 0x3100, 0x1200, name..".p8")
end

function load_sfx(name)
    reload(0x3200, 0x3200, 0x1100, name..".p8")
end