local addon, dark_addon = ...

local lastBehind = 0
local lastMaul = 0

dark_addon.event.register("UI_ERROR_MESSAGE", function(e, msg)
  if e==50 and strfind(msg,'behind') then
      lastBehind = GetTime()
  end
  if UnitAffectingCombat('player') then return end
  local p = dark_addon.environment.env.player
  if strfind(msg, 'standing to do') and (not p.buff('Food').exists or not p.buff('Drink').exists) then DoEmote('STAND') end
  if strfind(msg,'shapeshift') and dark_addon.protected then
    _RunMacroText('/cancelform')
  end
end)

dark_addon.event.register("UNIT_SPELLCAST_SUCCEEDED", function(caster, castGUID, spellID)
  if not UnitIsUnit(caster,'player') then return end
  if GetSpellInfo(spellID) == "Maul" then
    lastMaul = GetTime()
  end
end)

local caster
local bear
local aquatic
local cat
local travel
local tanking
local mana
local energy
local hot
local selfheal
local strong
local php
local thp
local flee
local combo
local userip
local pshiftenergy
local enemiesaround
local healpartner
local rage
local maultime

local ClamID = {7973, 5524, 5523, 15874}
local ClamName = {'Big-mouth Clam', 'Thick-shelled Clam', 'Small Barnacled Clam', 'Soft-shelled Clam'}
local HealingPotionID = {118, 858, 4596, 1710, 18839, 3928, 13446}
local HealingPotionName = {'Minor Healing Potion', 'Lesser Healing Potion', 'Discolored Healing Potion', 'Greater Healing Potion', 'Combat Healing Potion', 'Superior Healing Potion', 'Major Healing Potion'}

local function useitem()

  for i=#ClamID,1,-1 do
    if GetItemCount(ClamID[i]) >= 1 then
      macro('/use '..ClamName[i])
      return true
    end
  end

  for i=#HealingPotionID,1,-1 do
    if GetItemCount(HealingPotionID[i]) >= 1 and (GetItemCooldown(HealingPotionID[i])) == 0 and player.health.percent < 10 then
      macro('/cancelform')
      macro('/use '..HealingPotionName[i])
      return true
    end
  end

  return false
end
setfenv(useitem, dark_addon.environment.env)

local function heal()
  if toggle('groupheal', false) then return false end
  -- Self Healing
  if modifier.control and not player.moving and mana > hot and php < 45 then
    macro('/cancelform')
    cast('Regrowth', 'player')
    return true
  end

  if caster and player.buff('Rejuvenation').down and php < 85 then
    cast('Rejuvenation', 'player')
    return true
  end

  if mana < hot and modifier.control then
    if not player.moving and mana > selfheal and php < 45 then
      macro('/cancelform')
      cast('Healing Touch', 'player')
      return true
    end
  end

  --Group Heal: Will use Healing Touch on lowest party member that is under 50% health if no mob is attacking you.
  if groupheal and enemiesaround == 0 then
    if modifier.control and not player.moving and mana > selfheal and lowest.health.percent < 50 then
      macro('/cancelform')
      cast('Healing Touch', lowest)
      return true
    end
  end

  return false
end
setfenv(heal, dark_addon.environment.env)

