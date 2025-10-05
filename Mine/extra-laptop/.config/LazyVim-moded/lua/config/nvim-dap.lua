-- C++ support for DAP with gdb

local dap = require("dap")
dap.adapters.lldb = {
  type = "executable",
  command = "lldb-vscode",
  name = "lldb",
}
