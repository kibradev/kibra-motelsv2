local StateD = nil
local WebOpen = false
local KibrahimV1 = true
local mId = 0
local isText = false
PlayerInMotelRoom = false 
CurrentMotel = 0
CurrentRoom = 0

Framework = nil

Citizen.CreateThread(function()
    while Framework == nil do
        TriggerEvent('0r-core:getSharedObject', function(obj) Framework = obj end)
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()    
    while KibrahimV1 do
        Wait(1000)
        if NetworkIsPlayerActive(PlayerId()) then
            TriggerServerEvent('Kibra:Motels:V2:Server:LoadMotelsRooms')
            CreateMotelBlips()
            break
        end
    end
    TriggerServerEvent('Kibra:Motels:V2:Server:Outbucket')
end)

RegisterNetEvent('0r-core:setJob', function(JobInfo)
    Framework.GetPlayerData().job = JobInfo
end)

RegisterNetEvent("Kibra:Motels:V2:Client:CacheMotels", function(mid,rid) 
    CurrentMotel = mid
    CurrentRoom = rid
end)

RegisterNetEvent('Kibra:Motels:V2:Client:UpdateMotels', function(Data)
    Config.Motels = Data
    ClearBlips()
    CreateMotelBlips()
end)

Citizen.CreateThread(function()
    while not Config.AutomaticPaymentInstruction do
        TriggerServerEvent('Kibra:Motels:V2:Server:CheckMotel', GetPlayerServerId(PlayerId()))
        Citizen.Wait(Config.BillingCheckTime*1000)
    end
end)

Citizen.CreateThread(function()
    while Config.AutomaticPaymentInstruction == true do
        TriggerServerEvent('Kibra:Motels:V2:AutoPayment')
        Citizen.Wait(Config.BillingCheckTime*1000)
    end
end)

RegisterCommand('kontrol', function()
    TriggerServerEvent('Kibra:Motels:V2:AutoPayment')
end)

Citizen.CreateThread(function()
    Framework.TriggerServerCallback('Kibra:Motels:V2:Server:DoorDataLoad', function(DoorState)
        for k,v in pairs(Config.Motels) do
            if not v.Teleport then
                for DoorNo, Door in pairs(v.Rooms) do
                    MotelId = k*1000
                    Conclusion = DoorNo+MotelId
                    if not IsDoorRegisteredWithSystem(0x100+Conclusion) then
                        AddDoorToSystem(0x100+Conclusion, v.DoorHash, Door.DoorCoord, true, true, true)
                        if DoorState[DoorNo] then StateDoor = DoorState[DoorNo].State else StateDoor = (v.AutoLock == true and 1 or 0) end
                        DoorSystemSetDoorState(0x100+Conclusion, StateDoor, 0, 1)
                        SetStateOfClosestDoorOfType(0x100+Conclusion, Door.DoorCoord, 1, 0.0, true)
                    end
                end
            end
        end
    end)
end)

RegisterNetEvent('Kibra:Motels:V2:Client:MotelKeyUsed', function(data)
    TriggerServerEvent('Kibra:Motels:V2:Server:UploadRooms')
    Framework.TriggerServerCallback('Kibra:Motels:V2:Server:CheckPlayerFatura', function(dataseks) 
        if dataseks then
            if Config.Inventory == "ox" then
                OxInventoryMotelKey(Framework.GetPlayerData().inventory[data.slot].metadata)
            elseif Config.Inventory == "QBCore" then 
                OtherInventory(data)
            else
                print("Invalid Inventory")
            end
        else
            Config.Notify(Config.Lang["NoAccessRoom"])
        end
    end)
end)

