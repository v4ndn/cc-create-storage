function distribute()
  while true do
    local ok, err = pcall(function()
      for id, info in pairs(storages) do
        if info.role == "accepter" then
          local accepter = peripheral.wrap(id)
          if accepter then
            for slot, item in pairs(accepter.list()) do
              local vaultId = getLowestSpaceTakenVault(storages)
              if vaultId then
                local targetId = storages[vaultId].reciever
                if targetId then
                  accepter.pushItems(targetId, slot, item.count)
                end
              end
            end
          end
        end
      end
    end)
    if not ok then
      print("distribution err: " .. err)
    end
    os.sleep(1)
  end
end
