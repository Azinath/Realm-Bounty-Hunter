function RBH_DisplayList()
   local i, n,name,amount,msg
   
   RBH_FilterHitList()
   
   RBH_Message("     ")   
   RBH_Message("------------------------------------------")   
   RBH_Message("Realm Bounty Hunter v"..RBH_VERSION,"GUILD")
   RBH_Message("------------------------------------------")
   RBH_Message("Target {skull} Bounty {circle} Claimer {cross}")
   RBH_Message("------------------------------------------")
   
   n = #RBH_HitListFiltered
   for i = 1, n do
      name = RBH_HitListFiltered[i].name
      amount =  RBH_HitListFiltered[i].amount
      msg = string.format("%s {skull} %s {circle}",name,RBH_CopperToGold(amount))
      if (RBH_HitList[i].state == "RBH_CLAIMED") then
         msg = string.format("%s {skull} %s {circle}  %s {cross}",name,RBH_CopperToGold(amount),RBH_HitListFiltered[i].claimer);
      end 
      RBH_Message(msg)
   end
end

function RBH_Message(msg)
   --SendChatMessage(msg, RBH_Config["channel"], nil)
   if RBH_Config["channel"] == "PRIVATE" then
      ChatFrame1:AddMessage(msg,0,1,0);
   else
      ChatThrottleLib:SendChatMessage("NORMAL", "RBH", msg, RBH_Config["channel"], nil, nil);
   end
end

function rbh_debug(msg)
    if RBH_Config == nil then
        return
    end
    if RBH_Config["debug"] then
       ChatFrame1:AddMessage(msg,0,1,0);
    end
end

function RBH_Msg(msg)
   ChatFrame1:AddMessage(msg,1,1,1)  
end
   