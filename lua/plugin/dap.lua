return {
    "mfussenegger/nvim-dap",
    dependencies = {
        {
            "rcarriga/nvim-dap-ui",
            opts = {},
            config = function(_, opts)
                local dap = require("dap")
                local dapui = require("dapui")
                dapui.setup(opts)
                dap.listeners.before.event_terminated["dapui_config"] = function()
                    dapui.close({})
                end
                dap.listeners.before.event_exited["dapui_config"] = function()
                    dapui.close({})
                end
            end,
        },
        {
            "theHamsta/nvim-dap-virtual-text",
            config = function()
                require("nvim-dap-virtual-text").setup()
            end,
            opts = {},
        },
        {
            "jay-babu/mason-nvim-dap.nvim",
            config = function()
                require("mason-nvim-dap").setup()
            end,
            dependencies = "mason.nvim",
            cmd = { "DapInstall", "DapUninstall" },
            opts = {
                automatic_setup = true,
                handlers = {},
                ensure_installed = { "delve" },
            },
        },
        {
            "nvim-telescope/telescope-dap.nvim",
            config = function()
                require("telescope").load_extension("dap")
            end,
            keys = {
                {
                    "<leader>ds",
                    function()
                        require("telescope").extensions.dap.list_breakpoints {}
                    end,
                    desc = "List Breakpoints",
                }
            }
        },
        -- golang debugger
        {
            "leoluz/nvim-dap-go",
            ft = "go",
            dependencies = "nvim-dap",
            config = function()
                require("dap-go").setup()
            end,
        },
    },
    keys = {
        { "<leader>dc" },
    },
    config = function()
        local dap = require("dap")
        vim.keymap.set("n", "<leader>da", dap.toggle_breakpoint,
            { noremap = true, silent = true, desc = "Toggle Breakpoint" })
        vim.keymap.set("n", "<leader>dc", dap.continue, { noremap = true, silent = true, desc = "Continue" })
        vim.keymap.set("n", "<leader>df", dap.run_to_cursor,
            { noremap = true, silent = true, desc = "Go to line (no execute)" })
        vim.keymap.set("n", "<leader>dO", dap.step_over, { noremap = true, silent = true, desc = "Step Over" })
        vim.keymap.set("n", "<leader>di", dap.step_into, { noremap = true, silent = true, desc = "Step Into" })
        vim.keymap.set("n", "<leader>do", dap.step_out, { noremap = true, silent = true, desc = "Step Out" })
        vim.keymap.set("n", "<leader>dh", require("dap.ui.widgets").hover,
            { noremap = true, silent = true, desc = "Widgets" })
        vim.keymap.set("n", "<leader>dd", require("dapui").eval, { noremap = true, silent = true, desc = "Debug Eval" })
        vim.keymap.set("n", "<leader>dt", require("dapui").toggle,
            { noremap = true, silent = true, desc = "Toggle DAP UI" })
        vim.keymap.set("n", "<leader>db", function() require("dapui").float_element("breakpoints") end,
            { noremap = true, silent = true, desc = "Debug Breakpoints" })
        vim.keymap.set("n", "<leader>d;", function() require("dapui").float_element("watches") end,
            { noremap = true, silent = true, desc = "Debug Watches" })
        vim.keymap.set("n", "<leader>dj", function() require("dapui").float_element("scopes") end,
            { noremap = true, silent = true, desc = "Debug Scopes" })
        vim.keymap.set("n", "<leader>dk",
            function() require("dapui").float_element("repl", { height = 70, width = 200, position = "center" }) end,
            { noremap = true, silent = true, desc = "Debug REPL" })
        vim.keymap.set("n", "<leader>dl",
            function() require("dapui").float_element("console", { height = 70, width = 200, position = "center" }) end,
            { noremap = true, silent = true, desc = "Debug Terminal" })
        vim.keymap.set("n", "<leader>dm", function() require("dapui").float_element("stacks") end,
            { noremap = true, silent = true, desc = "Debug Stacks" })
        vim.keymap.set("n", "<leader>dn", dap.up, { noremap = true, silent = true, desc = "Up" })
        vim.keymap.set("n", "<leader>dp", dap.down, { noremap = true, silent = true, desc = "Down" })
    end
}
