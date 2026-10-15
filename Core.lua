local _, AddonTable = ...

local GetItemInfo = C_Item and C_Item.GetItemInfo or GetItemInfo

local idtoclass = {
    [1] = "Warrior",
    [2] = "Paladin",
    [3] = "Hunter",
    [4] = "Rogue",
    [5] = "Priest",
    [6] = "Death Knight",
    [7] = "Shaman",
    [8] = "Mage",
    [9] = "Warlock",
    [10] = "Monk",
    [11] = "Druid",
    [12] = "Demon Hunter",
    [13] = "Evoker",
}

local idtospec = {
    --Death Knight
    [250] = "Blood",
    [251] = "Frost",
    [252] = "Unholy",
    --Demon Hunter
    [577] = "Havoc",
    [581] = "Vengeance",
    --Druid
    [102] = "Balance",
    [103] = "Feral",
    [104] = "Guardian",
    [105] = "Restoration",
    --Evoker
    [1473] = "Augmentation",
    [1467] = "Devastation",
    [1468] = "Preservation",
    --Hunter
    [253] = "Beast Mastery",
    [254] = "Marksmanship",
    [255] = "Survival",
    --Mage
    [62] = "Arcane",
    [63] = "Fire",
    [64] = "Frost",
    --Monk
    [268] = "Brewmaster",
    [269] = "Windwalker",
    [270] = "Mistweaver",
    --Paladin
    [65] = "Holy",
    [66] = "Protection",
    [70] = "Retribution",
    --Priest
    [256] = "Discipline",
    [257] = "Holy",
    [258] = "Shadow",
    --Rogue
    [259] = "Assassination",
    [260] = "Outlaw",
    [261] = "Subtlety",
    --Shaman
    [262] = "Elemental",
    [263] = "Enhancement",
    [264] = "Restoration",
    --Warlock
    [265] = "Affliction",
    [266] = "Demonology",
    [267] = "Destruction",
    --Warrior
    [71] = "Arms",
    [72] = "Fury",
    [73] = "Protection",
}

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("START_LOOT_ROLL")
eventFrame:RegisterEvent("BONUS_ROLL_ACTIVATE")
eventFrame:RegisterEvent("BONUS_ROLL_DEACTIVATE")
eventFrame:RegisterEvent("BONUS_ROLL_FAILED")
eventFrame:RegisterEvent("BONUS_ROLL_RESULT")
eventFrame:RegisterEvent("BONUS_ROLL_STARTED")
eventFrame:RegisterEvent("CANCEL_LOOT_ROLL")
eventFrame:RegisterEvent("CONFIRM_DISENCHANT_ROLL")
eventFrame:RegisterEvent("CONFIRM_LOOT_ROLL")
eventFrame:RegisterEvent("LOOT_BIND_CONFIRM")
eventFrame:RegisterEvent("LOOT_ITEM_AVAILABLE")
eventFrame:RegisterEvent("LOADING_SCREEN_DISABLED")
eventFrame:RegisterEvent("ADDON_LOADED")

