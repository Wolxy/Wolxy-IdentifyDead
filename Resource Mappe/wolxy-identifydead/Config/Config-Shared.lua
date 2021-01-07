--[[
    Du kan lære mere om konfiguration her: https://github.com/Wolxy/Wolxy-IdentifyDead/blob/development/Dokumentation/Konfiguration.md
]]--

Config = {
    ['General'] = { -- Basic ting i scriptet som jeg ikke kunne finde en anden kategori til.
        CheckForUpdates = true, -- Om scriptet skal tjekke om du bruger den nyeste version ved script start.
        PermissionRequired = nil, -- Den permission man skal have for at tjekke identitet og puls. Sæt til nil hvis alle spillere skal kunne.
        InfoToShow = 'Navn: {Fornavn} {Efternavn}<br>CPR: {CPR}<br>Alder: {Alder}', -- Hvad der skal stå når man undersøger en død spiller. Se under Config for at se alle placeholders. Skriv <br> for at lave en ny linje. Der vil blive tilføjet en linje mere hvis TjekPuls er slået til.
        InfoMode = 1, -- Hvordan identificering skal fungere og hvornår man kan. Se under Config for at se alle modes og forklaringer.
        InfoChance = 75, -- Hvor stor en chance man har for at kunne identificere en person. Dette virker kun hvis InfoMode er sat til 2.
        InfoItems = { -- De items en død person skal have på sig før man kan identificere dem (det er kun nødvendigt at de 1 en de følgende items på sig). Dette virker kun hvis InfoMode er sat til 3. Kunne måske være brugbart hvis din server har et item til sygesikringskort.
            'idkort'
        }
        TjekPuls = true, -- Om den døde spiller skal spørges om han / hun har puls. Dette vil blive vist til den der undersøger hvis denne indstilling er true.
        MaxDistance = 4, -- Den afstand man maksimalt må være væk fra en død spiller før at det tæller som at være i nærheden.
        DistanceUpdateInterval = 75, -- Hvor lang tid, i ms, der skal gå mellem hver opdatering af afstand. En for lav værdi kan lagge og en for høj værdi ville opdatere, og derfor tilføje 3D tekst, for sent og fjerne det for sent. Standard værdien er anbefalet.
        Button = 38 -- Den knap man skal trykke på for at finde identitet og tjekke puls.
    },
    ['3DText'] = { -- Indstillinger til 3D teksten der kommer over den nærmeste døde spiller
        Color = { -- Standard farven for 3D teksten, denne farve kan ændres af farvekoder som du kan se her: https://wiki.rage.mp/index.php?title=Fonts_and_Colors under GTA Colors.
            R = 255,
            G = 255,
            B = 255,
            A = 255 -- Jo lavere dette tal er, jo mere gennemsigtig er teksten (maks: 255), dette kan ikke ændres af farvekoder.
        },
        Font = 0, -- Den skrifttype 3D teksten skal stå med. Du kan finde alle skrifttyper i bunden af denne side: https://wiki.rage.mp/index.php?title=Fonts_and_Colors
        Scale = 0.75, -- Hvor stor 3D teksten skal være.
        Text = 'Tryk på ~b~{Knap}~s~ for at finde identitet og tjekke puls.', -- Det tekst der skal stå over den nærmeste døde spiller. "{Knap}" bliver automatisk ændret til den knap der er valgt under ['General'].
    },
    ['Notifikationer'] = { -- Indstillinger for notifikationer.
        System = 'Custom', -- Hvilket system der skal bruges til notifikationer. Se under Config for en liste over understøttede systemer.
        Notifikationer = { -- Alle notifikationer
            ServerError = { -- Notifikation til en spilelr hvis der opstod en server fejl.
                Tekst = 'Der opstod en server fejl, prøv venligst igen senere.', -- Teksten der skal stå i notifikationen.
                Type = 'error', -- Type af notifikation. Bestemmer ofte farve. (Virker ikke til mythic_notify notifikationer)
                Timeout = 4500, -- Hvor lang tid (i ms) notifikationen skal være på skærmen. (Virker ikke til GTA notifikationer)
                Location = 'BC', -- Lokation af notifikationen på skærmen. Se under Config for en forklaring. (Virker ikke til GTA notifikationer eller mythic_notify notifikationer)
                ProgressBar = true, -- Om der skal være en "progress bar" der viser hvornår notifikationen forsvinder. (Virker ikke til GTA notifikationer eller mythic_notify notifikationer)
                Important = true, -- Om notifikationen skal blinke når den kommer. (Virker kun til GTA notifikationer)
                SystemOverride = nil -- Ændrer notifikations systemet der skal bruges til denne notifikation. Sæt til nil hvis den der er valgt under Notifikationer.System skal bruges.
            },
            NoPermission = { -- Notifikation til spillere som, på en eller anden måde, prøve at identificere en spiller uden at have tilladelse.
                Tekst = 'Det har du ikke tilladelse til!', -- Teksten der skal stå i notifikationen.
                Type = 'error', -- Type af notifikation. Bestemmer ofte farve. (Virker ikke til mythic_notify notifikationer)
                Timeout = 4500, -- Hvor lang tid (i ms) notifikationen skal være på skærmen. (Virker ikke til GTA notifikationer)
                Location = 'BC', -- Lokation af notifikationen på skærmen. Se under Config for en forklaring. (Virker ikke til GTA notifikationer eller mythic_notify notifikationer)
                ProgressBar = true, -- Om der skal være en "progress bar" der viser hvornår notifikationen forsvinder. (Virker ikke til GTA notifikationer eller mythic_notify notifikationer)
                Important = true, -- Om notifikationen skal blinke når den kommer. (Virker kun til GTA notifikationer)
                SystemOverride = nil -- Ændrer notifikations systemet der skal bruges til denne notifikation. Sæt til nil hvis den der er valgt under Notifikationer.System skal bruges.
            }
        }
    }
}

