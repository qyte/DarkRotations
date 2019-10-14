
local HealingSpells = {
    --Druid
    --Regrowth
    [8936] = "100",--rank1
    [8938] = "190",--rank2
    [8939] = "275",--rank3
    [8940] = "360",--rank4
    [8941] = "450",--rank5
    [9750] = "580",--rank6
    [9856] = "720",--rank7
    [9857] = "890",--rank8
    [9858] = "1070",--rank9

    --Paladin
    --Flash of Light
    [19750] = "72",--rank1
    [19939] = "110",--rank2
    [19940] = "162",--rank3
    [19941] = "218",--rank4
    [19942] = "294",--rank5
    [19943] = "368",--rank6
    --Holy Light
    [635] = "46",--rank1
    [639] = "88",--rank2
    [647] = "181",--rank3
    [1026] = "345",--rank4
    [1042] = "538",--rank5
    [3472] = "758",--rank6
    [10328] = "1022",--rank7
    [10329] = "1343",--rank8
    [25292] = "1680"--rank9
}

local spellTargetTracker = {}
dark_addon.UnitHealthActual = {}

dark_addon.event.register("UNIT_HEALTH", function(unit)
    dark_addon.UnitHealthActual[unit] = UnitHealth(unit)
end)

local function failedSpellCast(unit, castGUID, spellID)
    spellTargetTracker[castGUID] = nil
end

dark_addon.event.register("UNIT_SPELLCAST_STOP", failedSpellCast)
dark_addon.event.register("UNIT_SPELLCAST_INTERRUPTED", failedSpellCast)
dark_addon.event.register("UNIT_SPELLCAST_FAILED_QUIET", failedSpellCast)
dark_addon.event.register("UNIT_SPELLCAST_FAILED", failedSpellCast)

dark_addon.event.register("UNIT_SPELLCAST_SENT", function(unit, target, castGUID, spellID)
    if not healingspells[spellID] then return end
    spellTargetTracker[castGUID].target = target
    spellTargetTracker[castGUID].time = GetTime()
end)

dark_addon.event.register("UNIT_SPELLCAST_SUCCEEDED", function(unit, castGUID, spellID)
    local target = spellTargetTracker[castGUID].target
    if dark_addon.UnitHealthActual[target] == nil then
        dark_addon.UnitHealthActual[target].hp = _G.UnitHealth(target)
        --dark_addon.UnitHealthActual[target].lastupdate = GetTime()
    end
    local newHp = dark_addon.UnitHealthActual[target].hp + HealingSpells[spellID]
    if newHp > UnitHealthMax(target) then
        newHp = UnitHealthMax(target)
    end
    dark_addon.UnitHealthActual[target].hp = newHp
    dark_addon.UnitHealthActual[target].lastupdate = GetTime()
end)
