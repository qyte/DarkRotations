local addon, dark_addon = ...

local health = { }
local UnitHealth = dark_addon.environment.UnitHealth
local UnitGetIncomingHeals = dark_addon.environment.UnitGetIncomingHeals

function health:percent()
  return self.actual / self.max * 100
end

function health:actual()
  return UnitHealth(self.unitID)
end

function health:max()
  return UnitHealthMax(self.unitID)
end

function health:effective()
  return (self.actual + self.incoming) / self.max * 100
end

function health:incoming()
  return UnitGetIncomingHeals(self.unitID) or 0
end

function health:missing()
  return self.max - self.actual
end

function dark_addon.environment.conditions.health(unit, called)
  return setmetatable({
    unitID = unit.unitID
  }, {
    __index = function(t, k)
      return health[k](t)
    end,
    __unm = function(t)
      return health['percent'](t)
    end
  })
end
