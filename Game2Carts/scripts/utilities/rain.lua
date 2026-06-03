function new_particle_system(maxparticles)
  local _pool={}

  function new_particle()
    local _x,_y=0,0
    local _xspeed,_yspeed=0,0
    local _done=true
    return {
      launch=function(x,y,xspd,yspd)
        if _done then
          _x,_y,_xspeed,_yspeed,_done=x,y,xspd,yspd,false
          return true
        end
      end,
      update=function()
        if (_done) return
        _x+=_xspeed
        _yspeed+=0.92
        _y+=_yspeed
        if _y > cam_y + 127 or _x<cam_x-1 or _x>cam_x+128 then
          _done=true
        end
      end,
      draw=function()
        if (_done) return
        line(_x,_y,_x+_xspeed,_y+_yspeed,7)
      end
    }
  end

  for i=1,maxparticles do
    _pool[i]=new_particle()
  end

  return {
    rain=function()
      local rand=rnd(5)
      for i=1,maxparticles do
        if _pool[i].launch(cam_x+rnd(127),cam_y-rand,0,rand) then
          return
        end
      end
    end,
    update=function()
      for i=1,maxparticles do
        _pool[i].update()
      end
    end,
    draw=function()
      for i=1,maxparticles do
        _pool[i].draw()
      end
    end
  }
end