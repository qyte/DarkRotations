local addon, dark_addon = ...

local thp
local php
local pmp
local usemanapotion
local usemanapotionpercent
local usehealingpotion
local usehealingpotionpercent
local usehealthstone
local usehealthstonepercent
local lightningshield
local lightningshieldpercent
local oocheal
local totem
local shockrange
local firetotem
local earthtotem
local watertotem
local airtotem
local searingtotem
local stoneclaw
local stoneclawenemies
local nova
local novaenemies

local ManaPotionID = {2455, 3385, 6149, 18841, 13444}
local ManaPotionName = {'Minor Mana Potion', 'Lesser Mana Potion', 'Greater Mana Potion', 'Combat Mana Potion', 'Major Mana Potion'}
local HealingPotionID = {118, 858, 4596, 1710, 18839, 3928, 13446}
local HealingPotionName = {'Minor Healing Potion', 'Lesser Healing Potion', 'Discolored Healing Potion', 'Greater Healing Potion', 'Combat Healing Potion', 'Superior Healing Potion', 'Major Healing Potion'}
local HealthstoneID = {5512, 19004, 19005, 5511, 19006, 19007, 5509, 19008, 19009, 5510, 19010, 19011, 9421, 19012, 19013}
local HealthstoneName = {'Minor Healthstone', 'Minor Healthstone', 'Minor Healthstone', 'Lesser Healthstone', 'Lesser Healthstone', 'Lesser Healthstone', 'Healthstone', 'Healthstone', 'Healthstone', 'Greater Healthstone', 'Greater Healthstone', 'Greater Healthstone', 'Major Healthstone', 'Major Healthstone', 'Major Healthstone'}

local HealingWaveMax = {36, 69, 136, 279, 389, 552, 759, 1040, 1389, 1620}
local HealingWaveCoef = {0, 0, 0, 0, 0.85, 0.85, 0.85, 0.85, 0.85, 0.85}
local function FindHealingWaveRank(unit)
    local rank = 1
    local toHeal = HealingWaveMax[rank] + GetSpellBonusHealing() *
                    HealingWaveCoef[rank]
    local checker = IsSpellKnown(SB.HealingWave[rank + 1]) and
                        not select(2, IsUsableSpell(SB.HealingWave[rank + 1]))
    while unit.health.missing > toHeal and rank < #HealingWaveMax and checker do
        rank = rank + 1
        toHeal = HealingWaveMax[rank] + GetSpellBonusHealing() *
                HealingWaveCoef[rank]
        if rank < #HealingWaveMax then
            checker = IsSpellKnown(SB.HealingWave[rank + 1]) and
                          not select(2, IsUsableSpell(SB.HealingWave[rank + 1]))
        end
    end
    return rank, HealingWaveMax[rank]
end
setfenv(FindHealingWaveRank, dark_addon.environment.env)

local function castByRank(spell, target)
  local name = GetSpellInfo(spell)
  local rank = GetSpellSubtext(spell)

  if rank == nil then
      if name == "Healing Wave" then cast('Healing Wave', target) end
  else
      _CastSpellByName(name .. "(" .. rank .. ")", target)
  end

end
setfenv(castByRank, dark_addon.environment.env)

local function heal()

  if not toggle('heal', false) then return false end
  
  if healingwave then
  if lowest.health.effective <= healingwavepercent then
      local rank, mag = FindHealingWaveRank(lowest)
      if rank > 0 and castable(SB.HealingWave) and not player.moving then
          GroupHealCastTime = GetTime()
          cast(SB.HealingWave[rank], lowest.unitID)
          return true
      end
  end
end

  return false
end
setfenv(heal, dark_addon.environment.env)

local dispeldelaypoison = 0
local dispeldelaydisease = 0

