local I = {
	"echasnovski/mini.starter",
	version = false, -- wait till new 0.7.0 release to put it back on semver
	event = "VimEnter",
	opts = function()
		local logo_pad = string.rep(" ", 3)
		local logo = table.concat({
			logo_pad .. "█▄░█ █░█ █ █▀▄▀█",
			logo_pad .. "█░▀█ ▀▄▀ █ █░▀░█",
		}, "\n")
		local pad = string.rep(" ", 6)
		local new_section = function(name, action, section)
			return { name = name, action = action, section = pad .. section }
		end

		local starter = require("mini.starter")
        --stylua: ignore
        local config = {
            evaluate_single = true,
            header = logo,
            items = {
                new_section("Find File", "Telescope find_files", "Telescope"),
                new_section("Grep Text", "Telescope live_grep", "Telescope"),
                new_section("New File", "ene | startinsert", "Built-in"),
                new_section("Quit", "qa", "Built-in"),
                new_section("Session", [[lua require("persistence").load()]], "Etc..."),
                new_section("Lazy", [[Lazy]], "Etc..."),
                new_section("Checkhealth", [[checkhealth]], "Etc...")
            },
            content_hooks = {
                starter.gen_hook.adding_bullet(pad .. "░ ", false),
                starter.gen_hook.aligning("center", "center"),
            },
        }
		return config
	end,
	config = function(_, config)
		-- close Lazy and re-open when starter is ready
		if vim.o.filetype == "lazy" then
			vim.cmd.close()
			vim.api.nvim_create_autocmd("User", {
				pattern = "MiniStarterOpened",
				callback = function()
					require("lazy").show()
				end,
			})
		end

		if vim.fn.argc() == 1 then
			return
		end

		local starter = require("mini.starter")
		starter.setup(config)

		vim.api.nvim_create_autocmd("User", {
			pattern = "LazyVimStarted",
			callback = function()
				local stats = require("lazy").stats()
				local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
				starter.config.footer = "⚡" .. stats.count .. " plugins (" .. ms .. " ms)"
				pcall(starter.refresh)
			end,
		})
	end,
}

return { I }
