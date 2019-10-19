local addon, dark_addon = ...

local bonus = 0

local heals = {}
function heals:avg()
    return math.floor((self.min + self.max)/2)
end
function heals:heal()
    return math.floor(self.avg + (self.coef * bonus))
end
function heals:hpm()
    return math.floor(self.heal / GetSpellPowerCost(self.id)[1].cost)
end
function heals:hps()
    return math.floor(self.heal / (select(4,GetSpellInfo(self.id)) / 1000))
end

dark_addon.healing = {
    --Druid
    --Regrowth
    [8936] = {min=93,max=107,coef=0},  --rank1
    [8938] = {min=176,max=201,coef=0},  --rank2
    [8939] = {min=255,max=290,coef=0.5714},  --rank3
    [8940] = {min=336,max=378,coef=0.5714},  --rank4
    [8941] = {min=425,max=478,coef=0.5714},  --rank5
    [9750] = {min=534,max=599,coef=0.5714},  --rank6
    [9856] = {min=672,max=751,coef=0.5714},  --rank7
    [9857] = {min=839,max=935,coef=0.5714},  --rank8
    [9858] = {min=1003,max=1119,coef=0.5714},  --rank9

    --Healing Touch
    [5185] = {min=40,max=55,coef=0},  --rank1
    [5186] = {min=94,max=119,coef=0},  --rank2
    [5187] = {min=204,max=253,coef=0},  --rank3
    [5188] = {min=376,max=459,coef=0.8571},  --rank4
    [5189] = {min=589,max=712,coef=1},  --rank5
    [6778] = {min=762,max=914,coef=1},  --rank6
    [8903] = {min=958,max=1143,coef=1},  --rank7
    [9758] = {min=1225,max=1453,coef=1},  --rank8
    [9888] = {min=1545,max=1826,coef=1},  --rank9
    [9889] = {min=1916,max=2257,coef=1},  --rank10
    [25297] = {min=2267,max=2677,coef=1},  --rank11

    --Priest
    --Greater Heal
    [2060] = {min=924,max=1034,coef=0.8571},--rank1
    [10963] = {min=1178,max=1318,coef=0.8571},--rank2
    [10964] = {min=1470,max=1642,coef=0.8571},--rank3
    [10965] = {min=1813,max=2021,coef=0.8571},--rank4
    [25314] = {min=1966,max=2194,coef=0.8571},--rank5
    
    --Prayer of Healing
    [596] = {min=312,max=333,coef=0.8571},--rank1
    [996] = {min=458,max=487,coef=0.8571},--rank2
    [10960] = {min=675,max=713,coef=0.8571},--rank3
    [10961] = {min=939,max=991,coef=0.8571},--rank4
    [25316] = {min=1041,max=1099,coef=0.8571},--rank5
    
    --Flash Heal
    [2061] = {min=202,max=247,coef=0.4286},--rank1
    [9472] = {min=269,max=325,coef=0.4286},--rank2
    [9473] = {min=339,max=406,coef=0.4286},--rank3
    [9474] = {min=414,max=492,coef=0.4286},--rank4
    [10915] = {min=534,max=633,coef=0.4286},--rank5
    [10916] = {min=662,max=783,coef=0.4286},--rank6
    [10917] = {min=828,max=975,coef=0.7143},--rank7
    
    --Heal
    [2054] = {min=307,max=353,coef=0},--rank1
    [2055] = {min=455,max=507,coef=0.8571},--rank2
    [6063] = {min=586,max=662,coef=0.8571},--rank3
    [6064] = {min=734,max=827,coef=0.8571},--rank4
    
    --Lesser Heal
    [2050] = {min=47,max=58,coef=0},--rank1
    [2052] = {min=76,max=91,coef=0},--rank2
    [2053] = {min=143,max=165,coef=0},--rank3

    --Paladin
    --Flash of Light
    [19750] = {min=67,max=77,coef=0.4286},--rank1
    [19939] = {min=102,max=117,coef=0.4286},--rank2
    [19940] = {min=153,max=171,coef=0.4286},--rank3
    [19941] = {min=206,max=231,coef=0.4286},--rank4
    [19942] = {min=278,max=310,coef=0.4286},--rank5
    [19943] = {min=348,max=389,coef=0.4286},--rank6
    --Holy Light
    [635] = {min=42,max=51,coef=0},--rank1
    [639] = {min=81,max=96,coef=0},--rank2
    [647] = {min=167,max=196,coef=0},--rank3
    [1026] = {min=322,max=368,coef=0.7143},--rank4
    [1042] = {min=506,max=569,coef=0.7143},--rank5
    [3472] = {min=717,max=799,coef=0.7143},--rank6
    [10328] = {min=968,max=1076,coef=0.7143},--rank7
    [10329] = {min=1272,max=1414,coef=0.7143},--rank8
    [25292] = {min=1590,max=1770,coef=0.7143},--rank9

    --Shaman
    --Healing Wave
    [331] = {min=36,max=47,coef=0},  --rank1
    [332] = {min=69,max=83,coef=0},  --rank2
    [547] = {min=136,max=163,coef=0},  --rank3
    [913] = {min=279,max=328,coef=0},  --rank4
    [939] = {min=389,max=454,coef=0.8571},  --rank5
    [959] = {min=552,max=639,coef=0.8571},  --rank6
    [8005] = {min=759,max=874,coef=0.8571},  --rank7
    [10395] = {min=1040,max=1191,coef=0.8571},  --rank8
    [10396] = {min=1389,max=1583,coef=0.8571},  --rank9
    
    --Lesser Healing Wave
    [8004] = {min=170,max=195,coef=0.4286},--rank1
    [8008] = {min=257,max=292,coef=0.4286},--rank2
    [8010] = {min=349,max=394,coef=0.4286},--rank3
    [10466] = {min=473,max=529,coef=0.4286},--rank4
    [10467] = {min=649,max=723,coef=0.4286},--rank5

    --Chain Heal
    [1064] = {min=332,max=381,coef=0.7143},--rank1
    [10622] = {min=419,max=479,coef=0.7143}--rank2
}