local function dispell()

  local dispellable_unit_poison = group.removable('poison')
  local dispellable_unit_disease = group.removable('disease')

  if not dispellable_unit_poison then dispeldelaypoison = 0 end

    if dark_addon.settings.fetch('shaman_curepoison', false) and dispellable_unit_poison then
        if dispeldelaypoison == 0 then
            dispeldelaypoison = GetTime() + 1.5 + math.random()
        else
        if dispeldelaypoison < GetTime() and castable(SB.CurePoison) then
            cast(SB.CurePoison, dispellable_unit_poison)
            dispeldelaypoison = 0
            return true
        end
    end
  end

  if not dispellable_unit_disease then dispeldelaydisease = 0 end

    if dark_addon.settings.fetch('shaman_curepoison', false) and dispellable_unit_disease then
        if dispeldelaydisease == 0 then
            dispeldelaydisease = GetTime() + 1.5 + math.random()
        else
        if dispeldelaydisease < GetTime() and castable(SB.CureDisease) then
            cast(SB.CureDisease, dispellable_unit_disease)
            dispeldelaydisease = 0
            return true
        end
    end
  end

  return false
end
setfenv(dispell, dark_addon.environment.env)

local function interrupt()

    if not toggle('interrupts', false) then return false end
    local intpercent = math.random(25, 45)
  
    if castable('Earth Shock') and target.interrupt('target', intpercent) and
        IsSpellInRange('Earth Shock', 'target') == 1 then
        cast('Earth Shock', 'target')
        return true
    end

    if castable('Earth Shock(Rank 1)') and target.interrupt('target', intpercent) and
      IsSpellInRange('Earth Shock', 'target') == 1 then
      cast('Earth Shock(Rank 1)', 'target')
      return true
  end
  
    return false
end
setfenv(interrupt, dark_addon.environment.env)

local function useitem()

    if usemanapotion then
      for i=#ManaPotionID,1,-1 do
        if GetItemCount(ManaPotionID[i]) >= 1
        and pmp <= usemanapotionpercent
        and (GetItemCooldown(ManaPotionID[i])) == 0 then
          macro('/use '..ManaPotionName[i])
          return true
        end
      end
    end
  
    if usehealthstone then
      for i=#HealthstoneID,1,-1 do
        if GetItemCount(HealthstoneID[i]) >= 1
        and php <= usehealthstonepercent
        and (GetItemCooldown(HealthstoneID[i])) == 0 then
          macro('/use '..HealthstoneName[i])
          return true
        end
      end
    end
  
    if usehealingpotion then
      for i=#HealingPotionID,1,-1 do
        if GetItemCount(HealingPotionID[i]) >= 1
        and php <= usehealingpotionpercent
        and (GetItemCooldown(HealingPotionID[i])) == 0 then
          macro('/use '..HealingPotionName[i])
          return true
        end
      end
    end
  
    return false
  end
setfenv(useitem, dark_addon.environment.env)

local function buffs()

    local weaponenchants = {
      [29] = 'Rockbiter Weapon',
      [6] = 'Rockbiter Weapon',
      [1] = 'Rockbiter Weapon',
      [503] = 'Rockbiter Weapon',
      [1663] = 'Rockbiter Weapon',
      [683] = 'Rockbiter Weapon',
      [1664] = 'Rockbiter Weapon',
      [5] = 'Flametongue Weapon',
      [4] = 'Flametongue Weapon',
      [3] = 'Flametongue Weapon',
      [523] = 'Flametongue Weapon',
      [1665] = 'Flametongue Weapon',
      [1666] = 'Flametongue Weapon',
      [2] = 'Frostbrand Weapon',
      [12] = 'Frostbrand Weapon',
      [524] = 'Frostbrand Weapon',
      [1667] = 'Frostbrand Weapon',
      [1668] = 'Frostbrand Weapon',
      [283] = 'Windfury Weapon',
      [284] = 'Windfury Weapon',
      [525] = 'Windfury Weapon',
      [1669] = 'Windfury Weapon'
    }
  
    local Hasweapon,timerem,_,weaponID = GetWeaponEnchantInfo()
  
    if Hasweapon and timerem / 1000 < 20 then cast(weaponenchants[weaponID],'player') end
  
    return false
  end
