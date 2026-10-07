-- Define the addon namespace
local addonName, addon = ...

--local addonName = "DoReadyTalentImporter" -- Replace with your addon's folder name
local version = C_AddOns.GetAddOnMetadata(addonName, "Version")
--print("DoReadyTalentImporter v" .. version .. " loaded.")

--MapName: The MOTHERLODE!! mapid: 1010 
--MapName: Cinderbrew Meadery mapid: 2335 
--MapName: Darkflame Cleft mapid: 2303 
--MapName: Priory of the Sacred Flame mapid: 2308 
--MapName: The Rookery mapid: 2316 
--MapName: Operation: Floodgate mapid: 2387 
--MapName: Mechagon mapid: 1491 
--MapName: Theater of Pain mapid: 1683
--MapName: Undermine mapid: 2406

local currentSeasonInstances = {
    --["The Rookery"] = "Rookery",
    --["Cinderbrew Meadery"] = "Meadery",
    --["Darkflame Cleft"] = "Darkflame",
    --["Priory of the Sacred Flame"] = "Priory",
    --["Operation: Floodgate"] = "Floodgate",
    --["Theater of Pain"] = "Theater",
    --["Mechagon"] = "Mechagon",
    --["The MOTHERLODE!!"] = "MOTHERLODE",
    --["Undermine"] = "Undermine",
    ["City of Echoes"] = "AraKara",
    ["Eco-Dome Al'dani"] = "EcoDome",
    ["Halls of Atonement"] = "HoA",
    ["Operation: Floodgate"] = "Floodgate",
    ["Priory of the Sacred Flame"] = "Priory",
    ["Tazavesh, So'leah's Gambit"] = "Gambit",
    ["Tazavesh, Streets of Wonder"] = "Streets",
    ["The Dawnbreaker"] = "Dawnbreaker",
    ["Manaforge Omega"] = "Manaforge",

    ["Altar of Fangs"] = "altar-of-fangs",
    ["Den of Nalorakk"] = "den-of-nalorakk",
    ["Kings Rest"] = "kings-rest",
    ["Murder Row"] = "murder-row",
    ["Ruby Life Pools"] = "ruby-life-pools",
    ["Sethraliss"] = "sethraliss",
    ["The Blinding Vale"] = "the-blinding-vale",
    ["Voidscar Arena"] = "voidscar-arena",
    ["Nekzali"] = "nekzali",
    ["Sentinels"] = "sentinels",
    ["Vashnik"] = "vashnik",
    ["Explorers"] = "explorers",
    ["Sszorak"] = "sszorak",
    ["The Twin Fangs"] = "the-twin-fangs",
    ["The Coiled Altar"] = "the-coiled-altar",
    ["Ulatek"] = "ulatek",
    ["Nymrissa"] = "nymrissa",
}

-- Create a basic addon frame
--local frame = CreateFrame("Frame")

-- Register the PLAYER_ENTERING_WORLD event to trigger when the player enters the game
--frame:RegisterEvent("READY_CHECK")

-- Function to get the current map name
function addon.GetCurrentMapName()
    local mapName = ""
    local uiMapID = C_Map.GetBestMapForUnit("player") -- Get the map ID for the player's current location
    if uiMapID then
        local mapInfo = C_Map.GetMapInfo(uiMapID) -- Get map information
        if mapInfo and mapInfo.name then
            mapName = mapInfo.name -- Return the map name
        end
    end
    --print("You are currently in: " .. mapName) -- Print the map name to the chat window
    --local configID = C_ClassTalents.GetActiveConfigID()
    --local talID = C_ClassTalents.GetLastSelectedSavedConfigID(PlayerUtil.GetCurrentSpecID())
    ----print("Last selected config ID:", talID) -- Print the last selected config ID
    --local configInfo = C_Traits.GetConfigInfo(talID)
    ----print("Config ID:", configID, "Name:", configInfo.name) -- Print the config ID and name
    --if string.find(configInfo.name, mapName) then
    --    print("DoReady talent profile for instance is active.")
    --else
    --    print("DoReady talent profile for instance is not active.")
    --end
    return mapName
end

---- Event handler function
--frame:SetScript("OnEvent", function(self, event, ...)
--    if event == "READY_CHECK" then
--        C_Timer.After(3, addon.GetCurrentMapName)
--    end
--end)

