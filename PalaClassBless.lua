-- Define Spell IDs and Names
-- Using Rank 1 IDs is usually sufficient for IsSpellKnown checks
local MIGHT_ID = 19740
local WISDOM_ID = 19742
local MIGHT_NAME = "Blessing of Might"
local WISDOM_NAME = "Blessing of Wisdom"

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
    print("PalaClassBless: OnBlessButtonClick started!") -- Debug print

    -- Check if you have a target, if its a player and a friendly
    if UnitExists("target") and UnitIsPlayer("target") and UnitIsFriend("player", "target") then
        -- Get the class of target (both local name and english token)
        -- We use the englsih token (ClassToken) for reliability across languages
        local _, classToken = UnitClass("target")
        print("PalaClassBless: Target class token: " .. (classToken or "nil")) -- Debug print

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
        local spellIdToCheck

        -- Covers what blessing to cast (name and ID)
        if classesForWisdom[classToken] then
            spellNameToCast = WISDOM_NAME
            spellIdToCheck = WISDOM_ID
            print("PalaClassBless: Decided on Blessing of Wisdom (ID: " .. spellIdToCheck .. ")") -- Debug print
        else
            spellNameToCast = MIGHT_NAME
            spellIdToCheck = MIGHT_ID
            print("PalaClassBless: Decided on Blessing of Might (ID: " .. spellIdToCheck .. ")") -- Debug print
        end

        -- Check if you actually know this spell USING ID (important!)
        if IsSpellKnown(spellIdToCheck) then
            print("PalaClassBless: Spell ID " .. spellIdToCheck .. " known, attempting cast by name...") -- Debug print
            -- Cast spell on target USING ITS NAME
            CastSpellByName(spellNameToCast, "target")
            print("PalaClassBless: Casting " .. spellNameToCast .. " on " .. UnitName("target"))
        else
             -- Let player know if the spell is not learned
             print("PalaClassBless: You do not know the spell '" .. spellNameToCast .. "'!")
        end

    else
        -- Let the player know the target is not a friendly player
        print("PalaClassBless: No friendly player is chosen as target..")
    end
end

-- Connect click-function to button
blessButton:SetScript("OnClick", OnBlessButtonClick)
print("PalaClassBless: OnClick script set.") -- Debug print

-- (Optional) Add a slash command to show or hide the button
SLASH_PALACLASSBLESS1 = "/palaclassbless" -- Define command
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