setfenv(buffs, dark_addon.environment.env)

local function dps()

    if target.distance < 8 and not IsCurrentSpell(6603) then
        auto_attack()
        return true
    end

    if stoneclaw and enemies.around(8) >= stoneclawenemies and not earthtotem then
      if castable('Stoneclaw Totem') and not player.moving then
        cast(SB.StoneclawTotem)
        return true
      end
    end

    if nova and enemies.around(8) >= novaenemies and not firetotem then
      if castable(SB.FireNovaTotem) and not player.moving then
        cast(SB.FireNovaTotem)
        return true
      end
    end

    if searingtotem and not firetotem and (not nova or enemies.around(8) < novaenemies) then
      if target.distance < 8 and castable('Searing Totem') and thp > 70 then
        cast(SB.SearingTotem)
        return true
      end
    end
    
    if castable('Flame Shock') and shockrange and thp > 70 then
        cast('Flame Shock', 'target')
        return true
    end

    if castable('Frost Shock') and shockrange and not UnitExists('targettarget') then
        cast('Frost Shock', 'target')
        return true
    end

    if castable('Earth Shock') and shockrange and not UnitExists('targettarget') then
        cast('Earth Shock', 'target')
        return true
    end

    if castable('Lightning Bolt') and not player.moving and not UnitExists('targettarget') then
        cast('Lightning Bolt', 'target')
        return true
    end

    if lightningshield then
        if castable('Lightning Shield') and player.buff('Lightning Shield').down and pmp > lightningshieldpercent then
            cast('Lightning Shield', 'player')
            return true
        end
    end

    return false
  end
setfenv(dps, dark_addon.environment.env)

local function combat()

  thp = target.health.percent
  php = player.health.percent
  pmp = player.power.mana.percent
  usemanapotion = dark_addon.settings.fetch('shaman_usemanapotion.check', false)
  usemanapotionpercent = dark_addon.settings.fetch('shaman_usemanapotion.spin', 10)
  usehealingpotion = dark_addon.settings.fetch('shaman_usehealingpotion.check', false)
  usehealingpotionpercent = dark_addon.settings.fetch('shaman_usehealingpotion.spin', 15)
  usehealthstone = dark_addon.settings.fetch('shaman_usehealthstone.check', false)
  usehealthstonepercent = dark_addon.settings.fetch('shaman_usehealthstone.spin', 20)
  lightningshield = dark_addon.settings.fetch('shaman_lightningshield.check', false)
  lightningshieldpercent = dark_addon.settings.fetch('shaman_lightningshield.spin', 75)
  healingwave = dark_addon.settings.fetch('shaman_healingwave.check', false)
  healingwavepercent = dark_addon.settings.fetch('shaman_healingwave.spin', 50)
  searingtotem = dark_addon.settings.fetch('shaman_searingtotem', false)
  stoneclaw = dark_addon.settings.fetch('shaman_stoneclaw.check', false)
  stoneclawenemies = dark_addon.settings.fetch('shaman_stoneclaw.spin', 2)
  nova = dark_addon.settings.fetch('shaman_nova.check', false)
  novaenemies = dark_addon.settings.fetch('shaman_nova.spin', 4)
  shockrange = IsSpellInRange('Earth Shock', 'target') == 1
  firetotem = GetTotemInfo(1) == true
  earthtotem = GetTotemInfo(2) == true
  watertotem = GetTotemInfo(3) == true
  airtotem = GetTotemInfo(4) == true

  if player.buff('Bandage').exists or player.channeling() then return end

  if useitem() then return end
  if heal() then return end
  if dispell() then return end

  if not target.alive or not target.enemy or target.debuff('Polymorph').any then return end

  if interrupt() then return end
  if buffs() then return end
  if dps() then return end
    -- combat
end

