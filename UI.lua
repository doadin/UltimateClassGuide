local ADDON_NAME, AddonTable = ...

-- Define the addon namespace
local addonName, addon = ...

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

local function GetPlayerClassSpec()
    local _, _, classID = UnitClass("player")
    local specIndex = GetSpecialization()
    local specID = specIndex and select(1, GetSpecializationInfo(specIndex))
    local class = idtoclass[classID]
    local specName = idtospec[specID]
    return class, specName
end

local function CreatePrettyBar(parent, stat, value, maxValue, y)
    local bar = CreateFrame("StatusBar", nil, parent)
    bar:SetPoint("TOPLEFT", 10, y)
    bar:SetSize(300, 20)
    bar:SetMinMaxValues(0, maxValue)
    bar:SetValue(value)

    -- Gradient texture
    bar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
    bar:GetStatusBarTexture():SetHorizTile(false)

    -- Color based on stat
    local colors = {
        ["mastery"] = {0.6, 0.2, 1},
        ["haste"]   = {1, 0.9, 0.2},
        ["crit"]    = {0.2, 1, 0.2},
        ["vers"]    = {0.2, 0.6, 1},
        ["intellect"] = {1, 0.5, 0.2},
    }

    local c = colors[string.lower(stat)] or {0.8, 0.8, 0.8}
    bar:SetStatusBarColor(c[1], c[2], c[3])

    -- Background
    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0, 0, 0, 0.5)

    -- Rounded mask (fake rounded corners)
    local mask = bar:CreateMaskTexture()
    mask:SetTexture("Interface\\BUTTONS\\WHITE8X8")
    mask:SetPoint("TOPLEFT")
    mask:SetPoint("BOTTOMRIGHT")
    mask:SetSize(300, 20)
    bar:GetStatusBarTexture():AddMaskTexture(mask)
    bg:AddMaskTexture(mask)

    -- Centered text
    local fs = bar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetPoint("CENTER", bar, "CENTER", 0, 0)
    fs:SetText(stat .. "  " .. value .. " / " .. maxValue)

    return bar
end

