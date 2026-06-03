--picoboard 1.3 by afburgess
--https://www.lexaloffle.com/bbs/?tid=4076

function picoboard()

--keymappings
if btnp(1) then keypos.x +=1 sfx(2) end
if btnp(0) then keypos.x -=1 sfx(2) end
if btnp(2) then keypos.y -=1 sfx(2) end
if btnp(3) then keypos.y +=1 sfx(2) end
if btnp(4) then backspace() end
if btnp(5) then select() end

--keyboard looping
if keypos.x > 9 then keypos.x = 0 end
if keypos.x < 0 then keypos.x = 9 end
if keypos.y > 2 then keypos.y = 0 end
if keypos.y < 0 then keypos.y = 2 end

--numpad key display shift
pr = numstate*27

--keyboard draw
rectfill(x-7,y-7,x+99,y+31,0)
rect(x-7,y-7,x+99,y+31,7)

for r1=0,9 do
 print(key[r1+1+pr],x+r1*10,y,7)
 print(key[r1+11+pr],x+r1*10,y+10,7)
end
for r2=0,5 do
 print(key[r2+21+pr],x+r2*10,y+20,7)
end

for r3=1,4 do
 spr(r3+4*numstate,x+49+r3*10,y+20)
end

--cursor draw
rect(keypos.x*10+x-3,keypos.y*10+y-3,keypos.x*10+x+5,keypos.y*10+y+7,7)

--displaystring
rectfill(64-#txtstr*2-5,45,64-#txtstr*2+4*#txtstr+5,59,0)
str=""
for i in all(txtstr) do
str=str..i..""
print(str,64-#txtstr*2,50,7)
end

--blinker
blk+=1
 blk %= 20
 if blk>10 then 
 rectfill(64-#txtstr*2+4*#txtstr,50,64-#txtstr*2+2+4*#txtstr,54,8)
 end

end


function select()
newkey = keypos.x + keypos.y*10 + 1

if newkey > 27 then
 if newkey == 28 then backspace() end
 if newkey == 29 then numpad() sfx(3) end
 if newkey == 30 then confirm() sfx(3) end
else
add(txtstr,key[newkey+pr])
sfx(0)
end
end

function backspace()
 if #txtstr > 0 then txtstr[#txtstr]=nil sfx(1) end
end

function numpad()
 numstate += 1
 numstate %= 2
end

function confirm()
    keyboard_result = ""
    for i in all(txtstr) do
        keyboard_result = keyboard_result..i
    end
    keyboard_active = false
    txtstr = {}
    if keyboard_callback != nil then
        keyboard_callback(keyboard_result)
    end
end

function open_keyboard(callback)
    keyboard_active = true
    txtstr = {}
    keyboard_callback = callback
end