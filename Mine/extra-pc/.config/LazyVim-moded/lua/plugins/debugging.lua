return {
  "mfussenegger/nvim-dap",
  dependecies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
  },
  config = function()
    local dap, dapui = require("dap"), require("dapui")

    require("dapui").setup()

    -- add language specific configurations
    -- C support for DAP with gdb
    dap.adapters.gdb = {
      type = "executable",
      command = "gdb",
      name = "gdb",
    }

    -- C++ support for DAP with lldb
    dap.adapters.lldb = {
      type = "executable",
      command = "lldb-vscode",
      name = "lldb",
    }

    -- C# support for DAP with csharp
    dap.adapters.csharp = {
      type = "executable",
      command = "csharp",
      name = "csharp",
    }

    -- Python support for DAP with ptvsd
    dap.adapters.ptvsd = {
      type = "server",
      host = "localhost",
      port = 5678,
    }

    -- Java support for DAP with jdtls
    dap.adapters.java = {
      type = "server",
      host = "localhost",
      port = 5005,
    }

    -- GDScript support for DAP with godot
    dap.adapters.godot = {
      type = "executable",
      command = "godot",
      args = { "--path", "/path/to/godot/project" },
    }

    -- JavaScript support for DAP with node
    dap.adapters.node2 = {
      type = "executable",
      command = "node",
      args = { "/path/to/vscode-node-debug2/out/src/nodeDebug.js" },
    }

    -- lua support for DAP with lua
    local dap = require("dap")
    dap.adapters["local-lua"] = {
      type = "executable",
      command = "node",
      args = {
        "/absolute/path/to/local-lua-debugger-vscode/extension/debugAdapter.js",
      },
      enrich_config = function(config, on_config)
        if not config["extensionPath"] then
          local c = vim.deepcopy(config)
          -- 💀 If this is missing or wrong you'll see
          -- "module 'lldebugger' not found" errors in the dap-repl when trying to launch a debug session
          c.extensionPath = "/absolute/path/to/local-lua-debugger-vscode/"
          on_config(c)
        else
          on_config(config)
        end
      end,
    }

    -- ui for dap
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end
  end,
}
