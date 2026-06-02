reading = false
  --mini game food stuff
  -- 2; coffee catch
  -- 12; soda fountain
  -- 96-97; fries
  -- 101; egg bacon tic tac toe
tile_types = {
  [2]   = "minigame_cc",
  [96]  = "minigame_fries",
  [101] = "minigame_ttt",
  
  [117] = "keypad_door",
  [56] = "door",
}

-- cartdata slots (all carts share "fightbufferv1")
-- slot 0 = reserved by gamedata
-- slot 1 = minigame handoff: points earned this session
-- slot 2 = return cart flag (1 = came back from minigame)
local SLOT_RETURN  = 2
local SLOT_PX      = 3
local SLOT_PY      = 6

local minigame_carts = {
  minigame_cc     = "coffee_catch.p8",
  minigame_fries  = "fries.p8",
  minigame_shapes = "shape_tracer.p8",
  minigame_ttt = "ttt.p8",
}

function is_interactable(tile)
  return tile ~= nil and tile_types[tile] ~= nil
end

function get_nearby_tile()
    local px = flr((player.x + 8) / 8)
    local py = flr((player.y + 8) / 8)
    local neighbors = {
        mget(px + 1, py),
        mget(px - 1, py),
        mget(px,     py + 1),
        mget(px,     py - 1),
    }
    for _, tile in ipairs(neighbors) do
        if is_interactable(tile) then return tile end
    end
    if objects then
        for _, obj in pairs(objects) do
            local ox = obj.x * 8
            local oy = obj.y * 8
            if abs(player.x - ox) < 12 and abs(player.y - oy) < 12 then
                return obj.id
            end
        end
    end
    return nil
end

function check_minigame_return()
    --[[cartdata("fightbufferv1")
    if dget(SLOT_RETURN) ~= 1 then return end

    local coffee_pts = dget(1)
    local fries_pts  = dget(4)
    local ttt_pts    = dget(5)
    local px = dget(SLOT_PX)
    local py = dget(SLOT_PY)

    -- clear slots immediately
    dset(1, 0)
    dset(2, 0)
    dset(4, 0)
    dset(5, 0)
    dset(SLOT_PX, 0)
    dset(SLOT_PY, 0)

    -- switch to gamedata and ADD to existing values, not overwrite
    cartdata("gamedata_v1")
    if coffee_pts >= 1 then add_food("coffee",     coffee_pts) end
    if fries_pts  >= 1 then add_food("fries",      fries_pts)  end
    if ttt_pts    >= 1 then add_food("bacon_eggs", ttt_pts)    end

    player.x = px
    player.y = py]]
end


function interact(tile)
    if not tile then tile = get_nearby_tile() end
    local type_ = tile_types[tile]
    if not type_ then return end

    if type_ == "door" then
        trigger_door(tile)
        return
    end

    if type_ == "keypad_door" then
        trigger_keypad_door(tile)
        return
    end

    if minigame_carts[type_] then
        if current_order == nil then
            show_message("no order yet. talk to a customer first.")
            return
        end
        if not allowed_minigames[type_] then
            show_message("you don't need that for this order.")
            return
        end
        launch_minigame(minigame_carts[type_])
        return
    end

    if type_ == "fight" then
        trigger_enemy_fight()
        return
    end
end

function launch_minigame(cart)
    cartdata("fightbufferv1")
    dset(SLOT_PX, player.x)
    dset(SLOT_PY, player.y)
    dset(1, 0)  -- clear coffee slot
    dset(4, 0)  -- clear fries slot
    dset(5, 0)  -- clear ttt slot
    dset(SLOT_RETURN, 0)
    load(cart)
end

function trigger_door(tile)
    for _, door in ipairs(doors) do
        local dx = abs(player.x - door.tile_x * 8)
        local dy = abs(player.y - door.tile_y * 8)
        if dx < 16 and dy < 16 then
            if door.condition and not door.condition() then
                show_message(door.locked_msg or "it won't open.")
                return
            end
            transition_to_room(door)
            return
        end
    end
end

function trigger_keypad_door(tile)
    -- find the matching door definition by proximity
    local kd = get_nearby_keypad_door()
    if not kd then return end

    -- already unlocked, just open it
    if is_door_unlocked(kd.save_slot) then
        transition_to_room(kd)
        return
    end

    -- open keyboard and check password on confirm
    open_keyboard(function(result)
        if result == kd.password then
            unlock_door(kd.save_slot)
            show_message("access granted.")
            -- transition after the message is dismissed
            on_dialogue_done = function()
                transition_to_room(kd)
            end
        else
            show_message("wrong code.")
        end
    end)
end

function get_nearby_keypad_door()
    for _, door in ipairs(doors) do
        if door.password then
            local dx = abs(player.x - door.tile_x * 8)
            local dy = abs(player.y - door.tile_y * 8)
            if dx < 24 and dy < 24 then return door end
        end
    end
end

function transition_to_room(door)
    fade_to_black(function()
        current_room_name = door.to
        map_coords = {x=rooms[door.to].x, y=rooms[door.to].y}
        player.x = door.arrive_x * 8
        player.y = door.arrive_y * 8
    end)
end

function in_minigame()  return false end
function minigames_update() end
function minigames_draw()   end

function draw_combat_interact_prompt()
    if throwables then
        for _, item in ipairs(throwables) do
            if not item.lift and not item.air then
                local dx = abs(player.x - item.x)
                local dy = abs(player.y - item.y)
                if dx < 16 and dy < 16 then
                    rectfill(cam_x + 24, cam_y + 118, cam_x + 103, cam_y + 127, 0)
                    print("press z to pick up", cam_x + 26, cam_y + 121, 7)
                    return
                end
            end
        end
    end
end

function show_message(msg)
    tb_init(0, type(msg) == "table" and msg or {msg})
end

function draw_message()
    tb_draw()
end

function draw_interact_prompt()
    if in_minigame() then return end
    local nearby_npc = get_nearby_npc()
    if nearby_npc then
        rectfill(cam_x + 24, cam_y + 118, cam_x + 103, cam_y + 127, 0)
        print("press z to talk", cam_x + 26, cam_y + 121, 7)
        return
    end
    local nearby = get_nearby_tile()
    if is_interactable(nearby) then
        rectfill(cam_x + 24, cam_y + 118, cam_x + 103, cam_y + 127, 0)
        print("press z to interact", cam_x + 26, cam_y + 121, 7)
    end
end

function check_interact_input()
    if btnp(4) then
        local nearby = get_nearby_tile()
        if is_interactable(nearby) then interact(nearby) end
    end
end

function check_street_trigger(x, y)
    local px = flr(x / 8)
    local py = flr(y / 8)
    local tile = mget(px, py)
    if fget(tile, 1) then return true end
    return false
end