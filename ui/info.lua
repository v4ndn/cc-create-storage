local config = require("core.config")
local storage = require("core.storage")
require("lib.cuts")

local M = {}

function M.run(storages)
  local w, h = term.getSize()

  local function collectStats()
    local rows = {}
    for id, info in pairs(storages) do
      local stats = storage.getStats(id)
      rows[#rows + 1] = {
        id = id,
        role = info.role,
        total = stats and stats.total or 0,
        capacity = stats and stats.capacity or 0,
        pct = stats and stats.pct or 0,
      }
    end
    table.sort(rows, function(a, b) return a.id < b.id end)
    return rows
  end

  local function draw(rows)
    cls()
    tcol(colors.white)
    pos(1, 1)
    term.write("STORAGE INFO")

    local currentY = 3
    for i = 1, #rows do
      local r = rows[i]
      pos(1, currentY)

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

      currentY = currentY + 1
    end
  end

  os.startTimer(5)

  local function drawFooter()
    pos(1, h)
    tcol(colors.gray)
    term.write("Press q or esc to exit")
  end

  local rows = collectStats()
  draw(rows)
  drawFooter()

  while true do
    local event, arg = os.pullEvent()
    if event == "timer" then
      rows = collectStats()
      draw(rows)
      drawFooter()
      os.startTimer(5)
    elseif event == "key" and (arg == keys.q or arg == keys.escape) then
      break
    end
  end
  cls()
end

return M