OtherInventory = function(data)
    local PlayerCoord = GetEntityCoords(PlayerPedId())
    for MotelNo, Motel in pairs(Config.Motels) do
        for RoomNo, Room in pairs(Motel.Rooms) do
            MotelId = MotelNo*1000
            Conclusion = RoomNo+MotelId
            local DoorDist = GetDistanceBetweenCoords(PlayerCoord, Room.DoorCoord, true)
            if DoorDist <= 2.0 then
                if not Motel.Teleport then
                    StateD = DoorSystemGetDoorState(0x100+Conclusion) == 0 and 1 or 0
                    if data.Pass == Room.Password and data.Room == RoomNo then
                        ChangeDoorStatus(StateD, Room, Conclusion)
                    else
                        Config.Notify(Config.Lang["Thiskeydoesnotbelongtothisthing"])
                    end
                else
                    if data.Pass == Room.Password and data.Room == RoomNo then
                        if not Room.DoorLock then
                            Config.Show("", Config.Lang["Locked"])
                        else
                            Config.Show("[E]", Config.Lang["EnterRoom"])
                        end
                        Animation()
                        TriggerServerEvent('Kibra:Motels:V2:Server:DoorLockTeleport', MotelNo, RoomNo, not Room.DoorLock)
                    else
                        Config.Notify(Config.Lang["Thiskeydoesnotbelongtothisthing"])
                    end
                end
            end
    
            local StashDist = GetDistanceBetweenCoords(PlayerCoord, Room.StashCoord, true)
            if StashDist <= 2.0 then
                if data.Pass == Room.Password and data.Room == RoomNo then
                    if not Room.StashLock then
                        Config.Show("", Config.Lang["Locked"])
                    else
                        Config.Show("[E]", Config.Lang["Stash"])
                    end
                    TriggerServerEvent('Kibra:Motels:V2:Server:StashLock', MotelNo, RoomNo, not Room.StashLock)
                end
            end
        end
    end
end

OxInventoryMotelKey = function(data)
    local PlayerCoord = GetEntityCoords(PlayerPedId())
    for MotelNo, Motel in pairs(Config.Motels) do
        for RoomNo, Room in pairs(Motel.Rooms) do
            MotelId = MotelNo*1000
            Conclusion = RoomNo+MotelId
            local DoorDist = GetDistanceBetweenCoords(PlayerCoord, Room.DoorCoord, true)
            if DoorDist <= 2.0 then
                if not Motel.Teleport then
                    StateD = DoorSystemGetDoorState(0x100+Conclusion) == 0 and 1 or 0
                    if data.Password == Room.Password then
                        ChangeDoorStatus(StateD, Room, Conclusion)
                    else
                        Config.Notify(Config.Lang["Thiskeydoesnotbelongtothisthing"])
                    end
                else
                    if data.Password == Room.Password then
                        if not Room.DoorLock then
                            Config.Show("", Config.Lang["Locked"])
                        else
                            Config.Show("[E]", Config.Lang["EnterRoom"])
                        end
                        Animation()
                        TriggerServerEvent('Kibra:Motels:V2:Server:DoorLockTeleport', MotelNo, RoomNo, not Room.DoorLock)
                    else
                        Config.Notify(Config.Lang["Thiskeydoesnotbelongtothisthing"])
                    end
                end
            end
    
            local StashDist = GetDistanceBetweenCoords(PlayerCoord, Room.StashCoord, true)
            if StashDist <= 2.0 then
                if data.Password == Room.Password then
                    if not Room.StashLock then
                        Config.Show("", Config.Lang["Locked"])
                    else
                        Config.Show("[E]", Config.Lang["Stash"])
                    end
                    TriggerServerEvent('Kibra:Motels:V2:Server:StashLock', MotelNo, RoomNo, not Room.StashLock)
                end
            end
        end
    end
end

RegisterNetEvent('Kibra:Motels:V2:Client:DoorLockTeleport', function(MotelNo, MotelRoomId, State)
    Config.Motels[MotelNo].Rooms[MotelRoomId].DoorLock = State
end)

RegisterNetEvent('Kibra:Motels:V2:Client:StashLock', function(MotelNo, MotelRoomId, State)
    Config.Motels[MotelNo].Rooms[MotelRoomId].StashLock = State
end)

