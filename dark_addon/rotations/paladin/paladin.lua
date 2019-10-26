local addon, dark_addon = ...

local dispeldelay = 0

local function interrupt()

    if not toggle('interrupts', false) then return false end
    local intpercent = math.random(35, 55)

    if castable('Hammer of Justice') and target.interrupt('target', intpercent) and IsSpellInRange('Hammer of Justice', 'target') == 1 then
        cast('Hammer of Justice', 'target')
        return true
    end

    return false
end
setfenv(interrupt, dark_addon.environment.env)

local function buffs()

    if not dark_addon.settings.fetch('paladin_AutoBuff', false) then return false end

    local NoAura = player.buff('Devotion Aura').down and player.buff('Retribution Aura').down and player.buff('Concentration Aura').down and
                       player.buff('Shadow Resistance Aura').down and player.buff('Fire Resistance Aura').down and player.buff('Frost Resistance Aura').down

    local blessings = {'Blessing of Might', 'Blessing of Wisdom', 'Blessing of Salvation', 'Blessing of Kings', 'Blessing of Sanctuary'}
    local buffunit
    for i = 1, #blessings do
        buffunit = group.match(function(unit)
            return IsSpellInRange(blessings[i], unit.unitID) == 1 and unit.buff(blessings[i]).up and unit.buff(blessings[i]).remains < math.random(25, 55)
        end)
        if buffunit and castable(blessings[i]) then
            macro("/stand")
            cast(blessings[i], buffunit)
            return true
        end
    end

    if castable('Righteous Fury') and player.buff('Righteous Fury').down and toggle('tank', false) then
        cast('Righteous Fury', 'player')
        return true
    end

    if player.buff('Righteous Fury').up and not toggle('tank', false) then macro('/cancelaura Righteous Fury') end

    if castable('Devotion Aura') and NoAura then
        cast('Devotion Aura', 'player')
        return true
    end

    return false
end
setfenv(buffs, dark_addon.environment.env)

local function dps()

    if not toggle('dps', false) then return false end

    local Useseal = player.buff('Seal of the Crusader').down and player.buff('Seal of Wisdom').down and player.buff('Seal of Light').down and
                        player.buff('Seal of Righteousness').down and player.power.mana.percent >= 20
    local Debuffer = toggle('boss', false) or target.health.percent >= 60
    local Unleash =
        player.buff('Seal of the Crusader').up or player.buff('Seal of Wisdom').up or player.buff('Seal of Light').up or player.power.mana.percent >=
            dark_addon.settings.fetch('paladin_unleash', 60)

    if castable('Divine Shield') and player.debuff('Forebearance').down and not toggle('tank', false) and player.health.percent < 15 then
        macro("/stopcasting")
        cast('Divine Shield', 'player')
        return true
    end

    if castable('Blessing of Protection') and not castable('Divine Shield') and player.debuff('Forebearance').down and not toggle('tank', false) and
        player.health.percent < 15 then
        macro("/stopcasting")
        cast('Blessing of Protection', 'player')
        return true
    end

    if castable('Lay on Hands') and not castable('Blessing of Protection') and not castable('Divine Shield') and player.debuff('Forebearance').down and
        not toggle('tank', false) and player.health.percent < 10 then
        macro("/stopcasting")
        cast('Lay on Hands', 'player')
        return true
    end

    if modifier.control and castable('Consecration') then
        cast('Consecration', 'player')
        return true
    end

    if dark_addon.settings.fetch('paladin_judge', 'jotc') == 'jotc' then
        if castable('Seal of the Crusader') and player.buff('Seal of the Crusader').down and player.power.mana.percent >= 50 and
            target.debuff('Judgement of the Crusader').down and Debuffer and not spell('Judgement').lastcast then
            cast('Seal of the Crusader', 'player')
            return true
        end
    end

    if dark_addon.settings.fetch('paladin_judge', 'jow') == 'jow' then
        if castable('Seal of Wisdom') and player.buff('Seal of Wisdom').down and Debuffer and target.debuff('Judgement of Wisdom').down and
            player.power.mana.percent >= 20 and not spell('Judgement').lastcast then
            cast('Seal of Wisdom', 'player')
            return true
        end
    end

    if dark_addon.settings.fetch('paladin_judge', 'jol') == 'jol' then
        if castable('Seal of Light') and player.buff('Seal of Light').down and not spell('Judgement').lastcast and target.debuff('Judgement of Light').down and
            player.power.mana.percent >= 20 then
            cast('Seal of Light', 'player')
            return true
        end
    end

    if castable('Judgement') and Unleash then
        cast('Judgement', 'target')
        return true
    end

    if dark_addon.settings.fetch('paladin_seal', 'sor') == 'sor' then
        if castable('Seal of Righteousness') and Useseal then
            cast('Seal of Righteousness', 'player')
            return true
        end
    end

    if dark_addon.settings.fetch('paladin_seal', 'sow') == 'sow' then
        if castable('Seal of Wisdom') and Useseal then
            cast('Seal of Wisdom', 'player')
            return true
        end
    end

    if dark_addon.settings.fetch('paladin_seal', 'sol') == 'sol' then
        if castable('Seal of Light') and Useseal then
            cast('Seal of Light', 'player')
            return true
        end
    end

    if castable('Exorcism') and (UnitCreatureType("target") == "Demon" or UnitCreatureType("target") == "Undead") and player.power.mana.percent > 30 then
        cast('Exorcism', target)
        return true
    end

    return false
