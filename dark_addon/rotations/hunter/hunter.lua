local addon, dark_addon = ...

local lastAuto

dark_addon.event.register("UNIT_SPELLCAST_SUCCEEDED", function(caster, castGUID, spellID)
	if not spellID == 75 then return end
	if not UnitIsUnit(caster,'player') then return end
	lastAuto = GetTime()
end)

local function interrupt()

  if not toggle('interrupts', false) then return false end
  local intpercent = math.random(15, 35)

  if castable('Intimidation') and target.interrupt('target', intpercent) then
      cast('Intimidation', 'target')
      return true
  end

  return false
end
setfenv(interrupt, dark_addon.environment.env)

local function rangedps()

  if not IsSpellInRange('Auto Shot') == 1 then return false end

  if GetTime() - lastAuto < 0.15 then return false end

  if toggle('cooldowns') and castable('Bestial Wrath') then
    cast(SB.BestialWrath)
    return true
  end

  if toggle('cooldowns') and castable('Rapid Fire') then
    cast('Rapid Fire', 'player')
    return true
  end

  if castable("Hunter's Mark") and not target.debuff("Hunter's Mark").any and player.power.mana.percent > 30 then
    cast("Hunter's Mark", 'target')
    return true
  end

  if GetTime() - lastAuto <= dark_addon.settings.fetch("hunter_stingtime", 1) then
    if dark_addon.settings.fetch('hunter_sting.check', false) and player.power.mana.percent > dark_addon.settings.fetch('hunter_sting.spin', 40) then
      if castable('Serpent Sting') and target.debuff('Serpent Sting').down and target.health.percent > 50 then
      cast('Serpent Sting', 'target')
      return true
      end
    end
  end
  
  if GetTime() - lastAuto <= dark_addon.settings.fetch("hunter_multitime", 0.5) then
    if dark_addon.settings.fetch('hunter_multi.check', false) and player.power.mana.percent > dark_addon.settings.fetch('hunter_multi.spin', 50) then
      if toggle('multitarget') and castable('Multi Shot') and not player.moving then
      cast('Multi Shot', 'target')
      return true
      end
    end
  end

  if GetTime() - lastAuto <= dark_addon.settings.fetch("hunter_aimedtime", 0.3) then
    if dark_addon.settings.fetch('hunter_aim.check', false) and player.power.mana.percent > dark_addon.settings.fetch('hunter_aim.spin', 50) then
      if castable('Aimed Shot') and not player.moving then
      cast('Aimed Shot', 'target')
      return true
      end
    end
  end

  if GetTime() - lastAuto <= dark_addon.settings.fetch("hunter_arcanetime", 1) then
    if dark_addon.settings.fetch('hunter_arcane.check', false) and player.power.mana.percent > dark_addon.settings.fetch('hunter_arcane.spin', 50) then
      if castable('Arcane Shot') then
      cast('Arcane Shot', 'target')
      return true
      end
    end
  end

  return false
end
setfenv(rangedps, dark_addon.environment.env)

local function meleedps()

  if target.distance > 8 then return false end

  if not IsCurrentSpell('Attack') then
    cast('Attack', 'target')
    return true
  end

  if castable('Mongoose Bite') then
    cast('Mongoose Bite', 'target')
    return true
  end

  if castable('Raptor Strike') and not IsCurrentSpell('Raptor Strike') then
    cast('Raptor Strike', 'target')
    return true
  end

  return false
end
setfenv(meleedps, dark_addon.environment.env)

local function combat()

  if not target.alive or not target.enemy or player.buff('Bandage').exists or target.debuff('Polymorph').up or 
    player.buff('Feign Death').up or player.channeling() then return false end

  if pet.exists and modifier.control and castable('Mend Pet') then
    cast('Mend Pet', 'pet')
    return true
  end
  
  if not pet.exists and modifier.control and castable(SB.CallPet) then
    cast(SB.CallPet)
    return true
  end
  
  if not pet.alive and modifier.control and castable(SB.RevivePet) then
    cast(SB.RevivePet)
    return true
  end

  if pet.exists and pet.power.focus.actual > 60 then
    macro('/click PetActionButton5')
  end
  
  if interrupt() then return end
  if rangedps() then return end
  if meleedps() then return end
    -- combat
end

local function resting()

  if pet.exists and modifier.control and castable('Mend Pet') then
    cast('Mend Pet', 'pet')
    return true
  end

  if not pet.exists and modifier.control and castable(SB.CallPet) then
    cast(SB.CallPet)
    return true
  end

  if not pet.alive and modifier.control and castable(SB.RevivePet) then
    cast(SB.RevivePet)
    return true
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
            max = 30,
            step = 1
          },
          { key = "aimedtime",
            type = "spinner",
            text = "Time window to use Aimed-Shot after Auto Shot",
            default = 0.3,
            desc = "",
            min = 0,
            max = 30,
            step = 1
          },
          { key = "arcanetime",
            type = "spinner",
            text = "Time window to use Arcane Shot after Auto Shot",
            default = 1,
            desc = "",
            min = 0,
            max = 30,
            step = 1
          },
          { key = "stingtime",
            type = "spinner",
            text = "Time window to use Serpent Sting after Auto Shot",
            default = 1,
            desc = "",
            min = 0,
            max = 30,
            step = 1
          },
          { type = 'header', text = 'Mana Settings', align= 'center'},
          { type = 'rule'},
          {
          key = 'multi', type = 'checkspin',
          text = 'Use Multi-Shot when above % of mana',
          default = 50,
          min = 5,
          max = 100,
          step = 5
          },
          {
          key = 'aim', type = 'checkspin',
          text = 'Use Aimed-Shot when above % of mana',
          default = 50,
          min = 5,
          max = 100,
          step = 5
          },
          {
            key = 'arcane', type = 'checkspin',
            text = 'Use Arcane Shot when above % of mana',
            default = 70,
            min = 5,
            max = 100,
            step = 5
          },
          {
            key = 'sting', type = 'checkspin',
            text = 'Use Serpent Sting when above % of mana',
            default = 70,
            min = 5,
            max = 100,
            step = 5
          },
          { type = 'header', text = 'INFO', align= 'center'},
          { type = 'rule'}, 
          {type = 'text', text = '-Will use Multi-Shot only if Multi-Target is toggled'},
          {type = 'text', text = '-Will use Rapid Fire and Bestial Wrath if Cooldowns is toggled'},
          {type = 'text', text = '-Will use Intimidation if Interrupt is toggled and target is casting'},
          { type = 'header', text = 'PET MANAGEMENT', align= 'center'},
          { type = 'rule'},
          {type = 'text', text = '-Hold down control key to Mend Pet when pet is alive'},
          {type = 'text', text = '-Hold down control key to call your pet when is not active'},
          {type = 'text', text = '-Hold down control key to Revive your pet when is dead'},
  }
  }

  configWindow = dark_addon.interface.builder.buildGUI(interface)

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
