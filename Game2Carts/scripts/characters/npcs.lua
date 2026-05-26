npcs = {}

function make_npc(x, y, spr_id, path, name, shirt_color, hair_color)
  return {
    x = x, y = y,
    spr_id = spr_id,
    name = name,
    path = path,
    path_i = 1,
    steps_left = #path > 0 and path[1].steps or 0,
    dir = "down",
    shirt_color = shirt_color or 10,
    hair_color = hair_color or 4,
  }
end

function spawn_npc(x, y, spr_id, path, name, shirt_color, hair_color)
  add(npcs, make_npc(x, y, spr_id, path, name, shirt_color, hair_color))
end

function update_npcs()
  for n in all(npcs) do
    if #n.path > 0 then
      local wp = n.path[n.path_i]
      n.x += wp.dx
      n.y += wp.dy
      n.steps_left -= 1
      if wp.dx < 0 then n.dir = "left"
      elseif wp.dx > 0 then n.dir = "right"
      elseif wp.dy < 0 then n.dir = "up"
      elseif wp.dy > 0 then n.dir = "down"
      end
      if n.steps_left <= 0 then
        n.path_i += 1
        if n.path_i > #n.path then n.path_i = 1 end
        n.steps_left = n.path[n.path_i].steps
      end
    end
  end
end

function draw_npcs()
  for n in all(npcs) do
    pal(10, n.shirt_color)
    pal(4, n.hair_color)
    spr(n.spr_id, n.x, n.y, 2, 2, n.dir == "left")
    pal(10,10) 
    pal(4, 4)
  end
end

function get_nearby_npc()
  for n in all(npcs) do
    local dx = abs(n.x - player.x)
    local dy = abs(n.y - player.y)
    if dx < 24 and dy < 24 then return n end
  end
end