local function panther()

  if modifier.control then return false end

  if toggle('tank', false) or toggle('groupheal', false) then return false end

  --get into cat form if you are not in Travel or Aquatic form
  if not travel or aquatic then
    if not cat and castable(SB.CatForm) then
      cast(SB.CatForm)
      return true
    end
  end

  if dark_addon.settings.fetch('druid_pshift', 'fps') == 'fps' then
    if mana >= GetSpellPowerCost('Cat Form')[1].cost and energy <= pshiftenergy then
      macro('/cancelform')
      cast(SB.CatForm)
      return true
    end
  end

  if dark_addon.settings.fetch('druid_pshift', 'pps') == 'pps' then
    if mana >= selfheal and energy <= pshiftenergy then
      macro('/cancelform')
      cast(SB.CatForm)
      return true
    end
  end

  if not cat then return false end

  if not IsCurrentSpell(6603) then
    auto_attack()
    return true
  end

  if castable(SB.FaerieFireFeral) and not target.debuff('Faerie Fire (Feral)').any then
    cast(SB.FaerieFireFeral,'target')
    return true
  end

  if target.distance > 10 then return false end

  -- Combo point finishers
  if userip and strong then
    if combo >= 4 and thp > 40 and castable(SB.Rip) and target.debuff(SB.Rip).down then
      cast('Rip', 'target')
      return true
    end
  end

  if castable(SB.FerociousBite) and combo >= 4 then
    cast(SB.FerociousBite,'target')
    return true
  end

  if combo >= 4 then return false end

  --Combo Builders

  --rake usage
  if dark_addon.settings.fetch('druid_userake', 'all') == 'all' then
    if castable(SB.Rake) and thp > 80 and target.debuff('Rake').down then
      cast(SB.Rake,'target')
      return true
    end
  end

  if dark_addon.settings.fetch('druid_userake', 'str') == 'str' then
    if castable(SB.Rake) and strong and thp > 40 and target.debuff('Rake').down then
      cast(SB.Rake,'target')
      return true
    end
  end

  --Will use Claw if your energy get 80 or higher to not waste energy (because you couldnt get behind the target to Shred)
  if GetTime() - lastBehind < 1 and energy >= 80 then
    if castable(SB.Claw) then
      cast(SB.Claw)
      return true
    end
  end

  -- Will use Shred if your target is not targeting you or if it flees from you
  if not tanking or not UnitExists('targettarget') then
    if castable(SB.Shred) and GetTime() - lastBehind > 0.5 then
      cast(SB.Shred,'target')
      return true
    end
  end

  if tanking and castable(SB.Claw) then
    cast(SB.Claw,'target')
    return true
  end


  return false
end
setfenv(panther, dark_addon.environment.env)

local function beartanking()

  if modifier.control then return false end

  if not toggle('tank', false) or toggle('groupheal', false) then return false end

  if not travel or aquatic then
    if not bear and IsSpellKnown(9634) and castable(SB.DireBearForm) then
      cast(SB.DireBearForm)
      return true
    end
  end

  if not travel or aquatic then
    if not bear and castable(SB.BearForm) and not IsSpellKnown(9634) then
      cast(SB.BearForm)
      return true
    end
  end

  if not bear or target.distance > 8 then return false end

  if not IsCurrentSpell(6603) then
    auto_attack()
    return true
  end

  if dark_addon.settings.fetch('druid_growl', false) then
    if not tanking and castable(SB.Growl) then
      cast(SB.Growl)
      return true
    end
  end

  if GetTime() - lastMaul >= maultime then
    if enemiesaround >= 3 and castable(SB.Maul) and not IsCurrentSpell('Maul') then
      cast(SB.Maul)
    end
  end

  if enemiesaround >= 3 and castable(SB.DemoralizingRoar) and not target.debuff('Demoralizing Roar').any and not target.debuff('Demoralizing Shout').any then
    cast(SB.DemoralizingRoar)
    return true
  end
  
  if enemiesaround >= 3 and castable(SB.Swipe) then
    cast(SB.Swipe)
    return true
  end

  if enemiesaround < 3 and castable(SB.Maul) and not IsCurrentSpell('Maul') then
    cast(SB.Maul)
  end

  if enemiesaround < 3 and castable(SB.Swipe) and rage > 70 then
    cast(SB.Swipe)
    return true
  end

  return false
end
setfenv(beartanking, dark_addon.environment.env)

local function prowling()

  if not target.exists or not target.alive or not target.enemy then return false end

  if dark_addon.settings.fetch('druid_prowl.check', false) and target.distance < dark_addon.settings.fetch('druid_prowl.spin', 18) then
    if castable('Prowl') and not IsStealthed() then
      cast(SB.Prowl)
      return true
    end
  end

  if IsStealthed() and IsSpellInRange('Ravage', 'target') == 1 and UnitPower("player", 3) == 100 then
    cast(SB.TigersFury)
    return true
  end

  if IsStealthed() and IsSpellInRange('Ravage', 'target') == 1 and castable(SB.Ravage) then
    cast(SB.Ravage)
    return true
  end

  return false
