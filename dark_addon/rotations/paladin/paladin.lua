local addon, dark_addon = ...

dark_addon.event.register("UI_ERROR_MESSAGE", function(_, msg)
    if UnitAffectingCombat('player') then return end
    local p = dark_addon.environment.env.player
    if strfind(msg, 'standing to do') and (not p.buff('Food').exists or not p.buff('Drink').exists) then _RunMacroText('/stand') end
end)

local php
local thp
local pmp
local tanking
local flee
local Group
local strong
local usemanapotion
local usemanapotionpercent
local usehealingpotion
local usehealingpotionpercent
local usehealthstone
local usehealthstonepercent
local RetAura
local DevAura
local SanAura
local NoResistAura
local pushback
local NoSeal

local ManaPotionID = {2455, 3385, 6149, 18841, 13444}
local ManaPotionName = {'Minor Mana Potion', 'Lesser Mana Potion', 'Greater Mana Potion', 'Combat Mana Potion', 'Major Mana Potion'}
local HealingPotionID = {118, 858, 4596, 1710, 18839, 3928, 13446}
local HealingPotionName = {
    'Minor Healing Potion', 'Lesser Healing Potion', 'Discolored Healing Potion', 'Greater Healing Potion', 'Combat Healing Potion', 'Superior Healing Potion',
    'Major Healing Potion'
}
local HealthstoneID = {5512, 19004, 19005, 5511, 19006, 19007, 5509, 19008, 19009, 5510, 19010, 19011, 9421, 19012, 19013}
local HealthstoneName = {
    'Minor Healthstone', 'Minor Healthstone', 'Minor Healthstone', 'Lesser Healthstone', 'Lesser Healthstone', 'Lesser Healthstone', 'Healthstone',
    'Healthstone', 'Healthstone', 'Greater Healthstone', 'Greater Healthstone', 'Greater Healthstone', 'Major Healthstone', 'Major Healthstone',
    'Major Healthstone'
}

local HolyLightMax = {51, 96, 196, 368, 569, 799, 1063, 1414, 1770}
local HolyLightCoef = {0, 0, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71, 0.71}
local function FindHolyLightRank(unit)
    local rank = 1
    local toHeal = HolyLightMax[rank] + GetSpellBonusHealing() * HolyLightCoef[rank]
    local checker = IsSpellKnown(SB.HolyLight[rank + 1]) and not select(2, IsUsableSpell(SB.HolyLight[rank + 1]))
    while unit.health.missing > toHeal and rank < #HolyLightMax and checker do
        rank = rank + 1
        toHeal = HolyLightMax[rank] + GetSpellBonusHealing() * HolyLightCoef[rank]
        if rank < #HolyLightMax then checker = IsSpellKnown(SB.HolyLight[rank + 1]) and not select(2, IsUsableSpell(SB.HolyLight[rank + 1])) end
    end
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
    return rank, FlashOfLightMax[rank]
end
setfenv(FindFlashOfLightRank, dark_addon.environment.env)

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
    return false
end
setfenv(heal, dark_addon.environment.env)

local function useitem()

    if usehealthstone then
        for i = #HealthstoneID, 1, -1 do
            if GetItemCount(HealthstoneID[i]) >= 1 and php <= usehealthstonepercent and (GetItemCooldown(HealthstoneID[i])) == 0 then
                macro('/use ' .. HealthstoneName[i])
                return true
            end
        end
    end

    if usehealingpotion then
        for i = #HealingPotionID, 1, -1 do
            if GetItemCount(HealingPotionID[i]) >= 1 and php <= usehealingpotionpercent and (GetItemCooldown(HealingPotionID[i])) == 0 then
                macro('/use ' .. HealingPotionName[i])
                return true
            end
        end
    end

    if usemanapotion then
        for i = #ManaPotionID, 1, -1 do
            if GetItemCount(ManaPotionID[i]) >= 1 and pmp <= usemanapotionpercent and (GetItemCooldown(ManaPotionID[i])) == 0 then
                macro('/use ' .. ManaPotionName[i])
                return true
            end
        end
    end

    return false
end
setfenv(useitem, dark_addon.environment.env)

local dispeldelaypurify = 0
local dispeldelaycleanse = 0

local function dispell()

    local dispellable_unit_purify = group.removable('poison', 'disease')
    local dispellable_unit_cleanse = group.removable('poison', 'disease', 'magic')

    if not dispellable_unit_purify then dispeldelaypurify = 0 end

    if dark_addon.settings.fetch('paladin_dispell', false) and dispellable_unit_purify and not IsSpellKnown(4987) then
        if dispeldelaypurify == 0 then
            dispeldelaypurify = GetTime() + 1.5 + math.random()
        else
            if dispeldelaypurify < GetTime() and castable(SB.Purify) then
                cast(SB.Purify, dispellable_unit_purify)
                dispeldelaypurify = 0
                return true
            end
        end
    end

    if not dispellable_unit_cleanse then dispeldelaycleanse = 0 end

    if dark_addon.settings.fetch('paladin_dispell', false) and dispellable_unit_cleanse then
        if dispeldelaycleanse == 0 then
            dispeldelaycleanse = GetTime() + 1.5 + math.random()
        else
            if dispeldelaycleanse < GetTime() and castable(SB.Cleanse) then
                cast(SB.Cleanse, dispellable_unit_cleanse)
                dispeldelaycleanse = 0
                return true
            end
        end
    end

    return false