local HealingSpells = dark_addon.healing

for key,t in pairs(HealingSpells) do
    t.id = key
    setmetatable(t,{__index = function(t, k) return heals[k](t) end})
end
function dark_addon.healing.CastBestHpm(unit, effective)
    --body
end
function dark_addon.healing.CastBestHps(unit, effective)
    --body
end


-- API CONSTANTS
--local ALL_DATA = 0x0f
local DIRECT_HEALS = 0x01
local CHANNEL_HEALS = 0x02
local HOT_HEALS = 0x04
--local ABSORB_SHIELDS = 0x08
local ALL_HEALS = bit.bor(DIRECT_HEALS, CHANNEL_HEALS, HOT_HEALS)
local CASTED_HEALS = bit.bor(DIRECT_HEALS, CHANNEL_HEALS)
local OVERTIME_HEALS = bit.bor(HOT_HEALS, CHANNEL_HEALS)

local UnitHealth = _G.UnitHealth
local UnitHealthMax = _G.UnitHealthMax
local UnitIsUnit = _G.UnitIsUnit
local healths = {}
function healths:hp()
    return UnitHealth(self.unitID)
end
function healths:actual()
    return self.hp + self.playerInc
end
function healths:effective()
    return self.hp + self.incoming
end
function healths:incoming()
    if UnitCanAttack('player',self.unitID) then return 0 end
    return dark_addon.Healcomm:GetHealAmount(self.unitGUID,ALL_HEALS) or 0
end
local function decreasePlayerIncoming(self, value)
    self.playerInc = self.playerInc - value
    if self.playerInc < 0 then
        self.playerInc = 0
    end
end

local playerGUID = nil
local healunit = dark_addon.savedHealTarget

dark_addon.UnitHealth = {}
setmetatable(dark_addon.UnitHealth,{
    __call = function(t,arg)
        local unit = arg
        if type(arg) == 'table' then
            unit = arg.unitID
        end
        local idx = UnitGUID(unit)
        if not idx then return t[unit] end --assuming a guid is passed as param
        if UnitCanAttack('player',unit) then
            return setmetatable({
                unitID = unit,
                unitGUID = idx,
                playerInc = 0
              }, {
                __index = function(t, k)
                  return healths[k](t)
                end
              })
        end
        local playerheal = 0
        local spellcast = CastingInfo()
        if CastingInfo() then
            playerheal = dark_addon.Healcomm:GetHealAmount(idx,DIRECT_HEALS,nil,playerGUID) or 0
            local playerhealafter = dark_addon.Healcomm:GetHealAmount(idx,DIRECT_HEALS,GetTime() + 0.5,playerGUID) or 0
            playerheal = playerheal - playerhealafter
            if playerheal > 0 then
                healunit = unit
            end
        end
        if t[idx] then
            t[idx].unitID = unit
            --[[if playerheal == 0 and t[idx].playerInc > 0 then
                local lag = select(4, GetNetStats()) / 1000
                local castclip = dark_addon.settings.fetch('_engine_castclip', 0.15)
                local ticker = dark_addon.settings.fetch('_engine_tickrate', 0.1)
                lag = lag + ticker + castclip
            end]]
            t[idx].playerInc = playerheal
            return t[idx]
        end
        t[idx] = setmetatable({
            unitID = unit,
            unitGUID = idx,
            playerInc = playerheal
          }, {
            __index = function(t, k)
              return healths[k](t)
            end
          })
        return t[idx]
    end
})

