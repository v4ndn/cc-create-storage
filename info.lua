local config = require("core.config")
local persistence = require("core.persistence")
local info = require("ui.info")

local storages = persistence.load(config.STORAGE_FILE)
info.run(storages)
