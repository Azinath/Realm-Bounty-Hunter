function RBH_SetNote(bounty_id, note)
    local timestamp = time()
    local msg
       
    if note == nil or bounty_id == nil then
        return
    end
    
    --check for existing note
    if RBH_Notes[bounty_id] == nil then
        RBH_Notes[bounty_id] = {}
    end
    
    RBH_Notes[bounty_id].timestamp = timestamp
    RBH_Notes[bounty_id].note = note
    
    msg = bounty_id..","..timestamp..","..msg
    RBH_SendAddonMessageToNetwork("BULK","RBH_NT_UPDATE",msg);
end

function RBH_NT_DoSync(sender)   
    local i,j,n,msg
    if RBH_HitList == nil then  
        RBH_HitList={}
        return
    end        
    n = #RBH_HitList        
    for  i = 1, n do        
        if RBH_IsBountyInActiveChannel(i) then
            j = RBH_HitList[i].id
            if RBH_Notes[j] ~= nil then
                msg = j.id..","..j.timestamp..","..j.note      
                rbh_debug("Send: "..msg)                         
                ChatThrottleLib:SendAddonMessage("BULK","RBH_NT_UPDATE",msg,"WHISPER",sender)
            end
        end
    end
end    

function RBH_NT_DoUpdate(msg,sender)  
    local id,timestamp,note
    local f, i
    id,timestamp,note = string.split(",",msg) 
    
    rbh_debug("RBH_NT_DoUpdate("..msg)
    
    --must have valid values
    if id == nil or timestamp == nil or note == nil then 
        rbh_debug("RBH_NT_DoUpdate: Error: nil value.")
        return
    end
    
    f,i = InHitList(id)
    rbh_debug("Is InHitList["..i.."]:"..tostring(f))
    
    if f == false then
        --no bounty for note
        return                   
    elseif RBH_Notes[id] == nil then
        --add new note
        RBH_Notes[id] = {}
        RBH_Notes[id].timestamp = timestamp
        RBH_Notes[id].note = note
    elseif timestamp > RBH_Notes[id].timestamp then
        --update note
        RBH_Notes[id].timestamp = timestamp
        RBH_Notes[id].note = note        
    end    
end