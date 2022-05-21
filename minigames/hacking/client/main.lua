local IsHacking = false

AddEventHandler('open:minigame', function(callback)
    Callbackk = callback
    openHack()
end)

function OpenHackingGame(puzzleDuration, puzzleLength, puzzleAmount, callback)
    Callbackk = callback
    openHack(puzzleDuration, puzzleLength, puzzleAmount)
end

RegisterNUICallback('callback', function(data, cb)
    closeHack()
    Callbackk(data.success)
    cb('ok')
end)

function openHack(puzzleDuration, puzzleLength, puzzleAmount)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
        duration = puzzleDuration,
        length = puzzleLength,
        amount = puzzleAmount
    })
    IsHacking = true
end

function closeHack()
    SetNuiFocus(false, false)
    IsHacking = false
end

function GetHackingStatus()
    return IsHacking
end