local vaultcache = require("core.vaultcache")

local M = {}

function M.run(storages)
  os.startTimer(0)

  while true do
    local event, arg = os.pullEvent("timer")

    local targetIds = vaultcache.lowestReceivers
    if targetIds and #targetIds > 0 then
      local ok, err = pcall(function()
        for id, info in pairs(storages) do
          if info.role == "accepter" then
            local acc = peripheral.wrap(id)
            if acc then
              for slot, item in pairs(acc.list()) do
                local remaining = item.count
                for _, targetId in ipairs(targetIds) do
                  if remaining <= 0 then break end
                  local perTarget = math.ceil(item.count / #targetIds)
                  local toPush = math.min(perTarget, remaining)
                  local pushed = acc.pushItems(targetId, slot, toPush)
                  remaining = remaining - pushed
                end
              end
            end
          end
        end
      end)
      if not ok then
        print("dist err: " .. err)
      end
    end

    os.startTimer(0)
  end
end

return M
