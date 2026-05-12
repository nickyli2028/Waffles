tile_types = {
  [20] = "minigame_cc",
}

current_message = ""
message_timer   = 0

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
  local type_ = tile_types[tile]
  if not type_ then return end

  if type_ == "minigame_cc" then
    cc_init()
    mode = "minigame_cc"
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
    if cc.state == 0 then mode = "overworld" end
  end
end

function minigames_draw()
  if mode == "minigame_cc" then
    cc_draw()
  end
end

function in_minigame()
  return mode == "minigame_cc"
end

function show_message(msg)
  current_message = msg
  message_timer   = 180
end

function draw_message()
  if message_timer > 0 then
    rectfill(0, 100, 127, 127, 0)
    print(current_message, 4, 108, 7)
    message_timer -= 1
  end
end

function draw_interact_prompt()
  local nearby = get_nearby_tile()
  if is_interactable(nearby) then
    rectfill(24, 118, 103, 127, 0)
    print("press z to interact", 26, 121, 7)
  end
end