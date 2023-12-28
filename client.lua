local QBCore = exports['qb-core']:GetCoreObject()
local DoorData = {}

Citizen.CreateThread(function() 
    for k,v in pairs(Config.Peds) do
        RequestModel(GetHashKey(v.pedModel)) 
        while not HasModelLoaded(GetHashKey(v.pedModel)) do 
            Wait(1)
        end
        local npc = CreatePed(1, GetHashKey(v.pedModel), v.pedCoords.x, v.pedCoords.y, v.pedCoords.z,  v.heading, false, true)
        SetPedCombatAttributes(npc, 46, true)               
        SetPedFleeAttributes(npc, 0, 0)               
        SetBlockingOfNonTemporaryEvents(npc, true)
        SetEntityAsMissionEntity(npc, true, true)
        SetEntityInvincible(npc, true)
        FreezeEntityPosition(npc, true)
    end
end)

Citizen.CreateThread(function()
    QBCore.Functions.TriggerCallback('l3code:server:DoorDataLoad', function(DoorState)
        for i,v in pairs(Config.Garage) do 
            if not IsDoorRegisteredWithSystem(0x100+i) then
                AddDoorToSystem(0x100+i, v.DoorHash, v.doorcoord, true, true, true)
                local StateDoor = DoorState[i] and DoorState[i].State or (v.AutoLock and 1 or 0)
                DoorSystemSetDoorState(0x100+i, StateDoor, 0, 1)
                SetStateOfClosestDoorOfType(0x100+i, v.doorcoord, 1, 0.0, true)
            end
        end
    end)
    TriggerEvent("l3code:start:textmarker")
end)

function DrawText3D(x, y, z, text)
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

RegisterNetEvent("l3code:start:textmarker",function()
    while true do
        local sleepTime = 500
        local playerCoord = GetEntityCoords(PlayerPedId())
        local PlayerData = QBCore.Functions.GetPlayerData()
        for i,v in pairs(Config.Garage) do
            if DoorData[PlayerData.citizenid] ~= nil then 
                if DoorData[PlayerData.citizenid].id == i then 
                    if #(playerCoord - v.doorcoord) <= 5.0 then
                        sleepTime = 1
                        DrawMarker(2, v.doorcoord.x, v.doorcoord.y, v.doorcoord.z , 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.2, 0.2, 0.2, 255, 255, 255, 255, true, true, 2, nil, nil, false)
                        local StateDoor = DoorSystemGetDoorState(0x100+i) == 0 and 1 or 0
                        if(#(playerCoord - v.doorcoord) <= 1) then 
                            if(StateDoor == 1) then 
                                DrawText3D(v.doorcoord.x, v.doorcoord.y, v.doorcoord.z + 0.3 ," ~g~["..tonumber(i).. "] ~w~ Kiliti Açık")
                            else
                                DrawText3D(v.doorcoord.x, v.doorcoord.y, v.doorcoord.z + 0.3 ," ~g~["..tonumber(i).. "] ~w~ Kilitli")
                            end
                            if IsControlJustReleased(0, 38) then
                                ChangeDoorStatus(StateDoor, i, v.doorcoord, DoorData[PlayerData.citizenid].id)
                            end
                        end  
                    end
                end
            end
        end
        Citizen.Wait(sleepTime)
    end
end)

function ChangeDoorStatus(x, conclusion, doorcord, i)
    if x == 1 then
        QBCore.Functions.Notify("Kapı Kilitlendi", "success")
    else
        QBCore.Functions.Notify("Kapı Kilidi Açıldı", "success")
    end
    TriggerServerEvent('l3code:Server:ChangeMotelDoorStatus', x, 0x100+conclusion, doorcord, i)
end

RegisterNetEvent('l3code:Client:ChangeDoorStatusEveryone', function(State, No, doorcord)
    DoorSystemSetDoorState(No, State, 0, 1)
    SetStateOfClosestDoorOfType(No, doorcord, 1, 0.0, true)
end)

RegisterNetEvent('l3code:client:sync:doordata', function(data)
    DoorData = data
end)





RegisterNetEvent('shop:open', function()
    local  menu = {}


    menu[#menu+1] = {
        header = "Garaj Yönetimi",
        isMenuHeader = true,
    }

    local PlayerData = QBCore.Functions.GetPlayerData()
    if DoorData[PlayerData.citizenid] == nil  then
        menu[#menu+1] = {
            header = 'Garaj Numaraları',
            txt = 'Bas Ve Garaj Satın Al',
            icon = 'fas fa-code-merge',
            params = {
                event = 'l3code:shop:garages',
                args = {}
            }
        }
    else
  
        menu[#menu+1] = {
            header = 'Garajı Sat',
            txt = 'Bastınğın Zaman Garajı Satar',
            icon = 'fas fa-code-merge',
            params = {
                event = 'l3code:shop:sellgaragesoru',
                args = {id = DoorData[PlayerData.citizenid].id}
        }
     }
    end

    exports['qb-menu']:openMenu(menu)
end)



RegisterNetEvent("l3code:shop:sellgaragesoru", function(data)
    local id = data.id
    local  menu = {}

    menu[#menu+1] = {
        header = "Garajı Satmak İstiyormusun",
        isMenuHeader = true,
    }

    menu[#menu+1] = {
            header = "Evet",
            icon = 'fas fa-code-merge',
            params = {
                event = 'l3code:shop:sellgarage',
                args = {
                    id = id
                }
                }
    }

    menu[#menu+1] = {
        header = "Hayır",
        icon = 'fas fa-code-merge',
        params = {
            event = 'qb-menu:client:closeMenu',
            }
    }
    exports['qb-menu']:openMenu(menu)
end)

RegisterNetEvent("l3code:shop:sellgarage",function(data)
    local id = data.id
    TriggerServerEvent("l3code:server:sellgarage",id)

end)


RegisterNetEvent("l3code:shop:garages",function()
   
   
    QBCore.Functions.TriggerCallback('l3code:server:getgarageuse', function(result)
        local  menu = {}
        menu[#menu+1] = {
            header = "Garajlar",
            isMenuHeader = true,
        }
        local data = result
        for i , v in pairs(data) do
           if( v == true )then 
            menu[#menu+1] = {
                header = 'Garaj ['..i .. "]",
                txt = 'Satın Almak İçin Tıkla',
                icon = 'fas fa-code-merge',
                params = {
                    event = 'l3code:shop:buygaragesoru',
                    args = {
                        id = i
                    }
                    }
                }

           end
        end
        exports['qb-menu']:openMenu(menu)
    end)
end)

RegisterNetEvent("l3code:shop:buygaragesoru", function(data)
    local id = data.id
    local  menu = {}

    menu[#menu+1] = {
        header = "Satın Almak İstiyormusun",
        isMenuHeader = true,
    }

    menu[#menu+1] = {
            header = "Evet",
            icon = 'fas fa-code-merge',
            params = {
                event = 'l3code:shop:buygarage',
                args = {
                    id = id
                }
                }
    }

    menu[#menu+1] = {
        header = "Hayır",
        icon = 'fas fa-code-merge',
        params = {
            event = 'qb-menu:client:closeMenu',
            }
    }
    exports['qb-menu']:openMenu(menu)
end)

RegisterNetEvent("l3code:shop:buygarage",function(data)
    local id = data.id
    TriggerServerEvent("l3code:server:buygarage",id)

end)

local garageNPC 

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    QBCore.Functions.TriggerCallback('l3code:server:doordataload', function(result)
        DoorData = result  
        local PlayerData = QBCore.Functions.GetPlayerData()
        if DoorData[PlayerData.citizenid] ~= nil  then
            local pedPos = Config.Garagepeds[DoorData[PlayerData.citizenid].id].pos
            local pedModel = Config.Garagepeds[DoorData[PlayerData.citizenid].id].model
            garageNPC = _CreatePed(pedModel,pedPos)
        end
       
        TriggerEvent("l3code:client:addboxzoneped")
    
        
    end)
end)



