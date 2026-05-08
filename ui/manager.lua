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
  local buttons = {}
  local selectors = {}

  local function drawMenu()
    buttons = {}
    selectors = {}
    cls()

    local receivers = storage.getReceivers(storages)
    local currentY = startY

    for id, info in pairs(storages) do
      pos(startX, currentY)
      if info.role ~= "unrecognized" then
        buttons[id .. "delete"] = {
          text = "DEL",
          color = colors.red,
          y = currentY,
          x = w - 6,
          onClick = function()
            storage.setRole(storages, id, "unrecognized")
          end
        }
      end
      if info.role == "vault" then
        selectors[id] = {
          text = info.reciever or "undefined",
          x = startX + #id + #info.role + 3,
          y = currentY,
        }
      end
      buttons[id .. "change"] = {
        text = "CHA",
        color = colors.gray,
        y = currentY,
        x = w - 2,
        onClick = function()
          local nextRole = config.roles[info.role].next
          storage.setRole(storages, id, nextRole)
          persistence.save(storages, config.STORAGE_FILE)
        end
      }

      local roleColor = config.roles[info.role].color
      term.blit(id .. " " .. info.role,
                string.rep("f", #id) .. "0" .. string.rep("0", #info.role),
                string.rep("0", #id) .. "f" ..
                string.rep(colors.toBlit(roleColor), #info.role))
      currentY = currentY + 1
    end

    for k, v in pairs(selectors) do
      pos(v.x + 2, v.y)

      buttons[k .. "selectorprev"] = {
        text = "<",
        color = colors.gray,
        y = v.y,
        x = v.x,
        onClick = function()
          if #receivers == 0 then return end
          local current = storages[k].reciever
          local idx = 1
          for i, r in ipairs(receivers) do
            if r == current then
              idx = i; break
            end
          end
          local prev = idx - 1
          if prev < 1 then prev = #receivers end
          storages[k].reciever = receivers[prev]
          persistence.save(storages, config.STORAGE_FILE)
        end
      }

      buttons[k .. "selectornext"] = {
        text = ">",
        color = colors.gray,
        y = v.y,
        x = v.x + #v.text + 3,
        onClick = function()
          if #receivers == 0 then return end
          local current = storages[k].reciever
          local idx = 1
          for i, r in ipairs(receivers) do
            if r == current then
              idx = i; break
            end
          end
          local next = idx + 1
          if next > #receivers then next = 1 end
          storages[k].reciever = receivers[next]
          persistence.save(storages, config.STORAGE_FILE)
        end
      }

      buttons[k .. "reset"] = {
        text = v.text,
        color = colors.gray,
        y = v.y,
        x = v.x + 2,
        onClick = function()
          storages[k].reciever = nil
          persistence.save(storages, config.STORAGE_FILE)
        end
      }

      term.write(v.text)
    end

    for k, v in pairs(buttons) do
      pos(v.x, v.y)
      term.blit(v.text, string.rep("0", #v.text),
                string.rep(colors.toBlit(v.color), #v.text))
    end
  end

  storage.detectNew(storages)

  while true do
    drawMenu()
    local event, button, mx, my = os.pullEvent()
    if event == "mouse_click" then
      for k, v in pairs(buttons) do
        if my == v.y and mx >= v.x and mx <= (v.x + #v.text) then
          v.onClick(button)
        end
      end
    end
    if event == "mouse_scroll" then
      if shiftModifier then
        startX = startX - button
      else
        startY = startY - button
      end
    end
    if event == "key" then
      if button == keys.leftShift then
        shiftModifier = true
      end
    end
    if event == "key_up" then
      if button == keys.leftShift then
        shiftModifier = false
      end
    end
  end
end

return M
