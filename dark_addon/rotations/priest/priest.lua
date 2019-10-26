local addon, dark_addon = ...

local lastAuto = 0

dark_addon.event.register("UNIT_SPELLCAST_SUCCEEDED", function(caster, castGUID, spellID)
	if not spellID == 5019 then return end
	if not UnitIsUnit(caster,'player') then return end
	lastAuto = GetTime()
end)

local function heal()
  --if GetTime() - lastAuto < 2 then return false end
  if player.health.percent < 90 and player.buff('Power Word: Shield').down and
    castable('Power Word: Shield') and player.debuff('Weakened Soul').down then
    cast('Power Word: Shield', 'player')
    return true
  end

  if player.health.percent < 70 and player.buff('Renew').down and castable('Renew') then
    cast('Renew', 'player')
    return true
  end

  if player.health.percent < 60 and player.buff('Power Word: Shield').up and castable('Lesser Heal') and not player.moving then
    cast('Lesser Heal', 'player')
    return true
  end

  return false
end
setfenv(heal, dark_addon.environment.env)

local function dps()
  --if GetTime() - lastAuto < 2 then return false end

  --[[if castable('Mind Blast') and not player.moving then
    cast('Mind Blast', 'target')
    return true
  end]]

  if castable('Shadow Word: Pain') and target.debuff('Shadow Word: Pain').down and target.health.percent > 50 then
    cast('Shadow Word: Pain', 'target')
    return true
  end

  return false
end
setfenv(dps, dark_addon.environment.env)

local function wand()
  local pain = target.debuff('Shadow Word: Pain').down and target.health.percent > 50
  local shield = player.health.percent < 90 and player.buff('Power Word: Shield').down and player.debuff('Weakened Soul').down
  local hot = player.health.percent < 70 and player.buff('Renew').down
  local lheal = player.health.percent < 60

  if player.power.mana.percent > 5 then
    if pain then return false end
    if shield then return false end
    if hot then return false end
    if lheal then return false end
  end

  if GetTime() - lastAuto > 2 then
    cast('Shoot','target')
    lastAuto = GetTime()
    return true
  end

  return true
end
setfenv(wand, dark_addon.environment.env)

local function combat()

  if not target.alive or not target.enemy or player.buff('Bandage').exists or target.debuff('Polymorph').up or 
    player.channeling() then return end

  if not wand() and GetTime() - lastAuto < 1 then
    cast('Shoot','target')
    lastAuto = 0
    return
  end
  if heal() then return end
  if not IsSpellInRange('Smite') == 1 then return end
  if dps() then return end
    -- combat
end

local function gcd()
  if not UnitAffectingCombat('player') then return end
  if not target.alive or not target.enemy or player.buff('Bandage').exists or target.debuff('Polymorph').up or player.channeling() then return end

  if not wand() and GetTime() - lastAuto < 1 then
    cast('Shoot','target')
    lastAuto = 0
    return
  end
  if heal() then return end
  if not IsSpellInRange('Smite') == 1 then return end
  if dps() then return end
  
end

local function resting()

  if not player.alive or player.buff('Food').exists or player.buff('Drink').exists or
    player.buff('Bandage').exists or player.channeling() or player.casting then return end

  if castable(SB.PowerWordFortitude) and player.buff(SB.PowerWordFortitude).down then
    macro("/stand")
    cast(SB.PowerWordFortitude, player)
    return true
  end
    -- resting
end

dark_addon.rotation.register({
  class = dark_addon.rotation.classes.priest,
  name = 'priest',
  label = 'Bundled Priest',
  combat = combat,
  gcd = combat,
  resting = resting
})
