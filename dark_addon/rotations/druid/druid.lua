local addon, dark_addon = ...

local caster
local bear
local aquatic
local cat
local travel
local FormMana
local SuperHealCost
local HealCost

local function interrupt()

  if not toggle('interrupts', false) then return false end
  local intpercent = math.random(35, 55)

  if bear and castable('Bash') and target.interrupt('target', intpercent) and
      IsSpellInRange('Bash', 'target') == 1 then
      cast('Bash', 'target')
      return true
  end

  return false
end
setfenv(interrupt, dark_addon.environment.env)

local function buffs()

  if not dark_addon.settings.fetch('druid_AutoBuff', false) then return false end

  if player.buff('Mark of the Wild').down and player.power.mana.percent > 40 then
    macro("/cancelform")
    macro("/stand")
    cast('Mark of the Wild', 'player')
    return true
  end

  if player.buff('Thorns').down and player.power.mana.percent > 40 then
    macro("/cancelform")
    macro("/stand")
    cast('Thorns', 'player')
    return true
  end

  return false
end
setfenv(buffs, dark_addon.environment.env)

local function tiger()

  if not toggle('cat', false) or toggle('tank', false) or toggle('balance', false) then return false end

  local Faer = GetSpellPowerCost('Faerie Fire')[1].cost + GetSpellPowerCost('Bear Form')[1].cost

  if player.health.percent < 20 and FormMana < HealCost and FormMana > GetSpellPowerCost('Bear Form')[1].cost and
    GetItemCount(929) >= 1 then
    macro("/cancelform")
    macro("/use Healing Potion")
    return true
  end
  
  if modifier.control and not player.moving and FormMana < SuperHealCost and FormMana > HealCost then
    macro("/cancelform")
    cast('Healing Touch', 'player')
    return true
  end
  
  if modifier.control and player.buff('Regrowth').down and not
    player.moving and not spell('Regrowth').lastcast and FormMana > SuperHealCost then
    macro("/cancelform")
    cast('Regrowth', 'player')
    return true
  end

  if caster and player.buff('Rejuvenation').down and castable('Rejuvenation') and spell('Regrowth').lastcast then
    cast('Rejuvenation', 'player')
    return true
  end

  if caster and target.debuff('Faerie Fire').down and FormMana > Faer and 
    castable('Faerie Fire') and IsSpellInRange('Faerie Fire', 'target') == 1 then
    cast('Faerie Fire', 'target')
    return true
  end

  if not bear and enemies.around(8) >= 3 and FormMana > GetSpellPowerCost('Bear Form')[1].cost and not IsSpellKnown(9634) then
    macro("/cancelform")
    cast(SB.BearForm)
    return true
  end

  if not bear and FormMana > GetSpellPowerCost(9634)[1].cost and 
    enemies.around(8) >= 3 and IsSpellKnown(9634) then
    macro("/cancelform")
    cast(SB.DireBearForm)
    return true
  end

  if not cat and castable(SB.CatForm) and enemies.around(8) <= 2 and not bear then
    macro("/cancelform")
    cast(SB.CatForm)
    return true
  end

  if castable('Faerie Fire Feral') and target.debuff('Faerie Fire Feral').down and
      IsSpellInRange('Faerie Fire Feral', 'target') == 1 then
      cast('Faerie Fire Feral', 'target')
    return true
  end

  if target.distance > 8 then return false end

  if not IsCurrentSpell("Attack") then
    macro("/startattack")
    return true
  end

  if cat and castable('Ferocious Bite') and player.power.combopoints.actual >= 4 then
    cast('Ferocious Bite', 'target')
    return true
  end

  if cat and not modifier.control and castable('Claw') then
    cast('Claw', 'target')
    return true
  end

  if bear and castable('Demoralizing Roar') and target.debuff('Demoralizing Roar').down and enemies.around(8) >= 3 then
    cast(SB.DemoralizingRoar)
    return true
  end

  if bear and castable('Swipe') and enemies.around(8) >= 3 then
    cast(SB.Swipe)
    return true
  end

  if bear and castable('Maul') and enemies.around(8) <= 2 then
    cast(SB.Maul)
    return true
  end

  return false
end
setfenv(tiger, dark_addon.environment.env)