local function CreateBiSWindow()
    local f = CreateFrame("Frame", "DoIsBisMainWindow", UIParent, "BackdropTemplate")
    f:SetSize(500, 500)
    f:SetPoint("CENTER")
    f:SetBackdrop({
        bgFile = "Interface/Tooltips/UI-Tooltip-Background",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 4, right = 4, top = 4, bottom = 4 }
    })
    f:SetBackdropColor(0, 0, 0, 0.85)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    f:Hide()

    f.title = f:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    f.title:SetPoint("TOP", 0, -10)
    f.title:SetText("BiS Items")

    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", -5, -5)

    ---------------------------------------------------
    -- TABS
    ---------------------------------------------------
    f.tabs = {}

    local function CreateTab(parent, id, text)
        local tab = CreateFrame("Button", nil, parent, "PanelTabButtonTemplate")
        tab:SetID(id)
        tab:SetText(text)
        tab:SetScript("OnClick", function(self)
            PanelTemplates_SetTab(parent, self:GetID())
            parent:SelectTab(self:GetID())
        end)
        return tab
    end

    f.tabs[1] = CreateTab(f, 1, "Stats")
    f.tabs[1]:SetPoint("TOPLEFT", f, "BOTTOMLEFT", 5, 2)

    f.tabs[2] = CreateTab(f, 2, "Gear")
    f.tabs[2]:SetPoint("LEFT", f.tabs[1], "RIGHT", -20, 2)

    f.tabs[3] = CreateTab(f, 3, "Trinkets")
    f.tabs[3]:SetPoint("LEFT", f.tabs[2], "RIGHT", -20, 2)

    f.tabs[4] = CreateTab(f, 4, "Talents")
    f.tabs[4]:SetPoint("LEFT", f.tabs[3], "RIGHT", -20, 2)

    PanelTemplates_SetNumTabs(f, 4)
    PanelTemplates_SetTab(f, 1)

    ---------------------------------------------------
    -- TAB CONTENT FRAMES
    ---------------------------------------------------
    f.tabFrames = {}

    ---------------------------------------------------
    -- STATS TAB CONTENT FRAME (with nested tabs)
    ---------------------------------------------------
    f.tabFrames[1] = CreateFrame("Frame", nil, f)
    f.tabFrames[1]:SetAllPoints(f)
    
    local statsFrame = f.tabFrames[1]
    
    ---------------------------------------------------
    -- NESTED SUB-TABS INSIDE STATS TAB
    ---------------------------------------------------
    statsFrame.subTabs = {}
    
    local function CreateSubTab(parent, id, text)
        local tab = CreateFrame("Button", nil, parent, "PanelTabButtonTemplate")
        tab:SetID(id)
        tab:SetText(text)
        tab:SetScript("OnClick", function(self)
            PanelTemplates_SetTab(parent, self:GetID())
            parent:SelectSubTab(self:GetID())
        end)
        return tab
    end
    
    statsFrame.subTabs[1] = CreateSubTab(statsFrame, 1, "M+")
    statsFrame.subTabs[1]:SetPoint("TOPLEFT", statsFrame, "TOPLEFT", 20, -40)
    
    statsFrame.subTabs[2] = CreateSubTab(statsFrame, 2, "Raid")
    statsFrame.subTabs[2]:SetPoint("LEFT", statsFrame.subTabs[1], "RIGHT", -20, 0)
    
    PanelTemplates_SetNumTabs(statsFrame, 2)
    PanelTemplates_SetTab(statsFrame, 1)
    
    ---------------------------------------------------
    -- SUB-TAB CONTENT FRAMES
    ---------------------------------------------------
    statsFrame.subFrames = {}
    
    statsFrame.subFrames[1] = CreateFrame("Frame", nil, statsFrame)
    statsFrame.subFrames[1]:SetPoint("TOPLEFT", 10, -80)
    statsFrame.subFrames[1]:SetPoint("BOTTOMRIGHT", -10, 10)
    
    statsFrame.subFrames[2] = CreateFrame("Frame", nil, statsFrame)
    statsFrame.subFrames[2]:SetPoint("TOPLEFT", 10, -80)
    statsFrame.subFrames[2]:SetPoint("BOTTOMRIGHT", -10, 10)
    statsFrame.subFrames[2]:Hide()
    
    function statsFrame:SelectSubTab(id)
        for i, frame in pairs(self.subFrames) do
            frame:Hide()
        end
        self.subFrames[id]:Show()
    end

    ---------------------------------------------------
    -- POPULATE M+ AND RAID STATS
    ---------------------------------------------------
    function statsFrame:SetMPlusStats(stats)
        local frame = self.subFrames[1]
    
        -- Clear old children
        for _, child in ipairs({frame:GetChildren()}) do child:Hide() end
    
        local y = -10
        
        for stat, maxValue in pairs(stats) do
            -- Create bar
            local statNumberG = _G["LE_UNIT_STAT_" .. string.upper(stat)]
            if stat ~= "Strength" and stat ~= "Intellect" and stat ~= "Agility" then
                local _, value = 0,0
                if statNumberG then
                    _, value, _, _ = UnitStat("player", statNumberG)
                end
                if stat == "Crit" then
                    value = GetCombatRating(9)
                end
                if stat == "Haste" then
                    value = GetCombatRating(18)
                end
                if stat == "Mastery" then
                    value = GetCombatRating(26)
                end
                if stat == "Vers" then
                    value = GetCombatRating(29)
                end
                CreatePrettyBar(frame, stat, value, maxValue, y)
                y = y - 30
            end
        end
    end
    
    function statsFrame:SetRaidStats(stats)
        local frame = self.subFrames[2]
    
        -- Clear old children
        for _, child in ipairs({frame:GetChildren()}) do child:Hide() end
    
        local y = -10
        
        for stat, maxValue in pairs(stats) do
            -- Create bar
            local statNumberG = _G["LE_UNIT_STAT_" .. string.upper(stat)]
            if stat ~= "Strength" and stat ~= "Intellect" and stat ~= "Agility" then
                local _, value = 0,0
                if statNumberG then
                    _, value, _, _ = UnitStat("player", statNumberG)
                end
                if stat == "Crit" then
                    value = GetCombatRating(9)
                end
                if stat == "Haste" then
                    value = GetCombatRating(18)
                end
                if stat == "Mastery" then
                    value = GetCombatRating(26)
                end
                if stat == "Vers" then
                    value = GetCombatRating(29)
                end
                CreatePrettyBar(frame, stat, value, maxValue, y)
                y = y - 30
            end
        end
    end

    f.tabFrames[2] = CreateFrame("Frame", nil, f)
    f.tabFrames[2]:SetAllPoints(f)
    f.tabFrames[2]:Hide()

    f.tabFrames[3] = CreateFrame("Frame", nil, f)
    f.tabFrames[3]:SetAllPoints(f)
    f.tabFrames[3]:Hide()

    f.tabFrames[4] = CreateFrame("Frame", nil, f)
    f.tabFrames[4]:SetAllPoints(f)
    f.tabFrames[4]:Hide()

    function f:SelectTab(id)
        for i, frame in pairs(self.tabFrames) do
            frame:Hide()
        end
        self.tabFrames[id]:Show()
    end

    return f
