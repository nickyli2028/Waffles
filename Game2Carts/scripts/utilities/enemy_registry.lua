enemies = {
  {
    name = "default",
    fight_cart = "waffles_erics_copy.p8",
  },
}

function start_fight()
  local e = enemies[flr(rnd(#enemies)) + 1]

  -- backup waffles sheet 2 (128-191) into bad_coworker sheet 3 (192-255)
  reload(0x1000, 0x1000, 0x0800, "waffles_erics_copy.p8")
  cstore(0x1800, 0x1000, 0x0800, "bad_coworker.p8")

  -- randomly pick sheet 0 or sheet 1 from bad_coworker to replace waffles sheet 2
  local src = (flr(rnd(2)) == 0) and 0x0000 or 0x0800
  reload(0x1000, src, 0x0800, "bad_coworker.p8") 
  cstore(0x1000, 0x1000, 0x0800, "waffles_erics_copy.p8")

  load(e.fight_cart)
end