local function tank()

  local Group = GetNumGroupMembers()
  local ThornCostBear = GetSpellPowerCost('Thorns')[1].cost + GetSpellPowerCost('Bear Form')[1].cost
  local ThornCostDireBear = GetSpellPowerCost('Thorns')[1].cost + GetSpellPowerCost(9634)[1].cost
  local UseThorns = (FormMana > ThornCostBear and not IsSpellKnown(9634)) or (FormMana > ThornCostDireBear and IsSpellKnown(9634))

  if not toggle('tank', false) or toggle('cat', false) or toggle('balance', false) then return false end

  if player.health.percent < 50 and player.buff('Regrowth').down and player.buff('Rejuvenation').down and not
    player.moving and Group == 0 and FormMana > HealCost then
    macro("/cancelform")
    cast('Regrowth', 'player')
    return true
  end

  if caster and player.buff('Rejuvenation').down and Group == 0 and castable('Rejuvenation') then
    cast('Rejuvenation', 'player')
    return true
  end

  if player.health.percent > 50 and player.buff('Thorns').down and UseThorns then
    macro("/cancelform")
    cast('Thorns', 'player')
    return true
  end

  if not bear and IsSpellKnown(9634) then
    macro('/cancelform')
    cast(SB.DireBearForm)
    return true
  end

  if not bear and not IsSpellKnown(9634) then
    macro('/cancelform')
    cast(SB.BearForm)
    return true
  end

  if castable('Faerie Fire Feral') and target.debuff('Faerie Fire Feral').down and
      IsSpellInRange('Faerie Fire Feral', 'target') == 1 then
      cast('Faerie Fire Feral', 'target')
    return true
  end

  if target.distance > 8 then return false end

  if not IsCurrentSpell("Attack") then
    macro("/startattack")
    return true
  end

  if castable('Demoralizing Roar') and target.debuff('Demoralizing Roar').down and 
      (enemies.around(8) >= 3 or toggle('boss', false)) then
    cast(SB.DemoralizingRoar)
    return true
  end

  local aoeswipe = enemies.match( function (unit)
    local CrowdControl = unit.debuff('Polymorph').up or unit.debuff('Sap').up or unit.debuff('Freezing Trap').up
    CrowdControl = CrowdControl or unit.debuff('Seduction').up or unit.debuff('Hibernate').up
    if unit.distance < 8 and CrowdControl then return true end
    return false
  end)

  if castable('Swipe') and enemies.around(8) >= 3 and not aoeswipe then
    cast(SB.Swipe)
    return true
  end

  if castable('Maul') and (enemies.around(8) <= 2 or aoeswipe) then
    cast(SB.Maul)
    return true
  end

  return false
end
setfenv(tank, dark_addon.environment.env)

local function balance()

  if not toggle('balance', false) or toggle('cat', false) or toggle('tank', false) then return false end

  if castable('Rejuvenation') and player.buff('Rejuvenation').down and
    player.health.percent < 80 then
      cast('Rejuvenation', 'player')
      return true
  end

  if castable('Regrowth') and player.buff('Regrowth').down and
    player.health.percent < 50 then
      cast('Regrowth', 'player')
      return true
  end

  if castable('Thorns') and player.buff('Thorns').down then
    cast('Thorns', 'target')
    return true
  end

  if not IsSpellInRange('Moonfire', 'target') == 1 then return false end

  if castable('Insect Swarm') and target.debuff('Insect Swarm').down then
    cast('Insect Swarm', 'target')
    return true
  end

  if castable('Moonfire') and target.debuff('Moonfire').down then
    cast('Moonfire', 'target')
    return true
  end

  if castable('Wrath') and (target.distance < 8 or not castable('Starfire')) then
    cast('Wrath', 'target')
    return true
  end

  if castable('Starfire') then
    cast('Starfire', 'target')
    return true
  end

  if not IsCurrentSpell("Attack") and castable('Starfire') then
    macro("/startattack")
    return true
  end

  return false
end
setfenv(balance, dark_addon.environment.env)

