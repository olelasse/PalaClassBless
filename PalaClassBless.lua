-- Define Spells
local MACRO_FORMAT = "/cast [@target] %s"
local SPELL_INFOS = {
    {
        name = "Blessing of Wisdom",
        id = 19742,
        classes = {
            ["MAGE"] = true,
            ["WARLOCK"] = true,
            ["PRIEST"] = true,
            ["DRUID"] = true,
            ["PALADIN"] = true,
            ["SHAMAN"] = true
        }
    },
    { -- DEFAULT needs to be last!
        name = "Blessing of Might",
        id = 19740
    },
}

-- Create a SECURE button using the InsecureActionButtonTemplate (insecure to disable it in combat)
local blessButton = CreateFrame("Button", nil, UIParent, "InsecureActionButtonTemplate")
blessButton:SetSize(80, 25) -- Width, Height
blessButton:SetPoint("CENTER") -- Startposition (middle of the screen)
blessButton:SetText("Bless") -- Text on the button
blessButton:SetClampedToScreen(true) -- Make sure it stays on the screen
blessButton:RegisterForClicks("AnyUp", "AnyDown") -- Register all Clicks

-- Configure the button to run a macro
blessButton:SetAttribute("type", "macro")

-- Make the button dragable and register Events
blessButton:SetMovable(true)
blessButton:EnableMouse(true)
blessButton:RegisterForDrag("LeftButton")
blessButton:RegisterEvent("PLAYER_TARGET_CHANGED")
blessButton:RegisterEvent("PLAYER_ENTERING_WORLD")
blessButton:RegisterEvent("SPELLS_CHANGED")
blessButton:SetScript("OnEvent", UpdateBlessMacro)
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

-- Function to update the button's macro text based on the current target
local function UpdateBlessMacro()
    if not blessButton then print("PalaClassBless: UpdateBlessMacro - blessButton is nil!") return end
    if not (UnitExists("target") and UnitIsPlayer("target") and UnitIsFriend("player", "target")) then
         blessButton:SetAttribute("macrotext", "")
         return
    end
    
    local classToken = UnitClassBase("target")
    local spellNameToUse, spellIdToCheck

    for _, spell in ipairs(SPELL_INFOS) do
        if ((spell.classes and spell.classes[classToken]) or not spell.classes) and IsSpellKnown(spell.id) then
            spellNameToUse = spell.name
            spellIdToCheck = spell.id
            break
        end
    end
    if not (spellNameToUse and spellIdToCheck) then
        print("PalaClassBless: Cannot set macro - no valid spell found!")
        return
    end

    local newMacroText = string.format(MACRO_FORMAT, spellNameToUse)
    blessButton:SetAttribute("macrotext", newMacroText)
    -- print("PalaClassBless: Macro updated to: " .. newMacroText) -- Debug
end

-- Run the update once initially when the addon loads
UpdateBlessMacro()

-- Slash command to show/hide the button (with enhanced debugging)
SLASH_PALACLASSBLESS1 = "/palaclassbless"
SlashCmdList["PALACLASSBLESS"] = function(msg)
    print("--- PalaClassBless Slash Command Start ---")
    if blessButton then
        print("SlashCmd: blessButton object exists.")
        local isShown = blessButton:IsShown()
        local alpha = blessButton:GetAlpha()
        local strata = blessButton:GetFrameStrata()
        local level = blessButton:GetFrameLevel()
        print(("SlashCmd: Current State - IsShown: %s, Alpha: %.2f, Strata: %s, Level: %d"):format(tostring(isShown), alpha, strata, level))

        print(("SlashCmd: Button is currently %s. %s button."):format(isShown and "shown" or "hidden", isShown and "Hiding" or "Showing"))
        blessButton:SetShown(not isShown)
        print(("PalaClassBless: Button %s"):format(isShown and "hidden. Type /palaclassbless to show." or "shown."))
        -- Check state *after* trying to show/hide
        print(("SlashCmd: State AFTER action - IsShown: %s, Alpha: %.2f"):format(tostring(blessButton:IsShown()), blessButton:GetAlpha()))
    else
         print("SlashCmd: ERROR - blessButton object is nil!")
    end
    print("--- PalaClassBless Slash Command End ---")
end

print("PalaClassBless Addon (Secure Version with Debugging) loaded successfully!")
