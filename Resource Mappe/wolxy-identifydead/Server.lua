CurrentVersion = '0'
ResourceName = GetCurrentResourceName()

local Tunnel = module('vrp', 'lib/Tunnel')
local Proxy = module('vrp', 'lib/Proxy')

vRP = Proxy.getInterface('vRP')
vRPclient = Tunnel.getInterface('vRP', ResourceName)

MySQL = module('vrp_mysql', 'MySQL')

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

    -- Bare for at være sikker:
    local ToBeRemoved = {}
    for k, v in pairs(IdentifyingPlayers) do
        local Parts = {}
        for Part in string.gmatch(k, '([^|]+)') do
            table.insert(Parts, Part)
        end
        if Part[1] == Player then
            table.insert(ToBeRemoved, k)
        end
    end
    for _, v in pairs(ToBeRemoved) do
        IdentifyingPlayers[v] = nil
    end
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

RegisterNetEvent('Wolxy:IdentifyDead:Identifying')
AddEventHandler('Wolxy:IdentifyDead:Identifying', function(Player2)
    local Player = source
    local UserID = vRP.getUserId({Player})
    local UserID2 = vRP.getUserId({Player2})
    
    if UserID ~= nil then
        if UserID2 ~= nil then
            vRPclient.isInComa(Player2, {}, function(InComa)
                if InComa then
                    if DoesPlayerHaveAccess(UserID) then
                        local Key = Player .. '|' .. Player2
                        if IdentifyingPlayers[Key] == nil then
                            IdentifyingPlayers[Key] = {}
                            SendNotification(Player, 'Identifying')
                            if Config.General.InfoMode == 1 then
                                vRP.getUserIdentity({UserID2, function(Identity)
                                    IdentifyingPlayers[Key].Identity = Identity
                                    IdentifyingPlayers[Key].Job = vRP.getUserGroupByType({UserID2, 'job'})
                                end})
                            elseif Config.General.InfoMode == 2 then
                                if CanOrCantBeIdentified[Player2] ~= false then
                                    if CanOrCantBeIdentified[Player2] == true then
                                        vRP.getUserIdentity({UserID2, function(Identity)
                                            IdentifyingPlayers[Key].Identity = Identity
                                            IdentifyingPlayers[Key].Job = vRP.getUserGroupByType({UserID2, 'job'})
                                        end})
                                    else
                                        if math.random() < (Config.General.InfoChance / 100) then
                                            vRP.getUserIdentity({UserID2, function(Identity)
                                                IdentifyingPlayers[Key].Identity = Identity
                                                IdentifyingPlayers[Key].Job = vRP.getUserGroupByType({UserID2, 'job'})
                                            end})
                                            CanOrCantBeIdentified[Player2] = true
                                        else
                                            CanOrCantBeIdentified[Player2] = false
                                        end
                                    end
                                end
                            elseif Config.General.InfoMode == 3 then
                                local HasAny = false

                                for _, v in pairs(Config.General.InfoItems) do
                                    if vRP.getInventoryItemAmount({UserID2, v}) > 0 then
                                        HasAny = true
                                        break
                                    end
                                end

                                if HasAny then
                                    vRP.getUserIdentity({UserID2, function(Identity)
                                        IdentifyingPlayers[Key].Identity = Identity
                                        IdentifyingPlayers[Key].Job = vRP.getUserGroupByType({UserID2, 'job'})
                                    end})
                                end
                            elseif Config.General.InfoMode == 4 then
                                HasDriversLicense(UserID2, function(HasDL)
                                    if HasDL then
                                        vRP.getUserIdentity({UserID2, function(Identity)
                                            IdentifyingPlayers[Key].Identity = Identity
                                            IdentifyingPlayers[Key].Job = vRP.getUserGroupByType({UserID2, 'job'})
                                        end})
                                    end
                                end)
                            elseif Config.General.InfoMode == 5 then
                                local HasAny = false

                                for _, v in pairs(Config.General.InfoItems) do
                                    if vRP.getInventoryItemAmount({UserID2, v}) > 0 then
                                        HasAny = true
                                        break
                                    end
                                end

                                if HasAny then
                                    vRP.getUserIdentity({UserID2, function(Identity)
                                        IdentifyingPlayers[Key].Identity = Identity
                                        IdentifyingPlayers[Key].Job = vRP.getUserGroupByType({UserID2, 'job'})
                                    end})
                                else
                                    HasDriversLicense(UserID2, function(HasDL)
                                        if HasDL then
                                            vRP.getUserIdentity({UserID2, function(Identity)
                                                IdentifyingPlayers[Key].Identity = Identity
                                                IdentifyingPlayers[Key].Job = vRP.getUserGroupByType({UserID2, 'job'})
                                            end})
                                        end
                                    end)
                                end
                            elseif Config.General.InfoMode == 6 then
                                vRP.request({Player2, Config.General.TjekIDRequestTekst, Config.General.TjekIDRequestTime, function(Player3, HarID)
                                    if IdentifyingPlayers[Key] ~= nil then
                                        if HarID then
                                            vRP.getUserIdentity({UserID2, function(Identity)
                                                IdentifyingPlayers[Key].Identity = Identity
                                                IdentifyingPlayers[Key].Job = vRP.getUserGroupByType({UserID2, 'job'})
                                                if IdentifyingPlayers[Key].IdentityFunc ~= nil then
                                                    IdentifyingPlayers[Key].IdentityFunc()
                                                end
                                            end})
                                        end
                                    end
                                end})
                            end
        
                            if Config.General.TjekPuls then
                                if Config.General.TjekPulsMode == 1 then
                                    vRP.request({Player2, Config.General.TjekPulsRequestTekst, Config.General.TjekPulsRequestTime, function(Player3, HarPuls)
                                        if IdentifyingPlayers[Key] ~= nil then
                                            if HarPuls ~= nil then
                                                IdentifyingPlayers[Key].HarPuls = HarPuls
                                                if IdentifyingPlayers[Key].HarPulsFunc ~= nil then
                                                    IdentifyingPlayers[Key].HarPulsFunc()
                                                end
                                            else
                                                SendNotification(Player, 'ServerError')
                                            end
                                        end
                                    end})
                                elseif Config.General.TjekPulsMode == 2 then
                                    vRP.request({Player2, Config.General.TjekPulsRequestTekst, Config.General.TjekPulsRequestTime, function(Player3, HarPuls)
                                        if IdentifyingPlayers[Key] ~= nil then
                                            if HarPuls ~= nil then
                                                if HarPuls then
                                                    local TimesClosed = 0
        
                                                    local Menu = {
                                                        name = Config.General.TjekPulsMenuHeaderTekst,
                                                        css = {
                                                            top = '75px',
                                                            header_color = Config.General.TjekPulsMenuHeaderColor
                                                        },
                                                        onclose = function()
                                                            TimesClosed = TimesClosed + 1
                                                            if TimesClosed >= Config.General.TjekPulsMenuMaxClosesBeforeDefault then
                                                                IdentifyingPlayers[Key].HarPuls = Config.General.TjekPulsDefaultPuls
                                                                if IdentifyingPlayers[Key].HarPulsFunc ~= nil then
                                                                    IdentifyingPlayers[Key].HarPulsFunc()
                                                                end
                                                                vRP.closeMenu({Player3})
                                                            end
                                                        end
                                                    }
        
                                                    for _, v in pairs(Config.General.TjekPulsValues) do
                                                        Menu[v] = {
                                                            function(Player4, Valg)
                                                                IdentifyingPlayers[Key].HarPuls = Valg
                                                                if IdentifyingPlayers[Key].HarPulsFunc ~= nil then
                                                                    IdentifyingPlayers[Key].HarPulsFunc()
                                                                end
                                                                vRP.closeMenu({Player4})
                                                            end
                                                        }
                                                    end
        
                                                    vRP.openMenu({Player3, Menu})
                                                else
                                                    IdentifyingPlayers[Key].HarPuls = false
                                                    if IdentifyingPlayers[Key].HarPulsFunc ~= nil then
                                                        IdentifyingPlayers[Key].HarPulsFunc()
                                                    end
                                                end
                                            else
                                                SendNotification(Player, 'ServerError')
                                            end
                                        end
                                    end})
                                elseif Config.General.TjekPulsMode == 3 then
                                    local TimesClosed = 0
        
                                    local Menu = {
                                        name = Config.General.TjekPulsMenuHeaderTekst,
                                        css = {
                                            top = '75px',
                                            header_color = Config.General.TjekPulsMenuHeaderColor
                                        },
                                        onclose = function()
                                            TimesClosed = TimesClosed + 1
                                            if TimesClosed >= Config.General.TjekPulsMenuMaxClosesBeforeDefault then
                                                IdentifyingPlayers[Key].HarPuls = Config.General.TjekPulsDefaultPuls
                                                if IdentifyingPlayers[Key].HarPulsFunc ~= nil then
                                                    IdentifyingPlayers[Key].HarPulsFunc()
                                                end
                                                vRP.closeMenu({Player3})
                                            end
                                        end
                                    }
        
                                    for _, v in pairs(Config.General.TjekPulsValues) do
                                        Menu[v] = {
                                            function(Player4, Valg)
                                                IdentifyingPlayers[Key].HarPuls = Valg
                                                if IdentifyingPlayers[Key].HarPulsFunc ~= nil then
                                                    IdentifyingPlayers[Key].HarPulsFunc()
                                                end
                                                vRP.closeMenu({Player4})
                                            end
                                        }
                                    end
        
                                    Menu['Ingen puls'] = {
                                        function(Player4, Valg)
                                            IdentifyingPlayers[Key].HarPuls = Valg
                                            if IdentifyingPlayers[Key].HarPulsFunc ~= nil then
                                                IdentifyingPlayers[Key].HarPulsFunc()
                                            end
                                            vRP.closeMenu({Player4})
                                        end
                                    }
        
                                    vRP.openMenu({Player3, Menu})
                                elseif Config.General.TjekPulsMode == 4 then
                                    vRP.prompt({player, Config.General.TjekPulsPromptName, Config.General.TjekPulsPromptDefault, function(Player4, Puls)
                                        if Puls ~= nil then
                                            IdentifyingPlayers[Key].HarPuls = Puls
                                            if IdentifyingPlayers[Key].HarPulsFunc ~= nil then
                                                IdentifyingPlayers[Key].HarPulsFunc()
                                            end
                                            vRP.closeMenu({Player4})
                                        else
                                            SendNotification(Player, 'ServerError')
                                        end
                                    end})
                                end
                            end
                        else
                            SendNotification(Player, 'ServerError')
                        end
                    else
                        SendNotification(Player, 'NoPermission')
                        TriggerClientEvent('Wolxy:IdentifyDead:HasPerm', Player, false)
                    end
                else
                    SendNotification(Player, 'ServerError')
                end
            end)
        else
            SendNotification(Player, 'ServerError')
        end
    else
        SendNotification(Player, 'ServerError')
    end
end)

