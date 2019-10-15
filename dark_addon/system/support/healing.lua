local addon, dark_addon = ...

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

local healths = {}
function healths:actual()
    if GetTime() - self.lastupdate > 5 then
        self:update()
    end
    return self.hp + self.playerInc
end
function healths:update()
    self.hp = UnitHealth(self.unitID)
    self.lastupdate = GetTime()
end
function healths:decreaseIncoming(value)
    self.incoming = self.incoming - value
    self.lastupdate = GetTime()
end
function healths:decreasePlayerIncoming(value)
    self.playerInc = self.playerInc - value
    self.lastupdate = GetTime()
end
function healths:increaceIncoming(value)
    self.incoming = self.incoming + value
    self.lastupdate = GetTime()
end
function healths:increacePlayerIncoming(value)
    self.playerInc = self.playerInc + value
    self.lastupdate = GetTime()
end

dark_addon.UnitHealthActual = {}
function dark_addon.UnitHealthActual.CreateNew(unit)
  return setmetatable({
    unitID = unit,
    unitGUID = UnitGUID(unit),
    hp = UnitHealth(unit),
    playerInc = 0,
    incoming = 0,
    lastupdate = GetTime()
  }, {
    __index = function(t, k)
      return healths[k](t)
    end
  })
end

local spellTargetTracker = {}

dark_addon.event.register("UNIT_HEALTH", function(unit)
    local guid = UnitGUID(unit)
	if not dark_addon.UnitHealthActual[guid] then
		dark_addon.UnitHealthActual[guid] = dark_addon.UnitHealthActual.CreateNew(unit)
    end
    dark_addon.UnitHealthActual[guid].unitID = unit
    dark_addon.UnitHealthActual[guid].update()
end)

local function failedSpellCast(caster, castGUID, spellID)
    if not HealingSpells[spellID] then return end
    if not spellTargetTracker[castGUID] then return end
    local guid = spellTargetTracker[castGUID].guid
    spellTargetTracker[castGUID] = nil
    if not dark_addon.UnitHealthActual[guid] then return end
    dark_addon.UnitHealthActual[guid].decreaseIncoming(HealingSpells[spellID])
    if UnitIsUnit(caster,'player') then
        dark_addon.UnitHealthActual[guid].decreasePlayerIncoming(HealingSpells[spellID])
    end
end

dark_addon.event.register("UNIT_SPELLCAST_STOP", failedSpellCast)
dark_addon.event.register("UNIT_SPELLCAST_INTERRUPTED", failedSpellCast)
dark_addon.event.register("UNIT_SPELLCAST_FAILED_QUIET", failedSpellCast)
dark_addon.event.register("UNIT_SPELLCAST_FAILED", failedSpellCast)

dark_addon.event.register("UNIT_SPELLCAST_SENT", function(caster, target, castGUID, spellID)
    if not HealingSpells[spellID] then return end
    spellTargetTracker[castGUID] = {}
    spellTargetTracker[castGUID].target = target
    spellTargetTracker[castGUID].guid = UnitGUID(target)
    local guid = spellTargetTracker[castGUID].guid
    if not dark_addon.UnitHealthActual[guid] then
        dark_addon.UnitHealthActual[guid] = dark_addon.UnitHealthActual.CreateNew(target)
    end
    dark_addon.UnitHealthActual[guid].unitID = target
    dark_addon.UnitHealthActual[guid].increaceIncoming(HealingSpells[spellID])
    --dark_addon.UnitHealthActual[guid].update()
    if UnitIsUnit(caster,'player') then
        dark_addon.UnitHealthActual[guid].increacePlayerIncoming(HealingSpells[spellID])
    end
end)

dark_addon.event.register("UNIT_SPELLCAST_SUCCEEDED", function(caster, castGUID, spellID)
    if not HealingSpells[spellID] then return end
    local guid = spellTargetTracker[castGUID].guid
    local target = spellTargetTracker[castGUID].target
    if not dark_addon.UnitHealthActual[guid] then
        dark_addon.UnitHealthActual[guid] = dark_addon.UnitHealthActual.CreateNew(target)
    end
    dark_addon.UnitHealthActual[guid].unitID = target
    dark_addon.UnitHealthActual[guid].decreaseIncoming(HealingSpells[spellID])
    local _, _, lagHome, lagWorld = GetNetStats()
    local lag = (((lagHome + lagWorld) / 2) / 1000) * 2
    lag = lag + dark_addon.settings.fetch('_engine_tickrate', 0.1)
    if UnitIsUnit(caster,'player') then
        C_Timer.After(lag, function() dark_addon.UnitHealthActual[guid].decreasePlayerIncoming(HealingSpells[spellID]) end)
    end
end)
