local M = {}

M.STORAGE_FILE = "storages.json"
M.PERIPHERAL_PREFIX = "create:"
M.DEFAULT_STACK = 64

M.roles = {
  unrecognized = { color = colors.red, next = "vault" },
  vault = { color = colors.cyan, next = "reciever" },
  reciever = { color = colors.orange, next = "accepter" },
  accepter = { color = colors.lime, next = "vault" },
}

return M
