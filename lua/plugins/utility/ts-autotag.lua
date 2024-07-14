local js_filetypes = {
	"html",
	"javascript",
	"typescript",
	"javascriptreact",
	"typescriptreact",
	"svelte",
	"vue",
	"tsx",
	"jsx",
	"rescript",
	"xml",
	"php",
	"markdown",
	"astro",
	"glimmer",
	"handlebars",
	"hbs",
}

return {
	"windwp/nvim-ts-autotag",
	ft = js_filetypes,
	config = function()
		require("nvim-ts-autotag").setup()
	end,
}
