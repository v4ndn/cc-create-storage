local config = require("core.config")
local storage = require("core.storage")
require("lib.cuts")

local M = {}

function M.run(storages)
  local w, h = term.getSize()
  local startY = 1
  local startX = 1
  local shiftModifier = false
  local phase = "collect"
  local collectIndex = 1
  local rows = {}

  local function initCollection()
    local ids = {}
    for id, info in pairs(storages) do
      ids[#ids + 1] = id
    end
    table.sort(ids)
    rows = {}
    for i, id in ipairs(ids) do
      rows[i] = { id = id, role = storages[id].role, total = 0, capacity = 0, pct = 0 }
    end
    collectIndex = 1
    phase = "collect"
    os.startTimer(0)
  end

  local function drawRows()
    cls()
    tcol(colors.white)
    pos(1, 1)
    term.write("STORAGE INFO")

    local visible = h - 4
    for i = startY, math.min(#rows, startY + visible - 1) do
      local r = rows[i]
      local y = 3 + (i - startY)
      pos(startX, y)

      local statText
      if r.capacity > 0 then
        statText = " " .. r.total .. "/" .. r.capacity .. " " .. r.pct .. "%"
      else
        statText = " " .. r.total .. " items"
      end

      local roleColor = config.roles[r.role] and config.roles[r.role].color or colors.white

      term.blit(r.id .. " " .. r.role .. statText,
                string.rep("f", #r.id) .. "0" .. string.rep("0", #r.role) .. string.rep("7", #statText),
                string.rep("0", #r.id) .. "f" ..
                string.rep(colors.toBlit(roleColor), #r.role) ..
                string.rep("f", #statText))
    end

    pos(1, h)
    tcol(colors.gray)
    term.write("Press q or esc to exit")
  end

  initCollection()
  drawRows()

  while true do
    local event, arg, mx, my = os.pullEvent()

    if event == "timer" then
      if phase == "collect" then
        if collectIndex <= #rows then
          local id = rows[collectIndex].id
          local stats = storage.getStats(id)
          if stats then
            rows[collectIndex].total = stats.total
            rows[collectIndex].capacity = stats.capacity
            rows[collectIndex].pct = stats.pct
          end
          collectIndex = collectIndex + 1
        end
        if collectIndex > #rows then
          drawRows()
          phase = "display"
          os.startTimer(5)
        else
          os.startTimer(0)
        end
      elseif phase == "display" then
        initCollection()
      end

    elseif event == "mouse_scroll" then
      if shiftModifier then
        startX = startX - arg
      else
        startY = startY - arg
      end
      if startY < 1 then startY = 1 end
      if startX < 1 then startX = 1 end
      drawRows()

    elseif event == "key" then
      if arg == keys.leftShift then
        shiftModifier = true
      elseif arg == keys.q or arg == keys.escape then
        break
      end

    elseif event == "key_up" then
      if arg == keys.leftShift then
        shiftModifier = false
      end
    end
  end
  cls()
end

return M
