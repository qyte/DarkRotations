local addon, dark_addon = ...

local lastAuto = 0
local lastMark = 0

dark_addon.event.register("UNIT_SPELLCAST_SUCCEEDED", function(caster, castGUID, spellID)
	if not spellID == 75 then return end
	if not UnitIsUnit(caster,'player') then return end
	lastAuto = GetTime()
end)

dark_addon.event.register("UNIT_SPELLCAST_SUCCEEDED", function(caster, castGUID, spellID)
	if not spellID == 14324 then return end
	if not UnitIsUnit(caster,'player') then return end
	lastMark = GetTime()
end)
local autoshotslot = nil
dark_addon.event.register("PLAYER_ENTERING_WORLD", function ( ... )
  for i=1,120 do
    local type,spellid = GetActionInfo(i)
    if spellid==75 then autoshotslot = i end
  end
end)

local tanking
local php
local thp
local pmp
local usehealingpotion
local usehealingpotionpercent
local usehealthstone
local usehealthstonepercent
local usemanapotion
local usemanapotionpercent
local focus
local usesting
local usestingmana
local usemark
local usemarkmana
local usearcane
local usearcanemana
local useaim
local useaimmana
local useconcussive
local useconcussivemana
local usemulti
local usemultimana
local strong

local ClamID = {7973, 5524, 5523, 15874}
local ClamName = {'Big-mouth Clam', 'Thick-shelled Clam', 'Small Barnacled Clam', 'Soft-shelled Clam'}
local ManaPotionID = {2455, 3385, 6149, 18841, 13444}
local ManaPotionName = {'Minor Mana Potion', 'Lesser Mana Potion', 'Greater Mana Potion', 'Combat Mana Potion', 'Major Mana Potion'}
local HealingPotionID = {118, 858, 4596, 1710, 18839, 3928, 13446}
local HealingPotionName = {'Minor Healing Potion', 'Lesser Healing Potion', 'Discolored Healing Potion', 'Greater Healing Potion', 'Combat Healing Potion', 'Superior Healing Potion', 'Major Healing Potion'}
local HealthstoneID = {5512, 19004, 19005, 5511, 19006, 19007, 5509, 19008, 19009, 5510, 19010, 19011, 9421, 19012, 19013}
local HealthstoneName = {'Minor Healthstone', 'Minor Healthstone', 'Minor Healthstone', 'Lesser Healthstone', 'Lesser Healthstone', 'Lesser Healthstone', 'Healthstone', 'Healthstone', 'Healthstone', 'Greater Healthstone', 'Greater Healthstone', 'Greater Healthstone', 'Major Healthstone', 'Major Healthstone', 'Major Healthstone'}

local function useitem()

  if player.channeling() then return false end

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

  return false
end
setfenv(useitem, dark_addon.environment.env)

local function interrupt()

  if not toggle('interrupts', false) or player.channeling() then return false end
  local intpercent = math.random(15, 35)

  if castable('Intimidation') and target.interrupt('target', intpercent) then
      cast('Intimidation', 'target')
      return true
  end

  return false
end
setfenv(interrupt, dark_addon.environment.env)

local function petbattle()

  local HaveClaw = IsSpellKnown(16827, "[pet]") or IsSpellKnown(16828, "[pet]") or IsSpellKnown(16829, "[pet]") or IsSpellKnown(16830, "[pet]") or IsSpellKnown(16831, "[pet]") or IsSpellKnown(16832, "[pet]") or IsSpellKnown(3009, "[pet]") or IsSpellKnown(3010, "[pet]")
  local HaveBite = IsSpellKnown(17253, "[pet]") or IsSpellKnown(17255, "[pet]") or IsSpellKnown(17256, "[pet]") or IsSpellKnown(17257, "[pet]") or IsSpellKnown(17258, "[pet]") or IsSpellKnown(17259, "[pet]") or IsSpellKnown(17260, "[pet]") or IsSpellKnown(17261, "[pet]")
  local HaveScreech = IsSpellKnown(24423, "[pet]") or IsSpellKnown(24577, "[pet]") or IsSpellKnown(24578, "[pet]") or IsSpellKnown(24579, "[pet]")

  if not UnitExists('pettarget') then return false end
  
  if HaveClaw and focus >= 40 then
    cast('Claw', 'pettarget')
    return true
  end

  if toggle('growl', false) and focus >= 15 and not UnitCreatureType("target") == "Mechanical" then
    cast('Growl', 'pettarget')
    return true
  end

  if HaveBite and focus >= 50 then
    cast('Bite', 'pettarget')
    return true
  end

  if HaveScreech and focus >= 35 and target.debuff('Screech').down then
    cast('Screech', 'pettarget')
    return true
  end

return false
end
setfenv(petbattle, dark_addon.environment.env)

