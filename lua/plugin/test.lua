return {
    {
        "nvim-neotest/neotest",
        dependencies = {
            "nvim-lua/plenary.nvim",
            "antoinemadec/FixCursorHold.nvim",
            "nvim-treesitter/nvim-treesitter",
            "marilari88/neotest-vitest",
            "nvim-neotest/neotest-go",
            "rcasia/neotest-java"
        },
        keys = {
            { "<leader>rt" },
            { "<leader>rT" },
            { "<leader>rr" },
            { "<leader>ro" },
        },
        config = function()
            local neotest = require("neotest")
            neotest.setup({
                adapters = {
                    require("neotest-vitest"),
                    require("neotest-go"),
                    require("neotest-java"),
                }
            })
            vim.keymap.set("n", "<leader>rt", function()
                neotest.run.run()
            end, { desc = "Run single function test" })
            vim.keymap.set("n", "<leader>rT", function()
                neotest.run.run(vim.fn.expand("%"))
            end, { desc = "Run file tests" })
            vim.keymap.set("n", "<leader>rr", function()
                neotest.summary.toggle()
            end, { desc = "Open Neotest Summary" })
            vim.keymap.set("n", "<leader>ro", function()
                neotest.output_panel.toggle()
            end, { desc = "Open Neotest Output Panel" })
            vim.keymap.set("n", "<leader>rc", function()
                neotest.output_panel.clear()
            end, { desc = "Clear Neotest Output Panel" })
        end,
    },
}