RegisterNetEvent("l3code:client:buygarageped",function()
   
    local PlayerData = QBCore.Functions.GetPlayerData()
    if DoorData[PlayerData.citizenid] ~= nil  then
        local pedPos = Config.Garagepeds[DoorData[PlayerData.citizenid].id].pos
        local pedModel = Config.Garagepeds[DoorData[PlayerData.citizenid].id].model
        garageNPC = _CreatePed(pedModel,pedPos)
    end

end)

RegisterNetEvent("l3code:client:sellgarageped",function()
    if(DoesEntityExist(garageNPC))then 
        DeleteEntity(garageNPC)
    end
end)


function _CreatePed(model,coords)
    RequestModel(GetHashKey(model)) 
    while not HasModelLoaded(GetHashKey(model)) do 
        Wait(1)
    end
    npc = CreatePed(1, GetHashKey(model), coords.x, coords.y, coords.z,coords.w, true, true)
    SetPedCombatAttributes(npc, 46, true)               
    SetPedFleeAttributes(npc, 0, 0)               
    SetBlockingOfNonTemporaryEvents(npc, true)
    SetEntityAsMissionEntity(npc, true, true)
    SetEntityInvincible(npc, true)
    FreezeEntityPosition(npc, true)
    return npc
end


RegisterNetEvent('garagemenu', function(data)
    local PlayerData = QBCore.Functions.GetPlayerData()
    local menu = {}
    local id = DoorData[PlayerData.citizenid].id
    menu[#menu + 1] = {
        header = "Garage Menu Welcome",
        isMenuHeader = true,
    }

    
    menu[#menu + 1] = {
        header = "Storage",
        icon = 'fas fa-code-merge',
        params = {
            event = 'garagestash',
            args = { id = id }
        }
    }
    
    exports['qb-menu']:openMenu(menu)
end)

stashData = {
    private = true, 

}


RegisterNetEvent('garagestash', function(data)
    local privateStash = nil
    local PlayerData = QBCore.Functions.GetPlayerData()

    privateStash = data.id
    TriggerServerEvent("inventory:server:OpenInventory", "stash", 'stash'..privateStash, {
        maxweight = Config.StashMaxWeight,
        slots = Config.StashSlots,
    })
    TriggerEvent("inventory:client:SetCurrentStash",'stash'..privateStash)

end)


local showingGarages = false
local showDuration = 5 * 1000

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)

        if showingGarages then
            for i, v in pairs(Config.Garage) do
                DrawText3D(v.doorcoord.x, v.doorcoord.y, v.doorcoord.z + 0.3, "Garage " .. i)
            end
        end
    end
end)

RegisterCommand('allgarages', function()
    if not showingGarages then
        showingGarages = true
        Citizen.CreateThread(function()
            Citizen.Wait(showDuration)
            for i, v in pairs(Config.Garage) do
                if v.doorcoord then
                    DrawText3D(v.doorcoord.x, v.doorcoord.y, v.doorcoord.z + 0.3, "")
                end
            end
            showingGarages = false
        end)
    end
end, false)


