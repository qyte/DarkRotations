local addon, dark_addon = ...

local function combat()
    -- combat
end

local function resting()
    -- resting
end

dark_addon.rotation.register({
  class = dark_addon.rotation.classes.druid,
  name = 'druid',
  label = 'Bundled Druid',
  combat = combat,
  resting = resting
})
