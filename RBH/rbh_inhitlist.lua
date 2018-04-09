function InHitList (id)
   local n = #RBH_HitList;
   local i;
   for i = 1, n do 
      if id == RBH_HitList[i].id then
         return true, i
      end
   end
   return false, 0
end