local function rangedps()

  local immune = UnitCreatureType("target") == "Mechanical" or UnitCreatureType("target") == "Elemental" or UnitCreatureType("target") == "Totem"

  if GetTime() - lastAuto < 0.15 then return false end
  if target.distance < 8 or target.distance > 35 then return false end

  if modifier.control and pet.exists and not player.moving and castable(SB.MendPet) and not player.channeling() then
    cast(SB.MendPet)
    return true
  end

  if IsAutoRepeatAction(autoshotslot) == false then
    auto_shot()
  end
  
  if toggle('cooldowns') and castable('Bestial Wrath') then
    cast(SB.BestialWrath)
    return true
  end

  if toggle('cooldowns') and castable('Rapid Fire') then
    cast(SB.RapidFire)
    return true
  end

  if useconcussive and pmp > useconcussivemana then
    if castable(SB.ConcussiveShot) and thp < 90 and (not UnitExists('targettarget') or tanking) then
      cast(SB.ConcussiveShot)
      return true
    end
  end

  if marktime and usemark and pmp > usemarkmana then
    if castable(SB.HuntersMark) and not target.debuff(SB.HuntersMark).any and (thp > 80 or strong) then
      cast(SB.HuntersMark)
      return true
    end
  end

  if stingtime and usesting and pmp > usestingmana then
    if castable(SB.SerpentSting) and target.debuff(SB.SerpentSting).down and (thp > 80 or strong) then
      cast(SB.SerpentSting)
      return true
    end
  end

  if arcanetime and useaim and pmp > useaimmana then
    if castable(SB.AimedShot) and not player.moving then
      cast(SB.AimedShot)
      return true
    end
  end

  if aimedtime and usearcane and pmp > usearcanemana then
    if castable(SB.ArcaneShot) then
      cast(SB.ArcaneShot)
      return true
    end
  end

  return false
end
setfenv(rangedps, dark_addon.environment.env)

local function meleedps()

  if not toggle('melee', false) then return false end

  if target.distance > 7 then return false end

  if not IsCurrentSpell(6603) then
    auto_attack()
    return true
  end

  if castable(SB.MongooseBite) then
    cast(SB.MongooseBite)
    return true
  end

  if castable(SB.RaptorStrike) and not IsCurrentSpell('Raptor Strike') then
    cast(SB.RaptorStrike)
    return true
  end

  return false
end
setfenv(meleedps, dark_addon.environment.env)

local function combat()

  if not target.alive or not target.enemy or player.buff('Bandage').exists or target.debuff('Polymorph').up or 
    player.buff('Feign Death').up then return end

  tanking = UnitIsUnit('player','targettarget') == true
  php = player.health.percent
  thp = target.health.percent
  pmp = player.power.mana.percent
  usehealingpotion = dark_addon.settings.fetch('hunter_usehealingpotion.check', false)
  usehealingpotionpercent = dark_addon.settings.fetch('hunter_usehealingpotion.spin', 15)
  usehealthstone = dark_addon.settings.fetch('hunter_usehealthstone.check', false)
  usehealthstonepercent = dark_addon.settings.fetch('hunter_usehealthstone.spin', 20)
  usemanapotion = dark_addon.settings.fetch('hunter_usemanapotion.check', false)
  usemanapotionpercent = dark_addon.settings.fetch('hunter_usemanapotion.spin', 5)
  focus = UnitPower("pet", 2)
  stingtime = GetTime() - lastAuto <= dark_addon.settings.fetch("hunter_stingtime", 1)
  multitime = GetTime() - lastAuto <= dark_addon.settings.fetch("hunter_multitime", 0.5)
  aimedtime = GetTime() - lastAuto <= dark_addon.settings.fetch("hunter_aimedtime", 0.3)
  arcanetime = GetTime() - lastAuto <= dark_addon.settings.fetch("hunter_arcanetime", 1)
  marktime = GetTime() - lastMark <= dark_addon.settings.fetch("hunter_marktime", 10)
  usesting = dark_addon.settings.fetch('hunter_sting.check', false)
  usestingmana = dark_addon.settings.fetch('hunter_sting.spin', 60)
  usemark = dark_addon.settings.fetch('hunter_mark.check', false)
  usemarkmana = dark_addon.settings.fetch('hunter_mark.spin', 40)
  usearcane = dark_addon.settings.fetch('hunter_arcane.check', false)
  usearcanemana = dark_addon.settings.fetch('hunter_arcane.spin', 80)
  useaim = dark_addon.settings.fetch('hunter_aim.check', false)
  useaimmana = dark_addon.settings.fetch('hunter_aim.spin', 40)
  useconcussive = dark_addon.settings.fetch('hunter_concussive.check', false)
  useconcussivemana = dark_addon.settings.fetch('hunter_concussive.spin', 40)
  usemulti = dark_addon.settings.fetch('hunter_multi.check', false)
  usemultimana = dark_addon.settings.fetch('hunter_multi.spin', 40)
  strong = UnitClassification("target") == "elite" or UnitClassification("target") == "rareelite" or UnitClassification("target") == "worldboss"

  
  petbattle()
  if interrupt() then return end
  if useitem() then return end
  if player.channeling() then return end
  if rangedps() then return end
  if meleedps() then return end
    -- combat
