local storage = require("core.storage")

local M = {}

function M.run(storages)
  while true do
    local ok, err = pcall(function()
      for id, info in pairs(storages) do
        if info.role == "accepter" then
          local acc = peripheral.wrap(id)
          if acc then
            for slot, item in pairs(acc.list()) do
              local vaultId = storage.findLowestVault(storages)
              if vaultId then
                local targetId = storages[vaultId].reciever
                if targetId then
                  acc.pushItems(targetId, slot, item.count)
                end
              end
            end
          end
        end
      end
    end)
    if not ok then
      print("dist err: " .. err)
    end
    os.sleep(1)
  end
end

return M
