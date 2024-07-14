return {
	"nvim-pack/nvim-spectre",
    -- stylua: ignore
    keys = {
        { "<leader>sp" },
    },
	config = function()
		vim.keymap.set("n", "<leader>sp", function()
			require("spectre").open()
		end, { silent = true, noremap = true, desc = "Replace in files (Spectre)" })
	end,
}