end

local function resting()

  for i=#ClamID,1,-1 do
    if GetItemCount(ClamID[i]) >= 1 then
      macro('/use '..ClamName[i])
      return true
    end
  end


    -- resting
end

local function interface()

  local interface = {
      
          key = 'hunter',
          title = 'hunter by Rohirrim',
          width = 340,
          height = 430,
          resize = true,
          show= false,
          template = {
          { type = 'header', text = 'hunter Settings', align= 'center'}, 
          { type = 'rule'}, 
          { key = "multitime",
            type = "spinner",
            text = "Time window to use Multi-Shot after Auto Shot",
            default = 0.5,
            desc = "",
            min = 0,
            max = 3,
            step = 0.1
          },
          { key = "aimedtime",
            type = "spinner",
            text = "Time window to use Aimed-Shot after Auto Shot",
            default = 0.3,
            desc = "",
            min = 0,
            max = 3,
            step = 0.1
          },
          { key = "arcanetime",
            type = "spinner",
            text = "Time window to use Arcane Shot after Auto Shot",
            default = 1,
            desc = "",
            min = 0,
            max = 3,
            step = 0.1
          },
          { key = "stingtime",
            type = "spinner",
            text = "Time window to use Serpent Sting after Auto Shot",
            default = 1,
            desc = "",
            min = 0,
            max = 3,
            step = 0.1
          },
          { key = "marktime",
            type = "spinner",
            text = "Use Mark after x seconds of last Mark",
            default = 10,
            desc = "",
            min = 0,
            max = 50,
            step = 1
          },
          { type = 'header', text = 'Mana Settings', align= 'center'},
          { type = 'rule'},
          {
          key = 'multi', type = 'checkspin',
          text = 'Use Multi-Shot when above % of mana',
          default = 40,
          min = 5,
          max = 100,
          step = 5
          },
          {
          key = 'aim', type = 'checkspin',
          text = 'Use Aimed-Shot when above % of mana',
          default = 40,
          min = 5,
          max = 100,
          step = 5
          },
          {
            key = 'arcane', type = 'checkspin',
            text = 'Use Arcane Shot when above % of mana',
            default = 80,
            min = 5,
            max = 100,
            step = 5
          },
          {
            key = 'sting', type = 'checkspin',
            text = 'Use Serpent Sting when above % of mana',
            default = 60,
            min = 5,
            max = 100,
            step = 5
          },
          {
            key = 'mark', type = 'checkspin',
            text = 'Use Hunters Mark when above % of mana',
            default = 40,
            min = 5,
            max = 100,
            step = 5
          },
          {
            key = 'concussive', type = 'checkspin',
            text = 'Use Concussive Shot when above % of mana on fleeing targets',
            default = 40,
            min = 5,
            max = 100,
            step = 5
          },
          { type = 'header', text = 'Use Item', align= 'center'},
          { type = 'rule'}, 
          { key = 'usehealingpotion',
          type = 'checkspin',
          text = 'Use Healing Potion when under % HP',
          default = 15,
          min = 5,
          max = 100,
          step = 5 },
          { key = 'usehealthstone',
          type = 'checkspin',
          text = 'Use Healthstone when under % HP',
          default = 20,
          min = 5,
          max = 100,
          step = 5 },
          { key = 'usemanapotion',
          type = 'checkspin',
          text = 'Use Mana Potion when under % Mana',
          default = 5,
          min = 5,
          max = 100,
          step = 5 },
  }
  }

  configWindow = dark_addon.interface.builder.buildGUI(interface)

  dark_addon.interface.buttons.add_toggle(
    {
        name = 'growl',
        label = 'Growl',
        on = {
            label = 'Growl',
            color = dark_addon.interface.color.blue,
            color2 = dark_addon.interface.color.dark_blue
        },
        off = {
            label = 'Growl',
            color = dark_addon.interface.color.grey,
            color2 = dark_addon.interface.color.dark_grey
        }
    })

    dark_addon.interface.buttons.add_toggle(
      {
          name = 'melee',
          label = 'Melee',
          on = {
              label = 'Melee',
              color = dark_addon.interface.color.blue,
              color2 = dark_addon.interface.color.dark_blue
          },
          off = {
              label = 'Melee',
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
  class = dark_addon.rotation.classes.hunter,
  name = 'hunter',
  label = 'Bundled Hunter',
  combat = combat,
  resting = resting,
  interface = interface
})