local function heal()

  if not toggle('heal', false) then return false end

  if not toggle('targetheal', false) then
  
  if dark_addon.settings.fetch('druid_swiftness.check', false) then
    if lowest.health.percent <= dark_addon.settings.fetch('druid_swiftness.spin', 25) and
    castable(SB.NaturesSwiftness) then
      macro("/cast Nature's Swiftness")
      cast('Healing Touch', 'lowest')
    end
  end

  if dark_addon.settings.fetch('druid_regrowth.check', false) then
    if lowest.health.percent <= dark_addon.settings.fetch('druid_regrowth.spin', 35) and
    castable('Regrowth') then
      cast('Regrowth', 'lowest')
    end
  end

  if dark_addon.settings.fetch('druid_regrowthbuff.check', false) then
    if lowest.health.percent <= dark_addon.settings.fetch('druid_regrowthbuff.spin', 50) and
    castable('Regrowth') and lowest.buff('Regrowth').down then
      cast('Regrowth', 'lowest')
    end
  end

  if dark_addon.settings.fetch('druid_healtouchmax.check', false) then
    if lowest.health.percent <= dark_addon.settings.fetch('druid_healtouchmax.spin', 50) and
    castable('Healing Touch') then
      cast('Healing Touch', 'lowest')
    end
  end

  if dark_addon.settings.fetch('druid_healtouch4.check', false) then
    if lowest.health.percent <= dark_addon.settings.fetch('druid_healtouch4.spin', 80) and
    castable('Healing Touch[Rank4]') then
      cast('Healing Touch[Rank4]', 'lowest')
    end
  end

  if dark_addon.settings.fetch('druid_rejuva.check', false) then
    if lowest.health.percent <= dark_addon.settings.fetch('druid_rejuva.spin', 85) and
    castable('Rejuvenation') and lowest.buff('Rejuvenation').down then
      cast('Rejuvenation', 'lowest')
    end
  end

  end

  if toggle('targetheal', false) then

  if dark_addon.settings.fetch('druid_swiftness.check', false) then
    if target.health.percent <= dark_addon.settings.fetch('druid_swiftness.spin', 25) and
    castable(SB.NaturesSwiftness) then
      macro("/cast Nature's Swiftness")
      cast('Healing Touch', 'target')
    end
  end

  if dark_addon.settings.fetch('druid_regrowth.check', false) then
    if target.health.percent <= dark_addon.settings.fetch('druid_regrowth.spin', 35) and
    castable('Regrowth') then
      cast('Regrowth', 'target')
    end
  end

  if dark_addon.settings.fetch('druid_regrowthbuff.check', false) then
    if target.health.percent <= dark_addon.settings.fetch('druid_regrowthbuff.spin', 50) and
    castable('Regrowth') and target.buff('Regrowth').down then
      cast('Regrowth', 'target')
    end
  end

  if dark_addon.settings.fetch('druid_healtouchmax.check', false) then
    if target.health.percent <= dark_addon.settings.fetch('druid_healtouchmax.spin', 50) and
    castable('Healing Touch') then
      cast('Healing Touch', 'target')
    end
  end

  if dark_addon.settings.fetch('druid_healtouch4.check', false) then
    if target.health.percent <= dark_addon.settings.fetch('druid_healtouch4.spin', 80) and
    castable('Healing Touch[Rank4]') then
      cast('Healing Touch[Rank4]', 'target')
    end
  end

  if dark_addon.settings.fetch('druid_rejuva.check', false) then
    if target.health.percent <= dark_addon.settings.fetch('druid_rejuva.spin', 85) and
    castable('Rejuvenation') and target.buff('Rejuvenation').down then
      cast('Rejuvenation', 'target')
    end
  end
end

  return false
end
setfenv(heal, dark_addon.environment.env)

local function combat()

  caster = GetShapeshiftForm() == 0
  bear = player.buff('Bear Form').up or player.buff('Dire Bear Form').up
  aquatic = player.buff('Aquatic Form').up
  cat = player.buff('Cat Form').up
  travel = player.buff('Travel Form').up
  FormMana = UnitPower("player", 0)
  SuperHealCost = GetSpellPowerCost('Cat Form')[1].cost + GetSpellPowerCost('Regrowth')[1].cost + GetSpellPowerCost('Rejuvenation')[1].cost
  HealCost = GetSpellPowerCost('Cat Form')[1].cost + GetSpellPowerCost('Healing Touch')[1].cost

  if not player.alive or player.buff('Bandage').exists or player.channeling() or player.casting then return end
  if travel or aquatic then return end

  if heal() then return end
  if not target.alive or not target.enemy then return end
  if tiger() then return end
  if tank() then return end
  if balance() then return end
    -- combat
end

local function resting()

  if not player.alive or player.buff('Food').exists or player.buff('Drink').exists or
    player.buff('Bandage').exists or player.channeling() or player.casting then return end

  if heal() then return end
  if buffs() then return end
    -- resting
end

