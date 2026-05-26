local diff_map = {easy=0, medium=1, hard=2}

enemies = {
  {
    name        = "default",
    fight_cart  = "waffles_erics_copy.p8",
    difficulty  = "medium",
    abilities   = {"shoot", "rush", "throw"},
  },
}

-- slot 0 = difficulty
-- slot 1 = has rush
-- slot 2 = has shoot  
-- slot 3 = has throw

function trigger_enemy_fight()
  cartdata("fightbufferv1")
  local e = enemies[flr(rnd(#enemies)) + 1]

  local diff_map = {easy=0, medium=1, hard=2}
  dset(0, diff_map[e.difficulty] or 1)
  dset(1, 0) dset(2, 0) dset(3, 0)
  for _, ab in ipairs(e.abilities) do
    if ab == "rush"  then dset(1, 1) end
    if ab == "shoot" then dset(2, 1) end
    if ab == "throw" then dset(3, 1) end
  end

  local src = (flr(rnd(2)) == 0) and 0x0000 or 0x0800
  local drc = (flr(rnd(2)) == 0) and 0x1000 or 0x1800
  reload(drc, src, 0x0800, "bad_coworker.p8")
  cstore(0x1000, 0x1000, 0x0800, "waffles_erics_copy.p8")

  load(e.fight_cart)
end