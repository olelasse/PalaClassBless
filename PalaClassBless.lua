-- Create main button
local blessButton = CreateFrame("Button", "BlessHelperButton", UIParent, "UIPanelButtonTemplate")
blessButton:SetSize(80, 25) -- Width, Height
blessButton:SetPoint("CENTER", UIParent, "CENTER", 0, 0) -- Startposition (middle of the screen)
blessButton:SetText("Bless") -- Text on the button

-- Make the button draggable
blessButton:SetMovable(true)
blessButton:EnableMouse(true)
blessButton:RegisterForDrag("LeftButton")
blessButton:SetScript("OnDragStart", blessButton.StartMoving)
blessButton:SetScript("OnDragStop", blessButton.StopMovingOrSizing)

-- Function that will be run when the button is pressed
local function OnBlessButtonClick(self, button)
    -- Check if you have a target, if its a player and a friendly
    if UnitExists("target") and UnitIsPlayer("target") and UnitIsFriend("player", "target") then
        -- Get the class of target (both local name and english token)
        -- We use the englsih token (ClassToken) for reliability across languages
        local _, classToken = UnitClass("target")

        -- Define what class usally prefers Blessing of Wisdom
        -- The KEY here is the english class-token
        local classesForWisdom = {
            ["MAGE"] = true,
            ["WARLOCK"] = true,
            ["PRIEST"] = true,
            ["DRUID"] = true,    -- Covers Resto/Balance. Feral might want Might, but Wisdom is safer.
            ["PALADIN"] = true,  -- Covers Holy. Ret/Prot wants Might.
            ["SHAMAN"] = true    -- Covers Resto/Elemental. Enhancement wants Might.
        }

        local spellToCast

        -- Covers what blessing to cast
        if classesForWisdom[classToken] then
            spellToCast = "Blessing of Wisdom" -- Excact name of the spell
        else
            -- Standard to Mgiht for Warrior, Rouge, Hunter
            spellToCast = "Blessing of Might"  -- Excact name of the spell
        end

        -- Check if you actually know this spell (important!)
        if IsSpellKnown(spellToCast) then
             -- Cast spell on target
             CastSpellByName(spellToCast, "target")
             print("PalaClassBless: Casting " .. spellToCast .. " on " .. UnitName("target"))
        else
             -- Let player know if the spell is not learned
             print("PalaClassBless: You do not know the spell '" .. spellToCast .. "'!")
        end

    else
        -- Let the player know the target is not a friendly player
        print("PalaClassBless: No friendly player is chosen as target..")
    end
end

-- Connect click-function to button
blessButton:SetScript("OnClick", OnBlessButtonClick)

-- (Optional) Add a slash command to show or hide the button
SLASH_BLESSHELPER1 = "/palaclassbless" -- Define command
SlashCmdList["PALACLASSBLESS"] = function(msg)
    if blessButton:IsShown() then
        blessButton:Hide()
        print("PalaClassBless: Button hidden. Type /palaclassbless to show.")
    else
        blessButton:Show()
        print("PalaClassBless: Button shown.")
    end
end

print("PalaClassBless Addon loaded!") -- Confirmation in the chat when logged in