end
setfenv(prowling, dark_addon.environment.env)

local function buffs()

  if IsStealthed() or player.buff('Aquatic Form').up or not dark_addon.settings.fetch('druid_autobuff', false) then return false end

  if castable(SB.MarkOfTheWild) and not player.buff('Mark of the Wild').any then
    cast(SB.MarkOfTheWild, 'player')
    return true
  end

  if castable(SB.Thorns) and not player.buff('Thorns').any then
    cast(SB.Thorns, 'player')
    return true
  end

  return false
end
setfenv(buffs, dark_addon.environment.env)

local dispeldelaypoison = 0
local dispeldelaycurse = 0

local function dispell()

  local dispellable_unit_poison = group.removable('poison')
  local dispellable_unit_curse = group.removable('curse')

  if not dispellable_unit_poison then dispeldelaypoison = 0 end

    if dark_addon.settings.fetch('druid_curepoison', false) and dispellable_unit_poison then
        if dispeldelaypoison == 0 then
            dispeldelaypoison = GetTime() + 1.5 + math.random()
        else
        if dispeldelaypoison < GetTime() and castable(SB.AbolishPoison) and not dispellable_unit_poison.buff('Abolish Poison').any then
            macro('/cancelform')
            cast(SB.AbolishPoison, dispellable_unit_poison)
            dispeldelaypoison = 0
            return true
        end
    end
  end

  if not dispellable_unit_curse then dispeldelaycurse = 0 end

    if dark_addon.settings.fetch('druid_removecurse', false) and dispellable_unit_curse then
        if dispeldelaycurse == 0 then
          dispeldelaycurse = GetTime() + 1.5 + math.random()
        else
        if dispeldelaycurse < GetTime() and castable(SB.RemoveCurse) then
            macro('/cancelform')
            cast(SB.RemoveCurse, dispellable_unit_curse)
            dispeldelaycurse = 0
            return true
        end
    end
  end

  return false
end
setfenv(dispell, dark_addon.environment.env)

local function partyheal()

  if not toggle('groupheal', false) then return false end

  if modifier.control and (travel or aquatic) then
    macro('/cancelform')
  end

  if travel or aquatic then return false end

  if GetShapeshiftForm() ~= 0 then macro('/cancelform') end

  --Oh Shit moment...
  if dark_addon.settings.fetch('druid_swift.check', false) and UnitAffectingCombat('player') then
    if castable(SB.NaturesSwiftness) and castable(SB.HealingTouch) and lowest.health.percent <= dark_addon.settings.fetch('druid_swift.spin', 15) then
      macro("/cast Nature's Swiftness")
      cast(SB.HealingTouch, lowest)
      return true
    end
  end

  --Regrowth for fast heal on emergency
  if dark_addon.settings.fetch('druid_growth.check', false) and UnitAffectingCombat('player') then
    if castable(SB.Regrowth) and lowest.health.percent <= dark_addon.settings.fetch('druid_growth.spin', 25) and not lowest.buff('Regrowth').any and not player.moving then
      cast(SB.Regrowth, lowest)
      return true
    end
  end

  --Healing Touch Max Rank
  if dark_addon.settings.fetch('druid_touch.check', false) then
    if castable(SB.HealingTouch) and lowest.health.percent <= dark_addon.settings.fetch('druid_touch.spin', 45) and not player.moving then
      cast(SB.HealingTouch, lowest)
      return true
    end
  end

  -- Combat Res
  if dark_addon.settings.fetch('druid_rebirth', false) then
		local group_unit_count = IsInGroup() and GetNumGroupMembers() or 1
		for i = 1, group_unit_count-1 do
			local unit = 'party'..i
			if UnitIsDead(unit) and castable(SB.Rebirth) then
			cast(SB.Rebirth, unit)
			return true
			end
		end
  end
  
  --Dispell
  if dispell() then return true end

  --Healing Touch Rank4
  if dark_addon.settings.fetch('druid_lowtouch.check', false) then
    if castable(SB.HealingTouch[4]) and lowest.health.percent <= dark_addon.settings.fetch('druid_lowtouch.spin', 70) and not player.moving then
      cast(SB.HealingTouch[4], lowest)
      return true
    end
  end

  if dark_addon.settings.fetch('druid_rejuva.check', false) then
    if castable(SB.Rejuvenation) and not lowest.buff('Rejuvenation').any and lowest.health.percent <= dark_addon.settings.fetch('druid_rejuva.spin', 60) then
      cast(SB.Rejuvenation, lowest)
      return true
    end
  end

  if not target.exists or not target.alive or target.enemy then return false end

  if dark_addon.settings.fetch('druid_keeprejuva', false) then
    if castable(SB.Rejuvenation) and not target.buff('Rejuvenation').any then
      cast(SB.Rejuvenation,'target')
      return true
    end
  end

  if dark_addon.settings.fetch('druid_keepgrowth', false) then
    if castable(SB.Regrowth) and not target.buff('Regrowth').any then
      cast(SB.Regrowth,'target')
      return true
    end
  end

  return false