end
setfenv(dispell, dark_addon.environment.env)

local function buffs()

    if not dark_addon.settings.fetch('paladin_AutoBuff', false) then return false end

    local blessings = {'Blessing of Might', 'Blessing of Wisdom', 'Blessing of Salvation', 'Blessing of Kings', 'Blessing of Sanctuary'}
    local buffunit
    for i = 1, #blessings do
        buffunit = group.match(function(unit)
            return IsSpellInRange(blessings[i], unit.unitID) == 1 and unit.buff(blessings[i]).up and unit.buff(blessings[i]).remains < math.random(25, 55)
        end)
        if buffunit and castable(blessings[i]) then
            cast(blessings[i], buffunit)
            return true
        end
    end

    if not toggle('tank', false) and player.buff('Righteous Fury').up then
        macro('/cancelaura Righteous Fury')
        return true
    end

    if toggle('tank', false) and player.buff('Righteous Fury').down then
        cast('Righteous Fury', 'player')
        return true
    end

    if not target.exists or UnitCanAssist('player','target') or not target.alive then return false end

    if pushback and NoResistAura and player.buff(SB.ConcentrationAura).down then
        cast(SB.ConcentrationAura)
        return true
    end

    if not pushback and NoResistAura and RetAura and player.buff(SB.RetributionAura).down then
        cast(SB.RetributionAura)
        return true
    end

    if not pushback and NoResistAura and DevAura and player.buff(SB.DevotionAura).down then
        cast(SB.DevotionAura)
        return true
    end

    if not pushback and NoResistAura and SanAura and player.buff(SB.SanctityAura).down then
        cast(SB.SanctityAura)
        return true
    end

    if strong and NoSeal and thp > 50 and castable(SB.SealOfTheCrusader) then
        cast(SB.SealOfTheCrusader)
        return true
    end

    if NoSeal and castable(SB.SealOfRighteousness) then
        cast(SB.SealOfRighteousness)
        return true
    end

    return false
end
setfenv(buffs, dark_addon.environment.env)

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

local function dps()

    if target.distance < 10 and not IsCurrentSpell(6603) then
        auto_attack()
        return true
    end

    if UnitCreatureType("target") == "Totem" or target.distance > 10 then return false end

    if modifier.control and not player.moving and enemies.around(8) >= 3 and castable(SB.Consecration) then
        cast(SB.Consecration)
        return true
    end

    if modifier.control and not player.moving and enemies.around(8) >= 3 and not tanking and castable(SB.HolyWrath) then
        if (UnitCreatureType("target") == "Demon" or UnitCreatureType("target") == "Undead") then
            cast(SB.HolyWrath)
            return true
        end
    end

    if castable('Judgement') and player.buff(SB.SealOfTheCrusader).up and target.debuff('Judgement of the Crusader').down then
        cast(SB.Judgement)
        return true
    end

    if castable('Judgement') and player.buff(SB.SealOfLight).up and target.debuff('Judgement of Light').down then
        cast(SB.Judgement)
        return true
    end

    if castable('Judgement') and player.buff(SB.SealOfWisdom).up and target.debuff('Judgement of Wisdom').down then
        cast(SB.Judgement)
        return true
    end

    if castable('Judgement') and player.buff(SB.SealOfRighteousness).up and (not tanking or flee) and toggle('tank', false) then
        cast(SB.Judgement)
        return true
    end

    if castable('Exorcism') and (UnitCreatureType("target") == "Demon" or UnitCreatureType("target") == "Undead") and (not tanking or flee) and
        toggle('tank', false) then
        cast(SB.Exorcism)
        return true
    end

    if usejudgement and not toggle('tank', false) then
        if castable('Judgement') and pmp > usejudgementpercent then
            cast(SB.Judgement)
            return true
        end
    end

    if useexorcism and not toggle('tank', false) then
        if castable('Exorcism') and pmp > useexorcismpercent and (UnitCreatureType("target") == "Demon" or UnitCreatureType("target") == "Undead") then
            cast(SB.Exorcism)
            return true
        end
    end

    return false
end
setfenv(dps, dark_addon.environment.env)

