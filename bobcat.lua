local QBCore = exports['qb-core']:GetCoreObject()

Config = Config or {}
local isBusy = false
local cops = 0
local locker = false

RegisterNetEvent('QBCore:Client:OnPlayerUnload')
AddEventHandler('QBCore:Client:OnPlayerUnload', function()
    isLoggedIn = false
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    isLoggedIn = true
end)

RegisterNetEvent('qb-police:CopCount', function()
    cops = amount
end)

local function Alert()
    exports['ps-dispatch']:BobcatRobbery()
end

local function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(5)
    end
end

RegisterNetEvent('updatebobcat2', function()
    local interiorid = GetInteriorAtCoords(883.4142, -2282.372, 31.44168)
	ActivateInteriorEntitySet(interiorid, "np_prolog_broken")
	RemoveIpl(interiorid, "np_prolog_broken")
	DeactivateInteriorEntitySet(interiorid, "np_prolog_clean")
	RefreshInterior(interiorid)
end)

function Carts()
    local model = "ch_prop_cash_low_trolly_01c"
    RequestModel(model)
    while not HasModelLoaded(model) do RequestModel(model) Wait(100) end
    ClearAreaOfObjects(989.14, 50.54, 10, 0)
    for i = 1, 4 do
        local obj = GetClosestObjectOfType(Config.Trolleys[i].coords, 3.0, `ch_prop_cash_low_trolly_01c`, false, false, false)
        if obj ~= 0 then
            DeleteObject(obj)
            Wait(1)
        end
        CreateObject(model, Config.Trolleys[i].coords, true, true, false)
        exports['qb-target']:AddBoxZone("cashcarts"..i, vector3(Config.Trolleys[i].coords), 1, 1, {
            name = "cashcarts"..i,
            heading = Config.Trolleys[i].h,
            debugPoly = false,
            minZ = Config.Trolleys[i].coords.z,
            maxZ = Config.Trolleys[i].coords.z + 1.2,
        }, {
            options = {
                {
                    type = "client",
                    event = "gc-bobcatheist:client:CashGrab",
                    icon = "fas fa-hand",
                    label = "Grab Cash",
                },
            },
            distance = 1.5
        })
    end
end