Citizen.CreateThread(function()
    while true do
        Sleep = 2000
        for k,v in pairs(Config.Motels) do
            for l,a in pairs(v.Rooms) do
                if #(GetEntityCoords(PlayerPedId()) - a.DoorCoord) <= 2.0 then
                    Sleep = 2
                    DrawMarker(2, a.DoorCoord.x, a.DoorCoord.y, a.DoorCoord.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 255, 0, 0, 0.7, false, false, false, 1, false, false, false)
                end
                if #(GetEntityCoords(PlayerPedId()) - a.Wardrobe) <= 1.0 then
                    Sleep = 2
                    DrawMarker(2, a.Wardrobe.x, a.Wardrobe.y, a.Wardrobe.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 255, 0, 0, 0.7, false, false, false, 1, false, false, false)
                end
                if v.Teleport then
                    if #(GetEntityCoords(PlayerPedId()) - a.StashCoord) <= 2.0 then
                        Sleep = 2
                        DrawMarker(2, a.StashCoord.x, a.StashCoord.y, a.StashCoord.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 255, 0, 0, 0.7, false, false, false, 1, false, false, false)
                    end
                    if #(GetEntityCoords(PlayerPedId()) - a.ExitCoord) <= 1.0 then
                        Sleep = 2
                        DrawMarker(2, a.ExitCoord.x, a.ExitCoord.y, a.ExitCoord.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, 255, 0, 0, 0.7, false, false, false, 1, false, false, false)
                    end
                end
            end
        end
        Citizen.Wait(Sleep)
    end
end)

RegisterNUICallback("DepositMoney", function(data)
    if data.Money ~= "" then
        Framework.TriggerServerCallback('Kibra:Motels:V2:Server:DepositMoney', function(x)
            if x then
                Config.Notify(Config.Lang["SuccessDeposited"])
                RefreshBossMenu()
            else
                Config.Notify(Config.Lang["YouDontEnoughCash"])
            end
        end, tonumber(data.MotelId), tonumber(data.Money))   
    else
        Config.Notify(Config.Lang["NotBlank"])
    end 
end)

RegisterNUICallback("RenameMotel", function(data)
    if data.mName ~= "" then
        Framework.TriggerServerCallback('Kibra:Motels:V2:Server:RenameMotel', function()
            Config.Notify(Config.Lang["SuccessMotelRename"])
            RefreshBossMenu()
        end, tonumber(data.MotelId), data.mName)   
    else
        Config.Notify(Config.Lang["NotBlank"])
    end 
end)

RegisterNUICallback("WithdrawMoney", function(data)
    if data.Money ~= "" then
        Framework.TriggerServerCallback('Kibra:Motels:V2:Server:WithdrawMoney', function(x)
            if x then
                Config.Notify(Config.Lang["SuccessWithdraw"])
                RefreshBossMenu()
            else
                Config.Notify(Config.Lang["EnoughCompanyMoney"])
            end
        end, tonumber(data.MotelId), tonumber(data.Money))   
    else
        Config.Notify(Config.Lang["NotBlank"])
    end 
end)

RegisterNUICallback("SellMotel", function(data)
    Framework.TriggerServerCallback('Kibra:Motels:V2:Server:SellMotel', function(x)
        if x then
            SendNUIMessage{type = "BossMenuClose"}
            Config.Notify(Config.Lang["SuccessMotelSell"])
        end
    end, tonumber(data.MotelId))
end)

RegisterCommand('opendoor', function()
    local PlayerCoord = GetEntityCoords(PlayerPedId())
    for MotelNo, Motel in pairs(Config.Motels) do
        for RoomNo, Room in pairs(Motel.Rooms) do
            MotelId = MotelNo*1000
            Conclusion = RoomNo+MotelId
            local DoorDist = GetDistanceBetweenCoords(PlayerCoord, Room.DoorCoord, true)
            if DoorDist <= 1.0 then
                if not Motel.Teleport then
                    StateD = DoorSystemGetDoorState(0x100+Conclusion) == 0 and 1 or 0
                    if not Config.PoliceRaid then
                        if Config.Motels[MotelNo].Owner == Framework.GetPlayerData().identifier then
                            ChangeDoorStatus(StateD, Room, Conclusion)
                        else
                            Config.Notify(Config.Lang["Youdonthaveaccess"])
                        end
                    else
                        if Config.Motels[MotelNo].Owner == Framework.GetPlayerData().identifier or Framework.GetPlayerData().job.name == Config.PoliceJob then
                            ChangeDoorStatus(StateD, Room, Conclusion)
                        else
                            Config.Notify(Config.Lang["Youdonthaveaccess"])
                        end
                    end
                end
            end
        end
    end
end)

RegisterKeyMapping('opendoor', 'Open Motel Door (only motel owner or police)', 'keyboard', Config.OpenDoorKey)