local function EJUpdate()
    local _, classFilename, classID = UnitClass("player")
    local currentSpec = GetSpecialization()
    local specID = select(1, GetSpecializationInfo(currentSpec))
    if EncounterJournalEncounterFrameInfo and EncounterJournalEncounterFrameInfo.LootContainer and EncounterJournalEncounterFrameInfo.LootContainer.ScrollBox then
        local lootFrames = EncounterJournalEncounterFrameInfo.LootContainer.ScrollBox.view.frames
        for _, Button in pairs(lootFrames) do
            if Button and Button.name then
                if not Button.DoIsBiSlabel then
                    Button.DoIsBiSlabel = Button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                end
                Button.DoIsBiSlabel:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
                Button.DoIsBiSlabel:SetPoint("CENTER", 0, -4)
                Button.DoIsBiSlabel:SetText("")
                Button.DoIsBiSlabel:SetTextColor(1, 1, 0)   -- yellow
                Button.DoIsBiSlabel:SetJustifyH("LEFT")
                Button.DoIsBiSlabel:SetJustifyV("BOTTOM")
                local ItemName = Button.name:GetText()
                ItemName = Button.itemID and GetItemInfo(Button.itemID)
                --if AddonTable.ResolveTokenNameForMyClass(ItemName) then
                --    ItemName = AddonTable.ResolveTokenNameForMyClass(ItemName)
                --end
                if ItemName then
                    --print(ItemName)
                    for className, classData in pairs(AddonTable.bis) do
                        if className == idtoclass[classID] then
                            for specName, specData in pairs(classData) do
                                if specName == idtospec[specID] then
                                    for contentType, slot in pairs(specData) do
                                        --DevTools_Dump(slot)
                                        for _, item in pairs(slot) do
                                            if item.name and item.name == ItemName then
                                                if not Button.DoIsBiSlabel:GetText() or (Button.DoIsBiSlabel:GetText() and not Button.DoIsBiSlabel:GetText():find(contentType)) then
                                                    local currentText = Button.DoIsBiSlabel:GetText() or ""
                                                    Button.DoIsBiSlabel:SetText(currentText .. " " .. contentType)
                                                end
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

eventFrame:SetScript("OnEvent", function(self, event, ...)
    local _, classFilename, classID = UnitClass("player")
    local currentSpec = GetSpecialization()
    local specID = select(1, GetSpecializationInfo(currentSpec))
    if event ~= "ADDON_LOADED" then
        if AddonTable.bis[idtoclass[classID]] and AddonTable.bis[idtoclass[classID]][idtospec[specID]] then
            for i = 1, 10 do
                local button = _G["GroupLootFrame"..i]
                if button and button:IsVisible() then
                    local ItemName = button.Name:GetText()
                    --if AddonTable.ResolveTokenNameForMyClass(ItemName) then
                    --    ItemName = AddonTable.ResolveTokenNameForMyClass(ItemName)
                    --end
                    if not button.label then
                        button.label = button:CreateFontString(nil, "OVERLAY", "GameFontNormal")
                    end
                    button.label:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
                    button.label:SetPoint("CENTER", 0, -4)
                    button.label:SetText("")
                    button.label:SetTextColor(1, 1, 0)   -- yellow
                    button.label:SetJustifyH("LEFT")
                    button.label:SetJustifyV("BOTTOM")
                    --if AddonTable.bis[classFilename][idtospec[specID]]["O"][ItemName] then
                    --    local currentText = button.label:GetText()
                    --    button.label:SetText(currentText .. " O ")
                    --end
                    --if AddonTable.bis[classFilename][idtospec[specID]]["M+"][ItemName] then
                    --    local currentText = button.label:GetText()
                    --    button.label:SetText(currentText .. " M+ ")
                    --end
                    --if AddonTable.bis[classFilename][idtospec[specID]]["R"][ItemName] then
                    --    local currentText = button.label:GetText()
                    --    button.label:SetText(currentText .. " R ")
                    --end
                    for className, classData in pairs(AddonTable.bis) do
                        if className == idtoclass[classID] then
                            for specName, specData in pairs(classData) do
                                if specName == idtospec[specID] then
                                    for contentType, slot in pairs(specData) do
                                        for _, item in pairs(slot) do
                                            if item.name and item.name == ItemName then
                                                local currentText = button.label:GetText() or ""
                                                button.label:SetText(currentText .. " " .. contentType)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if event == "ADDON_LOADED" and ... == "Blizzard_EncounterJournal" then
        if EncounterJournalEncounterFrameInfo then
            local sb = EncounterJournalEncounterFrameInfo.LootContainer.ScrollBar
            sb:RegisterCallback(ScrollBoxListMixin.Event.OnScroll, function()
                EJUpdate()
            end)
        end
    end
end)

