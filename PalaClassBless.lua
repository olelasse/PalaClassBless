-- Define Spell IDs and Names
local MIGHT_ID = 19740
local WISDOM_ID = 19742
local MIGHT_NAME = "Blessing of Might"
local WISDOM_NAME = "Blessing of Wisdom"

-- Create a SECURE button using the SecureActionButtonTemplate
local blessButton = CreateFrame("Button", "PalaClassBlessSecureButton", UIParent, "SecureActionButtonTemplate")
blessButton:SetSize(80, 25)
blessButton:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
blessButton:SetText("Bless")

-- Configure the button to run a macro
blessButton:SetAttribute("type", "macro")

-- Make the button draggable (Note: Dragging secure frames can sometimes be tricky)
blessButton:SetMovable(true)
blessButton:EnableMouse(true)
blessButton:RegisterForDrag("LeftButton")
-- Add a check to only allow dragging outside of combat lockdown
blessButton:SetScript("OnDragStart", function(self)
    if not InCombatLockdown() then
        self:StartMoving()
    else
        print("PalaClassBless: Cannot move button during combat lockdown.")
    end
end)
blessButton:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    -- Here you could add code to save the button's position if desired
end)

-- Define the macro format
local macroFormat = "/cast [@target] %s" -- %s gets replaced with the spell name

-- Function to update the button's macro text based on the current target
local function UpdateBlessMacro()
    if not blessButton then return end -- Safety check

    local spellNameToUse = MIGHT_NAME -- Default to Might
    local spellIdToCheck = MIGHT_ID   -- Default ID check

    -- Check if target is valid for blessing
    if UnitExists("target") and UnitIsPlayer("target") and UnitIsFriend("player", "target") then
        local _, classToken = UnitClass("target")
        -- Define classes that prefer Wisdom
        local classesForWisdom = {
             ["MAGE"] = true, ["WARLOCK"] = true, ["PRIEST"] = true,
             ["DRUID"] = true, ["PALADIN"] = true, ["SHAMAN"] = true
        }
        -- If target class is in the list, switch to Wisdom
        if classesForWisdom[classToken] then
            spellNameToUse = WISDOM_NAME
            spellIdToCheck = WISDOM_ID
        end

        -- IMPORTANT: Check if the Paladin actually knows the determined spell
        if not IsSpellKnown(spellIdToCheck) then
             print("PalaClassBless: Cannot set macro - spell '" .. spellNameToUse .. "' (ID: " .. spellIdToCheck .. ") not known.")
             blessButton:SetAttribute("macrotext", "") -- Clear the macro if spell not known
             return -- Exit the function
        end

    else
         -- No valid target, clear the macro so the button does nothing or provide feedback
         -- print("PalaClassBless: No valid target, clearing macro.") -- Optional Debug
         blessButton:SetAttribute("macrotext", "")
         return -- Exit the function
    end

    -- Set the button's macro text attribute
    local newMacroText = string.format(macroFormat, spellNameToUse)
    blessButton:SetAttribute("macrotext", newMacroText)
    -- print("PalaClassBless: Macro updated to: " .. newMacroText) -- Optional Debug for testing
end

-- Create a small invisible frame to listen for events
local eventFrame = CreateFrame("Frame", "PalaClassBlessEventFrame")
eventFrame:RegisterUnitEvent("UNIT_TARGET", "player") -- Listen for player target changes
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")     -- Update when logging in/reloading UI
eventFrame:RegisterEvent("SPELLS_CHANGED")           -- Update if spells are learned/unlearned

-- Set the script to run when one of the registered events occurs
eventFrame:SetScript("OnEvent", function(self, event, unit)
    -- Check if the event is UNIT_TARGET and the unit affected is the player
    if event == "UNIT_TARGET" and unit == "player" then
        UpdateBlessMacro()
    -- Also run the update on login or when spells change
    elseif event == "PLAYER_ENTERING_WORLD" or event == "SPELLS_CHANGED" then
        UpdateBlessMacro()
    end
end)

-- Run the update once initially when the addon loads, in case the player already has a target
UpdateBlessMacro()

-- Slash command to show/hide the button (remains mostly the same)
SLASH_PALACLASSBLESS1 = "/palaclassbless"
SlashCmdList["PALACLASSBLESS"] = function(msg)
    if blessButton:IsShown() then
        blessButton:Hide()
        print("PalaClassBless: Button hidden. Type /palaclassbless to show.")
    else
        blessButton:Show()
        print("PalaClassBless: Button shown.")
    end
end

print("PalaClassBless Addon (Secure Version) loaded successfully!")