RegisterNetEvent('Wolxy:IdentifyDead:Identify')
AddEventHandler('Wolxy:IdentifyDead:Identify', function(Player2)
    local Player = source
    local UserID = vRP.getUserId({Player})
    local UserID2 = vRP.getUserId({Player2})

    if UserID ~= nil then
        if UserID2 ~= nil then
            if DoesPlayerHaveAccess(UserID) then
                local Key = Player .. '|' .. Player2
                if IdentifyingPlayers[Key] ~= nil then
                    if IdentifyingPlayers[Key].Identity ~= nil then
                        if IdentifyingPlayers[Key].HarPuls ~= nil then
                            PlayerIdentifiedNotif(Player, Key, IdentifyingPlayers[Key].Identity, IdentifyingPlayers[Key].Job, IdentifyingPlayers[Key].HarPuls)
                        else
                            IdentifyingPlayers[Key].HarPulsFunc = function()
                                PlayerIdentifiedNotif(Player, Key, IdentifyingPlayers[Key].Identity, IdentifyingPlayers[Key].Job, IdentifyingPlayers[Key].HarPuls)
                            end
                        end
                    else
                        if Config.General.InfoMode == 6 then
                            IdentifyingPlayers[Key].IdentityFunc = function()
                                if IdentifyingPlayers[Key].HarPuls ~= nil then
                                    PlayerIdentifiedNotif(Player, Key, IdentifyingPlayers[Key].Identity, IdentifyingPlayers[Key].Job, IdentifyingPlayers[Key].HarPuls)
                                else
                                    IdentifyingPlayers[Key].HarPulsFunc = function()
                                        PlayerIdentifiedNotif(Player, Key, IdentifyingPlayers[Key].Identity, IdentifyingPlayers[Key].Job, IdentifyingPlayers[Key].HarPuls)
                                    end
                                end
                            end
                        else
                            SendNotification(Player, 'NoIDFound')
                            IdentifyingPlayers[Key] = nil
                        end
                    end
                else
                    SendNotification(Player, 'ServerError')
                end
            else
                SendNotification(Player, 'NoPermission')
                TriggerClientEvent('Wolxy:IdentifyDead:HasPerm', Player, false)
            end
        else
            SendNotification(Player, 'ServerError')
        end
    else
        SendNotification(Player, 'ServerError')
    end
end)

