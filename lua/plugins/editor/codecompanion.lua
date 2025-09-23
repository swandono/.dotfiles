local fidget_spinner = {}

fidget_spinner.handles = {}

function fidget_spinner:init()
	local group = vim.api.nvim_create_augroup("CodeCompanionFidgetHooks", {})

	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "CodeCompanionRequestStarted",
		group = group,
		callback = function(request)
			local handle = fidget_spinner:create_progress_handle(request)
			fidget_spinner:store_progress_handle(request.data.id, handle)
		end,
	})

	vim.api.nvim_create_autocmd({ "User" }, {
		pattern = "CodeCompanionRequestFinished",
		group = group,
		callback = function(request)
			local handle = fidget_spinner:pop_progress_handle(request.data.id)
			if handle then
				fidget_spinner:report_exit_status(handle, request)
				handle:finish()
			end
		end,
	})
end

function fidget_spinner:store_progress_handle(id, handle)
	self.handles[id] = handle
end

function fidget_spinner:pop_progress_handle(id)
	local handle = self.handles[id]
	self.handles[id] = nil
	return handle
end

function fidget_spinner:create_progress_handle(request)
	local progress = self._progress or require("fidget.progress")
	self._progress = progress
	return progress.handle.create({
		title = " Requesting assistance (" .. request.data.strategy .. ")",
		message = "In progress...",
		lsp_client = {
			name = self:llm_role_title(request.data.adapter),
		},
	})
end

function fidget_spinner:llm_role_title(adapter)
	local parts = {}
	table.insert(parts, adapter.formatted_name)
	if adapter.model and adapter.model ~= "" then
		table.insert(parts, "(" .. adapter.model .. ")")
	end
	return table.concat(parts, " ")
end

function fidget_spinner:report_exit_status(handle, request)
	if request.data.status == "success" then
		handle.message = "Completed"
	elseif request.data.status == "error" then
		handle.message = " Error"
	else
		handle.message = "󰜺 Cancelled"
	end
end

return {
	{
		"olimorris/codecompanion.nvim",
		event = { "BufReadPre", "BufNewFile", "InsertEnter" },
		dependencies = {
			"nvim-lua/plenary.nvim",
			"j-hui/fidget.nvim",
			{ "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
		},
		opts = {
			strategies = {
				-- Use the documented adapter table form to set both name and model
				chat = {
					adapter = { name = "copilot", model = "gpt-5-mini" },
					-- Override chat buffer keymaps: don't bind <C-c> to close; use <C-x> instead
					keymaps = {
						send = {
							modes = {
								n = { "<CR>" },
							},
						},
						close = {
							modes = { n = "<C-x>", i = "<C-x>" },
						},
					},
				},
				inline = { adapter = { name = "copilot", model = "gpt-5-mini" } },
				cmd = { adapter = { name = "copilot", model = "gpt-5-mini" } },
			},
			display = {
				chat = {
					window = {
						position = "right",
						width = 0.35,
					},
				},
			},
		},
		init = function()
			fidget_spinner:init()
		end,
		config = function(_, opts)
			require("codecompanion").setup(opts)
			vim.keymap.set(
				"n",
				"<C-j>",
				"<cmd>CodeCompanionChat Toggle<cr>",
				{ silent = true, noremap = true, desc = "Code Companion Chat" }
			)
			vim.keymap.set(
				"n",
				"<leader>cc",
				"<cmd>CodeCompanionActions<cr>",
				{ silent = true, noremap = true, desc = "Code Companion Action" }
			)
		end,
	},
}
