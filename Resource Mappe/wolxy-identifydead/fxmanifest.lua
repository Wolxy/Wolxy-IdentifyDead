name 'Wolxy-IdentifyDead'
author 'William Heldgaard / WillyGamez / Wolxy'
description 'Et vRP script der giver alle spillere (eller dem med en bestemt permission) mulighed for at undersøge døde spiller. Det vil sige at de f.eks kan finde navn, cpr nummer, alder osv. Scriptet gør det også muligt at tjekke puls. Alt dette kan konfigureres meget nemt og du kan helt selv vælge hvad man kan finde på en død spiller.'

dependency 'vrp'

client_scripts {
    'Config/Config-Shared.lua',
	'Client.lua'
}

server_scripts {
	'@vrp/lib/utils.lua',
    '@vrp/lib/Tools.lua',
    'Config/Config-Shared.lua',
    'Vars/Vars-S.lua',
	'Server.lua'
}

-- Skal være her!
files {
    'LICENSE'
}

fx_version 'adamant'
game 'gta5'