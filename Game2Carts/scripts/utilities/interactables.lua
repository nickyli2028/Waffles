reading = false
  --mini game food stuff
  -- 2; coffee catch
  -- 12; soda fountain
  -- 96-97; fries
  -- 101; egg bacon tic tac toe
tile_types = {
  [2]   = "minigame_cc",
  [96]  = "minigame_fries",
  [117] = "minigame_shapes",
  [101] = "minigame_ttt",
}

-- cartdata slots (all carts share "fightbufferv1")
-- slot 0 = reserved by gamedata
-- slot 1 = minigame handoff: points earned this session
-- slot 2 = return cart flag (1 = came back from minigame)
local SLOT_POINTS  = 1
local SLOT_RETURN  = 2
local SLOT_PX      = 3
local SLOT_PY      = 4

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
  if dget(SLOT_RETURN) == 1 then
    local pts = dget(SLOT_POINTS)
    if pts > 0 then add_minigame_points(pts) end
    player.x = dget(SLOT_PX)
    player.y = dget(SLOT_PY)
    dset(SLOT_POINTS, 0)
    dset(SLOT_RETURN, 0)
    dset(SLOT_PX, 0)
    dset(SLOT_PY, 0)
  end
end

function interact(tile)
  if not tile then tile = get_nearby_tile() end
  local type_ = tile_types[tile]
  if not type_ then return end

  if minigame_carts[type_] then
    launch_minigame(minigame_carts[type_])
    return
  end

  if type_ == "fight" then
    trigger_enemy_fight()
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

function launch_minigame(cart)
  -- clear handoff so stale points don't carry over
  dset(SLOT_PX, player.x)
  dset(SLOT_PY, player.y)
  dset(SLOT_POINTS, 0)
  dset(SLOT_RETURN, 0)
  load(cart)
end

-- kept as stubs so any lingering references don't error
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
