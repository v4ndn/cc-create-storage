local M = {}

function M.load(path)
  local file = fs.open(path, "r")
  if not file then return {} end
  local data = textutils.unserialiseJSON(file.readAll())
  file.close()
  return data or {}
end

function M.save(data, path)
  local file = fs.open(path, "w")
  file.write(textutils.serialiseJSON(data))
  file.close()
end

return M
