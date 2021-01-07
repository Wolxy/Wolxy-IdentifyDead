CurrentVersion = '0'
ResourceName = GetCurrentResourceName()

local Tunnel = module('vrp', 'lib/Tunnel')
local Proxy = module('vrp', 'lib/Proxy')

vRP = Proxy.getInterface('vRP')
vRPclient = Tunnel.getInterface('vRP', ResourceName)

if Config.General.CheckForUpdates then
    PerformHttpRequest('https://raw.githubusercontent.com/Wolxy/Wolxy-IdentifyDead/development/Version.md', function(Error, Version)
        if Version ~= CurrentVersion then
            Print4()
            print('^1-----------------------------------------------------')
            print('^1Ny version af: ' .. ResourceName .. ' er blevet udgivet!')
            print('^1Hent den seneste version her: https://github.com/Wolxy/Wolxy-IdentifyDead')
            print('^1-----------------------------------------------------')
            Print4()
        else
            Print4()
            print('^2-----------------------------------------------------')
            print('^2Din version af: ' .. ResourceName .. ' er den nyeste!')
            print('^2-----------------------------------------------------')
            Print4()
        end
    end)
end

function Print4()
    for i = 1, 4 do
        print('')
    end
end

AddEventHandler('vRP:playerSpawn', function(UserID, Player, FirstSpawn)
    if FirstSpawn then
        TriggerClientEvent('Wolxy:IdentifyDead:AddPlayer', -1, Player)
        local Sources = vRP.getUsers({})
        TriggerClientEvent('Wolxy:IdentifyDead:AddPlayers', Player, Sources)
    end
    UpdatePlayerPerms(UserID, Player)
end)

AddEventHandler('vRP:playerLeave', function(UserID, Player)
    TriggerClientEvent('Wolxy:IdentifyDead:RemovePlayer', -1, Player)
end)

AddEventHandler('vRP:playerLeaveGroup', function(UserID)
    local Player = vRP.getUserSource({UserID})
    UpdatePlayerPerms(UserID, Player)
end)

AddEventHandler('vRP:playerJoinGroup', function(UserID)
    local Player = vRP.getUserSource({UserID})
    UpdatePlayerPerms(UserID, Player)
end)

function DoesPlayerHaveAccess(UserID)
    if Config.General.PermissionRequired == nil then
        return true
    else
        return vRP.hasPermission({UserID, Config.General.PermissionRequired})
    end
end

function UpdatePlayerPerms(UserID, Player)
    TriggerClientEvent('Wolxy:IdentifyDead:HasPerm', Player, DoesPlayerHaveAccess(UserID))
end

RegisterNetEvent('Wolxy:IdentifyDead:Identify')
AddEventHandler('Wolxy:IdentifyDead:Identify', function(Player2)
    local Player = source
    local UserID = vRP.getUserId({Player})
    if UserID ~= nil then
        if DoesPlayerHaveAccess(UserID) then
            
        else
            SendNotification(Player, 'NoPermission')
        end
    else
        SendNotification(Player, 'ServerError')
    end
end)

function SendNotification(Player, Notifikation)
    local Notifikation2 = Config.Notifikationer.Notifikationer[Notifikation]
    local System = Notifikation2.SystemOverride or Config.Notifikationer.System
    System = string.lower(System)
    if System == 'gta' then
        TriggerClientEvent('Wolxy:IdentifyDead:GTANotif', Player, Vars.Notifikationer.GTATypeColors[Notifikation2.Type] .. Notifikation2.Tekst, Notifikation2.Important)
    elseif System == 'pnotify' then
        TriggerClientEvent('pNotify:SendNotification', Player, {
            type = Notifikation2.Type,
            layout = Vars.Notifikationer.pNotify.Locations[Notifikation2.Location],
            text = Notifikation2.Tekst,
            timeout = Notifikation2.Timeout,
            progressBar = Notifikation2.ProgressBar
        })
    elseif System == 'mythic_notify' or System == 'mythic' then
        TriggerClientEvent('Wolxy:IdentifyDead:MythicNotif', Player, Vars.Notifikationer.Mythic.Types[Notifikation2.Type], Notifikation2.Timeout, Notifikation2.Tekst)
    elseif System == 'custom' then
        TriggerClientEvent('Wolxy:IdentifyDead:Notif', Player, {
            Tekst = Notifikation2.Tekst,
            Type = Notifikation2.Type,
            Location = Notifikation2.Location,
            Timeout = Notifikation2.Timeout,
            ProgressBar = Notifikation2.ProgressBar
        })
    end
end





-- DONT TOUCH!!
RegisterNetEvent('Wolxy:IdentifyDead:ScumbagDetected')
AddEventHandler('Wolxy:IdentifyDead:ScumbagDetected', function()
    print('^1Tjek venligst i bunden af Client.lua i resourcen: ' .. ResourceName)
end)