function PlayerIdentifiedNotif(Player, Key, Identity, Job, HarPuls)
    local Notifikation = Config.Notifikationer.Notifikationer.Identified

    local Tekst = Config.General.InfoToShow
    Tekst = string.gsub(Tekst, '{Fornavn}', Identity.firstname)
    Tekst = string.gsub(Tekst, '{Efternavn}', Identity.name)
    Tekst = string.gsub(Tekst, '{Telefon}', Identity.phone)
    Tekst = string.gsub(Tekst, '{CPR}', Identity.registration)
    Tekst = string.gsub(Tekst, '{Alder}', Identity.age)
    Tekst = string.gsub(Tekst, '{Job}', Job)

    local System = Notifikation.SystemOverride or Config.Notifikationer.System
    System = string.lower(System)

    if System == 'custom' then
        TriggerClientEvent('Wolxy:IdentifyDead:Notif', Player, {
            Tekst = Tekst,
            Type = Notifikation.Type,
            Location = Notifikation.Location,
            Timeout = Notifikation.Timeout,
            ProgressBar = Notifikation.ProgressBar
        })
    elseif System == 'pnotify' then
        TriggerClientEvent('pNotify:SendNotification', Player, {
            type = Notifikation.Type,
            layout = Vars.Notifikationer.pNotify.Locations[Notifikation.Location],
            text = Tekst,
            timeout = Notifikation.Timeout,
            progressBar = Notifikation.ProgressBar
        })
    elseif System == 'mythic_notify' or System == 'mythic' then
        TriggerClientEvent('Wolxy:IdentifyDead:MythicNotif', Player, Vars.Notifikationer.Mythic.Types[Notifikation.Type], Notifikation.Timeout, Tekst)
    else
        SendNotification(Player, 'ServerError')
    end
end

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

function HasDriversLicense(UserID, CB)
    MySQL.query('vRP/dmv_search', {id = UserID}, function(Rows)
        CB(#Rows > 0)
    end)
end

-- Dont touch!
IdentifyingPlayers = {}
CanOrCantBeIdentified = {}

function UpdateCanOrCantBeIdentified()
    for k, v in pairs(CanOrCantBeIdentified) do
        vRPclient.isInComa(k, {}, function(InComa)
            if not InComa then
                CanOrCantBeIdentified[k] = nil
            end
        end)
    end

    SetTimeout(5000, UpdateCanOrCantBeIdentified)
end

UpdateCanOrCantBeIdentified()





-- DONT TOUCH!!
RegisterNetEvent('Wolxy:IdentifyDead:ScumbagDetected')
AddEventHandler('Wolxy:IdentifyDead:ScumbagDetected', function()
    print('^1Tjek venligst i bunden af Client.lua i resourcen: ' .. ResourceName)
end)