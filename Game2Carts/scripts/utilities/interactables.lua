reading = false

tile_types = {
  [96] = "fight",
  [97] = "minigame_cc",
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
    if is_interactable(tile) then
      return tile
    end
  end
  if objects then
    for _, obj in pairs(objects) do
      local ox = obj.x * 8 - cam_x
      local oy = obj.y * 8 - cam_y
      if abs(player.x - ox) < 12 and abs(player.y - oy) < 12 then
        return obj.id
      end
    end
  end
  return nil
end

function interact(tile)
  if not tile then tile = get_nearby_tile() end
  local type_ = tile_types[tile]
  if not type_ then return end

  if type_ == "minigame_cc" then
    prev_mode = mode
    cc_init()
    mode = "minigame_cc"
  elseif type_ == "task_order" then
    prev_mode = mode
    mode = "task_order"
  elseif type_ == "fight" then
    start_fight()
  end

  if objects then
    for i, obj in pairs(objects) do
      if type_ == obj.name then
        deli(objects, i)
        break
      end
    end
  end
end

function minigames_update()
  if mode == "minigame_cc" then
    cc_update()
    if cc.state == 0 then
      mode = prev_mode or "overworld"
      prev_mode = nil
    end
  elseif mode == "task_order" then
    -- todo
  end
end

function minigames_draw()
  if mode == "minigame_cc" then
    cc_draw()
  elseif mode == "task_order" then
    -- todo
  end
end

function in_minigame()
  return mode == "minigame_cc" or mode == "task_order"
end

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

-- textbox system
function tb_init(voice, string)
  reading = true
  tb = {
    str = string,
    voice = voice,
    i = 1,
    cur = 0,
    char = 0,
    x = 0,
    y = 106,
    w = 127,
    h = 21,
    col1 = 0,
    col2 = 7,
    col3 = 7,
  }
end

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
    end
  end
end

function tb_draw()
  if reading then
    rectfill(cam_x + tb.x, cam_y + tb.y, cam_x + tb.x + tb.w, cam_y + tb.y + tb.h, tb.col1)
    rect(cam_x + tb.x, cam_y + tb.y, cam_x + tb.x + tb.w, cam_y + tb.y + tb.h, tb.col2)
    print(sub(tb.str[tb.i], 1, tb.char), cam_x + tb.x + 2, cam_y + tb.y + 2, tb.col3)
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
    if is_interactable(nearby) then
      interact(nearby)
    end
  end
end