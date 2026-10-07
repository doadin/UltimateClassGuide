-- Define the addon namespace
local addonName, addon = ...

local DefaultSettings = {
    automaticMode = false, -- Default value for automatic mode
}

-- Table to store saved settings
UltimateClassGuideSavedSettings = UltimateClassGuideSavedSettings or {}

-- Create a frame for the settings panel
local settingsFrame = CreateFrame("Frame", "UltimateClassGuideSettingsFrame", InterfaceOptionsFramePanelContainer)
settingsFrame.name = "Ultimate Class Guide" -- Name of the addon in the Interface Options
--InterfaceOptions_AddCategory(settingsFrame)

-- Title for the settings panel
local title = settingsFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Ultimate Class Guide Settings")

-- Checkbox for "Automatic Mode Active"
local automaticModeCheckbox = CreateFrame("CheckButton", "UltimateClassGuideAutomaticModeCheckbox", settingsFrame, "InterfaceOptionsCheckButtonTemplate")
automaticModeCheckbox:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
automaticModeCheckbox.Text:SetText("Automatic Mode Active")
automaticModeCheckbox:SetChecked(UltimateClassGuideSavedSettings.automaticMode ~= nil and UltimateClassGuideSavedSettings.automaticMode or DefaultSettings.automaticMode) -- Use saved value or default
automaticModeCheckbox:SetScript("OnClick", function(self)
    local isChecked = self:GetChecked()
    UltimateClassGuideSavedSettings.automaticMode = isChecked -- Save the setting to the SavedSettings table
    --print("Automatic Mode Active:", isChecked)
end)

local category, layout = Settings.RegisterCanvasLayoutCategory(settingsFrame, settingsFrame.name, settingsFrame.name)
category.ID = settingsFrame.name
Settings.RegisterAddOnCategory(category)