RegisterNUICallback("ChangeRoomRentPrice", function(data)
    if data.mRoomPrice ~= "" then
        if Config.MaximumRoomRentalPrice >= tonumber(data.mRoomPrice) then
            Framework.TriggerServerCallback('Kibra:Motels:V2:Server:UpdateRoomRentPrice', function(x)
                if x then
                    Config.Notify(Config.Lang["UpdateMotelPrice"])
                    RefreshBossMenu()
                end
            end, tonumber(data.MotelId), tonumber(data.mRoomPrice))  
        else
            Config.Notify(Config.Lang["MaxRoomPrice"]) 
        end
    else
        Config.Notify(Config.Lang["NotBlank"])
    end 
end)

RegisterNUICallback("TransferMotelOwnership", function(data)
    Player, Dist = Framework.Game.GetClosestPlayer()
    if Dist ~= -2 then
        cPlayer = GetPlayerServerId(Player)
        Framework.TriggerServerCallback('Kibra:Motels:V2:Server:TransferOwnerMotels', function(x)
            if x then
                Config.Notify(Config.Lang["SuccessOwnershipTransfer"])
            else
                Config.Notify(Config.Lang["Thereisnoonenearyou"])
            end
        end, tonumber(data.MotelId), cPlayer)
    else
        Config.Notify(Config.Lang["Thereisnoonenearyou"])
    end
end)

RegisterNUICallback("LeaveMotelRoom", function(datax)
    Framework.TriggerServerCallback('Kibra:Motels:V2:Server:LeaveMotelRoom', function(data)
        if data then
            SetNuiFocus(false, false)
            WebOpen = false
            TriggerScreenblurFadeOut(150)
            SendNUIMessage({type = "CloseMotel"})
            Config.Notify(Config.Lang["LeaveMotelRoom"])
        end
    end, datax.mid)
end)

RegisterNUICallback("xTargetKickMotel", function(data)
    Framework.TriggerServerCallback('Kibra:Motels:V2:Server:TargetKickMotelRoom', function(x)
        if x then
            Config.Notify(Config.Lang["SuccessKickMotelRoom"])
            RefreshBossMenu()
        end
    end, tonumber(data.MotelId), tonumber(data.RoomId))
end)

RegisterNUICallback("OpenBossMenu", function()
    CheckNearMotel()
    SendNUIMessage({
        type = "BossMenuOpen",
        bMotels = Config.Motels[mId],
        mid = mId,
        sellmoney = Config.Motels[mId].SalePrice/Config.MotelSalePriceRatio
    })
end)

RegisterNUICallback("CopyMotelKey", function(datax)
    Framework.TriggerServerCallback('Kibra:Motels:V2:Server:CopyMotelRoomKey', function(data)
        if data then
            SetNuiFocus(false, false)
            WebOpen = false
            TriggerScreenblurFadeOut(150)
            SendNUIMessage({type = "CloseMotel"})
            Config.Notify(Config.Lang["CopyMotelKey"])
        else
            Config.Notify(Config.Lang["Enoughtforkey"])
        end
    end, datax.mid)
end)

RegisterNUICallback("NewMotelKey", function(datax)
    Framework.TriggerServerCallback('Kibra:Motels:V2:Server:NewMotelRoomKey', function(data)
        if data then
            SetNuiFocus(false, false)
            WebOpen = false
            TriggerScreenblurFadeOut(150)
            SendNUIMessage({type = "CloseMotel"})
            Config.Notify(Config.Lang["CopyMotelKey"])
        else
            Config.Notify(Config.Lang["Enoughtforkey"])
        end
    end, datax.mid)
end)

Citizen.CreateThread(function()
    local alreadyEnteredZone = false
    local text = nil
    while true do
        wait = 5
        local ped = PlayerPedId()
        local inZone = false
        for k,v in pairs(Config.Motels) do
            local dist = #(GetEntityCoords(ped)-vector3(v.Reception.x, v.Reception.y, v.Reception.z))
            if dist <= 3.0 then
                wait = 5
                if not WebOpen then
                    inZone  = true
                    text = Config.UIControls.ReceptionText
                    DrawMarker(21, v.Reception.x, v.Reception.y, v.Reception.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.4, 0.4, 0.4, v.MarkerColor.r, v.MarkerColor.g, v.MarkerColor.b, v.MarkerColor.a, false, false, false, 1, false, false, false)
                    if IsControlJustReleased(0, Config.Controls.ReceptionOpenKey) then
                        WebOpen = true
                        OpenMotel(k)
                    end
                    break
                end
            else
                wait = 2
            end
        end
        
        if inZone and not alreadyEnteredZone then
            alreadyEnteredZone = true
            Config.Show(Config.UIControls.ReceptionOpenKey, text)
        end

        if not inZone and alreadyEnteredZone then
            alreadyEnteredZone = false
            Config.Hide()
        end
        Citizen.Wait(wait)
    end
end)