end

local function CreateBiSScrollArea(parent)
    local scrollFrame = CreateFrame("ScrollFrame", nil, parent, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 10, -40)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetPoint("TOPLEFT")
    content:SetPoint("TOPRIGHT")
    content:SetWidth(scrollFrame:GetWidth())  -- CRITICAL
    content:SetHeight(1)
    --content:SetSize(1, 1) -- will expand dynamically
    scrollFrame:SetScrollChild(content)

    return scrollFrame, content
end



local function BuildRowsForClassSpec(className, specName)
    local rows = {}

    if not AddonTable or not AddonTable.bis then
        return rows
    end

    local classData = AddonTable.bis[className]
    if not classData then
        return rows
    end

    local specData = classData[specName]
    if not specData then
        return rows
    end

    for contentType, slot in pairs(specData) do
        table.insert(rows, { isHeader = true, text = contentType })
        for _,data in pairs(slot) do
            --local itemName = data and data.id and C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(data.id)
            --itemName = itemName or ("Item " .. tostring(data.id))
            local itemLink = select(2, GetItemInfo(data.itemid)) or ("item:" .. data.itemid)
            table.insert(rows, { isHeader = false, text = itemLink, itemID = data.itemid, source = data.source, sourceType = data.sourceType })
        end
    end

    return rows
end

local function BuildTrinketRowsForClassSpec(className, specName)
    local rows = {}

    if not AddonTable or not AddonTable.trinkets then
        return rows
    end

    local classData = AddonTable.trinkets[className]
    if not classData then
        return rows
    end

    local specData = classData[specName]
    if not specData then
        return rows
    end

    for contentType, slot in pairs(specData) do
        table.insert(rows, { isHeader = true, text = contentType })
        for _,data in pairs(slot) do
            --local itemName = data and data.id and C_Item and C_Item.GetItemNameByID and C_Item.GetItemNameByID(data.id)
            --itemName = itemName or ("Item " .. tostring(data.id))
            local itemLink = select(2, GetItemInfo(data.itemid)) or ("item:" .. data.itemid)
            table.insert(rows, { isHeader = false, text = itemLink, itemID = data.itemid, tier = contentType})
        end
    end

    return rows
end

local function BuildTalentRowsForClassSpec(className, specName)
    local rows = {}

    if not AddonTable or not AddonTable.talents then
        return rows
    end

    local classData = AddonTable.talents[className]
    if not classData then
        return rows
    end

    local specData = classData[specName]
    if not specData then
        return rows
    end

    for contentType, talentstring in pairs(specData) do
        table.insert(rows, { isHeader = false, text = contentType, talentString = talentstring, tier = contentType})
    end

    return rows
end