function ThermitePlanting()
    RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
    RequestModel("hei_p_m_bag_var22_arm_s")
    RequestNamedPtfxAsset("scr_ornate_heist")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") and not HasModelLoaded("hei_p_m_bag_var22_arm_s") and not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
        Citizen.Wait(50)
    end

    local ped = PlayerPedId()
    SetEntityHeading(ped, 179.93)
    local pos = vector3(882.3, -2258.27, 32.46)
    Citizen.Wait(100)
    local rotx, roty, rotz = table.unpack(vec3(GetEntityRotation(ped)))
    local bagscene = NetworkCreateSynchronisedScene(pos.x, pos.y, pos.z, rotx, roty, rotz, 2, false, false, 1065353216, 0, 1.3)
    local bag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), pos.x, pos.y, pos.z,  true,  true, false)
    SetEntityCollision(bag, false, true)

    local x, y, z = table.unpack(GetEntityCoords(ped))
    local thermite = CreateObject(GetHashKey("hei_prop_heist_thermite"), x, y, z + 0.2,  true,  true, true)
    SetEntityCollision(thermite, false, true)
    AttachEntityToEntity(thermite, ped, GetPedBoneIndex(ped, 28422), 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
    
    NetworkAddPedToSynchronisedScene(ped, bagscene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, bagscene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)
    SetPedComponentVariation(ped, 5, 0, 0, 0)
    NetworkStartSynchronisedScene(bagscene)
    Citizen.Wait(5000)
    DetachEntity(thermite, 1, 1)
    FreezeEntityPosition(thermite, true)
    DeleteObject(bag)
    NetworkStopSynchronisedScene(bagscene)
    Citizen.CreateThread(function()
        Citizen.Wait(15000)
        DeleteEntity(thermite)
    end)
end

function ThermiteEffect()
   RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") do
        Citizen.Wait(50)
    end
    local ped = PlayerPedId()
    Citizen.Wait(1500)
    TriggerServerEvent("gc-bobcatheist:server:ThermitePtfx", ptfx)
    Citizen.Wait(500)
    TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_intro", 8.0, 8.0, 1000, 36, 1, 0, 0, 0)
    TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 8.0, 8.0, 3000, 49, 1, 0, 0, 0)
    local ptfx

    RequestNamedPtfxAsset("scr_ornate_heist")
    while not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
        Citizen.Wait(1)
    end
        ptfx = vector3(882.1320, -2257.27, 32.461)
    SetPtfxAssetNextCall("scr_ornate_heist")
    local effect = StartParticleFxLoopedAtCoord("scr_heist_ornate_thermal_burn", ptfx, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    Citizen.Wait(4000)
    StopParticleFxLooped(effect, 0)
    ClearPedTasks(ped)
    Citizen.Wait(2000)
    QBCore.Functions.Notify("The lock had been melted", "success")
    TriggerServerEvent('qb-doorlock:server:updateState', Config.Door1, false)
end

RegisterNetEvent('gc-bobcatheist:client:CashGrab', function()
    TriggerEvent('gc-bobcatheist:client:Closest', closestTrolley)
    local ped = PlayerPedId()
    local model = "hei_prop_heist_cash_pile"
    Trolley = GetClosestObjectOfType(GetEntityCoords(ped), 1.0, `ch_prop_cash_low_trolly_01c`, false, false, false)
    local CashAppear = function()
	    local pedCoords = GetEntityCoords(ped)
        local grabmodel = GetHashKey(model)
        RequestModel(grabmodel)
        while not HasModelLoaded(grabmodel) do
            Wait(100)
        end
	    local grabobj = CreateObject(grabmodel, pedCoords, true)
	    FreezeEntityPosition(grabobj, true)
	    SetEntityInvincible(grabobj, true)
	    SetEntityNoCollisionEntity(grabobj, ped)
	    SetEntityVisible(grabobj, false, false)
	    AttachEntityToEntity(grabobj, ped, GetPedBoneIndex(ped, 60309), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, false, false, false, false, 0, true)
	    local startedGrabbing = GetGameTimer()
	    Citizen.CreateThread(function()
		    while GetGameTimer() - startedGrabbing < 37000 do
			    Wait(1)
			    DisableControlAction(0, 73, true)
			    if HasAnimEventFired(ped, `CASH_APPEAR`) then
				    if not IsEntityVisible(grabobj) then
					    SetEntityVisible(grabobj, true, false)
				    end
			    end
			    if HasAnimEventFired(ped, `RELEASE_CASH_DESTROY`) then
				    if IsEntityVisible(grabobj) then
                        SetEntityVisible(grabobj, false, false)
				    end
			    end
		    end
		    DeleteObject(grabobj)
	    end)
    end
	local trollyobj = Trolley
    local emptyobj = `hei_prop_hei_cash_trolly_03`

	if IsEntityPlayingAnim(trollyobj, "anim@heists@ornate_bank@grab_cash", "cart_cash_dissapear", 3) then
		return
    end

    print(GetEntityHeading(trollyobj))
    local rot = GetEntityHeading(trollyobj)
    local targetPosition = GetEntityCoords(trollyobj)
    local targetRotation = vector3(0.0, 0.0, rot)
    local animPos = GetAnimInitialOffsetPosition('anim@heists@ornate_bank@grab_cash', "intro", targetPosition[1], targetPosition[2], targetPosition[3], targetRotation, 0, 2)
    local targetHeading = rot
    TaskGoStraightToCoord(ped, animPos, 0.025, 5000, targetHeading, 0.05)
    Wait(2500)

    local baghash = `ch_p_m_bag_var02_arm_s`
    RequestAnimDict("anim@heists@ornate_bank@grab_cash")
    RequestModel(baghash)
    RequestModel(emptyobj)
    while not HasAnimDictLoaded("anim@heists@ornate_bank@grab_cash") and not HasModelLoaded(emptyobj) and not HasModelLoaded(baghash) do
        Wait(100)
    end
	while not NetworkHasControlOfEntity(trollyobj) do
		Wait(1)
		NetworkRequestControlOfEntity(trollyobj)
	end
	local bag = CreateObject(`ch_p_m_bag_var02_arm_s`, GetEntityCoords(PlayerPedId()), true, false, false)
    local scene1 = NetworkCreateSynchronisedScene(GetEntityCoords(trollyobj), GetEntityRotation(trollyobj), 2, false, false, 1065353216, 0, 1.3)
	NetworkAddPedToSynchronisedScene(ped, scene1, "anim@heists@ornate_bank@grab_cash", "intro", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, scene1, "anim@heists@ornate_bank@grab_cash", "bag_intro", 4.0, -8.0, 1)
    SetPedComponentVariation(ped, 5, 0, 0, 0)
	NetworkStartSynchronisedScene(scene1)
	Wait(1500)
	CashAppear()
	local scene2 = NetworkCreateSynchronisedScene(GetEntityCoords(trollyobj), GetEntityRotation(trollyobj), 2, true, true, 1065353216, 0, 1.3)
	NetworkAddPedToSynchronisedScene(ped, scene2, "anim@heists@ornate_bank@grab_cash", "grab", 1.5, -4.0, 1, 16, 1148846080, 0)
	NetworkAddEntityToSynchronisedScene(bag, scene2, "anim@heists@ornate_bank@grab_cash", "bag_grab", 4.0, -8.0, 1)
	NetworkAddEntityToSynchronisedScene(trollyobj, scene2, "anim@heists@ornate_bank@grab_cash", "cart_cash_dissapear", 4.0, -8.0, 1)
	NetworkStartSynchronisedScene(scene2)
	Wait(37000) -- why tf did I put this here??
	local scene3 = NetworkCreateSynchronisedScene(GetEntityCoords(trollyobj), GetEntityRotation(trollyobj), 2, false, false, 1065353216, 0, 1.3)
	NetworkAddPedToSynchronisedScene(ped, scene3, "anim@heists@ornate_bank@grab_cash", "exit", 1.5, -4.0, 1, 16, 1148846080, 0)
	NetworkAddEntityToSynchronisedScene(bag, scene3, "anim@heists@ornate_bank@grab_cash", "bag_exit", 4.0, -8.0, 1)
	NetworkStartSynchronisedScene(scene3)
    TriggerServerEvent('gc-bobcatheist:server:CartItem')
	Wait(1800)
	DeleteObject(bag)
    SetPedComponentVariation(ped, 5, 82, 0, 0)
	RemoveAnimDict("anim@heists@ornate_bank@grab_cash")
	SetModelAsNoLongerNeeded(emptyobj)
    SetModelAsNoLongerNeeded(`ch_p_m_bag_var02_arm_s`)
    LocalPlayer.state:set("inv_busy", false, true)
    print('closestTrolly',closestTrolly)
    Config.Trolleys[closestTrolly].hit = true
end)

RegisterNetEvent('gc-bobcatheist:client:Closest', function(data)
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local dist
    inRange = false
    for k, v in pairs(Config.Trolleys) do
        dist = #(pos - vector3(Config.Trolleys[k].coords.x, Config.Trolleys[k].coords.y, Config.Trolleys[k].coords.z))
        if dist < 1.5 and Config.Trolleys[k].hit == false then
            closestTrolly = k
            inRange = true
        end
    end
    if not inRange then
        closestTrolly = nil
    end
end)

RegisterNetEvent("gc-bobcatheist:client:ThermitePtfx", function(coords)
    RequestNamedPtfxAsset("scr_ornate_heist")
    while not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
        Wait(50)
    end
    SetPtfxAssetNextCall("scr_ornate_heist")
    local effect = StartParticleFxLoopedAtCoord("scr_ornate_heist_thernite_burn", coords, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
        Wait(5000)
    StopParticleFxLooped(effect, 0)
end)

function DoorThermite()
    local pos = GetEntityCoords(PlayerPedId())
    if LocalPlayer.state.isLoggedIn then
        QBCore.Functions.TriggerCallback('gc-bobcatheist:server:getCops', function(cops)
            if cops >= Config.Cops then
                QBCore.Functions.TriggerCallback("gc-bobcatheist:Cooldown", function(cooldown)
                    if not Cooldown then
                        if cops >= 0 then
                            QBCore.Functions.TriggerCallback('QBCore:HasItem', function(hasitem)
                                if hasitem then
                                    Alert()
                                    exports["memorygame"]:thermiteminigame(Config.ThermiteBlocks, Config.ThermiteAttempts, Config.ThermiteShow, Config.ThermiteTime,
                                    function() -- success
                                        ThermiteEffect()
                                        HackSuccessThermite()
                                    end,
                                    function() -- fail
                                        HackFailedThermite()
                                    end)
                                else
                                    QBCore.Functions.Notify('You do not have the required items!', "error")
                                end
                            end, "thermite")
                        else
                            QBCore.Functions.Notify('Not Enough Cops', "error")
                        end
                    else
                        QBCore.Functions.Notify('Cooldown', "error")
                    end
                end)
            else
                QBCore.Functions.Notify('Not Enough Cops', "error")
            end
        end)
    else
        Wait(3000)
    end
end

function HackFailedThermite()
    QBCore.Functions.Notify("Should of worked! sikeee you failed L bozo", "error", "6000")
    local num = math.random(1, 100)
    local chance = 40 -- 60% chance to leave a fingerprint
    local ped = GetPlayerId()
    local pos = GetEntityCoords(ped)
    print(num)
    if num >= chance then 
        TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
        QBCore.Functions.Notify("You left a fingerprint!", "success", "6000")
    end
end

function HackSuccessThermite()
    QBCore.Functions.Notify("Door opened", "success", "6000")
    ClearPedTasksImmediately(PlayerPedId())
    TriggerServerEvent("gc-bobcatheist:successthermite")
    TriggerServerEvent('gc-bobcatheist:server:cooldown')
end

function progressthermite()
    Anim = true
    QBCore.Functions.Progressbar("hack_gate", "Placing Thermite...", 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@gangops@facility@servers@",
        anim = "hotwire",
        flags = 16,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
    end, function() -- Canceled
        StopAnimTask(PlayerPedId(), "anim@gangops@facility@servers@", "hotwire", 1.0)
    end)
end

RegisterNetEvent('gc-bobcatheist:client:ThermitebobcatDoor', function()
    progressthermite()
    Wait(10000)
    ThermitePlanting()
    DoorThermite()
end)

exports['qb-target']:AddBoxZone('bobcatthermite', vector3(882.18, -2258.11, 32.46), 1.00, 1.00, {
    name = 'bobcatthermite', 
    heading = 265.85,
    debugpoly = false,
    minZ = 32.46,
    maxZ = 33.46,
    }, {
    options = {
        { 
            type = 'client',
            event = 'gc-bobcatheist:client:ThermitebobcatDoor',
            icon = 'fas fa-bomb',
            label = 'Blow Door',
            item = 'thermite',
        }
    },
    distance = 1.5,
})

function ThermitePlanting2()
    RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
    RequestModel("hei_p_m_bag_var22_arm_s")
    RequestNamedPtfxAsset("scr_ornate_heist")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") and not HasModelLoaded("hei_p_m_bag_var22_arm_s") and not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
        Citizen.Wait(50)
    end

    local ped = PlayerPedId()
    SetEntityHeading(ped, 179.93)
    local pos = vector3(880.58, -2264.5, 32.44)
    Citizen.Wait(100)
    local rotx, roty, rotz = table.unpack(vec3(GetEntityRotation(ped)))
    local bagscene = NetworkCreateSynchronisedScene(pos.x, pos.y, pos.z, rotx, roty, rotz, 2, false, false, 1065353216, 0, 1.3)
    local bag = CreateObject(GetHashKey("hei_p_m_bag_var22_arm_s"), pos.x, pos.y, pos.z,  true,  true, false)
    SetEntityCollision(bag, false, true)

    local x, y, z = table.unpack(GetEntityCoords(ped))
    local thermite = CreateObject(GetHashKey("hei_prop_heist_thermite"), x, y, z + 0.2,  true,  true, true)
    SetEntityCollision(thermite, false, true)
    AttachEntityToEntity(thermite, ped, GetPedBoneIndex(ped, 28422), 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
    
    NetworkAddPedToSynchronisedScene(ped, bagscene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, bagscene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)
    SetPedComponentVariation(ped, 5, 0, 0, 0)
    NetworkStartSynchronisedScene(bagscene)
    Citizen.Wait(5000)
    DetachEntity(thermite, 1, 1)
    FreezeEntityPosition(thermite, true)
    DeleteObject(bag)
    NetworkStopSynchronisedScene(bagscene)
    Citizen.CreateThread(function()
        Citizen.Wait(15000)
        DeleteEntity(thermite)
    end)
end

function ThermiteEffect2()
    RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") do
        Citizen.Wait(50)
    end
    local ped = PlayerPedId()
    Citizen.Wait(1500)
    TriggerServerEvent("gc-bobcatheist:server:ThermitePtfx", ptfx)
    Citizen.Wait(500)
    TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_intro", 8.0, 8.0, 1000, 36, 1, 0, 0, 0)
    TaskPlayAnim(ped, "anim@heists@ornate_bank@thermal_charge", "cover_eyes_loop", 8.0, 8.0, 3000, 49, 1, 0, 0, 0)
    local ptfx

    RequestNamedPtfxAsset("scr_ornate_heist")
    while not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
        Citizen.Wait(1)
    end
        ptfx = vector3(880.49, -2263.60, 32.441)
    SetPtfxAssetNextCall("scr_ornate_heist")
    local effect = StartParticleFxLoopedAtCoord("scr_heist_ornate_thermal_burn", ptfx, 0.0, 0.0, 0.0, 1.0, false, false, false, false)
    Citizen.Wait(4000)
    StopParticleFxLooped(effect, 0)
    ClearPedTasks(ped)
    Citizen.Wait(2000)
    ClearPedTasks(ped)
    Citizen.Wait(2000)
    QBCore.Functions.Notify("The lock had been melted", "success")
    TriggerServerEvent('qb-doorlock:server:updateState', Config.Door2, false)
end

function DoorThermite2()
    local pos = GetEntityCoords(PlayerPedId())
    if LocalPlayer.state.isLoggedIn then
        QBCore.Functions.TriggerCallback("gc-bobcatheist:Cooldown", function(cooldown)
            if not Cooldown then
                if cops >= 0 then
                    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(hasitem)
                        if hasitem then
                            exports["memorygame"]:thermiteminigame(Config.ThermiteBlocks, Config.ThermiteAttempts, Config.ThermiteShow, Config.ThermiteTime,
                            function() -- success
                                ThermiteEffect2()
                                HackSuccessThermite()
                            end,
                            function() -- fail
                                HackFailedThermite()
                            end)
                        else
                            QBCore.Functions.Notify('You do not have the required items!', "error")
                        end
                    end, "thermite")
                else
                    QBCore.Functions.Notify('Not Enough Cops', "error")
                end
            else
                QBCore.Functions.Notify('Cooldown', "error")
            end
        end)
    else
        Citizen.Wait(3000)
    end
end

RegisterNetEvent('gc-bobcatheist:client:ThermitebobcatDoor2', function()
    progressthermite()
    Wait(10000)
    ThermitePlanting2()
    DoorThermite2()
end)

exports['qb-target']:AddBoxZone('bobcatthermite2', vector3(880.96, -2264.15, 32.44), 1.00, 1.00, {
    name = 'bobcatthermite2', 
    heading = 265.85,
    debugpoly = false,
    minZ = 32.44,
    maxZ = 33.44,
    }, {
    options = {
        { 
            type = 'client',
            event = 'gc-bobcatheist:client:ThermitebobcatDoor2',
            icon = 'fas fa-bomb',
            label = 'Blow Door',
            item = 'thermite',
        }
    },
    distance = 1.5,
})

local function hackanim()
    local animDict = "anim@heists@ornate_bank@hack"
    RequestAnimDict(animDict)
    RequestModel("hei_prop_hst_laptop")
    RequestModel("ch_p_m_bag_var02_arm_s") 
    local loc = {x,y,z,h}
    loc.x = 874.93
    loc.y = -2263.26
    loc.z = 32.15
    loc.h = 358.84
    while not HasAnimDictLoaded(animDict)
        or not HasModelLoaded("hei_prop_hst_laptop")
        or not HasModelLoaded("ch_p_m_bag_var02_arm_s") do
        Wait(100)
    end
    local ped = PlayerPedId()
    local pos = GetEntityCoords(ped)
    local targetPosition, targetRotation = (vec3(GetEntityCoords(ped))), vec3(GetEntityRotation(ped))
    local animPos = GetAnimInitialOffsetPosition(animDict, "hack_enter", loc.x + 0, loc.y + 0, loc.z + 1.15)
    local animPos2 = GetAnimInitialOffsetPosition(animDict, "hack_loop", loc.x + 0, loc.y + 0, loc.z + 1.15)
    local animPos3 = GetAnimInitialOffsetPosition(animDict, "hack_exit", loc.x + 0, loc.y + 0, loc.z + 1.15)
    QBCore.Functions.TriggerCallback('QBCore:HasItem', function(hasitem)
            if hasitem then
                bag = CreateObject(`ch_p_m_bag_var02_arm_s`, targetPosition, 1, 1, 0)
                laptop = CreateObject(`hei_prop_hst_laptop`, targetPosition, 1, 1, 0)
                local IntroHack = NetworkCreateSynchronisedScene(animPos, targetRotation, 0, true, false, 1065353216, 0, 1.3)
                NetworkAddPedToSynchronisedScene(ped, IntroHack, animDict, "hack_enter", 0, 0, 1, 16, 1148846080, 0)
                NetworkAddEntityToSynchronisedScene(bag, IntroHack, animDict, "hack_enter_bag", 4.0, -8.0, 1)
                NetworkAddEntityToSynchronisedScene(laptop, IntroHack, animDict, "hack_enter_laptop", 4.0, -8.0, 1)
                HackLoop = NetworkCreateSynchronisedScene(animPos2, targetRotation, 2, false, true, 1065353216, -1, 1.0)
                NetworkAddPedToSynchronisedScene(ped, HackLoop, animDict, "hack_loop", 0, 0, -1, 1, 1148846080, 0)
                NetworkAddEntityToSynchronisedScene(bag, HackLoop, animDict, "hack_loop_bag", 1.0, 0.0, 1)
                NetworkAddEntityToSynchronisedScene(laptop, HackLoop, animDict, "hack_loop_laptop", 1.0, -0.0, 1)
                HackLoopFinish = NetworkCreateSynchronisedScene(animPos3, targetRotation, 2, false, false, 1065353216, -1, 1.3)
                NetworkAddPedToSynchronisedScene(ped, HackLoopFinish, animDict, "hack_exit", 0, 0, -1, 16, 1148846080, 0)
                NetworkAddEntityToSynchronisedScene(bag, HackLoopFinish, animDict, "hack_exit_bag", 4.0, -8.0, 1)
                NetworkAddEntityToSynchronisedScene(laptop, HackLoopFinish, animDict, "hack_exit_laptop", 4.0, -8.0, 1)
                SetPedComponentVariation(ped, 5, 0, 0, 0)
                NetworkStartSynchronisedScene(IntroHack)
                TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["laptop_green"], "remove")
                TriggerServerEvent("QBCore:Server:RemoveItem", "laptop_green", 1)
                Wait(6000)
                FreezeEntityPosition(PlayerPedId(), true)
                NetworkStopSynchronisedScene(IntroHack)
                NetworkStartSynchronisedScene(HackLoop)
                    exports['hacking']:OpenHackingGame(Config.LaptopTime, Config.LaptopBlocks, Config.LaptopRepeat, function(Success)
                    if Success then -- success
                        Alert()
                        NetworkStopSynchronisedScene(HackLoop)
                        NetworkStartSynchronisedScene(HackLoopFinish)
                        Wait(6000)
                        NetworkStopSynchronisedScene(HackLoopFinish)
                        DeleteObject(bag)
                        DeleteObject(laptop)
                        FreezeEntityPosition(PlayerPedId(), false)
                        HackSuccess()
                        SpawnGuards()
                        SetPedComponentVariation(PlayerPedId(), 5, 82, 0, 0)
                    else
                        NetworkStopSynchronisedScene(HackLoop)
                        NetworkStartSynchronisedScene(HackLoopFinish)
                        Wait(6000)
                        NetworkStopSynchronisedScene(HackLoopFinish)
                        DeleteObject(bag)
                        DeleteObject(laptop)
                        HackFailed()
                        FreezeEntityPosition(PlayerPedId(), false)
                        SetPedComponentVariation(PlayerPedId(), 5, 82, 0, 0)
                    end
                end)
            else
                QBCore.Functions.Notify('You do not have the required items!', "error")
            end
        end, "laptop_green")
end

function HackSuccess()
    QBCore.Functions.Notify("Door opened", "success", "6000")
    TriggerServerEvent('gc-bobcatheist:success')
    TriggerServerEvent('qb-doorlock:server:updateState', Config.Door3, false)
    Wait(4000)
    QBCore.Functions.PoliceNotify("Bobcat Robbery", "police", "6000")
end

function HackFailed()
    QBCore.Functions.Notify("Should of worked! sikeee you failed L bozo", "error", "6000")
    if math.random(1, 100) <= 40 then
        TriggerServerEvent("evidence:server:CreateFingerDrop", pos)
        QBCore.Functions.Notify("You left a fingerprint!", "success", "6000")
    end
end

RegisterNetEvent('gc-bobcatheist:client:Hack', function()
    hackanim()
end)

exports['qb-target']:AddBoxZone('system', vector3(874.93, -2263.26, 31.99), 1, 1, {
    name = 'system',
    heading = 124.11,
    debugpoly = false,
    minZ = 31.99,
    maxZ = 33.99,
    }, {
        options = {
            {
                type = 'client',
                event = 'gc-bobcatheist:client:Hack',
                icon = 'fas fa-laptop',
                label = 'Hack Computer System',
                item = 'laptop_green',
            },
        },
    distance = 1.5
})

guards = {
    ['npcguards'] = {}
}

function loadModel(model)
    if type(model) == 'number' then
        model = model
    else
        model = GetHashKey(model)
    end
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(0)
    end
end

function SpawnGuards()
    local ped = PlayerPedId()

    SetPedRelationshipGroupHash(ped, `PLAYER`)
    AddRelationshipGroup('npcguards')

    for k, v in pairs(Config['guards']['npcguards']) do
        loadModel(v['model'])
        guards['npcguards'][k] = CreatePed(26, GetHashKey(v['model']), v['coords'], v['heading'], true, true)
        NetworkRegisterEntityAsNetworked(guards['npcguards'][k])
        networkID = NetworkGetNetworkIdFromEntity(guards['npcguards'][k])
        SetNetworkIdCanMigrate(networkID, true)
        SetNetworkIdExistsOnAllMachines(networkID, true)
        SetPedRandomComponentVariation(guards['npcguards'][k], 0)
        SetPedRandomProps(guards['npcguards'][k])
        SetEntityAsMissionEntity(guards['npcguards'][k])
        SetEntityVisible(guards['npcguards'][k], true)
        SetPedRelationshipGroupHash(guards['npcguards'][k], `npcguards`)
        SetPedAccuracy(guards['npcguards'][k], 75)
        SetPedArmour(guards['npcguards'][k], 100)
        SetPedCanSwitchWeapon(guards['npcguards'][k], true)
        SetPedDropsWeaponsWhenDead(guards['npcguards'][k], false)
        SetPedFleeAttributes(guards['npcguards'][k], 0, false)
        GiveWeaponToPed(guards['npcguards'][k], `WEAPON_CARBINERIFLE`, 255, false, false)
        local random = math.random(1, 2)
        if random == 2 then
            TaskGuardCurrentPosition(guards['npcguards'][k], 10.0, 10.0, 1)
        end
    end

    SetRelationshipBetweenGroups(0, `npcguards`, `npcguards`)
    SetRelationshipBetweenGroups(5, `npcguards`, `PLAYER`)
    SetRelationshipBetweenGroups(5, `PLAYER`, `npcguards`)
end

RegisterNetEvent('gc-bobcatheist:client:Lockdown', function() 
    QBCore.Functions.Notify("The building is now locked down!", "success", "6000")
    TriggerServerEvent('qb-doorlock:server:updateState', Config.Door1, true)
    TriggerServerEvent('qb-doorlock:server:updateState', Config.Door2, true)
    TriggerServerEvent('qb-doorlock:server:updateState', Config.Door3, true)
    local interiorid = GetInteriorAtCoords(883.4142, -2282.372, 31.44168)
    ActivateInteriorEntitySet(interiorid, "np_prolog_clean")
    RemoveIpl(interiorid, "np_prolog_clean")
    DeactivateInteriorEntitySet(interiorid, "np_prolog_broken")
    RefreshInterior(interiorid)
end)

exports['qb-target']:AddBoxZone('lockdown', vector3(876.81, -2262.29, 32.44), 1, 1, {
    name='lockdown',
    heading=177.54,
    debugPoly=false,
    minZ = 32.44,
    maxZ = 33.44,
    }, {
        options = {
            {
                type = 'client',
                event = 'gc-bobcatheist:client:Lockdown',
                icon = 'fas fa-lock',
                label = 'Lockdown',
                job = 'police',
            },
        },
    distance = 1.5
})

-- test
--[[RegisterCommand('bobcat', function()
    RequestIpl("prologue06_int_np")
    local interiorid = GetInteriorAtCoords(883.4142, -2282.372, 31.44168)
    DeactivateInteriorEntitySet(interiorid, "np_prolog_broken")
    ActivateInteriorEntitySet(interiorid, "np_prolog_clean")
    RefreshInterior(interiorid)
end)--]]

function progresslocker()
    Anim = true
    QBCore.Functions.Progressbar("hack_gate", "Searching Locker...", 10000, false, true, {
        disableMovement = true,
        disableCarMovement = true,
        disableMouse = false,
        disableCombat = true,
    }, {
        animDict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
        anim = "machinic_loop_mechandplayer",
        flags = 16,
    }, {}, {}, function() -- Done
        StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
    end, function() -- Canceled
        StopAnimTask(PlayerPedId(), "anim@amb@clubhouse@tutorial@bkr_tut_ig3@", "machinic_loop_mechandplayer", 1.0)
    end)
    Wait(10000)
    local success = exports['qb-lock']:StartLockPickCircle(8, 10, success)
    if success then
        TriggerServerEvent('gc-bobcatheist:server:LockerItem') -- Get Item
        locker = false
    else
        QBCore.Functions.Notify("You Found nothing, try again", "error", "6000")
    end
end

RegisterNetEvent('gc-bobcatheist:client:locker', function()
    progresslocker()
end)

exports['qb-target']:AddBoxZone('locker', vector3(883.8, -2281.91, 32.44), 1, 1, {
    name='locker',
    heading=355.19,
    debugPoly=false,
    minZ = 32.44,
    maxZ = 33.44,
    }, {
        options = {
            {
                type = 'client',
                event = 'gc-bobcatheist:client:locker',
                icon = 'fas fa-magnifying-glass',
                label = 'Search Armory...',
                
                canInteract = function()
                    if locker then return true else return false end
                end
            },
        },
    distance = 1.5
})

function BombPlanting()
    RequestAnimDict("anim@heists@ornate_bank@thermal_charge")
    RequestModel("ch_p_m_bag_var02_arm_s")
    RequestNamedPtfxAsset("scr_ornate_heist")
    while not HasAnimDictLoaded("anim@heists@ornate_bank@thermal_charge") and not HasModelLoaded("hei_p_m_bag_var22_arm_s") and not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
        Citizen.Wait(50)
    end

    local ped = PlayerPedId()
    SetEntityHeading(ped, 75.46)
    local pos = vector3(890.50, -2284.89, 32.44)
    Citizen.Wait(100)
    local rotx, roty, rotz = table.unpack(vec3(GetEntityRotation(ped)))
    local bagscene = NetworkCreateSynchronisedScene(pos.x, pos.y, pos.z, rotx, roty, rotz, 2, false, false, 1065353216, 0, 1.3)
    local bag = CreateObject(GetHashKey("ch_p_m_bag_var02_arm_s"), pos.x, pos.y, pos.z,  true,  true, false)
    SetEntityCollision(bag, false, true)

    local x, y, z = table.unpack(GetEntityCoords(ped))
    local thermite = CreateObject(GetHashKey("ch_prop_ch_explosive_01a"), x, y, z + 0.2,  true,  true, true)
    SetEntityCollision(thermite, false, true)
    AttachEntityToEntity(thermite, ped, GetPedBoneIndex(ped, 28422), 0, 0, 0, 0, 0, 200.0, true, true, false, true, 1, true)
    NetworkAddPedToSynchronisedScene(ped, bagscene, "anim@heists@ornate_bank@thermal_charge", "thermal_charge", 1.5, -4.0, 1, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(bag, bagscene, "anim@heists@ornate_bank@thermal_charge", "bag_thermal_charge", 4.0, -8.0, 1)
    SetPedComponentVariation(ped, 5, 0, 0, 0)
    NetworkStartSynchronisedScene(bagscene)
    Citizen.Wait(5000)
    DetachEntity(thermite, 1, 1)
    FreezeEntityPosition(thermite, true)
    DeleteObject(bag)
    NetworkStopSynchronisedScene(bagscene)
    TriggerEvent('inventory:client:ItemBox', QBCore.Shared.Items["weapon_pipebomb"], "remove")
    TriggerServerEvent("QBCore:Server:RemoveItem", "weapon_pipebomb", 1)
    QBCore.Functions.Notify('You have successfully planted the bomb!', 'success', '5000')
    QBCore.Functions.Notify('Bomb will explode in ' ..Config.Time.. ' seconds.', 'error', '5000')
    Wait(Config.Time * 1000)
    AddExplosion(Config.Explosion[1].x, Config.Explosion[1].y, Config.Explosion[1].z, 82, 5.0, true, false, 15.0)
    DeleteObject(thermite)
    Wait(50)
    TriggerServerEvent('updatebobcat3')
    print("fixed -- only took 5 months lol")
    print('This project will no longer be mantained by me')
    print("discord.gg/RubyRP")
    Carts()
end

RegisterNetEvent('bomb-anim', function()
    BombPlanting()
    locker = true
end)

exports['qb-target']:AddBoxZone('bomb', vector3(890.89, -2284.89, 32.44), 1, 1, {
    name='bomb',
    heading=75.46,
    debugPoly=false,
    minZ = 32.44,
    maxZ = 33.44,
    }, {
        options = {
            {
                type = 'client',
                event = 'bomb-anim',
                icon = 'fas fa-bomb',
                label = 'Place Bomb',
                item = 'weapon_pipebomb',
            },
        },
    distance = 1.5
})