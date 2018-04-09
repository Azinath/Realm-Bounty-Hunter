function RBH_ActionQueueInit()
   RBH_ActionQueue = {}
   if RBH_Timer == nil then
      RBH_Timer = CreateFrame("Frame")       
      RBH_Timer:SetScript("OnUpdate", RBH_ActionQueueUpdate)
   end
   
end

function RBH_ActionQueueUpdate()
   if #RBH_ActionQueue == 0 then 
      RBH_Timer:Hide()
      return 
   end 
   if time() >= RBH_ActionQueue[1].ts then 
      RunScript(RBH_ActionQueue[1].script)
      table.remove(RBH_ActionQueue, 1)
   end
end

function RBH_ActionQueueAdd(script, delay)
   table.insert(RBH_ActionQueue, {ts=time()+delay, script=script})
   table.sort(RBH_ActionQueue, RBH_ActionSort)
   RBH_Timer:Show()
end

function RBH_ActionSort(a,b)
   return a.ts < b.ts
end