end
setfenv(partyheal, dark_addon.environment.env)


local function combat()
  
  if not player.alive or player.buff('Food').exists or player.buff('Drink').exists or player.buff('Bandage').exists or player.channeling() or player.casting or
  UnitIsAFK('player') or IsResting() then return end

  tanking = UnitIsUnit('player','targettarget')
  flee = not UnitExists('targettarget')
  caster = GetShapeshiftForm() == 0
  bear = player.buff('Bear Form').up or player.buff('Dire Bear Form').up
  aquatic = player.buff('Aquatic Form').up
  cat = player.buff('Cat Form').up
  travel = player.buff('Travel Form').up
  mana = UnitPower("player", 0)
  rage = UnitPower("player", 1)
  energy = UnitPower("player", 3)
  hot = GetSpellPowerCost('Cat Form')[1].cost + GetSpellPowerCost('Regrowth')[1].cost + GetSpellPowerCost('Rejuvenation')[1].cost
  selfheal = GetSpellPowerCost('Cat Form')[1].cost + GetSpellPowerCost('Healing Touch')[1].cost
  strong = UnitClassification("target") == "elite" or UnitClassification("target") == "rareelite" or UnitClassification("target") == "worldboss"
  php = player.health.percent
  thp = target.health.percent
  combo = player.power.combopoints.actual
  userip = dark_addon.settings.fetch('druid_userip', false)
  pshiftenergy = dark_addon.settings.fetch("druid_pshiftenergy", 20)
  maultime = dark_addon.settings.fetch("druid_maul", 5)
  enemiesaround = enemies.count(function (unit) return UnitIsUnit('player',unit.unitID..'target') end)
  healpartner = dark_addon.settings.fetch('druid_healpartner', false)

  if useitem() then return end
  if partyheal() then return end
  if heal() then return end
  if not target.alive or not target.enemy or target.debuff('Polymorph').any then return end
  if panther() then return end
  if beartanking() then return end
    -- combat
end

local function resting()

  if not player.alive or player.buff('Food').exists or player.buff('Drink').exists or player.buff('Bandage').exists or player.channeling() or player.casting or
  UnitIsAFK('player') or IsResting() then return end

  mana = UnitPower("player", 0)
  hot = GetSpellPowerCost('Cat Form')[1].cost + GetSpellPowerCost('Regrowth')[1].cost + GetSpellPowerCost('Rejuvenation')[1].cost
  selfheal = GetSpellPowerCost('Cat Form')[1].cost + GetSpellPowerCost('Healing Touch')[1].cost
  php = player.health.percent

  if useitem() then return end
  if partyheal() then return end
  if heal() then return end
  if buffs() then return end
  if prowling() then return end
    -- -- resting
end

