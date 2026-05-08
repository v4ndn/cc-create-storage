require("storageutils")
require("cuts")

local rolecolors = {
  unrecognized = colors.red,
  vault = colors.cyan,
  accepter = colors.lime,
  reciever = colors.orange,
}

local storages = loadStorages("storages.json")
local w, h = term.getSize()

local function collectStats()
  local rows = {}
  for id, info in pairs(storages) do
    local storage = peripheral.wrap(id)
    local total = 0
    local capacity = 0
    local pct = 0
    if storage then
      local items = storage.list()
      for k, v in pairs(items) do
        total = total + v.count
      end
      local ok, size = pcall(storage.size, storage)
      if ok then
        capacity = size * 64
        pct = math.floor(total / capacity * 100)
      end
    end
    rows[#rows + 1] = {
      id = id,
      role = info.role,
      total = total,
      capacity = capacity,
      pct = pct,
    }
  end
  table.sort(rows, function(a, b) return a.id < b.id end)
  return rows
end

function draw(rows)
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

    term.blit(r.id .. " " .. r.role .. statText,
              string.rep("f", #r.id) .. "0" .. string.rep("0", #r.role) .. string.rep("7", #statText),
              string.rep("0", #r.id) .. "f" ..
              string.rep(colors.toBlit(rolecolors[r.role]), #r.role) ..
              string.rep("f", #statText))

    currentY = currentY + 1
  end
end

local rows = collectStats()
draw(rows)

pos(1, h)
tcol(colors.gray)
term.write("Press any key to exit")
os.pullEvent("key")
cls()
