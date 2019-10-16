local addon, dark_addon = ...

local function buffs()
  if castable(SB.MarkOfTheWild) and player.buff(SB.MarkOfTheWild).down then
    cast(SB.MarkOfTheWild,'player')
    return true
  end
  if castable(SB.Thorns) and player.buff(SB.Thorns).down then
    cast(SB.Thorns,'player')
    return true
  end
end
setfenv(buffs, dark_addon.environment.env)

local function heal()--HealingTouch Regrowth Rejuvenation
  local HealingTouchpct = 50
  local Regrowthpct = 70
  local Rejuvpct = 80
  if lowest.health.percent <= HealingTouchpct then
    if castable(SB.HealingTouch) then
      cast(SB.HealingTouch,'player')
      return true
    end
  end
  if lowest.health.percent <= Regrowthpct then
    if castable(SB.Regrowth) and player.buff(SB.Regrowth).down then
      cast(SB.Regrowth,'player')
      return true
    end
  end
  if lowest.health.percent <= Rejuvpct then
    if castable(SB.Rejuvenation) and player.buff(SB.Rejuvenation).down then
      cast(SB.Rejuvenation,'player')
      return true
    end
  end
end
setfenv(heal, dark_addon.environment.env)

local function combat()
  if not player.alive or player.buff('Bandage').exists or 
          player.channeling() or player.casting then return end

  if heal() then return end
  if buffs() then return end
  if not target.alive or not target.enemy or target.debuff('Polymorph').up then return end
  if target.distance < 10 then
    auto_attack()
  end
end

local function resting()
  if not player.alive or player.buff('Food').exists or player.buff('Drink').exists or
  player.buff('Bandage').exists or player.channeling() or player.casting then return end

  if heal() then return end
  if buffs() then return end
end

dark_addon.rotation.register({
  class = dark_addon.rotation.classes.druid,
  name = 'druid',
  label = 'Bundled Druid',
  combat = combat,
  resting = resting
})
