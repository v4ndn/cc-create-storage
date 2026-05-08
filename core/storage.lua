local config = require("core.config")

local M = {}

function M.wrap(name)
  return peripheral.wrap(name)
end

function M.isAvailable(name)
  return peripheral.wrap(name) ~= nil
end

function M.countItems(name)
  local storage = peripheral.wrap(name)
  if not storage then return 0 end
  local total = 0
  for _, item in pairs(storage.list()) do
    total = total + item.count
  end
  return total
end

function M.getStats(name)
  local storage = peripheral.wrap(name)
  if not storage then return nil end
  local items = storage.list()
  local total = 0
  for _, item in pairs(items) do
    total = total + item.count
  end
  local ok, size = pcall(storage.size, storage)
  local capacity = ok and (size * config.DEFAULT_STACK) or 0
  local pct = capacity > 0 and math.floor(total / capacity * 100) or 0
  return { total = total, capacity = capacity, pct = pct }
end

function M.detectNew(storages)
  for _, name in pairs(peripheral.getNames()) do
    if name:sub(1, #config.PERIPHERAL_PREFIX) == config.PERIPHERAL_PREFIX then
      if not storages[name] then
        storages[name] = { name = name, role = "unrecognized" }
      end
    end
  end
end

function M.getReceivers(storages)
  local list = {}
  for id, info in pairs(storages) do
    if info.role == "reciever" then
      list[#list + 1] = id
    end
  end
  table.sort(list)
  return list
end

function M.findLowestVault(storages)
  local min = 123479987123123409
  local best = nil
  for id, info in pairs(storages) do
    if info.role == "vault" then
      local total = M.countItems(id)
      if total < min then
        min = total
        best = id
      end
    end
  end
  return best
end

function M.setRole(storages, name, role)
  if storages[name] then
    storages[name].role = role
  end
end

function M.isRecognized(storages, name)
  return storages[name] ~= nil and storages[name].role ~= "unrecognized"
end

return M
