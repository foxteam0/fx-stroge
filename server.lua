local QBCore = exports['qb-core']:GetCoreObject()
local DoorData = {}
local DoorState = {}

QBCore.Functions.CreateCallback('l3code:server:DoorDataLoad', function(source, cb)
    cb(DoorState)
end)

RegisterNetEvent('l3code:Server:ChangeMotelDoorStatus', function(State, No, doorcord, i)
   
    DoorState = { State = State }
    TriggerClientEvent("l3code:Client:ChangeDoorStatusEveryone", -1, State, No, doorcord)
end)

Citizen.CreateThread(function()
    for i, v in pairs(Config.Garage) do
        MySQL.Async.fetchAll('SELECT * FROM `fx-storge` WHERE id = @id', { ['@id'] = i }, function(result)
            if not result or #result == 0 then
                MySQL.Async.execute('INSERT INTO `fx-storge` SET id = ?', { i })
            end
        end)
    end
end)

QBCore.Functions.CreateCallback('l3code:server:doordataload', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)

    MySQL.Async.fetchAll('SELECT * FROM `fx-storge` WHERE owner = @owner', { ['@owner'] = Player.PlayerData.citizenid }, function(result)
        DoorData[Player.PlayerData.citizenid] = result[1] or nil
        cb(DoorData)
    end)
end)

QBCore.Functions.CreateCallback('l3code:server:getgarageuse', function(source, cb)
    local NotUseGarage = {}

    MySQL.Async.fetchAll('SELECT * FROM `fx-storge`', {}, function(result)
        for i, v in pairs(result) do
            NotUseGarage[i] = v.owner == nil
        end
        cb(NotUseGarage)
    end)
end)

RegisterServerEvent('removemoneymens')
AddEventHandler('removemoneymens', function(price)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    Player.Functions.RemoveMoney('cash', price, "buy-storage")
end)

RegisterNetEvent("l3code:server:buygarage", function(id)
    local Player = QBCore.Functions.GetPlayer(source)
    local cash = Player.PlayerData.money["cash"]
    local bank = Player.PlayerData.money["bank"]

    if cash >= 300 then
        local durum = Player.Functions.RemoveMoney("cash", 300)
        if durum then
            TriggerEvent("l3code:event:buygarages", source, id)
        else
            TriggerClientEvent("QBCore:Notify", source, "Bi Sorun Oluştu", "error", 2500)
        end
    else
        if bank >= 300 then
            local durum = Player.Functions.RemoveMoney("bank", 300)
            if durum then
                TriggerEvent("l3code:event:buygarages", source, id)
            else
                TriggerClientEvent("QBCore:Notify", source, "Bi Sorun Oluştu", "error", 2500)
            end
        else
            TriggerClientEvent("QBCore:Notify", source, "Yeterince Paran Yok", "error", 2500)
        end
    end
end)


RegisterNetEvent("l3code:event:buygarages", function(source, id)
    local Player = QBCore.Functions.GetPlayer(source)

    MySQL.Async.execute('UPDATE `fx-storge` SET owner = ?  WHERE id = ?', {Player.PlayerData.citizenid, id}, function(rowsChanged)
        if rowsChanged > 0 then
            MySQL.Async.fetchAll('SELECT * FROM `fx-storge` WHERE owner = ?', {Player.PlayerData.citizenid}, function(result)
                if #result == 0 then
                    DoorData[Player.PlayerData.citizenid] = nil
                else
                    DoorData[Player.PlayerData.citizenid] = {}
                    DoorData[Player.PlayerData.citizenid].owner = result[1].owner
                    DoorData[Player.PlayerData.citizenid].id = result[1].id
                end
                TriggerClientEvent("l3code:client:sync:doordata", source, DoorData)
            end)
            Citizen.Wait(100)
            TriggerClientEvent("l3code:client:buygarageped", source)
        else
            print("Garaj satın alma işlemi başarısız oldu.")
        end
    end)
end)



RegisterNetEvent("l3code:server:sellgarage",function(id)
    local source = source
    local Player = QBCore.Functions.GetPlayer(source)
    local id = DoorData[Player.PlayerData.citizenid].id
   
    TriggerEvent('l3code:Server:ChangeMotelDoorStatus', 1, 0x100+id,  Config.Garage[id].doorcoord)


    local durum = Player.Functions.AddMoney("cash", 300) 

    MySQL.Async.execute('UPDATE `fx-storge` SET owner = ?  WHERE id = ?', {nil,id})

    Citizen.Wait(100)

    MySQL.Async.fetchAll('SELECT * FROM `fx-storge` WHERE owner = @owner ', {['@owner'] = Player.PlayerData.citizenid}, function(result)
        if #result == 0 then
            DoorData[Player.PlayerData.citizenid] = nil
        else
            DoorData[Player.PlayerData.citizenid] = {}
            DoorData[Player.PlayerData.citizenid].owner = result[1].owner
            DoorData[Player.PlayerData.citizenid].id = result[1].id
        end
        TriggerClientEvent("l3code:client:sync:doordata",source,DoorData)
        
    end)
    Citizen.Wait(100)
    TriggerClientEvent("l3code:client:sellgarageped",source)
   
end)

