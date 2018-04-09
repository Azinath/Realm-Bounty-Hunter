function RBH_UnitType(guid)   
   local B = tonumber(guid:sub(5,5), 16);
   local maskedB = B % 8; -- x % 8 has the same effect as x & 0x7 on numbers <= 0xf
   --local knownTypes = {[0]="player", [3]="NPC", [4]="pet", [5]="vehicle"};
   
   return maskedB
end

--respond to request to validate claimed bounty from issuer
function RBH_ValidateClaimedBountyReq(id, sender)
    local i, msg
    for i = 1,#RBH_HitList do
        if id == RBH_HitList[i].id and sender == RBH_HitList[i].issuer and RBH_GetFullName("player") == RBH_HitList[i].claimer then
            if RBH_Claimed ~= nil and RBH_Claimed[id] ~= nil and RBH_Claimed[id].guid ~= nil then
                msg = id..","..RBH_Claimed[id].guid                 
                rbh_debug("Validating bounty")
            else
                msg = ""
                rbh_debug("Invalid bounty")
            end
            
            ChatThrottleLib:SendAddonMessage("ALERT","RBH_VALIDATE_ACK",msg,"WHISPER",sender)            
            
            break
        end
    end
 end

--parse message sent by bounty claimer 
function RBH_ValidateClaimedBountyAck(msg, sender)
    local i
    local id, guid = string.split(",",msg)
    
    for i = 1,#RBH_HitList do
        if id == RBH_HitList[i].id and sender == RBH_HitList[i].claimer and RBH_GetFullName("player") == RBH_HitList[i].issuer then
            local fullName = RBH_HitList[i].name.."-"..RBH_HitList[i].realm
            
            if guid == RBH_Intel[fullName].guid then
                RBH_HitList[i].valid = true
                RBH_HitListUpdate()
                rbh_debug("Bounty validated")
            end
            
            break
        end
    end
 end
 