local function cleartable(t)
    for key,_ in pairs(t) do
        t[key] = nil
    end
end

local spellTargetTracker = {}

dark_addon.event.register("PLAYER_ENTERING_WORLD", function()
    bonus = GetSpellBonusHealing()
    playerGUID = UnitGUID('player')
    cleartable(dark_addon.UnitHealth)
    cleartable(spellTargetTracker)
end)
dark_addon.event.register("UNIT_HEALTH", function(unit)
    if UnitCanAttack('player', unit) then return end
    dark_addon.UnitHealth(unit)
end)

dark_addon.on_ready(function()
    local lag = select(4, GetNetStats()) / 1000
    local castclip = dark_addon.settings.fetch('_engine_castclip', 0.15)
    local ticker = dark_addon.settings.fetch('_engine_tickrate', 0.1)
    lag = lag + ticker + castclip
    if not healunit then return end
end)
local function failedSpellCast(caster, castGUID, spellID)
    if not HealingSpells[spellID] then return end
    if not spellTargetTracker[castGUID] then return end
    local health = dark_addon.UnitHealth(spellTargetTracker[castGUID])
    spellTargetTracker[castGUID] = nil
    if not health then return end
    if UnitIsUnit(caster,'player') then
        decreasePlayerIncoming(health, HealingSpells[spellID].heal)
    end
    dark_addon.console.debug(1, 'engine', 'engine', string.format('UnitHealth of %s is now %d', target, health.actual))
end

dark_addon.event.register("UNIT_SPELLCAST_STOP", failedSpellCast)
dark_addon.event.register("UNIT_SPELLCAST_INTERRUPTED", failedSpellCast)
dark_addon.event.register("UNIT_SPELLCAST_FAILED_QUIET", failedSpellCast)
dark_addon.event.register("UNIT_SPELLCAST_FAILED", failedSpellCast)

dark_addon.event.register("UNIT_SPELLCAST_START", function(caster, castGUID, spellID)
    if not HealingSpells[spellID] then return end
    dark_addon.console.debug(1, 'engine', 'engine', string.format('STARTED spell %s by %s',dark_addon.environment.GetSpellName(spellID),caster))
    if not spellTargetTracker[castGUID] then
        dark_addon.console.debug(1, 'engine', 'engine', string.format('casting STARTED before SENT spell %s',dark_addon.environment.GetSpellName(spellID)))
    end
end)

dark_addon.event.register("UNIT_SPELLCAST_DELAYED", function(caster, castGUID, spellID)
    if not HealingSpells[spellID] then return end
    if not spellTargetTracker[castGUID] then return end
    dark_addon.console.debug(1, 'engine', 'engine', string.format('DELAYED spell %s',dark_addon.environment.GetSpellName(spellID)))
end)

local function findUnitByName(target)
    local group = dark_addon.environment.group
    if UnitGUID(target) then return unit end
    if dark_addon.savedHealTarget and UnitName(target) == UnitName(dark_addon.savedHealTarget) then return dark_addon.savedHealTarget end
    local groupmember = dark_addon.environment.group.match(function (unit) return UnitName(unit) == UnitName(target) end )
    if groupmember then return groupmember.unitID end
    return false
end

dark_addon.event.register("UNIT_SPELLCAST_SENT", function(caster, target, castGUID, spellID)
    if not HealingSpells[spellID] then return end
    if not UnitGUID(target) and not dark_addon.savedHealTarget then return end
    spellTargetTracker[castGUID] = dark_addon.savedHealTarget or target
    if not UnitGUID(spellTargetTracker[castGUID]) then
        spellTargetTracker[castGUID] = nil
        return
    end
    dark_addon.savedHealTarget = false
    local health = dark_addon.UnitHealth(spellTargetTracker[castGUID])
    if UnitIsUnit(caster,'player') then
        increacePlayerIncoming(health, HealingSpells[spellID].heal)
    end
end)

dark_addon.event.register("UNIT_SPELLCAST_SUCCEEDED", function(caster, castGUID, spellID)
    if not HealingSpells[spellID] then return end
    if not spellTargetTracker[castGUID] then return end
    local target = spellTargetTracker[castGUID]
    spellTargetTracker[castGUID] = nil
    local health = dark_addon.UnitHealth(target)
    local _, _, lagHome, lagWorld = GetNetStats()
    local lag = (((lagHome + lagWorld) / 2) / 1000) * 2
    lag = lag + dark_addon.settings.fetch('_engine_tickrate', 0.1)
    if UnitIsUnit(caster,'player') then
        C_Timer.After(lag, function()
            decreasePlayerIncoming(health, HealingSpells[spellID].heal)
        end)
    end
end)