local function ImportTalentProfile(class, spec, loadoutName, importString)
    TogglePlayerSpellsFrame()
    --print("Importing talent profile for class:", class, "spec:", spec, "name:", loadoutName, "importString:", importString)
    --print("Importing talent profile for class:", class, "spec:", spec, "name:", loadoutName)
    --if class then
    --    return
    --end
    local canCreate = C_ClassTalents.CanCreateNewConfig()
    if not canCreate then
        --print("Cannot create new config.")
        return
    end
    if not C_AddOns.IsAddOnLoaded("Blizzard_PlayerSpells") then
        local loaded = C_AddOns.LoadAddOn("Blizzard_PlayerSpells")
    end
    local configIDs = C_ClassTalents.GetConfigIDsBySpecID(PlayerUtil.GetCurrentSpecID())
    --C_ClassTalents.RequestNewConfig(loadoutName)

    --for i,id in ipairs(configIDs) do
    --    local configInfo = C_Traits.GetConfigInfo(id)
    --    --print("Config ID:", id, "Name:", configInfo.name)
    --    if configInfo.name == loadoutName then
    --        local CurimportString = C_Traits.GenerateImportString(id)
    --        print("CurimportString: ", CurimportString)
    --        if CurimportString ~= importString then
    --            AskLoadTalent()
    --        end
    --    end
    --end

    local configID = C_ClassTalents.GetActiveConfigID()
    local configInfo = C_Traits.GetConfigInfo(configID)
    local treeID = configInfo and configInfo.treeIDs and configInfo.treeIDs[1]
    local importStream = ExportUtil.MakeImportDataStream(importString)
    local headerValid, serializationVersion, specID, treeHash = ClassTalentImportExportMixin:ReadLoadoutHeader(importStream)
    if not headerValid then
        --print("Invalid import string.")
        return
    end
    local loadoutContent = ClassTalentImportExportMixin:ReadLoadoutContent(importStream, treeID)
    local loadoutEntryInfo = ClassTalentImportExportMixin:ConvertToImportLoadoutEntryInfo(configID, treeID, loadoutContent)
    local success, err = C_ClassTalents.ImportLoadout(configID, loadoutEntryInfo, loadoutName)
    --local success, err = ClassTalentImportExportMixin:ImportLoadout(importString,loadoutName)
    --ClassTalentImportExportMixin:ViewLoadout(importString, 80)
    --if not success then
    --    print("Import failed:", err)
    --else
    --    print("Talent profile '" .. loadoutName .. "' imported successfully.")
    --end

    --print("imported string: ", importString)

    configIDs = C_ClassTalents.GetConfigIDsBySpecID(PlayerUtil.GetCurrentSpecID())
    for i,id in ipairs(configIDs) do
        local configInfo = C_Traits.GetConfigInfo(id)
        --print("Config ID:", id, "Name:", configInfo.name)
        if configInfo.name == loadoutName then
            local CurimportString = C_Traits.GenerateImportString(id)
            if CurimportString ~= addon.talents[class][string.upper(spec)][addon.GetCurrentMapName()] then
                C_ClassTalents.DeleteConfig(id)
                --print("cleaned up old config")
            end
        end
    end
end

local function AskToUpdateTalents(class, spec, loadoutName, importString, CurrentMapName)
    -- Define the popup dialog
    StaticPopupDialogs["UCG_UPDATE_CONFIRMATION"] = {
        text = "Import new Talents for "  .. CurrentMapName .. "?(if accepted, don't move if change talents is casted!)",
        button1 = "Accept",
        button2 = "Cancel",
        OnAccept = function()
            --print("You accepted!")
            ImportTalentProfile(class, spec, loadoutName, importString)
            -- Add your logic for the "Accept" action here
        end,
        OnCancel = function()
            --print("You canceled!")
            -- Add your logic for the "Cancel" action here
        end,
        timeout = 0, -- No timeout
        whileDead = true, -- Allow popup while the player is dead
        hideOnEscape = true, -- Close the popup when pressing Escape
        preferredIndex = 3, -- Avoid conflicts with other popups
    }
    -- Show the popup
    StaticPopup_Show("UCG_UPDATE_CONFIRMATION")
end

local function AskToActivateTalents(configID, autoApply, CurrentMapName)
    -- Define the popup dialog
    StaticPopupDialogs["UCG_ACTIVATE_CONFIRMATION"] = {
        text = "Change To Talents for "  .. CurrentMapName .. "?(if accepted, don't move if change talents is casted!)",
        button1 = "Accept",
        button2 = "Cancel",
        OnAccept = function()
            --print("You accepted!")
            local result, changeError, newLearnedNodeIDs = C_ClassTalents.LoadConfig(configID, autoApply)
            --print("LoadConfig result:", type(result), "Change error:", changeError, "New learned node IDs:", newLearnedNodeIDs)
            C_ClassTalents.UpdateLastSelectedSavedConfigID(PlayerUtil.GetCurrentSpecID(), configID)
            if result ~= 0 then
                --print("LoadConfig success:", result)
                C_Timer.After(3, function()
                    C_ClassTalents.UpdateLastSelectedSavedConfigID(PlayerUtil.GetCurrentSpecID(), configID)
                end)
                --C_ClassTalents.UpdateLastSelectedSavedConfigID(PlayerUtil.GetCurrentSpecID(), configID)
            end
            -- Add your logic for the "Accept" action here
        end,
        OnCancel = function()
            --print("You canceled!")
            -- Add your logic for the "Cancel" action here
        end,
        timeout = 0, -- No timeout
        whileDead = true, -- Allow popup while the player is dead
        hideOnEscape = true, -- Close the popup when pressing Escape
        preferredIndex = 3, -- Avoid conflicts with other popups
    }
    -- Show the popup
    StaticPopup_Show("UCG_ACTIVATE_CONFIRMATION")