end
setfenv(dps, dark_addon.environment.env)

local HolyLightMax = {51, 96, 196, 368, 569, 799, 1063}
local HolyLightCoef = {0, 0, 0, 0.71, 0.71, 0.71, 0.71}
local function FindHolyLightRank(unit)
    local rank = 1
    local toHeal = HolyLightMax[rank] + GetSpellBonusHealing() * HolyLightCoef[rank]
    local checker = IsSpellKnown(SB.HolyLight[rank + 1]) and not select(2, IsUsableSpell(SB.HolyLight[rank + 1]))
    while unit.health.missing > toHeal and rank < #HolyLightMax and checker do
        rank = rank + 1
        toHeal = HolyLightMax[rank] + GetSpellBonusHealing() * HolyLightCoef[rank]
        if rank < #HolyLightMax then checker = IsSpellKnown(SB.HolyLight[rank + 1]) and not select(2, IsUsableSpell(SB.HolyLight[rank + 1])) end
    end
    toHeal = HolyLightMax[rank] + GetSpellBonusHealing() * HolyLightCoef[rank]
    if rank > 1 and unit.health.missing < toHeal * 0.8 then rank = rank - 1 end
    return rank, HolyLightMax[rank]
end
setfenv(FindHolyLightRank, dark_addon.environment.env)

local FlashOfLightMax = {77, 117, 171, 231, 310, 389}
local FlashLightCoef = {0.4285, 0.4285, 0.4285, 0.4285, 0.4285, 0.4285}
local function FindFlashOfLightRank(unit)
    local rank = 1
    local toHeal = FlashOfLightMax[rank] + GetSpellBonusHealing() * FlashLightCoef[rank]
    local checker = IsSpellKnown(SB.FlashOfLight[rank + 1]) and not select(2, IsUsableSpell(SB.FlashOfLight[rank + 1]))
    while unit.health.missing > toHeal and rank < #FlashOfLightMax and checker do
        rank = rank + 1
        toHeal = FlashOfLightMax[rank] + GetSpellBonusHealing() * FlashLightCoef[rank]
        if rank < #FlashOfLightMax then checker = IsSpellKnown(SB.FlashOfLight[rank + 1]) and not select(2, IsUsableSpell(SB.FlashOfLight[rank + 1])) end
    end
    toHeal = FlashOfLightMax[rank] + GetSpellBonusHealing() * FlashLightCoef[rank]
    if rank > 1 and unit.health.missing < toHeal * 0.8 then rank = rank - 1 end
    return rank, FlashOfLightMax[rank]
end
setfenv(FindFlashOfLightRank, dark_addon.environment.env)

--
-- Heal Group
--
local function heal()

    if not toggle('heal', false) then return false end

    local holylightpercent

    -- Holy Light
    if not dark_addon.settings.fetch('paladin_holylightpercent.check', false) then
        holylightpercent = 0
    else
        holylightpercent = dark_addon.settings.fetch('paladin_holylightpercent.spin', 70)
    end

    local flashoflightpercent

    -- Flash Of Light
    if not dark_addon.settings.fetch('paladin_flashlightpercent.check', false) then
        flashoflightpercent = 0
    else
        flashoflightpercent = dark_addon.settings.fetch('paladin_flashlightpercent.spin', 70)
    end

    -- to save mana, use the lowest rank holy light that will fully heal
    if lowest.health.percent <= holylightpercent then
        local rank, mag = FindHolyLightRank(lowest)
        if rank > 0 and castable(SB.HolyLight[rank]) and not player.moving then
            cast(SB.HolyLight[rank], lowest)
            return true
        end
    end

    -- to save mana, use the lowest rank flash of light the will fully heal
    if lowest.health.percent <= flashoflightpercent then
        local rank, mag = FindFlashOfLightRank(lowest)
        if rank > 0 and castable(SB.FlashOfLight[rank]) and not player.moving then
            cast(SB.FlashOfLight[rank], lowest)
            return true
        end
    end

    if not incombat then
        local group_unit_count = IsInGroup() and GetNumGroupMembers() or 1
        for i = 1, group_unit_count - 1 do
            local unit = 'party' .. i
            if UnitIsDead(unit) and castable(SB.Redemption) then
                cast(SB.Redemption, unit)
                return true
            end
        end
    end

    local dispellable_unit = group.removable('disease', 'poison')
    if not dispellable_unit then dispeldelay = 0 end

    if dark_addon.settings.fetch('paladin_purify', false) and dispellable_unit then
        if dispeldelay == 0 then
            dispeldelay = GetTime() + 1.5 + math.random()
        else
            if dispeldelay < GetTime() and castable('Purify') then
                cast(SB.Purify, dispellable_unit)
                dispeldelay = 0
                return true
            end
        end
    end

    return false