Citizen.CreateThread(function()
    local alreadyEnteredZone = false
    while true do
        wait = 5
        local ped = PlayerPedId()
        local inZone = false
        for k,v in pairs(Config.Motels) do
            if v.Teleport then
                for g,h in pairs(v.Rooms) do
                    local dist = #(GetEntityCoords(ped) - vector3(h.DoorCoord.x, h.DoorCoord.y, h.DoorCoord.z))
                    if dist <= 2.0 then wait = 5 inZone = true else wait = 2 end 
                    local dist2 = #(GetEntityCoords(ped) - vector3(h.StashCoord.x, h.StashCoord.y, h.StashCoord.z))
                    if dist2 <= 2.0 then wait = 5 inZone = true else wait = 2 end 
                    local dist3 = #(GetEntityCoords(ped) - vector3(h.ExitCoord.x, h.ExitCoord.y, h.ExitCoord.z))
                    if dist3 <= 1.0 then 
                        wait = 5 
                        inZone = true 
                    else 
                        wait = 2 
                    end 
                end
            else
                for j,m in pairs(v.Rooms) do
                    local dist = #(GetEntityCoords(ped) - vector3(m.StashCoord.x, m.StashCoord.y, m.StashCoord.z))
                    if dist <= 2.0 then wait = 5 inZone = true else wait = 2 end 
                end
            end
        end
        if inZone and not alreadyEnteredZone then
            alreadyEnteredZone = true
        end
        if not inZone and alreadyEnteredZone then
            alreadyEnteredZone = false
            Config.Hide()
        end
        Citizen.Wait(wait)
    end
end)

Citizen.CreateThread(function()
    local alreadyEnteredZone = false
    while true do
        wait = 5
        local ped = PlayerPedId()
        local inZone = false
        for k,v in pairs(Config.Motels) do
            if v.Teleport then
                for g,h in pairs(v.Rooms) do
                    local dist = #(GetEntityCoords(ped) - vector3(h.ExitCoord.x, h.ExitCoord.y, h.ExitCoord.z)) 
                    if dist <= 1.0 then
                        wait = 5 
                        inZone = true 
                    end
                end
            end
        end
        if inZone and not alreadyEnteredZone then
            alreadyEnteredZone = true
            Config.Show(Config.UIControls.ExitOpenKey, Config.UIControls.ExitText)
        end
        if not inZone and alreadyEnteredZone then
            alreadyEnteredZone = false
            Config.Hide()
        end
        Citizen.Wait(wait)
    end
end)

Citizen.CreateThread(function()
    local alreadyEnteredZone = false
    while true do
        wait = 5
        local ped = PlayerPedId()
        local inZone = false
        for k,v in pairs(Config.Motels) do
            for g,h in pairs(v.Rooms) do
                local dist = #(GetEntityCoords(ped) - vector3(h.Wardrobe.x, h.Wardrobe.y, h.Wardrobe.z)) 
                if dist <= 1.0 then
                    wait = 5 
                    inZone = true 
                end
            end
        end
        if inZone and not alreadyEnteredZone then
            alreadyEnteredZone = true
            Config.Show(Config.UIControls.WardrobeOpenKey, Config.UIControls.WardrobeText)
        end
        if not inZone and alreadyEnteredZone then
            alreadyEnteredZone = false
            Config.Hide()
        end
        Citizen.Wait(wait)
    end
end)

