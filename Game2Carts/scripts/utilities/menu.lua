-- main menu template by googroker
-- https://www.lexaloffle.com/bbs/?tid=35751


function update_menu()
 --move and clamp cursor
 if(btnp(2)) cy-=1
 if(btnp(3)) cy+=1
 cy=mid(1,cy,#mbutts/2)
 
 --if 🅾️ pressed, activate button
 if(btnp(4)) mbutts[cy*2]()
end

function draw_menu()
 cls()
 
 --draw your background here
 
 --a title isn't really 
 --nessecary but i think it 
 --adds some much-needed flair
 spr(32,47,10,5,2)
 
 --for every menu item...
 for i,p in pairs(mbutts) do
  --only draw every other
  --entry, only the labels
  --(this is kinda hacky but eh)
  if i%2==1 then
   --change what h equals to
   --change the text and
   --highlight colours
   local h=5
   if(cy*2-1==i) h=7
   --print the label, adjusting
   --for text length to be
   --exactly centered
   print(p,64-#p*2,40+i*6,h)
  end
 end
end

