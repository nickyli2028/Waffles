

local CC_IDLE    = 0
local CC_PLAYING = 1
local CC_RESULT  = 2

cc = {
  state        = CC_IDLE,
  score        = 0,
  high_score   = 0,
  lives        = 3,
  pot_x        = 56,
  drops        = {},
  tick         = 0,
  speed        = 1,
  spawn_rate   = 60,
  result_timer = 0,
  msg          = "",
  msg_col      = 9,   -- initialized so draw never errors
  msg_timer    = 0,
}

local POT_Y     = 108
local POT_W     = 16
local POT_SPD   = 2.5
local DROP_SIZE = 3

function cc_save()
  dset(12, cc.high_score)
end

function cc_load()
  cc.high_score = dget(12)
end

function cc_spawn_drop()
  add(cc.drops, {
    x   = 4 + rnd(116),
    y   = -4,
    spd = cc.speed + rnd(0.8),
  })
end

function cc_show_msg(s, col)
  cc.msg     = s
  cc.msg_col = col or 9
  cc.msg_timer = 60
end

function cc_init()
  cc_load()
  cc.state      = CC_PLAYING
  cc.score      = 0
  cc.lives      = 3
  cc.pot_x      = 56
  cc.drops      = {}
  cc.tick       = 0
  cc.speed      = 1
  cc.spawn_rate = 60
  cc.msg        = ""
  cc.msg_col    = 9
  cc.msg_timer  = 0
end

function cc_update()
  if cc.state == CC_IDLE then
    cc.tick += 1
    if btnp(4) then cc_init() end
    return
  end

  if cc.state == CC_RESULT then
    cc.result_timer -= 1
    if cc.result_timer <= 0 or btnp(4) then
      cc.state = CC_IDLE
    end
    return
  end

  -- playing
  cc.tick += 1
  if cc.msg_timer > 0 then cc.msg_timer -= 1 end

  if btn(0) then cc.pot_x -= POT_SPD end
  if btn(1) then cc.pot_x += POT_SPD end
  cc.pot_x = mid(2, cc.pot_x, 127 - POT_W - 2)

  if cc.tick % cc.spawn_rate == 0 then
    cc_spawn_drop()
    if cc.score > 50 and rnd(1) < 0.3 then
      cc_spawn_drop()
    end
  end

  for d in all(cc.drops) do
    d.y += d.spd

    -- caught?
    if d.y + DROP_SIZE >= POT_Y and d.y < POT_Y + 6 then
      if d.x >= cc.pot_x - 2 and d.x <= cc.pot_x + POT_W + 2 then
        del(cc.drops, d)
        cc.score += 1
        cc_show_msg("+1", 11)

        if cc.score % 10 == 0 then
          cc.speed      = min(cc.speed + 0.3, 4)
          cc.spawn_rate = max(cc.spawn_rate - 5, 20)
          cc_show_msg("faster!", 9)
        end

        if cc.score > cc.high_score then
          cc.high_score = cc.score
          cc_save()
        end
      end
    end

    -- missed
    if d.y > 128 then
      del(cc.drops, d)
      cc.lives -= 1
      cc_show_msg("miss! -1 life", 8)
      if cc.lives <= 0 then
        cc_end()
      end
    end
  end
end

function cc_end()
  cc.state        = CC_RESULT
  cc.result_timer = 180
  if cc.score > cc.high_score then
    cc.high_score = cc.score
    cc_save()
  end
end

function cc_draw()
  cls(1)
  camera(0, 0)
  palt()         -- reset transparency so our drawing is clean
  palt(0, false) -- don't treat black as transparent

  if cc.state == CC_IDLE   then cc_draw_idle()   return end
  if cc.state == CC_RESULT then cc_draw_result()  return end
  cc_draw_game()
end

function cc_draw_idle()
  rectfill(0, 0,   127, 127, 1)
  rectfill(0, 100, 127, 127, 5)
  rectfill(0, 98,  127, 101, 4)

  print("coffee catch!", 24, 18, 9)
  print("catch the drops!", 20, 30, 7)

  local dy = cc.tick % 80
  cc_draw_drop(62, dy, 12)
  cc_draw_pot(52, 88)

  print("left/right: move pot", 10, 68, 6)
  print("hi: "..cc.high_score, 4, 4, 7)

  if (cc.tick % 60) < 30 then
    print("press x to start", 20, 110, 9)
  end
end

function cc_draw_result()
  rectfill(14, 24, 113, 103, 0)
  rect(14,  24, 113, 103, 9)
  rect(15,  25, 112, 102, 4)

  print("game over!",   38, 32, 8)
  print("caught: "..cc.score,        36, 48, 7)
  print("hi score: "..cc.high_score, 28, 58, 9)

  local grade, gcol
  if     cc.score >= 40 then grade, gcol = "grade: s  perfect!",  9
  elseif cc.score >= 25 then grade, gcol = "grade: a  great!",   11
  elseif cc.score >= 15 then grade, gcol = "grade: b  good",     12
  elseif cc.score >= 8  then grade, gcol = "grade: c  ok",        7
  else                        grade, gcol = "grade: f  spilled!", 8
  end
  print(grade, 20, 72, gcol)

  if (cc.tick % 60) < 30 then
    print("x to continue", 30, 88, 9)
  end
  cc.tick += 1
end

function cc_draw_game()
  rectfill(0, 0,   127, 127, 1)
  rectfill(0, 96,  127, 127, 5)
  rectfill(0, 94,  127, 97,  4)

  for d in all(cc.drops) do
    cc_draw_drop(d.x, d.y, 12)
  end

  cc_draw_pot(cc.pot_x, POT_Y)

  -- hud
  rectfill(0, 0, 127, 9, 0)
  print("caught:"..cc.score,    2,  2, 7)
  print("hi:"..cc.high_score,  60,  2, 6)

  -- lives as cups
  for i=1, cc.lives do
    local lx = 127 - i*10
    rectfill(lx,   2, lx+6, 7, 12)
    rectfill(lx+1, 7, lx+5, 8, 12)
    pset(lx+3, 1, 7)
  end

  -- speed bar
  local spd_pct = (cc.speed - 1) / 3
  rectfill(2, 120, 30,                    122, 0)
  rectfill(2, 120, 2+flr(spd_pct*28),    122, 9)
  print("spd", 2, 123, 6)

  if cc.msg_timer > 0 then
    print(cc.msg, 40, 14, cc.msg_col)
  end
end

function cc_draw_drop(x, y, col)
  circfill(x, y+1, DROP_SIZE-1, col)
  pset(x, y-1, col)
  pset(x, y-2, col)
end

function cc_draw_pot(x, y)
  rectfill(x,        y,    x+POT_W,   y+10, 5)
  rectfill(x+1,      y+1,  x+POT_W-1, y+9,  4)
  rectfill(x-1,      y-1,  x+POT_W+1, y+1,  6)
  rect(x+POT_W+1,    y+2,  x+POT_W+4, y+7,  4)
  rectfill(x-4,      y+2,  x,          y+5,  5)
  pset(x-5, y+3, 5)
  pset(x-5, y+4, 5)
  rectfill(x+2, y+3, x+POT_W-2, y+8, 0)
  pset(x+3, y+2, 7)
end

-- =============================================
-- entry points:
--   cc_init()    -- start the mini game
--   cc_update()  -- call in _update()
--   cc_draw()    -- call in _draw()
--   cc.state == CC_IDLE (0) = finished/not started
-- =============================================