end

function addon:CheckTalentUpdate(class, spec, CurrentMapName, importString)
    local configIDs = C_ClassTalents.GetConfigIDsBySpecID(PlayerUtil.GetCurrentSpecID())
    local configUpdate = false
    local configExists = false
    for i,id in ipairs(configIDs) do
        local configInfo = C_Traits.GetConfigInfo(id)
        --print("Config ID:", id, "Name:", configInfo.name)
        if currentSeasonInstances[CurrentMapName] then
            if configInfo.name == "UCG " .. currentSeasonInstances[CurrentMapName] .. " " .. version then
                local CurimportString = C_Traits.GenerateImportString(id)
                --print("CurimportString for ", configInfo.name .. " : ", CurimportString)
                configExists = true
            end
        end
    end
    if not configExists then
        --print("config not found")
        if addon.talents[class][spec][currentSeasonInstances[CurrentMapName]] then
            --print("found update for zone")
            configUpdate = true
        end
    end
    --print("ConfigUpdate: ", configUpdate)
    if configUpdate then
        local loadoutName = "UCG " .. currentSeasonInstances[CurrentMapName] .. " " .. version
        AskToUpdateTalents(class, spec, loadoutName, importString, CurrentMapName)
    end
end

local frame = CreateFrame("Frame")
--frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("LOADING_SCREEN_DISABLED")
frame:RegisterEvent("READY_CHECK")

frame:SetScript("OnEvent", function(self, event)
    --if not SavedSettings.automaticMode then return end
    if event == "LOADING_SCREEN_DISABLED" then
        local _, playerClass = UnitClass("player")
        playerClass = playerClass:gsub("(%a)(%w*)", function(a, b)
            return a:upper() .. b:lower()
        end)
        local specIndex = GetSpecialization()
        local specID = GetSpecializationInfo(specIndex)
        local specNames = {
            [62] = "Arcane",
            [63] = "Fire",
            [64] = "Frost",
            [65] = "Holy",
            [66] = "Protection",
            [70] = "Retribution",
            [71] = "Arms",
            [72] = "Fury",
            [73] = "Protection",
            [102] = "Balance",
            [103] = "Feral",
            [104] = "Guardian",
            [105] = "Restoration",
            [250] = "Blood",
            [251] = "Frost",
            [252] = "Unholy",
            [253] = "Beast Mastery",
            [254] = "Marksmanship",
            [255] = "Survival",
            [256] = "Discipline",
            [257] = "Holy",
            [258] = "Shadow",
            [259] = "Assassination",
            [260] = "Outlaw",
            [261] = "Subtlety",
            [262] = "Elemental",
            [263] = "Enhancement",
            [264] = "Restoration",
            [265] = "Affliction",
            [266] = "Demonology",
            [267] = "Destruction",
            [268] = "Brewmaster",
            [269] = "Windwalker",
            [270] = "Mistweaver",
            [577] = "Havoc",
            [581] = "Vengeance",
            [1467] = "Devastation",
            [1468] = "Preservation",
            [1473] = "Augmentation",
        }
        C_Timer.After(3, function()
            if not C_AddOns.IsAddOnLoaded("Blizzard_PlayerSpells") then
                C_AddOns.LoadAddOn("Blizzard_PlayerSpells")
            end
            --for name in pairs(currentSeasonInstances) do
            --    CheckTalentUpdate(playerClass,specNames[specID], name , addon.TalentStrings[playerClass][string.upper(specNames[specID])][name])
            --end
            --if addon.talents[playerClass][specNames[specID]][addon.GetCurrentMapName()] then
            --    addon:CheckTalentUpdate(playerClass,specNames[specID], addon.GetCurrentMapName(), addon.talents[playerClass][specNames[specID]][addon.GetCurrentMapName()])
            --end
            local classTalents = addon.talents[playerClass]
            local specName = specNames[specID]
            local mapName = addon.GetCurrentMapName()
            local mapNameTable = currentSeasonInstances[addon.GetCurrentMapName()]
            --print("Checking talents for class:", playerClass, "spec:", specName, "map:", mapName, "mapNameTable:", mapNameTable)
            
            if classTalents and specName and classTalents[specName] and classTalents[specName][mapNameTable] then
                --print("Checking talents for class:", playerClass, "spec:", specName, "map:", mapName)
                addon:CheckTalentUpdate(playerClass, specName, mapName, classTalents[specName][mapNameTable])
            end
            local specID = PlayerUtil.GetCurrentSpecID()
            if specID then
                -- Get the ID of the last selected saved talent loadout for the current spec
                local activeConfigID = C_ClassTalents.GetLastSelectedSavedConfigID(specID)
                if activeConfigID then
                    -- Get information about the active talent loadout
                    local configInfo = C_Traits.GetConfigInfo(activeConfigID)
                    if configInfo and configInfo.name and configInfo.name ~= loadoutName then
                        --print("Active Talent Loadout Name: " .. configInfo.name)
                        local configIDs = C_ClassTalents.GetConfigIDsBySpecID(PlayerUtil.GetCurrentSpecID())
                        for i,id in ipairs(configIDs) do
                            local configInfo = C_Traits.GetConfigInfo(id)
                            --print("Config ID:", id, "Name:", configInfo.name)
                            if configInfo.name == loadoutName then
                                AskToActivateTalents(id, true, currentSeasonInstances[addon.GetCurrentMapName()])
                            end
                        end
                    end
                end
            end
            if addon.GetCurrentMapName() == "Tazavesh, the Veiled Market" then
                print("DoReady Detected Tazavesh, the Veiled Market, import from gui.)")
                addon:OpenUI("")
            end
        end)
    end
    if event == "READY_CHECK" then
        C_Timer.After(3, function()
            if currentSeasonInstances[addon.GetCurrentMapName()] then
                local loadoutName = "UCG " .. currentSeasonInstances[addon.GetCurrentMapName()] .. " " .. version
                -- Get the current specialization ID
                local specID = PlayerUtil.GetCurrentSpecID()
                if specID then
                    -- Get the ID of the last selected saved talent loadout for the current spec
                    local activeConfigID = C_ClassTalents.GetLastSelectedSavedConfigID(specID)
                    if activeConfigID then
                        -- Get information about the active talent loadout
                        local configInfo = C_Traits.GetConfigInfo(activeConfigID)
                        if configInfo and configInfo.name and configInfo.name ~= loadoutName then
                            --print("Active Talent Loadout Name: " .. configInfo.name)
                            local configIDs = C_ClassTalents.GetConfigIDsBySpecID(PlayerUtil.GetCurrentSpecID())
                            for i,id in ipairs(configIDs) do
                                local configInfo = C_Traits.GetConfigInfo(id)
                                --print("Config ID:", id, "Name:", configInfo.name)
                                if configInfo.name == loadoutName then
                                    AskToActivateTalents(id, true, currentSeasonInstances[addon.GetCurrentMapName()])
                                end
                            end
                        end
                    end
                end
            end
        end)
    end
end)

