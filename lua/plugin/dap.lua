return {
    "mfussenegger/nvim-dap",
    dependencies = {
        {
            "rcarriga/nvim-dap-ui",
            keys = {
                { "<leader>dd", function() require("dapui").toggle({}) end,    desc = "Toggle DAP UI" },
                { "<leader>dr", function() require("dap").repl.toggle({}) end, desc = "Toggle REPL" },
            },
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
            dependencies = "nvim-dap",
            config = function()
                require("dap-go").setup()
            end,
        },
    },
    keys = {
        {
            "<leader>dj",
            function() require("dap").toggle_breakpoint() end,
            desc =
            "Toggle Breakpoint"
        },
        {
            "<leader>dc",
            function() require("dap").continue() end,
            desc =
            "Continue"
        },
        {
            "<leader>dp",
            function() require("dap").down() end,
            desc =
            "Down"
        },
        { "<leader>dn", function() require("dap").up() end, desc = "Up" },
        {
            "<leader>dl",
            function() require("dapui").eval() end,
            desc =
            "Eval"
        },
        {
            "<leader>dt",
            function() require("dap").terminate() end,
            desc =
            "Terminate"
        },
        {
            "<leader>dh",
            function() require("dap.ui.widgets").hover() end,
            desc =
            "Widgets"
        },
        {
            "<leader>dk",
            function() require("dap").run_to_cursor() end,
            desc =
            "Go to line (no execute)"
        },
        {
            "<leader>di",
            function() require("dap").step_into() end,
            desc =
            "Step Into"
        },
        {
            "<leader>do",
            function() require("dap").step_out() end,
            desc =
            "Step Out"
        },
        {
            "<leader>dO",
            function() require("dap").step_over() end,
            desc =
            "Step Over"
        },
    },
}
