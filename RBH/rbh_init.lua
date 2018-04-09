RBH_Largess = 0

function RBH_PlayerOffline(self,event,msg)
    local pattern = "No player named '.*' is currently playing."
    
    if (string.match(msg, pattern)) then
        return true
    else
        return false
    end
end

function RBH_Purge()
    local i,n,daysOld
    i = 1
    
    if RBH_HitList == nil then
       return
    end
    
    n = #RBH_HitList
    while (i <= n) do
        daysOld = (time()- tonumber(RBH_HitList[i].timestamp))/86400
        if ((RBH_Config["RejectHorde"] and RBH_HitList[i].faction == "Horde") or
          (RBH_Config["RejectAlliance"] and RBH_HitList[i].faction == "Alliance") or
          (RBH_Config["RejectUnknown"] and RBH_HitList[i].faction == "UNKNOWN") or
          (tonumber(RBH_HitList[i].amount) < RBH_Config["MinAmount"]) or
          (daysOld > RBH_Config["MaxAge"])) then      
            table.remove(RBH_HitList,i)
            n = n - 1
            i = i - 1
        end
        i = i + 1
    end
    
    RBH_HitListUpdate()
end

function RBH_Init()
    --set version string
    RBH_VERSION = GetAddOnMetadata("RBH", "version")
   
    if RBH_HitList == nil then
        RBH_HitList = {}
    end      
	
	if RBH_Notes == nil then
        RBH_Notes = {}
    end
   
    if RBH_Intel == nil then
        RBH_Intel = {}
    end
    
    if RBH_Claimed == nil then
        RBH_Claimed = {}
    end
   
    if RBH_CurrMoney == nil then
       RBH_CurrMoney = GetMoney()
    end
   
    if RBH_Config == nil then
       RBH_Config = {}
       RBH_Config["channel"] = "GUILD"
    end 

    if RBH_Config["ShowHorde"] == nil then
        RBH_Config["ShowHorde"] = true
    end
    
    RBH_BountyFilters.ShowHorde = RBH_Config["ShowHorde"]
    
    if RBH_Config["ShowAlliance"] == nil then
        RBH_Config["ShowAlliance"] = true
    end
    
    RBH_BountyFilters.ShowAlliance = RBH_Config["ShowAlliance"]
    
    if RBH_Config["ShowOpen"] == nil then
        RBH_Config["ShowOpen"] = true
    end
    
    RBH_BountyFilters.ShowOpen = RBH_Config["ShowOpen"]
   
    if RBH_Config["ShowClaimed"] == nil then
        RBH_Config["ShowClaimed"] = true
    end
    
    RBH_BountyFilters.ShowClaimed = RBH_Config["ShowClaimed"]
   
    if RBH_Config["ShowPaid"] == nil then
        RBH_Config["ShowPaid"] = true
    end
    
    RBH_BountyFilters.ShowPaid = RBH_Config["ShowPaid"]
    
    if RBH_Config["ShowRealmChannel"] == nil then
        RBH_Config["ShowRealmChannel"] = true
    end
    
    RBH_BountyFilters.ShowRealmChannel = RBH_Config["ShowRealmChannel"]
    
    if RBH_Config["ShowGuildChannel"] == nil then
        RBH_Config["ShowGuildChannel"] = true
    end
    
    RBH_BountyFilters.ShowGuildChannel = RBH_Config["ShowGuildChannel"]
    
    if RBH_Config["ShowPrivateChannel"] == nil then
        RBH_Config["ShowPrivateChannel"] = true
    end
    
    RBH_BountyFilters.ShowPrivateChannel = RBH_Config["ShowPrivateChannel"]
    
    if RBH_Config["RealmChannel"] == nil then
        RBH_Config["RealmChannel"] = true
    end
    
    if RBH_Config["GuildChannel"] == nil then
        RBH_Config["GuildChannel"] = true
    end
    
    if RBH_Config["PrivateChannel"] == nil then
        RBH_Config["PrivateChannel"] = true
    end    
  
    if RBH_Config["ClaimYourOwnBounties"] == nil then
        RBH_Config["ClaimYourOwnBounties"] = false
    end
    
    if RBH_Config["RejectHorde"] == nil then
        RBH_Config["RejectHorde"] = false
    end
    
    if RBH_Config["RejectAlliance"] == nil then
        RBH_Config["RejectAlliance"] = false
    end
    
    if RBH_Config["RejectUnknown"] == nil then
        RBH_Config["RejectUnknown"] = false
    end
    
    if RBH_Config["MinAmount"] == nil then
        RBH_Config["MinAmount"] = 0
    end
    
    if RBH_Config["MaxAge"] == nil then
        RBH_Config["MaxAge"] = 365
    end
    
	if RBH_Config["ClassColors"] == nil then
		RBH_Config["ClassColors"] = true
	end
	
    RBH_CreateGUI()   
    RBH_ActionQueueInit()   
   
    --get player faction and enemy faction
    RBH_PlayerFaction = UnitFactionGroup("player")
    
    if RBH_PlayerFaction == "Alliance" then
       RBH_EnemyFaction = "Horde"
    else
       RBH_EnemyFaction = "Alliance"
    end
   
    SLASH_RBH1 = "/rbh"
    SlashCmdList["RBH"] = RBH_Commands;
   
    --set portrait icon
    SetPortraitToTexture(RBH_HitListFrameSkullnXBonesTexture,"interface\\targetingframe\\targetdead")
    --SendAddonMessage("RBH_HL_SYNC_REQ",nil,"GUILD");
    
    ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM",RBH_PlayerOffline)
    RBH_Purge()
end  

function RBH_GetTotalIssuedBountiesValue()
    local i
    local amount = 0
    for i=1,#RBH_HitList do
        if RBH_HitList[i].issuer == RBH_GetFullName("player") and RBH_HitList[i].state ~= "RBH_PAID" and 
           RBH_HitList[i].state ~= "RBH_DEL" then
            amount = amount + RBH_HitList[i].amount
        end
    end
    
    return amount
end