addon.RecheckTalentUpdate = function()
    local _, playerClass = UnitClass("player")
    local specIndex = GetSpecialization()
    local specID = GetSpecializationInfo(specIndex)
    local specNames = {
        [62] = "Arcane",
        [63] = "Fire",
        [64] = "Frost",
        [65] = "Holy",
        [66] = "Protection",
        [70] = "Retribution",
        [71] = "Arms",
        [72] = "Fury",
        [73] = "Protection",
        [102] = "Balance",
        [103] = "Feral",
        [104] = "Guardian",
        [105] = "Restoration",
        [250] = "Blood",
        [251] = "Frost",
        [252] = "Unholy",
        [253] = "Beast Mastery",
        [254] = "Marksmanship",
        [255] = "Survival",
        [256] = "Discipline",
        [257] = "Holy",
        [258] = "Shadow",
        [259] = "Assassination",
        [260] = "Outlaw",
        [261] = "Subtlety",
        [262] = "Elemental",
        [263] = "Enhancement",
        [264] = "Restoration",
        [265] = "Affliction",
        [266] = "Demonology",
        [267] = "Destruction",
        [268] = "Brewmaster",
        [269] = "Windwalker",
        [270] = "Mistweaver",
        [577] = "Havoc",
        [581] = "Vengeance",
        [1467] = "Devastation",
        [1468] = "Preservation",
        [1473] = "Augmentation",
    }

    if not C_AddOns.IsAddOnLoaded("Blizzard_PlayerSpells") then
        C_AddOns.LoadAddOn("Blizzard_PlayerSpells")
    end
    --for name in pairs(currentSeasonInstances) do
    --    CheckTalentUpdate(playerClass,specNames[specID], name , addon.TalentStrings[playerClass][string.upper(specNames[specID])][name])
    --end
    addon:CheckTalentUpdate(playerClass,specNames[specID], currentSeasonInstances[addon.GetCurrentMapName()], addon.TalentStrings[playerClass][string.upper(specNames[specID])][addon.GetCurrentMapName()])

end

