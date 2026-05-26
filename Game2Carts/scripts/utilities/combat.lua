MAX_PROJECTILES = 6
PROJ_SIZE = 12

diff_settings = {
  easy   = { cooldown = 180, rush_spd = 1.2, proj_spd = 1.0, telegraph = 40 },
  medium = { cooldown = 120, rush_spd = 2.0, proj_spd = 1.5, telegraph = 25 },
  hard   = { cooldown =  70, rush_spd = 3.2, proj_spd = 2.2, telegraph = 12 },
}

enemy_ai = {
  abilities    = {},   -- list assigned from enemy_registry
  difficulty   = "medium",
  next_idx     = 1,    -- which ability fires next
  cooldown     = 0,    -- frames until next ability triggers
  telegraph    = 0,    -- frames of white flash warning remaining
  pending      = nil,  -- ability queued after telegraph finishes
  rushing      = false,
  rush_spd     = 0,
  rush_startx  = 0,
}

-- call this from _init (or wherever you set up the fight) to
-- configure the enemy. e is the entry from the enemies table.
function setup_enemy_ai(e)
  enemy_ai.abilities  = e.abilities  or {}
  enemy_ai.difficulty = e.difficulty or "medium"
  enemy_ai.next_idx   = 1
  local ds = diff_settings[enemy_ai.difficulty] or diff_settings.medium
  enemy_ai.cooldown   = ds.cooldown
  enemy_ai.telegraph  = 0
  enemy_ai.pending    = nil
  enemy_ai.rushing    = false
end

function update_enemy_ai()
  local ds = diff_settings[enemy_ai.difficulty] or diff_settings.medium

  --flash white, then fire
  if enemy_ai.telegraph > 0 then
    enemy_ai.telegraph -= 1
    customer.telegraph_flash = (enemy_ai.telegraph % 8 < 4)
    if enemy_ai.telegraph == 0 then
      customer.telegraph_flash = false
      execute_ability(enemy_ai.pending, ds)
      enemy_ai.pending  = nil
      enemy_ai.cooldown = ds.cooldown
    end
    return
  end

  -- ── rush movement
  if enemy_ai.rushing then
    customer.x -= enemy_ai.rush_spd
    if customer.x <= player.x + 20 then
      -- deal damage on contact
      player.health -= 0.15
      enemy_ai.rushing = false
      -- bounce back to start position over time (instant snap for now)
      customer.x = enemy_ai.rush_startx
    end
    return
  end

  if enemy_ai.cooldown > 0 then
    enemy_ai.cooldown -= 1
    return
  end

  if #enemy_ai.abilities == 0 then return end
  local ability = enemy_ai.abilities[enemy_ai.next_idx]
  enemy_ai.next_idx = (enemy_ai.next_idx % #enemy_ai.abilities) + 1
  enemy_ai.pending   = ability
  enemy_ai.telegraph = ds.telegraph
end

function execute_ability(ability, ds)
  if ability == "rush" then
    ability_rush(ds)
  elseif ability == "shoot" then
    ability_shoot(ds)
  elseif ability == "throw" then
    ability_throw()
  end
end

--charge at the player
function ability_rush(ds)
  enemy_ai.rushing    = true
  enemy_ai.rush_spd   = ds.rush_spd
  enemy_ai.rush_startx = customer.x
  customer.spr = 132
end

--fire a projectile toward the player
function ability_shoot(ds)
  local count = 0
  for _ in all(projectiles) do count += 1 end
  if count >= MAX_PROJECTILES then return end

  customer.spr = 132 

  local proj = {
    dir  = 0,
    x    = customer.x - 16,
    y    = customer.y - 8,
    tpe  = 0,
    spd  = ds.proj_spd,
    w    = PROJ_SIZE,
    h    = PROJ_SIZE,
  }
  add(projectiles, proj)
end

--hurl the nearest throwable item at the player
function ability_throw()
  local nearest = nil
  local best    = 999
  for item in all(throwables) do
    if not item.air and not item.lift then
      local d = abs(item.x - customer.x)
      if d < best then
        best    = d
        nearest = item
      end
    end
  end
  if nearest then
    nearest.air    = true
    nearest.airx   = nearest.x
    nearest.airy   = nearest.y
    nearest.airdir = 0   -- throw left toward player
  end
end


function update_projectiles()
  for proj in all(projectiles) do
    local spd = proj.spd or 1.5
    if proj.dir == 0 then
      proj.x -= spd
    else
      proj.x += spd
    end
    -- off-screen cull
    if proj.x < cam_coords.x - 32 or proj.x > cam_coords.x + 160 then
      del(projectiles, proj)
    elseif hit(proj) then
      if proj.tpe == 0 then
        player.health -= .2
      elseif proj.tpe == 1 then
        customer.health -= .02
      end
      del(projectiles, proj)
    end
  end
end

function update_throwables()
  for item in all(throwables) do
    if item.lift == true then
      player.action_time = 2
      if player.dir == 0 then
        item.x = player.x
      else
        item.x = player.x - 8
      end
      item.y = player.y - 27
    end
    if item.air then
      if item.airdir == 1 then
        item.x += 1
      else
        item.x -= 1
      end
      item.y = item.airy + .008 * (item.x - item.airx - 10)^2
      if item.y > 56 then
        item.air = false
        item.y   = 56
        if item.x > 320 then item.x = 304 end
        if item.x < 0   then item.x = 0   end
        if item.x < customer.x + 12
        and item.x > customer.x - 12 then
          customer.health -= .2
        end
        -- enemy-thrown items hit the player too
        if item.x < player.x + 12
        and item.x > player.x - 12 then
          player.health -= .15
        end
      end
    end
  end
end

function hit(proj)
  local pw = (proj.w or PROJ_SIZE) / 2
  local ph = (proj.h or PROJ_SIZE) / 2

  if proj.tpe == 0 then
    local cx = proj.x + pw
    return cx > player.x - 5
        and cx < player.x + 5
        and proj.y + ph/2 > player.y - 11
        and proj.y - ph/2 < player.y + 12

  elseif proj.tpe == 1 then
    local cx = proj.x + pw
    return cx > customer.x - 8
        and cx < customer.x + 8
        and proj.y + ph/2 > customer.y - 16
        and proj.y - ph/2 < customer.y + 16
  end
end

function try_punch()
  if not punch() then return false end
  customer.health -= 0.07
  customer.hit_flash = 2
  return true
end

function update_hit_flash()
  if customer.hit_flash and customer.hit_flash > 0 then
    customer.hit_flash -= 1
  end
end

function check_health()
  if player.health   < 0 then player.health   = 0 end
  if customer.health < 0 then customer.health = 0 end
  if player.health == 0 or customer.health == 0 then
    game_state = 3
  end
end