local function interface()

  local interface = {
      
    key = 'druid',
    title = 'druid by Rohirrim',
    width = 340,
    height = 600,
    resize = true,
    show= false,
    template = {
      { type = 'header', text = 'Druid Settings', align= 'center'}, 
      { type = 'rule'},
      { type = 'header', text = 'Feral DPS', align= 'center'},
      { type = 'rule'},
      {key = 'autobuff', type = 'checkbox', text = 'Auto Buff', desc = '', default = false},
      {key = 'healpartner', type = 'checkbox', text = 'Heal party members', desc = 'Will heal group member if press control and no mob attacking you', default = false},
      {key = 'prowl', type = 'checkspin', text = 'Use Prowl at x yards', default = 18, min = 5, max = 100, step = 1},
      {key = 'userip', type = 'checkbox', text = 'Use Rip on Elites and Bosses', desc = '', default = false},
      { key = 'userake',
        type = 'dropdown',
        text = 'Use Rake on',
        desc = '',
        default = 'none',
        list = {{key = 'all', text = 'All mobs'}, {key = 'str', text = 'Elite or Boss'}, {key = 'none', text = 'Dont Use'}}
      },
      { type = 'rule'},
      { type = 'header', text = 'Powershift Options', align= 'center'},
      { type = 'rule'},
      { key = 'pshift',
        type = 'dropdown',
        text = 'Mana Management',
        desc = '',
        default = 'none',
        list = {{key = 'fps', text = 'Use all Mana'}, {key = 'pps', text = 'Save for Heal'}, {key = 'none', text = 'No Powershift'}}
      },
      {key = 'pshiftenergy', type = 'spinner', text = 'Powershift when Energy is <', default = 20, desc = '', min = 5, max = 100, step = 1},
      { type = 'header', text = 'Feral Tank', align= 'center'},
      { type = 'rule'},
      {key = 'growl', type = 'checkbox', text = 'Auto use Growl', desc = '', default = false},
      {key = 'maul', type = 'spinner', text = 'Use Maul every x Seconds when AoE', default = 5, desc = '', min = 1, max = 100, step = 1},
      { type = 'header', text = 'Group Heal', align= 'center'},
      { type = 'rule'},
      {key = 'swift', type = 'checkspin', text = 'Use Nature Swiftness / Healing Touch at % HP', default = 15, min = 5, max = 300, step = 5},
      {key = 'touch', type = 'checkspin', text = 'Use Healing Touch at % HP', default = 45, min = 5, max = 300, step = 5},
      {key = 'lowtouch', type = 'checkspin', text = 'Use Healing Touch Rank4 at % HP', default = 70, min = 5, max = 300, step = 5},
      {key = 'growth', type = 'checkspin', text = 'Use Regrowth at % HP', default = 25, min = 5, max = 300, step = 5},
      {key = 'rejuva', type = 'checkspin', text = 'Use Rejuvenation at % HP', default = 25, min = 5, max = 300, step = 5},
      {key = 'keeprejuva', type = 'checkbox', text = 'Keep Rejuvenation up on target', desc = '', default = false},
      {key = 'keepgrowth', type = 'checkbox', text = 'Keep Regrowth HoT up on target', desc = '', default = false},
      {key = 'rebirth', type = 'checkbox', text = 'Auto use of Rebirth', desc = '', default = false},
      {key = 'removecurse', type = 'checkbox', text = 'Auto Remove Curse', desc = '', default = false},
      {key = 'curepoison', type = 'checkbox', text = 'Auto Cure Poison', desc = '', default = false}
    }
  }

  configWindow = dark_addon.interface.builder.buildGUI(interface)

  dark_addon.interface.buttons.add_toggle(
    {
        name = 'tank',
        label = 'Tank',
        on = {
            label = 'Tank',
            color = dark_addon.interface.color.blue,
            color2 = dark_addon.interface.color.dark_blue
        },
        off = {
            label = 'Tank',
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })

    dark_addon.interface.buttons.add_toggle(
    {
        name = 'groupheal',
        label = 'Group Heal',
        on = {
            label = 'Group Heal',
            color = dark_addon.interface.color.blue,
            color2 = dark_addon.interface.color.dark_blue
        },
        off = {
            label = 'Group Heal',
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