--[[
    Placeholders er tekst som scriptet automatisk ændrer til det information som placeholderen skal vise, altså det information om den døde spiller.
    Eksempler:
        {Fornavn} bliver måske til: Nikolas
        {Efternavn} bliver måske til: Hansen

    Alle placeholders:
        {Fornavn}: Den døde spillers karakters fornavn.
        {Efternavn}: Den døde spillers karakters efternavn.
        {CPR}: Den døde spillers karakters CPR nummer.
        {Alder} Den døde spillers karakters alder.
]]--

--[[
    Her er de forskellige modes til InfoMode:
        1: Man kan altid identificere en person.
        2: Scriptet vælger tilfældigt om man kan identificere en person. Chancen kan ændres i Config.General.InfoChance.
        3: Man kan kun identificere en person hvis de har et bestemt item der er på en liste på sig. Listen af items der tæller kan ændres i Config.General.InfoItems.
        4: Man kan kun identificere en person hvis de har et kørekort.
        5: En blanding af 3 og 4. Man kan kun identificere en person hvis de har et bestemt item der er på en liste eller et kørekort. Listen af items der tæller kan ændres i Config.General.InfoItems.
        6: Den døde spiller bliver spurgt om de har noget id på sig som man kan undersøge. Hvis de har så kan man identificere dem. Hvis ikke så kan man ikke identificere dem.
]]--

--[[
    Understøttede nofitikations systemer (skal skrives som de står herunder):
        GTA
        pNotify
        mythic_notify
        Custom
]]--

--[[
    Forklaring af notifikations lokationer.
        Første bogstav (lodret position):
            T: Toppen af skærmen. (Top)
            C: Midten af skærmen. (Center)
            B: Bunden af skærmen. (Bottom)

        Andet bogstav (vandret position):
            L: Venstre side af skærmen. (Left)
            C: Midten af skærmen. (Center)
            R: Højre side af skærmen. (Right)

    Eksempler:
        BC: I midten og i bunden af skærmen.
        TR: Øverst højre hjørne af skærmen.
        BL: Nederst venstre hjørne af skærmen.
]]--