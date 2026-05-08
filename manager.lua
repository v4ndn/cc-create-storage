require("storageutils")
require("cuts")

local rolecolors = {
  unrecognized = colors.red,
  vault = colors.cyan,
  accepter = colors.lime,
  reciever = colors.orange,
}

local nextRole = {
  unrecognized = "vault",
  vault = "reciever",
  reciever = "accepter",
  accepter = "vault",
}

local w, h = term.getSize()
storages = loadStorages("storages.json")

local startY = 1
local startX = 1

local shiftModifier = false

function drawMenu()
  buttons = {}
  selectors = {}
  cls()

  function onClick(mouse, id, currentRole)
    storages[id].role = nextRole[currentRole]
    saveStorages(storages, "storages.json")
  end

  local receivers = {}
  for id, info in pairs(storages) do
    if info.role == "reciever" then
      receivers[#receivers + 1] = id
    end
  end
  table.sort(receivers)

  local currentY = startY
  for id, info in pairs(storages) do
    pos(startX, currentY)
    if info.role ~= "unrecognized" then
      buttons[id .. "delete"] = {
        text = "DEL",
        color = colors.red,
        y = currentY,
        x = w - 6,
        onClick = function(mouse)
          unrecognizeStorage(storages, id)
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
      onClick = function(mouse)
        onClick(mouse, id, info.role)
      end
    }


    term.blit(id .. " " .. info.role,
              string.rep("f", #id) .. "0" .. string.rep("0", #info.role),
              string.rep("0", #id) .. "f" ..
              string.rep(colors.toBlit(rolecolors[info.role]), #info.role))
    currentY = currentY + 1
  end
  for k, v in pairs(selectors) do
    pos(v.x + 2, v.y)
    buttons[k .. "selectorprev"] = {
      text = "<",
      color = colors.gray,
      y = v.y,
      x = v.x,
      onClick = function(mouse)
        if #receivers == 0 then return end
        local current = storages[k].reciever
        local idx = 1
        for i, r in ipairs(receivers) do
          if r == current then
            idx = i; break
          end
        end
        local prevIdx = idx - 1
        if prevIdx < 1 then prevIdx = #receivers end
        storages[k].reciever = receivers[prevIdx]
        saveStorages(storages, "storages.json")
      end
    }
    buttons[k .. "selectornext"] = {
      text = ">",
      color = colors.gray,
      y = v.y,
      x = v.x + #v.text + 3,
      onClick = function(mouse)
        if #receivers == 0 then return end
        local current = storages[k].reciever
        local idx = 1
        for i, r in ipairs(receivers) do
          if r == current then
            idx = i; break
          end
        end
        local nextIdx = idx + 1
        if nextIdx > #receivers then nextIdx = 1 end
        storages[k].reciever = receivers[nextIdx]
        saveStorages(storages, "storages.json")
      end
    }
    buttons[k .. "reset"] = {
      text = v.text,
      color = colors.gray,
      y = v.y,
      x = v.x + 2,
      onClick = function(mouse)
        storages[k].reciever = nil
        saveStorages(storages, "storages.json")
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

function main()
  detectVaults(storages)


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

require("distribution")
parallel.waitForAny(main, distribute)
saveStorages(storages, "storages.json")
