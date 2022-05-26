local QBCore = exports['qb-core']:GetCoreObject()
local Cooldown = false
MarkedMin = 25000
MarkedMax = 50000

RegisterServerEvent("gc-bobcatheist:successthermite") 
AddEventHandler("gc-bobcatheist:successthermite", function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['thermite'], 'remove')
    player.Functions.RemoveItem("thermite", 1)
end)

RegisterServerEvent('gc-bobcatheist:server:cooldown')
AddEventHandler('gc-bobcatheist:server:cooldown', function()
    Cooldown = true
    local timer = 60000 * 60000
    while timer > 0 do
        Wait(1000)
        timer = timer - 1000
        if timer == 0 then
            Cooldown = false
        end
    end
end)

QBCore.Functions.CreateCallback("gc-bobcatheist:Cooldown", function(source, cb)
    if Cooldown then
        cb(true)
    else
        cb(false)
    end
end)

QBCore.Functions.CreateCallback('gc-bobcatheist:server:getCops', function(source, cb)
    local amount = 0
    for k, v in pairs(QBCore.Functions.GetQBPlayers()) do
        if v.PlayerData.job.name == 'police' then
            amount = amount + 1
        end
    end
    cb(amount)
end)


RegisterServerEvent('gc-bobcatheist:server:ThermitePtfx', function(coords)
    TriggerClientEvent('gc-bobcatheist:client:ThermitePtfx', -1, coords)
end)

RegisterServerEvent("gc-bobcatheist:success") 
AddEventHandler("gc-bobcatheist:success", function()
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['laptop_green'], 'remove')
    player.Functions.RemoveItem("laptop_green", 1)
end)

RegisterNetEvent('gc-bobcatheist:server:CartItem', function(type)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local bags = math.random(1, 3)
    local info = {
        worth = math.random(MarkedMin, MarkedMax)
    }
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['markedbills'], "add")
    player.Functions.AddItem('markedbills', 5, false, info)
end)

RegisterNetEvent('gc-bobcatheist:server:LockerItem', function(type)
    local src = source
    local player = QBCore.Functions.GetPlayer(src)
    local bags = math.random(2, 4)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['weapon_combatmg'], "add")
    player.Functions.AddItem('weapon_combatmg', bags, false)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['mg_ammo'], "add")
    player.Functions.AddItem('mg_ammo', 10, false)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['weapon_assaultrifle'], "add")
    player.Functions.AddItem('weapon_assaultrifle', bags, false)
    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items['rifle_ammo'], "add")
    player.Functions.AddItem('rifle_ammo', 10, false)
end)

RegisterNetEvent('sync', function(status)
    if status == true then
        return
    elseif status == false then
        TriggerClientEvent('bomb-anim')
    end
end)