end
setfenv(heal, dark_addon.environment.env)

local function combat()

    if not player.alive or player.buff('Bandage').exists or player.channeling() or player.casting then return end

    if heal() then return end
    if buffs() then return end
    if not target.alive or not target.enemy or target.debuff('Polymorph').up then return end
    if interrupt() then return end
    if dps() then return end
    -- combat
end

local function resting()

    if not player.alive or player.buff('Food').exists or player.buff('Drink').exists or player.buff('Bandage').exists or player.channeling() or player.casting then
        return
    end

    if heal() then return end
    if buffs() then return end
    -- resting
end

local function interface()

    local interface = {

        key = 'paladin',
        title = 'Paladin by Rohirrim',
        width = 350,
        height = 400,
        resize = true,
        show = false,
        template = {
            {type = 'header', text = 'Paladin Settings', align = 'center'}, {type = 'rule'},
            {key = 'AutoBuff', type = 'checkbox', text = 'Auto Buff', desc = '', default = false}, {type = 'text', text = ' Buffs '}, {
                key = 'buff',
                type = 'dropdown',
                text = 'Blessing of',
                desc = '',
                default = 'bom',
                list = {{key = 'bom', text = 'Might'}, {key = 'bow', text = 'Wisdom'}, {key = 'bok', text = 'Kings'}, {key = 'san', text = 'Sanctuary'}}
            }, {
                key = 'seal',
                type = 'dropdown',
                text = 'Seal of',
                desc = '',
                default = 'sor',
                list = {{key = 'sor', text = 'Righteousness'}, {key = 'sow', text = 'Wisdom'}, {key = 'sol', text = 'Light'}}
            }, {
                key = 'judge',
                type = 'dropdown',
                text = 'Judgment of',
                desc = '',
                default = 'default',
                list = {{key = 'default', text = 'None'}, {key = 'jotc', text = 'the Crusader'}, {key = 'jow', text = 'Wisdom'}, {key = 'jol', text = 'Light'}}
            }, {key = 'unleash', type = 'checkspin', text = 'Judgement at % of mana', default = 60, min = 5, max = 100, step = 5}, {type = 'rule'},
            {type = 'header', text = 'Group Heal', align = 'center'},
            {key = 'holylightpercent', type = 'checkspin', text = 'Holy Light % to heal at', default = 55, min = 5, max = 100, step = 5},
            {key = 'flashlightpercent', type = 'checkspin', text = 'Flash of Light % to heal at', default = 75, min = 5, max = 100, step = 5},
            {key = 'purify', type = 'checkbox', text = 'Purify', desc = '', default = false}
        }
    }

    configWindow = dark_addon.interface.builder.buildGUI(interface)

    dark_addon.interface.buttons.add_toggle({
        name = 'dps',
        label = 'DPS',
        on = {label = 'DPS', color = dark_addon.interface.color.teal, color2 = dark_addon.interface.color.dark_teal},
        off = {label = 'DPS', color = dark_addon.interface.color.grey, color2 = dark_addon.interface.color.dark_grey}
    })

    dark_addon.interface.buttons.add_toggle({
        name = 'tank',
        label = 'Tank',
        on = {label = 'Tank', color = dark_addon.interface.color.teal, color2 = dark_addon.interface.color.dark_teal},
        off = {label = 'Tank', color = dark_addon.interface.color.grey, color2 = dark_addon.interface.color.dark_grey}
    })

    dark_addon.interface.buttons.add_toggle({
        name = 'heal',
        label = 'Heal',
        on = {label = 'Heal', color = dark_addon.interface.color.teal, color2 = dark_addon.interface.color.dark_teal},
        off = {label = 'Heal', color = dark_addon.interface.color.grey, color2 = dark_addon.interface.color.dark_grey}
    })

    dark_addon.interface.buttons.add_toggle({
        name = 'boss',
        label = 'Boss',
        on = {label = 'Boss', color = dark_addon.interface.color.teal, color2 = dark_addon.interface.color.dark_teal},
        off = {label = 'Boss', color = dark_addon.interface.color.grey, color2 = dark_addon.interface.color.dark_grey}
    })

    dark_addon.interface.buttons.add_toggle({
        name = 'settings',
        label = 'Rotation Settings',
        font = 'dark_addon_icon',
        on = {label = dark_addon.interface.icon('cog'), color = dark_addon.interface.color.cyan, color2 = dark_addon.interface.color.dark_blue},
        off = {label = dark_addon.interface.icon('cog'), color = dark_addon.interface.color.grey, color2 = dark_addon.interface.color.dark_grey},
        callback = function(self)
            if configWindow.parent:IsShown() then
                configWindow.parent:Hide()
            else
                configWindow.parent:Show()
            end

        end
    })
end

dark_addon.rotation.register({
    class = dark_addon.rotation.classes.paladin,
    name = 'paladin',
    label = 'Bundled Paladin',
    combat = combat,
    resting = resting,
    interface = interface
})
