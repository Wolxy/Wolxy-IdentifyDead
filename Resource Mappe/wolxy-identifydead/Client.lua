-- Dont touch!! Vigtige variabler herunder.
OnlinePlayers = {}
ClosestDeadPlayer = nil
HasPerm = Config.General.PermissionRequired == nil
IsChecking = false

RegisterNetEvent('Wolxy:IdentifyDead:AddPlayer')
AddEventHandler('Wolxy:IdentifyDead:AddPlayer', function(PlayerToAdd)
    OnlinePlayers[PlayerToAdd] = GetPlayerFromServerId(PlayerToAdd)
end)

RegisterNetEvent('Wolxy:IdentifyDead:AddPlayers')
AddEventHandler('Wolxy:IdentifyDead:AddPlayers', function(PlayersToAdd)
    for k, v in pairs(PlayersToAdd) do
        OnlinePlayers[v] = GetPlayerFromServerId(v)
    end
end)

RegisterNetEvent('Wolxy:IdentifyDead:RemovePlayer')
AddEventHandler('Wolxy:IdentifyDead:RemovePlayer', function(PlayerToRemove)
    OnlinePlayers[PlayerToRemove] = nil
end)

RegisterNetEvent('Wolxy:IdentifyDead:HasPerm')
AddEventHandler('Wolxy:IdentifyDead:HasPerm', function(HasPerm)
    HasPerm = HasPerm
end)

RegisterNetEvent('Wolxy:IdentifyDead:GTANotif')
AddEventHandler('Wolxy:IdentifyDead:GTANotif', function(Tekst, Important)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(Tekst)
    EndTextCommandThefeedPostTicker(Important, false)
end)

RegisterNetEvent('Wolxy:DeadCheck:SendMythicNotify')
AddEventHandler('Wolxy:DeadCheck:SendMythicNotify', function(Type, Timeout, Tekst)
    exports['mythic_notify'].DoCustomHudText(Type, Tekst, Timeout)
end)

RegisterNetEvent('Wolxy:IdentifyDead:Notif')
AddEventHandler('Wolxy:IdentifyDead:Notif', function(Options)
    SendNuiMessage({Wolxy_IdentifyDeadNotif = Options})
end)

Citizen.CreateThread(function()
    while true do
        if HasPerm then
            local Ped1 = PlayerPedId()
            local Coords1 = GetEntityCoords(Ped1)
            local Closest = {
                Distance = Config.General.MaxDistance + 0.1
            }

            for k, v in pairs(OnlinePlayers) do
                local Ped2 = GetPlayerPed(v)
                if GetEntityHealth(Ped2) <= 100 then
                    local Coords2 = GetEntityCoords(Ped2)
                    local Distance = #(Coords1 - Coords2)
                    if Distance <= Config.General.MaxDistance then
                        if Distance < Closest.Distance then
                            Closest = {
                                Coords = Coords2,
                                Distance = Distance,
                                Player = v
                            }
                        end
                    end
                end
            end

            if Closest.Coords ~= nil then
                ClosestDeadPlayer = Closest
            else
                ClosestDeadPlayer = nil
            end
        else
            ClosestDeadPlayer = nil
        end
        Wait(Config.General.DistanceUpdateInterval)
    end
end)

Citizen.CreateThread(function()
    while true do
        if HasPerm then
            if ClosestDeadPlayer ~= nil then
                local OnScreen, X2, Y2 = GetScreenCoordFromWorldCoord(ClosestDeadPlayer.Coords.x, ClosestDeadPlayer.Coords.y, ClosestDeadPlayer.Coords.z + 0.35)
                if OnScreen then
                    local Scale = (1 / (#(ClosestDeadPlayer.Coords - GetGameplayCamCoords())) * 2 * (1 / GetGameplayCamFov() * 100)) * Config['3DText'].Scale
                    SetTextScale(Scale * Config['3DText'].Scale, Scale * Config['3DText'].Scale)
                    SetTextFont(Config['3DText'].Font)
                    SetTextColour(Config['3DText'].Color.R, Config['3DText'].Color.G, Config['3DText'].Color.B, Config['3DText'].Color.A)
                    SetTextCentre(true)
                    BeginTextCommandDisplayText('STRING')
                    AddTextComponentSubstringPlayerName(string.gsub(Config['3DText'].Text, '{Knap}', string.gsub(GetControlInstructionalButton(0, Config.General.Button, true), 't_', '')))
                    EndTextCommandDisplayText(X2, Y2)
                end
                if not IsChecking then
                    if IsControlJustPressed(0, Config.General.Button) then
                        IsChecking = true
                        IdentifyDead(ClosestDeadPlayer.Coords, ClosestDeadPlayer.Player, ClosestDeadPlayer.Distance)
                    end
                end
            end
        end
        Wait(5)
    end
end)

function IdentifyDead(Coords2, Player, Distance)
    local Ped = PlayerPedId()
    local Coords = GetEntityCoords(Ped)

    TriggerServerEvent('Wolxy:IdentifyDead:Identifying', Player)

    TaskAchieveHeading(Ped, math.deg(math.atan(Coords.x - Coords2.x, Coords.y - Coords2.y)) % 360, 1500)

    Wait(1500)

    local Ped2 = GetPlayerPed(Player)
    TaskGoToEntity(Ped, Ped2, 4500, 0.5, 1.0, 1073741824 , 0)

    Wait(4500)

    RequestAnimDict('amb@medic@standing@kneel@base')
    RequestAnimDict('anim@gangops@facility@servers@bodysearch@')

    while not HasAnimDictLoaded('amb@medic@standing@kneel@base') do
        Wait(5)
    end

    while not HasAnimDictLoaded('anim@gangops@facility@servers@bodysearch@') do
        Wait(5)
    end

    TaskPlayAnim(Ped, 'amb@medic@standing@kneel@base', 'base', 8.0, -8.0, -1, 1, 0, false, false, false)
    TaskPlayAnim(Ped, 'anim@gangops@facility@servers@bodysearch@', 'player_search', 8.0, -8.0, -1, 48, 0, false, false, false)

    Wait(5150)

    ClearPedTasks(Ped)

    TriggerServerEvent('Wolxy:IdentifyDead:Identify', Player)
end





--[[
Koden herunder tjekker at min LICENSE fil er der. (Med "min" mener jeg selvfølgelig den originale skaber af scriptet: William Heldgaard "AKA Wolxy / WillyGamez")
Filen viser at det er mig der har lavet scriptet, og at alle har tilladelse til at bruge det, redigere i det osv.
Vær venlig ikke at fjerne filen, og hvis du ikke har en kopi af filen kan den hentes her: https://github.com/Wolxy/Wolxy-IdentifyDead , bare smid den i resource mappen og sikre dig at der står de tre linjer herunder i fxmanifest.lua.
files {
    'LICENSE'
}
Du er en fucking scumbag hvis du selv fjerner den. Respekter nu folk der arbejder for andre folks gavn.
]]--
if LoadResourceFile(GetCurrentResourceName(), 'LICENSE') == nil then
    for i = 1, 10 do
        print('MANGLENDE LICENSE FIl!!')
        print('Tjek venligst bunden af Client.lua i resourcen: ' .. GetCurrentResourceName() .. ' for mere info!')
    end
    TriggerServerEvent('Wolxy:IdentifyDead:ScumbagDetected')
end