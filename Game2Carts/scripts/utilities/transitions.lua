fade = 0
fading = -1         -- -1 = inactive
on_fade_done = nil  -- callback when fade hits 0

-- -1 = not started, 0 = running, 1 = done
fade_state = -1

-- fade to black lookup table
local fadetable0={
 {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
 {1,1,1,1,1,1,1,0,0,0,0,0,0,0,0},
 {2,2,2,2,2,2,1,1,1,0,0,0,0,0,0},
 {3,3,3,3,3,3,1,1,1,0,0,0,0,0,0},
 {4,4,4,2,2,2,2,2,1,1,0,0,0,0,0},
 {5,5,5,5,5,1,1,1,1,1,0,0,0,0,0},
 {6,6,13,13,13,13,5,5,5,5,1,1,1,0,0},
 {7,6,6,6,6,13,13,13,5,5,5,1,1,0,0},
 {8,8,8,8,2,2,2,2,2,2,0,0,0,0,0},
 {9,9,9,4,4,4,4,4,4,5,5,0,0,0,0},
 {10,10,9,9,9,4,4,4,5,5,5,5,0,0,0},
 {11,11,11,3,3,3,3,3,3,3,0,0,0,0,0},
 {12,12,12,12,12,3,3,1,1,1,1,1,1,0,0},
 {13,13,13,5,5,5,5,1,1,1,1,1,0,0,0},
 {14,14,14,13,4,4,2,2,2,2,2,1,1,0,0},
 {15,15,6,13,13,13,5,5,5,5,5,1,1,0,0}
}

-- fade to white lookup table
local fadetable1={
 {0,0,1,1,5,5,5,13,13,13,6,6,6,6,7},
 {1,1,5,5,13,13,13,13,13,6,6,6,6,6,7},
 {2,2,2,13,13,13,13,13,6,6,6,6,6,7,7},
 {3,3,3,3,13,13,13,13,6,6,6,6,6,7,7},
 {4,4,4,4,4,14,14,14,15,15,15,15,15,7,7},
 {5,5,13,13,13,13,13,6,6,6,6,6,6,7,7},
 {6,6,6,6,6,6,6,6,7,7,7,7,7,7,7},
 {7,7,7,7,7,7,7,7,7,7,7,7,7,7,7},
 {8,8,8,8,14,14,14,14,14,14,15,15,15,7,7},
 {9,9,9,10,10,10,15,15,15,15,15,15,15,7,7},
 {10,10,10,10,10,15,15,15,15,15,15,15,7,7,7},
 {11,11,11,11,11,11,6,6,6,6,6,6,6,7,7},
 {12,12,12,12,12,12,6,6,6,6,6,6,7,7,7},
 {13,13,13,13,6,6,6,6,6,6,6,6,7,7,7},
 {14,14,14,14,14,15,15,15,15,15,15,7,7,7,7},
 {15,15,15,15,15,15,15,7,7,7,7,7,7,7,7}
}

local function apply_fade0(i)
 for c=0,15 do
  if flr(i+1)>=16 then
   pal(c,0,1)
  else
   pal(c,fadetable0[c+1][flr(i+1)],1)
  end
 end
end

local function apply_fade1(i)
 for c=0,15 do
  if flr(i+1)>=16 then
   pal(c,7,1)
  else
   pal(c,fadetable1[c+1][flr(i+1)],1)
  end
 end
end

-- public api
function fade_to_black()
 fading = 0
 fade = 15
 fade_state = 0
end

function fade_to_white()
 fading = 1
 fade = 15
 fade_state = 0
end

function fade_from_black()
 fading = 2
 fade = 15
 fade_state = 0
end

function fade_from_white()
 fading = 3
 fade = 15
 fade_state = 0
end

function is_fading()
 return fading > -1
end

function transition_update()
 if fading > -1 then
  if fade > 0 then
   fade -= 0.5
  else
   -- fade finished
   if on_fade_done then
    on_fade_done()
    on_fade_done = nil
   end
   fading = -1
   fade_state = 1
  end
 end
end

function transition_draw()
 if fading == 0 then apply_fade0(ceil(fade))
 elseif fading == 1 then apply_fade1(ceil(fade))
 elseif fading == 2 then apply_fade0(15-ceil(fade))
 elseif fading == 3 then apply_fade1(15-ceil(fade))
 end
end