local addon, dark_addon = ...

dark_addon.environment = {
  conditions = { },
  hooks = { },
  unit_cache = { },
  group_cache = nil,
  hook_cache = { }
}

local env = { }

local function UnitHealth(unit)
  return dark_addon.UnitHealth(unit).actual
end
dark_addon.environment.UnitHealth = UnitHealth

local function UnitGetIncomingHeals(unit)
  return dark_addon.UnitHealth(unit).incoming
end

dark_addon.environment.UnitGetIncomingHeals = UnitGetIncomingHeals

local GetSpellName = function(spellid)
  local rank = GetSpellSubtext(spellid)
  local spellname = GetSpellInfo(spellid)
  if spellname ~= nil and rank ~= nil and rank ~= '' then
    spellname = spellname..'('..rank..')'
  end
  return spellname
end
dark_addon.environment.GetSpellName = GetSpellName

dark_addon.environment.env = setmetatable(env, {
  __index = function(_env, called)
    local ds = debugstack(2, 1, 0)
    local file, line = string.match(ds, '^.-\\(%a-%.lua):(%d+):.+$')
    dark_addon.console.file = file
    dark_addon.console.line = line
    if dark_addon.environment.logical.validate(called) then
      if not dark_addon.environment.unit_cache[called] then
        dark_addon.environment.unit_cache[called] = dark_addon.environment.conditions.unit(called)
      end
      return dark_addon.environment.unit_cache[called]
    elseif dark_addon.environment.virtual.validate(called) then
      local resolved, virtual_type = dark_addon.environment.virtual.resolve(called)
      if virtual_type == 'unit' then
        if not dark_addon.environment.unit_cache[resolved] then
          dark_addon.environment.unit_cache[resolved] = dark_addon.environment.conditions.unit(resolved)
        end
        return dark_addon.environment.unit_cache[resolved]
      elseif virtual_type == 'group' then
        if not dark_addon.environment.group_cache then
          dark_addon.environment.group_cache = dark_addon.environment.conditions.group()
        end
        return dark_addon.environment.group_cache
      end
    elseif dark_addon.environment.hooks[called] then
      if not dark_addon.environment.hook_cache[called] then
        dark_addon.environment.hook_cache[called] = dark_addon.environment.hooks[called]
      end
      return dark_addon.environment.hook_cache[called]
    end
    return _G[called]
  end
})

function dark_addon.environment.hook(func)
  setfenv(func, dark_addon.environment.env)
end

local latest = nil
function dark_addon.environment.iterator(raw)
  local members = GetNumGroupMembers()
  local group_type = IsInRaid() and 'raid' or IsInGroup() and 'party' or 'solo'
  local index = 0
  local returned_solo = false
  return function()
    local ipet = nil
    if latest then
      local ret = latest == 'player' and 'pet' or latest..'pet'
      if UnitExists(ret) then ipet = ret end
      latest = nil
    end
    if ipet then
      if raw then
        return ipet
      end
      if not dark_addon.environment.unit_cache[ipet] then
        dark_addon.environment.unit_cache[ipet] = dark_addon.environment.conditions.unit(ipet)
      end
      return dark_addon.environment.unit_cache[ipet]
    end
    local called
    if group_type == 'solo' and not returned_solo then
      returned_solo = true
      called = 'player'
    elseif group_type ~= 'solo' then
      if index <= members then
        index = index + 1
        if group_type == 'party' and index == members then
          called = 'player'
        else
          called = group_type .. index
        end
      end
    end
    if called then
      latest = called
      if raw then
        return called
      end
      if not dark_addon.environment.unit_cache[called] then
        dark_addon.environment.unit_cache[called] = dark_addon.environment.conditions.unit(called)
      end
      return dark_addon.environment.unit_cache[called]
    end
  end
end

dark_addon.environment.hooks.each_member = dark_addon.environment.iterator

dark_addon.environment.unit_buff = function(target, spell, owner)
  local buff, count, caster, expires, spellID
  local i = 0; local go = true
  while i <= 100 and go do
    i = i + 1
    buff, _, count, _, duration, expires, caster, stealable, _, spellID = dark_addon.libCD:UnitAura(target,i,"HELPFUL") -- _G['UnitBuff'](target, i)
    if not owner then
      if ((tonumber(spell) and spellID == tonumber(spell)) or buff == spell) and caster == "player" then go = false end
    elseif owner == "any" then
      if ((tonumber(spell) and spellID == tonumber(spell)) or buff == spell) then go = false end
    end
  end
  return buff, count, duration, expires, caster, stealable
end

dark_addon.environment.unit_debuff = function(target, spell, owner)
  local debuff, count, caster, expires, spellID
  local i = 0; local go = true
  while i <= 100 and go do
    i = i + 1
    debuff, _, count, _, duration, expires, caster, _, _, spellID = dark_addon.libCD:UnitAura(target,i,"HARMFUL") --_G['UnitDebuff'](target, i)
    if not owner then
      if ((tonumber(spell) and spellID == tonumber(spell)) or debuff == spell) and caster == "player" then go = false end
    elseif owner == "any" then
      if ((tonumber(spell) and spellID == tonumber(spell)) or debuff == spell) then go = false end
    end
  end
  return debuff, count, duration, expires, caster
end

dark_addon.environment.unit_reverse_debuff = function(target, candidates)
  local debuff, count, caster, expires, spellID
  local i = 0; local go = true
  while i <= 100 and go do
    i = i + 1
    debuff, _, count, _, duration, expires, caster, _, _, spellID = dark_addon.libCD:UnitAura(target,i,"HARMFUL") --_G['UnitDebuff'](target, i)
    if candidates[spellID] then go = false end
  end
  return debuff, count, duration, expires, caster, candidates[spellID]
end
