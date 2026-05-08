function loadStorages(path)
  local storagesFile = fs.open(path, "r")
  local storagesJSON = storagesFile.readAll()
  local storages = textutils.unserialiseJSON(storagesJSON)
  storagesFile.close()
  return storages
end

function saveStorages(storages, path)
  storagesFile = fs.open(path, "w+")
  storagesJSON = textutils.serialiseJSON(storages)
  storagesFile.write(storagesJSON)
  storagesFile.close()
end

function isVaultRecognized(storages, name)
  return storages[name] ~= nil and storages[name].role ~= "unrecognized"
end

function detectVaults(storages)
  local p = peripheral.getNames()

  for k, v in pairs(p) do
    if v:sub(1, 7) == "create:" then
      print("detected create vault with id" .. v)
      if not isVaultRecognized(storages, v) then
        storages[v] = { name = v, role = "unrecognized" }
        print("unrecognized")
      end
    end
  end
end

function countTotalStorageItems(name)
  local storage = peripheral.wrap(name)
  if not storage then return 0 end
  local taken = 0

  for k, v in pairs(storage.list()) do
    taken = taken + v.count
  end

  return taken
end

function getLowestSpaceTakenVault(storages)
  local taken = 123479987123123409
  local lowest = nil
  for k, v in pairs(storages) do
    if v.role == "vault" then
      local total = countTotalStorageItems(k)
      if (taken > total) then
        taken = total
        lowest = k
      end
    end
  end
  return lowest, taken
end

function recognizeStorage(storages, name, role)
  if storages[name] ~= nil then
    storages[name].role = role
  end
end

function unrecognizeStorage(storages, name)
  if storages[name] ~= nil then
    storages[name].role = "unrecognized"
  end
end