local function combat()

    if not player.alive or player.buff('Bandage').exists or player.channeling() or player.casting or UnitIsAFK('player') or IsResting() then return end

    php = player.health.percent
    thp = target.health.percent
    pmp = player.power.mana.percent
    tanking = UnitIsUnit('player', 'targettarget') == true
    flee = not UnitExists('targettarget')
    Group = GetNumGroupMembers()
    strong = UnitClassification("target") == "elite" or UnitClassification("target") == "rareelite" or UnitClassification("target") == "worldboss"
    usemanapotion = dark_addon.settings.fetch('paladin_usemanapotion.check', false)
    usemanapotionpercent = dark_addon.settings.fetch('paladin_usemanapotion.spin', 10)
    usehealingpotion = dark_addon.settings.fetch('paladin_usehealingpotion.check', false)
    usehealingpotionpercent = dark_addon.settings.fetch('paladin_usehealingpotion.spin', 15)
    usehealthstone = dark_addon.settings.fetch('paladin_usehealthstone.check', false)
    usehealthstonepercent = dark_addon.settings.fetch('paladin_usehealthstone.spin', 20)
    RetAura = dark_addon.settings.fetch('paladin_aura', 'ret') == 'ret'
    DevAura = dark_addon.settings.fetch('paladin_aura', 'dev') == 'dev'
    SanAura = dark_addon.settings.fetch('paladin_aura', 'san') == 'san'
    NoResistAura = player.buff('Shadow Resistance Aura').down and player.buff('Fire Resistance Aura').down and player.buff('Frost Resistance Aura').down
    pushback = enemies.around(8) >= 3 and php < 50 and tanking
    NoSeal = player.buff(SB.SealOfLight).down and player.buff(SB.SealOfRighteousness).down and player.buff(SB.SealOfTheCrusader).down and
                 player.buff(SB.SealOfWisdom).down
    usejudgement = dark_addon.settings.fetch('paladin_judgement.check', false)
    usejudgementpercent = dark_addon.settings.fetch('paladin_judgement.spin', 70)
    useexorcism = dark_addon.settings.fetch('paladin_exorcism.check', false)
    useexorcismpercent = dark_addon.settings.fetch('paladin_exorcism.spin', 70)

    if useitem() then return end
    if heal() then return end
    if dispell() then return end
    if buffs() then return end
    if not target.exists or not target.alive then return end
    if interrupt() then return end
    if dps() then return end

    -- combat
end

local function resting()

    if not player.alive or player.buff('Food').exists or player.buff('Drink').exists or player.buff('Bandage').exists or player.channeling() or player.casting or
        UnitIsAFK('player') or IsResting() then return end

    RetAura = dark_addon.settings.fetch('paladin_aura', 'ret') == 'ret'
    DevAura = dark_addon.settings.fetch('paladin_aura', 'dev') == 'dev'
    SanAura = dark_addon.settings.fetch('paladin_aura', 'san') == 'san'
    NoResistAura = player.buff('Shadow Resistance Aura').down and player.buff('Fire Resistance Aura').down and player.buff('Frost Resistance Aura').down
    pushback = enemies.around(8) >= 3 and php < 50 and tanking
    NoSeal = player.buff(SB.SealOfLight).down and player.buff(SB.SealOfRighteousness).down and player.buff(SB.SealOfTheCrusader).down and
                 player.buff(SB.SealOfWisdom).down

    if heal() then return end
    if dispell() then return end
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
            {key = 'AutoBuff', type = 'checkbox', text = 'Auto Buff', desc = '', default = false},
            {key = 'dispell', type = 'checkbox', text = 'Auto Dispel', desc = 'Will use Purify or Cleanse', default = false}, {
                key = 'aura',
                type = 'dropdown',
                text = 'Aura of',
                desc = 'Default aura to use',
                default = 'ret',
                list = {{key = 'ret', text = 'Retribution'}, {key = 'dev', text = 'Devotion'}, {key = 'san', text = 'Sanctity'}, {key = 'non', text = 'None'}}
            },
            {
                key = 'judgement',
                type = 'checkspin',
                text = 'Use judgment of the Righteousness at % mana when not tank',
                default = 70,
                min = 5,
                max = 100,
                step = 5
            }, {key = 'exorcism', type = 'checkspin', text = 'Use Exorcism at % Mana when not tank', default = 5, min = 5, max = 100, step = 5},
            {type = 'rule'}, {type = 'header', text = 'Use Item', align = 'center'},
            {key = 'usehealingpotion', type = 'checkspin', text = 'Use Healing Potion when under % HP', default = 15, min = 5, max = 100, step = 5},
            {key = 'usehealthstone', type = 'checkspin', text = 'Use Healthstone when under % HP', default = 20, min = 5, max = 100, step = 5},
            {key = 'usemanapotion', type = 'checkspin', text = 'Use Mana Potion when under % Mana', default = 5, min = 5, max = 100, step = 5}, {type = 'rule'},
            {type = 'header', text = 'Group Heal', align = 'center'},
            {key = 'holylightpercent', type = 'checkspin', text = 'Holy Light % to heal at', default = 55, min = 5, max = 100, step = 5},
            {key = 'flashlightpercent', type = 'checkspin', text = 'Flash of Light % to heal at', default = 75, min = 5, max = 100, step = 5}
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
