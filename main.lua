local config = require("core.config")
local persistence = require("core.persistence")
local distribution = require("core.distribution")
local vaultcache = require("core.vaultcache")
local manager = require("ui.manager")

local storages = persistence.load(config.STORAGE_FILE)

parallel.waitForAny(
  function() manager.run(storages) end,
  function() vaultcache.run(storages) end,
  function() distribution.run(storages) end
)

persistence.save(storages, config.STORAGE_FILE)
