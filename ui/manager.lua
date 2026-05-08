local config = require("core.config")
local storage = require("core.storage")
local persistence = require("core.persistence")
require("lib.cuts")

local M = {}

function M.run(storages)
  local w, h = term.getSize()
  local startY = 1
  local startX = 1
  local shiftModifier = false
  local selectedVault = nil
  local buttons = {}

  local function drawMenu()
    buttons = {}
    cls()

    local ids = {}
    for id, _ in pairs(storages) do ids[#ids + 1] = id end
    table.sort(ids)

    local currentY = startY
    for _, id in ipairs(ids) do local info = storages[id]
      pos(startX, currentY)

      local displayText = id .. " " .. info.role
      local fg = string.rep("f", #id) .. "0" .. string.rep("0", #info.role)
      local roleColor = config.roles[info.role].color
      local bg = string.rep("0", #id) .. "f" ..
                 string.rep(colors.toBlit(roleColor), #info.role)

      if info.role == "vault" then
        local linkText = " -> " .. (info.reciever or "none")
        displayText = displayText .. linkText
        fg = fg .. string.rep("7", #linkText)
        bg = bg .. string.rep("f", #linkText)
      end

      if info.role == "vault" then
        local selText = (selectedVault == id) and "SEL*" or "SEL "
        buttons[id .. "sel"] = {
          text = selText,
          color = (selectedVault == id) and colors.yellow or colors.gray,
          y = currentY, x = w - 11,
          onClick = function()
            if selectedVault == id then
              selectedVault = nil
            else
              selectedVault = id
            end
          end
        }
      end

      if info.role == "reciever" and selectedVault ~= nil then
        buttons[id .. "link"] = {
          text = "LINK", color = colors.lime,
          y = currentY, x = w - 11,
          onClick = function()
            storages[selectedVault].reciever = id
            persistence.save(storages, config.STORAGE_FILE)
            selectedVault = nil
          end
        }
      end

      if info.role ~= "unrecognized" then
        buttons[id .. "delete"] = {
          text = "DEL", color = colors.red,
          y = currentY, x = w - 6,
          onClick = function()
            storage.setRole(storages, id, "unrecognized")
          end
        }
      end

      buttons[id .. "change"] = {
        text = "CHA", color = colors.gray,
        y = currentY, x = w - 2,
        onClick = function()
          local nextRole = config.roles[info.role].next
          storage.setRole(storages, id, nextRole)
          persistence.save(storages, config.STORAGE_FILE)
        end
      }

      term.blit(displayText, fg, bg)
      currentY = currentY + 1
    end

    for k, v in pairs(buttons) do
      pos(v.x, v.y)
      term.blit(v.text, string.rep("0", #v.text),
                string.rep(colors.toBlit(v.color), #v.text))
    end
  end

  storage.pruneMissing(storages)
  storage.detectNew(storages)

  while true do
    drawMenu()
    local event, arg, mx, my = os.pullEvent()

    if event == "mouse_click" then
      for k, v in pairs(buttons) do
        if my == v.y and mx >= v.x and mx <= (v.x + #v.text) then
          v.onClick(arg)
        end
      end

    elseif event == "mouse_scroll" then
      if shiftModifier then
        startX = startX - arg
      else
        startY = startY - arg
      end

    elseif event == "key" then
      if arg == keys.leftShift then
        shiftModifier = true
      end

    elseif event == "key_up" then
      if arg == keys.leftShift then
        shiftModifier = false
      end
    end
  end
end

return M