local function PopulateScrollFrame(content, rows)
    -- Clear old rows
    for _, child in ipairs({ content:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end

    local yOffset = -5
    local width = content:GetParent():GetWidth() - 20
    --DevTools_Dump(rows)

    for _, row in ipairs(rows) do
        local rowFrame = CreateFrame("Frame", nil, content)
        rowFrame:SetPoint("TOPLEFT", 0, yOffset)
        rowFrame:SetPoint("TOPRIGHT", 0, yOffset)
        rowFrame:SetHeight(row.isHeader and 24 or 18)
        rowFrame:EnableMouse(true)

        local fs = rowFrame:CreateFontString(nil, "OVERLAY", row.isHeader and "GameFontNormalLarge" or "GameFontNormal")
        fs:SetPoint("LEFT", 5, 0)
        fs:SetWidth(500)
        fs:SetWordWrap(true)
        fs:SetNonSpaceWrap(true)
        fs:SetJustifyH("LEFT")
        fs:SetJustifyV("TOP")

        if row.isHeader then
            fs:SetText("|cffFFD100" .. row.text .. "|r")
            yOffset = yOffset - 26
        else
            if row.source then
                fs:SetText("• " .. row.text .. " " .. row.source.. " " .. row.sourceType)
            else
                fs:SetText("• " .. row.text)
            end

            rowFrame:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetHyperlink(row.text)
                GameTooltip:Show()
            end)

            rowFrame:SetScript("OnLeave", function()
                GameTooltip:Hide()
            end)

            rowFrame:SetScript("OnMouseUp", function(self, button)
                if button == "LeftButton" then
                    HandleModifiedItemClick(row.text)
                end
            end)

            yOffset = yOffset - 20
        end
    end

    content:SetHeight(-yOffset + 10)

end

local function PopulateTrinketScrollFrame(content, rows)
    -- Clear old rows
    for _, child in ipairs({ content:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end

    local yOffset = -5
    local width = content:GetParent():GetWidth() - 20

    local tierOrder = { "S", "A", "B", "C", "D" }
    for _, tier in ipairs(tierOrder) do
        for _, row in ipairs(rows) do
            if row.tier == tier then
                local rowFrame = CreateFrame("Frame", nil, content)
                rowFrame:SetPoint("TOPLEFT", 0, yOffset)
                rowFrame:SetPoint("TOPRIGHT", 0, yOffset)
                rowFrame:SetHeight(row.isHeader and 24 or 18)
                rowFrame:EnableMouse(true)
    
                local fs = rowFrame:CreateFontString(nil, "OVERLAY", row.isHeader and "GameFontNormalLarge" or "GameFontNormal")
                fs:SetPoint("LEFT", 5, 0)
                fs:SetWidth(500)
                fs:SetWordWrap(true)
                fs:SetNonSpaceWrap(true)
                fs:SetJustifyH("LEFT")
                fs:SetJustifyV("TOP")
    
                if row.isHeader then
                    fs:SetText("|cffFFD100" .. row.text .. "|r")
                    yOffset = yOffset - 26
                else
                    if row.source then
                        fs:SetText("• " .. row.text .. " " .. row.source.. " " .. row.sourceType .. " " .. row.tier)
                    else
                        fs:SetText("• " .. row.text .. " " .. row.tier)
                    end
    
                    rowFrame:SetScript("OnEnter", function(self)
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                        GameTooltip:SetHyperlink(row.text)
                        GameTooltip:Show()
                    end)
    
                    rowFrame:SetScript("OnLeave", function()
                        GameTooltip:Hide()
                    end)
    
                    rowFrame:SetScript("OnMouseUp", function(self, button)
                        if button == "LeftButton" then
                            HandleModifiedItemClick(row.text)
                        end
                    end)
    
                    yOffset = yOffset - 20
                end
            end
        end
    end

    content:SetHeight(-yOffset + 10)
end

local function formateContent(content)
    if content:find("-") then
        content = content:gsub("-", " ")
        content = content:gsub("(%a)(%w*)", function(first, rest)
            return first:upper() .. rest:lower()
        end)
        return content
    else
        content = content:gsub("(%a)(%w*)", function(first, rest)
            return first:upper() .. rest:lower()
        end)
        return content
    end
end

local function importTalentString(talentString)
    -- Implementation for importing talent string
    print("Importing talent string:", talentString)
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
    local mapName = addon.GetCurrentMapName()
    local mapNameTable = addon.currentSeasonInstances[addon.GetCurrentMapName()]
    local specName = specNames[specID]
    local classTalents = addon.talents[playerClass]
    addon:CheckTalentUpdate(playerClass, specName, mapName, classTalents[specName][mapNameTable])
end

local function PopulateTalentScrollFrame(content, rows)
    -- Clear old rows
    for _, child in ipairs({ content:GetChildren() }) do
        child:Hide()
        child:SetParent(nil)
    end

    local yOffset = -5
    local width = content:GetParent():GetWidth() - 20
    --DevTools_Dump(rows)

    for _, row in ipairs(rows) do
        local rowFrame = CreateFrame("Frame", nil, content)
        rowFrame:SetPoint("TOPLEFT", 0, yOffset)
        rowFrame:SetPoint("TOPRIGHT", 0, yOffset)
        rowFrame:SetHeight(row.isHeader and 24 or 18)
        rowFrame:EnableMouse(true)

        if row.isHeader then
            --fs:SetText("|cffFFD100" .. row.text .. "|r")
            yOffset = yOffset - 26
        else
            local talentString = row.talentString
            local btn = CreateFrame("Button", nil, rowFrame, "UIPanelButtonTemplate")
            btn:SetPoint("CENTER", 0, 0)
            btn:SetSize(150, 40)
            btn:SetText("Import " .. formateContent(row.text))

            btn:SetScript("OnClick", function(self, button, down)
                importTalentString(talentString)
            end)

            btn:RegisterForClicks("AnyUp")

            yOffset = yOffset - 40
        end
    end

    content:SetHeight(-yOffset + 10)

end


local window
local scrollFrame
local content
local TrinketscrollFrame
local Trinketcontent
local TalentscrollFrame
local Talentcontent

local function ShowBiSWindow()
    if not window then
        window = CreateBiSWindow()
        scrollFrame, content = CreateBiSScrollArea(window.tabFrames[2])
        TrinketscrollFrame, Trinketcontent = CreateBiSScrollArea(window.tabFrames[3])
        TalentscrollFrame, Talentcontent = CreateBiSScrollArea(window.tabFrames[4])
    end

    local class, spec = GetPlayerClassSpec()
    local statsData = AddonTable.stats[class][spec]
    if statsData then
        if statsData["M+"] then
            window.tabFrames[1]:SetMPlusStats(statsData["M+"])
        end
        if statsData["R"] then
            window.tabFrames[1]:SetRaidStats(statsData["R"])
        end
    end
    if not class or not spec then
        print("BiS: could not determine class/spec.")
        return
    end

    local rows = BuildRowsForClassSpec(class, spec)
    if #rows == 0 then
        print("BiS: no data for " .. class .. " / " .. spec)
    end

    PopulateScrollFrame(content, rows)

    local Trinketrows = BuildTrinketRowsForClassSpec(class, spec)
    if #Trinketrows == 0 then
        print("BiS: no data for " .. class .. " / " .. spec)
    end

    PopulateTrinketScrollFrame(Trinketcontent, Trinketrows)

    local Talentrows = BuildTalentRowsForClassSpec(class, spec)
    if #Talentrows == 0 then
        print("BiS: no data for " .. class .. " / " .. spec)
    end

    PopulateTalentScrollFrame(Talentcontent, Talentrows)

    if window then
        window.title:SetText(class .. " - " .. spec)
        window:SelectTab(1)
        if window:IsShown() then
            window:Hide()
        else
            window:Show()
        end
    end
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")

f:SetScript("OnEvent", function() --self, event, slot, hasItem
    local class, spec = GetPlayerClassSpec()
    local statsData = AddonTable.stats[class][spec]
    if statsData and window then
        if statsData["M+"] then
            window.tabFrames[1]:SetMPlusStats(statsData["M+"])
        end
        if statsData["R"] then
            window.tabFrames[1]:SetRaidStats(statsData["R"])
        end
    end
end)


SLASH_SHOWBIS1 = "/ucg"
SlashCmdList.SHOWBIS = function()
    ShowBiSWindow()
end

local function OnAddonCompartmentClick(ADDON_NAME, button)
    -- Toggle your BiS window here
    ShowBiSWindow()
end

local function OnAddonCompartmentEnter(ADDON_NAME)
    GameTooltip:SetOwner(AddonCompartmentFrame, "ANCHOR_RIGHT")
    GameTooltip:AddLine("Ultimate Class Guide")
    GameTooltip:AddLine("Click to open UI", 1, 1, 1)
    GameTooltip:Show()
end

local function OnAddonCompartmentLeave(ADDON_NAME)
    GameTooltip:Hide()
end

AddonCompartmentFrame:RegisterAddon({
    text = "Ultimate Class Guide",
    icon = "Interface\\AddOns\\UltimateClassGuide\\icon", -- replace with your icon
    notCheckable = true,
    func = OnAddonCompartmentClick,
    tooltipTitle = "Ultimate Class Guide",
    tooltipText = "Click to open UI",
    OnEnter = OnAddonCompartmentEnter,
    OnLeave = OnAddonCompartmentLeave,
})