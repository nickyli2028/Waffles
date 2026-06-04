-- scripts/driving.lua

local car_spr = 7 
local car_sw = 3
local car_sh = 2
local car_speed = 1.5
cars = {}

function make_car(x, y, spd, x_end, turn_x, color)
  return {
    x=x, y=y,
    spd=spd,
    x_start=x,
    y_start=y,
    x_end=x_end or 256,
    turn_x=turn_x,
    phase="right",
    color=color or 8, 
  }
end

function spawn_car()
  local colors = {1,2,3,4,5,6,7,8,9,10,12,13,14,15}
  local c = colors[flr(rnd(#colors))+1]
  local spd = 0.2 + rnd(3)
  add(cars, make_car(newcord("x", 1), newcord("y", 58.6), spd, newcord("y", 65), newcord("x", 29), c))
end

function update_cars()
  for c in all(cars) do
    if c.phase == "right" then
      c.x += c.spd
      if c.turn_x and c.x >= c.turn_x then
        c.phase = "down"
      end
    elseif c.phase == "down" then
      c.y += c.spd
      if c.y > c.x_end then
        del(cars, c)
        spawn_car()
      end
    end
  end
end

function draw_cars()
  for c in all(cars) do
    palt(11, true)
    palt(0, false)
    pal(3, c.color)
    spr(car_spr, c.x, c.y, car_sw, car_sh)
    pal()
  end
end

function draw_road()
  for tx = 1, 28, 4 do
    sspr(40, 0, 8, 16, newcord("x", tx), newcord("y", 59), 32, 32)
  end
  sspr(48, 0, 8, 8, newcord("x", 28), newcord("y", 59), 32, 32)
  rectfill(newcord("x", 1), newcord("y", 59), newcord("x", 3), newcord("y", 62.9), 4)
  rect(newcord("x", 1),     newcord("y", 59), newcord("x", 3), newcord("y", 62.9), 5)
end