Citizen.CreateThread(function()
    while true do
        local Sleep = 2000
        for k,v in pairs(Config.Motels) do
            for y,f in pairs(v.Rooms) do
                Dist = #(GetEntityCoords(PlayerPedId()) - f.DoorCoord)
                Dist2 = #(GetEntityCoords(PlayerPedId()) - f.StashCoord)
                Dist4 = #(GetEntityCoords(PlayerPedId()) - f.Wardrobe)
                if v.Teleport then
                    Dist3 = #(GetEntityCoords(PlayerPedId()) - f.ExitCoord)
                    if Dist <= 2.0 then
                        Sleep = 2
                        if IsControlJustPressed(0, 38) then
                            if not f.DoorLock then
                                EnterMotelRoom(k,y)
                            end
                        end
                    end
                    if Dist3 <= 2.0 then
                        Sleep = 2
                        if IsControlJustPressed(0, 38) then
                            ExitMotelRoom(k, y)
                        end
                    end
                end
                if Dist2 <= 1.0 then
                    Sleep = 2
                    if IsControlJustPressed(0, 38) then
                        if not f.StashLock then
                            Config.OpenMotelInventory(k,y)
                        end
                    end
                end
                if Dist4 <= 1.0 then
                    Sleep = 2
                    if IsControlJustPressed(0, 38) then
                        Config.OpenWardrobe()
                    end
                end
            end
        end
        Citizen.Wait(Sleep)
    end
end)


RegisterCommand(Config.UIFixCommand, function()
    Config.Hide()    
    SendNUIMessage{type = "BossMenuClose"}
    SendNUIMessage{type = "CloseModal"}
    SendNUIMessage{type = "CloseMotel"}
end)

RegisterNUICallback("CloseMotel", function()
    SetNuiFocus(false, false)
    WebOpen = false
    TriggerScreenblurFadeOut(150)
end)

RegisterNUICallback("BuyMotel", function(data)
    Framework.TriggerServerCallback('Kibra:Motels:V2:Server:BuyBusinessMotel', function(x)
        if x == 1 then
            Config.Notify(Config.Lang["SuccessBuyMotel"])
        elseif x == 2 then
            Config.Notify(Config.Lang["Enoughtforbuymotel"])
        elseif x == 3 then
            Config.Notify(Config.Lang["OtherOwner"])
        end
        SendNUIMessage({type = "CloseModal"})
        SetNuiFocus(false, false)
        WebOpen = false
        TriggerScreenblurFadeOut(150)
        SendNUIMessage({type = "CloseMotel"})
    end, tonumber(data.mid))
end)

RegisterNUICallback("MyMotelRooms", function()
    Framework.TriggerServerCallback('Kibra:Motels:V2:Server:PlayerMotels', function(data)
        SendNUIMessage({
            type = "ReloadMyMotelRooms",
            data = data
        })
    end)
end)

RegisterNUICallback("BuyMotelRoom", function(data)
    local RoomId = data.mid..'_'..data.rid
    Framework.TriggerServerCallback('Kibra:Motels:V2:Server:BuyMotelRoom', function(x)
        if x == 1 then
            SetNuiFocus(false, false)
            WebOpen = false
            TriggerScreenblurFadeOut(150)
            SendNUIMessage({type = "CloseMotel"})
        end
    end, RoomId)
end)

RegisterNetEvent('Kibra:Motels:V2:Client:CloseWeb', function()
    SetNuiFocus(false, false)
    WebOpen = false
    TriggerScreenblurFadeOut(150)
    SendNUIMessage({type = "CloseMotel"})
end)

RegisterNetEvent('Kibra:Motels:V2:Client:ChangeDoorStatusEveryone', function(Room, State, No)
    DoorSystemSetDoorState(No, State.State, 0 ,1)
	SetStateOfClosestDoorOfType(No, Room.DoorCoord, 1, 0.0, true)
end)

RegisterNUICallback("LoadAllRooms", function()
    CheckNearMotel()
    SendNUIMessage({
        type = "MotelDataLoad",
        Motel = Config.Motels[mId]
    })
end)

RegisterCommand(Config.ShowRoomNo, function()
    if isText == false then
        isText = true
    elseif isText == true then
        isText = false
    end
end)

local Blips = {}

function ClearBlips()
    for k,v in pairs(Blips) do
        RemoveBlip(v)
    end
end

