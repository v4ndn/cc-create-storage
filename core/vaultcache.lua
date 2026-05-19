local storage = require("core.storage")

local M = {
  lowestReceivers = {},
}

function M.run(storages)
  pcall(function()
    local vaults = storage.findLowestNVaults(storages, 3)
    local receivers = {}
    for _, v in ipairs(vaults) do
      if v.reciever then
        receivers[#receivers + 1] = v.reciever
      end
    end
    M.lowestReceivers = receivers
  end)

  while true do
    os.sleep(0)
    pcall(function()
      local vaults = storage.findLowestNVaults(storages, 3)
      local receivers = {}
      for _, v in ipairs(vaults) do
        if v.reciever then
          receivers[#receivers + 1] = v.reciever
        end
      end
      M.lowestReceivers = receivers
    end)
  end
end

return M