local function resting()

  oocheal = dark_addon.settings.fetch('shaman_oocheal', false)

  if not player.alive then return end

  if player.buff('Food').exists or player.buff('Drink').exists or
  player.buff('Bandage').exists or IsResting() == true then return end

  if dispell() then return end
  if buffs() then return end

  if not oocheal then return end

  if heal() then return end
    -- resting
end

local function interface()

local interface = {

    key = 'shaman',
    title = 'Classic Shaman by Rohirrim',
    width = 320,
    height = 390,
    resize = true,
    show = false,
    template = {
        { type = 'header',
        text = 'Classic Shaman Settings',
        align = 'center'
        }, {type = 'rule'}, 
        {
        key = 'oocheal',
        type = 'checkbox',
        text = 'Heal when out of combat',
        desc = '',
        default = false
        }, 
        { key = 'curepoison',
          type = 'checkbox',
          text = 'Remove Poison',
          desc = 'Will Remove Poison from yourself or a Group member',
          default = false
        }, {
        key = 'curedisease',
        type = 'checkbox',
        text = 'Remove Disease',
        desc = 'Will Remove Disease from yourself or a Group member',
        default = false
        }, {
        key = 'lightningshield',
        type = 'checkspin',
        text = 'Use Lightning Shiled if above % mana',
        default = 75,
        min = 5,
        max = 100,
        step = 5
        }, {
        key = 'healingwave',
        type = 'checkspin',
        text = 'Use Healing Wave at % Health',
        default = 50,
        min = 5,
        max = 100,
        step = 5
        }, {type = 'rule'}, 
        {type = 'text', text = ' Use Totems '}, 
        {
        key = 'searingtotem',
        type = 'checkbox',
        text = 'Use Searing Totem',
        desc = '',
        default = false
        },
        {key = 'stoneclaw',
        type = 'checkspin',
        text = 'Use stoneclaw totem when at or above enemies',
        default = 2,
        min = 1,
        max = 100,
        step = 5
        },
        {key = 'nova',
        type = 'checkspin',
        text = 'Use Fire Nova totem when at or above enemies',
        default = 4,
        min = 1,
        max = 100,
        step = 5
        }, {type = 'rule'}, 
        {type = 'text', text = ' Use Items '}, {
        key = 'usehealingpotion',
        type = 'checkspin',
        text = 'Use Healing Potion at % Health',
        default = 15,
        min = 5,
        max = 100,
        step = 5
        }, {
        key = 'usehealthstone',
        type = 'checkspin',
        text = 'Use Healthstone at % Health',
        default = 20,
        min = 5,
        max = 100,
        step = 5
        }, {
        key = 'usemanapotion',
        type = 'checkspin',
        text = 'Use Mana Potion at % Mana',
        default = 10,
        min = 5,
        max = 100,
        step = 5
        },
    }
  }

  configWindow = dark_addon.interface.builder.buildGUI(interface)

  dark_addon.interface.buttons.add_toggle(
      {
          name = 'dps',
          label = 'DPS',
          on = {
              label = 'DPS',
              color = dark_addon.interface.color.blue,
              color2 = dark_addon.interface.color.dark_blue
          },
          off = {
              label = 'DPS',
              color = dark_addon.interface.color.grey,
              color2 = dark_addon.interface.color.dark_grey
          }
      })

  dark_addon.interface.buttons.add_toggle(
      {
          name = 'heal',
          label = 'Heal',
          on = {
              label = 'Heal',
              color = dark_addon.interface.color.red,
              color2 = dark_addon.interface.color.dark_red
          },
          off = {
              label = 'Heal',
              color = dark_addon.interface.color.grey,
              color2 = dark_addon.interface.color.dark_grey
          }
      })

  dark_addon.interface.buttons.add_toggle(
      {
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
  class = dark_addon.rotation.classes.shaman,
  name = 'shaman',
  label = 'Bundled Shaman',
  combat = combat,
  resting = resting,
  interface = interface
})