function CreateMotelBlips()
    for k,v in pairs(Config.Motels) do
        local blip = AddBlipForCoord(v.MotelCenterCoord)
        SetBlipSprite(blip, v.Blip.BlipId)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, v.Blip.Scale)
        SetBlipColour(blip, v.Blip.Color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(v.MotelName)
        EndTextCommandSetBlipName(blip)
        table.insert(Blips, blip)
    end
end

Citizen.CreateThread(function()
    while true do
        local Sleep = 2000
        for k,v in pairs(Config.Motels) do
            for m,b in pairs(v.Rooms) do
                if #(GetEntityCoords(PlayerPedId()) - v.MotelCenterCoord) <= 15.0 then
                    Sleep = 5
                    if isText then DrawText3D(b.DoorCoord.x, b.DoorCoord.y, b.DoorCoord.z, m) end
                end
            end
        end
        Citizen.Wait(Sleep)
    end
end)

ExitMotelRoom = function(mid, rid)
    local player = PlayerPedId()
    DoScreenFadeOut(500)
    Wait(1500)
    SetEntityCoords(player, Config.Motels[CurrentMotel].Rooms[CurrentRoom].DoorCoord.x, Config.Motels[CurrentMotel].Rooms[CurrentRoom].DoorCoord.y, Config.Motels[CurrentMotel].Rooms[CurrentRoom].DoorCoord.z-1)
    Wait(500)
    TriggerServerEvent('Kibra:Motels:V2:Server:Outbucket')
    PlayerInMotelRoom = false
    CurrentMotel = 0
    CurrentRoom = 0
    DoScreenFadeIn(1000)
end

EnterMotelRoom = function(mid, rid)
    local player = PlayerPedId()
    DoScreenFadeOut(500)
    CurrentMotel = mid
    CurrentRoom = rid
    Wait(600)
    FreezeEntityPosition(player, true)
    SetEntityCoords(player, Config.Motels[mid].EnterRoomCoord.x, Config.Motels[mid].EnterRoomCoord.y, Config.Motels[mid].EnterRoomCoord.z-1.0)
    SetEntityHeading(player, Config.Motels[mid].EnterRoomCoord.w)
    Wait(1400)
    TriggerServerEvent("Kibra:Motels:V2:Server:SetBucket", mid, rid)
    DoScreenFadeIn(1000)
    FreezeEntityPosition(player, false)
    PlayerInMotelRoom = true
end

DrawText3D = function(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

CheckNearMotel = function()
    for k,v in pairs(Config.Motels) do
        if #(GetEntityCoords(PlayerPedId()) - v.Reception) <= 2.0 then
            mId = k
        end
    end
end

OpenMotel = function(k)
    TriggerScreenblurFadeIn(150)
    SetNuiFocus(true, true)
    TriggerServerEvent('Kibra:Motels:V2:Server:UploadMotels')
    Framework.TriggerServerCallback('Kibra:Motels:V2:Server:PlayerMotels', function(data) 
         SendNUIMessage(
            {
                type = "OpenMotel",
                Motel = Config.Motels[k],
                id = k,
                pMotels = data,
                pCid = Framework.GetIdentifier(),
                mRooms = #Config.Motels[k].Rooms,
            }
        )
    end)
end

CheckPlayerMotelOwner = function()
    for k,v in pairs(Config.Motels) do
        if Config.Motels[k].Owner == Framework.GetPlayerData().identifier then 
            return k
        else
            return false
        end
    end
end

RefreshBossMenu = function()
    CheckNearMotel()
    SendNUIMessage({
        type = "BossMenuOpen",
        bMotels = Config.Motels[mId],
        mid = mId,
        sellmoney = Config.Motels[mId].SalePrice/Config.MotelSalePriceRatio
    })
end

Animation = function()
    loadAnimDict("anim@heists@keycard@")
    TaskPlayAnim(PlayerPedId(), "anim@heists@keycard@", "exit", 5.0, 1.0, -1, 16, 0, 0, 0, 0 )
    Wait(400)
    ClearPedTasks(PlayerPedId())
end

ChangeDoorStatus = function(x, room, conclusion)
    if x == 1 then
        Config.Notify(Config.Lang["YouLockedDoor"])
    else
        Config.Notify(Config.Lang["UnlockedDoor"])
    end
    Animation()
    TriggerServerEvent('Kibra:Motels:V2:Server:ChangeMotelDoorStatus', room, x, 0x100+conclusion)
end

function loadAnimDict(dict)
    while (not HasAnimDictLoaded(dict)) do
        RequestAnimDict(dict)
        Wait(5)
    end
end
