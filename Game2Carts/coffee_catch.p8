pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
pot_x = 56
drops = {}
score = 0
hi    = 0
lives = 3
tick  = 0
spd   = 1
rate  = 60
msg   = ""
mcol  = 9
mtmr  = 0
state = 0  -- 0=title 1=play 2=checkpoint 3=over
otmr  = 0
points_banked = 0  -- how many points earned so far this session

pot_y = 108
pot_w = 16

local SLOT_COFFEE = 1
local SLOT_RETURN = 2
local SLOT_FIGHT  = 7
local PARENT_CART = "between_level.p8"

-- coin flip state
coin_timer   = 0
coin_face    = 0
coin_result  = -1
coin_done    = false

function _init()
    cartdata("coffee_catch_v1")
    hi = dget(0)
end

function update_coin_flip()
    coin_timer += 1
    local flip_rate = coin_timer < 60 and 4 or (coin_timer < 90 and 8 or 16)
    if coin_timer % flip_rate == 0 then
        coin_face = 1 - coin_face
    end
    if coin_timer >= 100 and not coin_done then
        coin_done = true
        coin_result = (flr(rnd(2)) == 0) and 1 or 0
        coin_face = coin_result == 1 and 0 or 1
    end
    if coin_done and btnp(4) then
        return_to_overworld(coin_result == 1)
    end
end

function draw_coin_flip()
    cls(0)
    rectfill(20,20,107,107,1)
    rect(20,20,107,107,9)
    print("uh oh...",42,28,8)
    if not coin_done then
        local w = (coin_timer % 8 < 4) and 20 or 6
        rectfill(64-w,52,64+w,72,9)
        rectfill(64-w+1,50,64+w-1,74,9)
        print("?",61,58,0)
    elseif coin_result == 1 then
        rectfill(44,48,84,78,8)
        rect(44,48,84,78,7)
        print("heads",52,60,7)
        print("fight!",50,70,8)
    else
        rectfill(44,48,84,78,11)
        rect(44,48,84,78,7)
        print("tails",52,60,7)
        print("safe!",52,70,3)
    end
    if coin_done then
        if tick%40<20 then print("z: continue",36,90,7) end
    else
        print("flipping...",36,90,6)
    end
end

function _update()
    tick += 1

    if state == 4 then
        update_coin_flip()
        return
    end

    if state == 0 then
        if btnp(4) then
            pot_x=56 drops={} score=0 lives=3
            tick=0 spd=1 rate=60 msg="" mtmr=0
            state=1
        end
        return
    end

    -- checkpoint: hit 10, ask to continue or cash out
    if state == 2 then
        if btnp(4) then
            -- continue playing for another point
            score=0 lives=3 drops={}
            tick=0 spd=1 rate=60 msg="" mtmr=0
            state=1
        end
        if btnp(5) then return_to_overworld() end
        return
    end

    -- game over
    if state == 3 then
        if points_banked == 0 then
            -- no banked points: x starts coin flip, o leaves
            if btnp(4) then
                coin_timer=0 coin_face=0 coin_result=-1 coin_done=false
                state=4
            elseif btnp(5) then
                return_to_overworld(false)
            end
        else
            -- already banked points: any button returns to title
            if btnp(4) or btnp(5) then state=0 end
        end
        return
    end

    -- play
    if mtmr>0 then mtmr-=1 end

    if btn(0) then pot_x-=2.5 end
    if btn(1) then pot_x+=2.5 end
    pot_x = mid(2, pot_x, 109)

    if tick%rate==0 then
        add(drops,{x=4+rnd(116),y=-4,s=spd+rnd(0.8)})
        if score>50 and rnd(1)<0.3 then
            add(drops,{x=4+rnd(116),y=-4,s=spd+rnd(0.8)})
        end
    end

    for d in all(drops) do
        d.y += d.s
        if d.y+3>=pot_y and d.y<pot_y+6
        and d.x>=pot_x-2 and d.x<=pot_x+pot_w+2 then
            del(drops,d)
            score+=1
            msg="+" mcol=11 mtmr=40
            if score%10==0 then
                spd=min(spd+0.3,4)
                rate=max(rate-5,20)
                msg="faster!" mcol=9 mtmr=60
            end
            if score>hi then hi=score dset(0,hi) end
            -- hit checkpoint
            if score >= 10 then
                points_banked += 1
                state=2
            end
        elseif d.y>128 then
            del(drops,d)
            lives-=1
            msg="miss!" mcol=8 mtmr=50
            if lives<=0 then state=3 otmr=200 end
        end
    end
end

function _draw()
    cls(1)
    palt(0,true)

    if state==4 then
        draw_coin_flip()
        return
    end

    if state==0 then
        rectfill(0,100,127,127,13)
        rectfill(0,98,127,101,6)
        print("coffee catch",28,20,9)
        print("catch the drops",22,34,7)
        print("hi: "..hi,4,4,7)
        spr(32,52,88,3,2)
        if tick%60<30 then print("z to play",43,108,9) end
        return
    end

    -- checkpoint screen
    if state==2 then
        rectfill(10,20,117,107,0)
        rect(10,20,117,107,9)
        print("10 drops caught!",18,30,11)
        print("banked: "..points_banked.." pt",22,45,7)
        print("z: cash out",22,65,6)
        print("x: go for more!",22,75,10)
        return
    end

    -- game over screen
    if state==3 then
        rectfill(20,30,107,98,0)
        rect(20,30,107,98,9)
        print("game over",38,38,8)
        print("score: "..score,36,52,7)
        print("banked: "..points_banked.." pt",36,62,11)
        if points_banked == 0 then
            print("x coin flip",34,78,9)
            print("o leave",38,88,7)
        else
            print("x/o continue",30,88,7)
        end
        return
    end

    -- play
    rectfill(0,96,127,127,13)
    rectfill(0,94,127,97,6)

    pal(12,4)
    for d in all(drops) do spr(2,d.x-4,d.y-4) end
    pal()
    spr(32,pot_x,pot_y,3,2)

    rectfill(0,0,127,9,0)
    print("score:"..score,2,2,7)
    print("hi:"..hi,70,2,6)
    for i=1,lives do
        pal(5,12) spr(0,128-i*10,1) pal()
    end

    local p=(spd-1)/3
    rectfill(2,120,30,122,0)
    rectfill(2,120,2+p*28,122,9)
    print("spd",2,123,6)

    if mtmr>0 then print(msg,50,14,mcol) end
end

function return_to_overworld(do_fight)
    cartdata("fightbufferv1")
    dset(SLOT_COFFEE, points_banked)
    dset(SLOT_RETURN, 1)
    dset(SLOT_FIGHT, do_fight and 1 or 0)
    load(PARENT_CART)
end

__gfx__
00666600000000000004000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06444460000000000044400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06444460000000000444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03666630000000000444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03333330000000000444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03377330000000000044400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
03377330000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00333300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06666666666660000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40000000000004555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40000000000004005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
40000000000004005000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
44000000000044555000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
04444444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