local function interface()

  local interface = {
      
          key = 'druid',
          title = 'druid by Rohirrim',
          width = 350,
          height = 400,
          resize = true,
          show= false,
          template = {
              { type = 'header', text = 'druid Settings', align= 'center'}, 
              { type = 'rule'}, 
          {   key = 'AutoBuff', type = 'checkbox',
              text = 'Auto Buff',
              desc = '',
              default = false
          }, {type = 'text', text = ' Buffs '},  
           { type = 'header', text = 'Heal Settings', align= 'center'}, 
            { type = 'rule'}, {
            key = "healtouch4",
            type = "checkspin",
            text = "Healing Touch Rank4",
            default = 80,
            desc = "Our efficient spam heal",
            min = 5,
            max = 100,
            step = 5
          }, {
           key = "healtouchmax",
           type = "checkspin",
           text = "Healing Touch MaxRank",
            default = 50,
            desc = "",
            min = 5,
            max = 100,
            step = 5
          }, {
          key = "swiftness",
          type = "checkspin",
          text = "Nature's Swiftness",
          default = 25,
          desc = "Use Nature's Swiftness with Max rank Healing Touch",
          min = 5,
          max = 100,
          step = 5
          }, {
          key = "regrowth",
          type = "checkspin",
          text = "Use Regrowth",
          default = 35,
          desc = "",
          min = 5,
          max = 100,
          step = 5
          }, {
          key = "regrowthbuff",
          type = "checkspin",
          text = "Apply Regrowth buff if target below %",
          default = 50,
          desc = "",
          min = 5,
          max = 100,
          step = 5
          },{
          key = "rejuva",
          type = "checkspin",
          text = "Rejuvenation",
          default = 85,
          desc = "",
          min = 5,
          max = 100,
          step = 5
          },
    }
  }
  
  configWindow = dark_addon.interface.builder.buildGUI(interface)
  
  dark_addon.interface.buttons.add_toggle({
    name = 'cat',
    label = 'Cat',
    on = {
      label = 'Cat',
      color = dark_addon.interface.color.teal,
      color2 = dark_addon.interface.color.dark_teal
    },
    off = {
      label = 'Cat',
      color = dark_addon.interface.color.grey,
      color2 = dark_addon.interface.color.dark_grey,
    }
  })
  
  dark_addon.interface.buttons.add_toggle({
    name = 'tank',
    label = 'Tank',
    on = {
      label = 'Tank',
      color = dark_addon.interface.color.teal,
      color2 = dark_addon.interface.color.dark_teal
    },
    off = {
      label = 'Tank',
      color = dark_addon.interface.color.grey,
      color2 = dark_addon.interface.color.dark_grey,
    }
  })
  
  dark_addon.interface.buttons.add_toggle({
    name = 'balance',
    label = 'Balance',
    on = {
      label = 'Balance',
      color = dark_addon.interface.color.teal,
      color2 = dark_addon.interface.color.dark_teal
    },
    off = {
      label = 'Balance',
      color = dark_addon.interface.color.grey,
      color2 = dark_addon.interface.color.dark_grey,
    }
  })
  
  dark_addon.interface.buttons.add_toggle({
      name = 'heal',
      label = 'Heal',
      on = {
          label = 'Heal',
          color = dark_addon.interface.color.teal,
          color2 = dark_addon.interface.color.dark_teal
      },
      off = {
          label = 'Heal',
          color = dark_addon.interface.color.grey,
          color2 = dark_addon.interface.color.dark_grey
      }
  })

  dark_addon.interface.buttons.add_toggle({
    name = 'targetheal',
    label = 'Target Heal',
    on = {
        label = 'Target Heal',
        color = dark_addon.interface.color.teal,
        color2 = dark_addon.interface.color.dark_teal
    },
    off = {
        label = 'Target Heal',
        color = dark_addon.interface.color.grey,
        color2 = dark_addon.interface.color.dark_grey
    }
})

  dark_addon.interface.buttons.add_toggle({
    name = 'boss',
    label = 'Boss',
    on = {
        label = 'Boss',
        color = dark_addon.interface.color.teal,
        color2 = dark_addon.interface.color.dark_teal
    },
    off = {
        label = 'Boss',
        color = dark_addon.interface.color.grey,
        color2 = dark_addon.interface.color.dark_grey
    }
})
  
  dark_addon.interface.buttons.add_toggle({
      name = 'settings',
      label = 'Rotation Settings',
      font = 'dark_addon_icon',
      on = {
          label = dark_addon.interface.icon('cog'),
          color = dark_addon.interface.color.cyan,
          color2 = dark_addon.interface.color.dark_blue
      },
      off = {
          label = dark_addon.interface.icon('cog'),
          color = dark_addon.interface.color.grey,
          color2 = dark_addon.interface.color.dark_grey
      },
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
  class = dark_addon.rotation.classes.druid,
  name = 'druid',
  label = 'Bundled Druid',
  combat = combat,
  resting = resting,
  interface = interface
})
