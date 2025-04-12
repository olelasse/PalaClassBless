-- Define Spell IDs and Names
local MIGHT_ID = 19740
local WISDOM_ID = 19742
local MIGHT_NAME = "Blessing of Might"
local WISDOM_NAME = "Blessing of Wisdom"

-- Create a SECURE button using the SecureActionButtonTemplate
local blessButton = CreateFrame("Button", "PalaClassBlessSecureButton", UIParent, "SecureActionButtonTemplate")
blessButton:SetSize(80, 25) -- Width, Height
blessButton:SetPoint("CENTER", UIParent, "CENTER", 0, 0) -- Startposition (middle of the screen)
blessButton:SetText("Bless") -- Text on the button
-- Add a visibility standard
blessButton:SetAlpha(1)
blessButton:Show() -- Make sure its visible at start

-- Configure the button to run a macro
blessButton:SetAttribute("type", "macro")

-- Make the button draggable
blessButton:SetMovable(true)
blessButton:EnableMouse(true)
blessButton:RegisterForDrag("LeftButton")
blessButton:SetScript("OnDragStart", function(self)
    if not InCombatLockdown() then
        self:StartMoving()
    else
        print("PalaClassBless: Cannot move button during combat lockdown.")
    end
end)
blessButton:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
end)

-- Define the macro format
local macroFormat = "/cast [@target] %s"

-- Function to update the button's macro text based on the current target
local function UpdateBlessMacro()
    if not blessButton then print("PalaClassBless: UpdateBlessMacro - blessButton is nil!") return end

    local spellNameToUse = MIGHT_NAME
    local spellIdToCheck = MIGHT_ID

    if UnitExists("target") and UnitIsPlayer("target") and UnitIsFriend("player", "target") then
        local _, classToken = UnitClass("target")
        local classesForWisdom = {
             ["MAGE"] = true, ["WARLOCK"] = true, ["PRIEST"] = true,
             ["DRUID"] = true, ["PALADIN"] = true, ["SHAMAN"] = true
        }
        if classesForWisdom[classToken] then
            spellNameToUse = WISDOM_NAME
            spellIdToCheck = WISDOM_ID
        end

        if not IsSpellKnown(spellIdToCheck) then
             print("PalaClassBless: Cannot set macro - spell '" .. spellNameToUse .. "' (ID: " .. spellIdToCheck .. ") not known.")
             blessButton:SetAttribute("macrotext", "")
             return
        end
    else
         blessButton:SetAttribute("macrotext", "")
         return
    end

    local newMacroText = string.format(macroFormat, spellNameToUse)
    blessButton:SetAttribute("macrotext", newMacroText)
    -- print("PalaClassBless: Macro updated to: " .. newMacroText) -- Debug
end

-- Create a small invisible frame to listen for events
local eventFrame = CreateFrame("Frame", "PalaClassBlessEventFrame")
eventFrame:RegisterUnitEvent("UNIT_TARGET", "player")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("SPELLS_CHANGED")

eventFrame:SetScript("OnEvent", function(self, event, unit)
    if event == "UNIT_TARGET" and unit == "player" then
        UpdateBlessMacro()
    elseif event == "PLAYER_ENTERING_WORLD" or event == "SPELLS_CHANGED" then
        UpdateBlessMacro()
    end
end)

-- Run the update once initially when the addon loads
UpdateBlessMacro()

-- Slash command to show/hide the button (with enhanced debugging)
SLASH_PALACLASSBLESS1 = "/palaclassbless"
SlashCmdList["PALACLASSBLESS"] = function(msg)
    print("--- PalaClassBless Slash Command Start ---")
    if blessButton then
        print("SlashCmd: blessButton object exists. Name: " .. blessButton:GetName())
        local isShown = blessButton:IsShown()
        local alpha = blessButton:GetAlpha()
        local strata = blessButton:GetFrameStrata()
        local level = blessButton:GetFrameLevel()
        print(string.format("SlashCmd: Current State - IsShown: %s, Alpha: %.2f, Strata: %s, Level: %d", tostring(isShown), alpha, strata, level))

        if isShown then
            print("SlashCmd: Button is currently shown. Hiding button.")
            blessButton:Hide()
            print("PalaClassBless: Button hidden. Type /palaclassbless to show.")
        else
            print("SlashCmd: Button is currently hidden or not shown. Showing button.")
            blessButton:SetAlpha(1) -- Ensure full alpha
            blessButton:Show()
            -- Re-apply position just in case it was moved off-screen
            blessButton:ClearAllPoints()
            blessButton:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            print("PalaClassBless: Button shown.")
        end
        -- Check state *after* trying to show/hide
        print(string.format("SlashCmd: State AFTER action - IsShown: %s, Alpha: %.2f", tostring(blessButton:IsShown()), blessButton:GetAlpha()))
    else
         print("SlashCmd: ERROR - blessButton object is nil!")
    end
    print("--- PalaClassBless Slash Command End ---")
end

-- Try explicitly showing the button again after everything is defined
if blessButton then
    blessButton:Show()
    print("PalaClassBless: Explicit Show() called at the end of the file.")
end

print("PalaClassBless Addon (Secure Version with Debugging) loaded successfully!")