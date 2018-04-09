function IsBountyOpen (name, realm)
    local n = #RBH_HitList
    local i
    local max_i = 0
    local curr_amount = 0
    local max_amount = 0
    local found = false
    
    for i = 1, n do 
        if (name == RBH_HitList[i].name and RBH_HitList[i].state == "RBH_OPEN" and
           (realm == RBH_HitList[i].realm or RBH_RemoveWhiteSpace(realm) == RBH_HitList[i].realm) and
           ((RBH_HitList[i].issuer ~= RBH_GetFullName("player")) or RBH_Config["ClaimYourOwnBounties"] == true)) then
            --find the bounty of max value
            curr_amount = tonumber(RBH_HitList[i].amount)
            if (curr_amount > max_amount) then
                max_amount = curr_amount
                max_i = i
                found = true
            end            
        end
   end
   
   return found, max_i
end

function RBH_IsBountyLocked(name)
    local n = #RBH_HitList;
    local i;
    for i = 1, n do 
        if name == RBH_HitList[i].name then
            if RBH_HitList[i].state == "RBH_OPEN_L" and RBH_HitList[i].state == "RBH_OPEN_SL" then
                return true
            else        
                return false
            end
        end
    end
    return false
end

function RBH_IsBountySplit(name)
    local n = #RBH_HitList;
    local i;
    for i = 1, n do 
        if name == RBH_HitList[i].name then
            if RBH_HitList[i].state == "RBH_OPEN_S" and RBH_HitList[i].state == "RBH_OPEN_SL" then
                return true
            else        
                return false
            end
        end
    end
    return false
end
