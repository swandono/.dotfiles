local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "settings.gradle" }
local root_dir = require("jdtls.setup").find_root(root_markers)

if not root_dir then
	vim.notify("jdtls: no project root found (need pom.xml/build.gradle/.git)", vim.log.levels.WARN)
	return
end

local project_name = "gps-" .. vim.fn.fnamemodify(root_dir, ":t")
local workspace_dir = vim.fn.expand("/root/.local/share/jdtls/workspace/") .. project_name

local jdtls_cmd = {
	"/root/.sdkman/candidates/java/current/bin/java",
	"-Declipse.application=org.eclipse.jdt.ls.core.id1",
	"-Dosgi.bundles.defaultStartLevel=4",
	"-Declipse.product=org.eclipse.jdt.ls.core.product",
	"-Dlog.protocol=true",
	"-Dlog.level=ALL",
	"-Xmx2G",
	"-XX:+UseG1GC",
	"-XX:MaxGCPauseMillis=200",
	"--add-modules=ALL-SYSTEM",
	"--add-opens",
	"java.base/java.lang=ALL-UNNAMED",
	"--add-opens",
	"java.base/java.util=ALL-UNNAMED",
	"-javaagent:" .. vim.fn.expand("/root/.local/share/jdtls/lombok.jar"),
	"-jar",
	vim.fn.expand("/root/.local/share/jdtls/plugins/org.eclipse.equinox.launcher_1.7.0.v20250424-1814.jar"),
	"-configuration",
	vim.fn.expand("/root/.local/share/jdtls/config_linux"),
	"-data",
	workspace_dir,
}

local config = {
	cmd = jdtls_cmd,
	root_dir = root_dir,
	filetype = { "java" },

	settings = {
		java = {
			project = {
				excludeFolders = {
					root_dir .. "/target",
					root_dir .. "/build",
				},
			},
			referencesCodeLens = { enabled = false },
			implementationsCodeLens = { enabled = false },
			codeGeneration = { toString = { template = "" } },
		},
	},

	init_options = {
		bundles = {
			vim.fn.glob(
				"/root/.local/share/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-0.53.1.jar",
				1
			),
		},
	},

	handlers = {
		["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
			underline = true,
			virtual_text = false, -- less flicker in the buffer
			signs = true,
			update_in_insert = false,
			debounce = 300, -- wait 300ms after you stop typing
		}),
	},
}

require("jdtls").start_or_attach(config)

vim.keymap.set("n", "<leader>dg", [[<CMD> JdtUpdateDebugConfig<CR>]], {
	silent = true,
	noremap = true,
	desc = "JDT LS: Update Debug Config",
})
vim.keymap.set("n", "<leader>dG", [[<CMD> JdtUpdateConfig<CR>]], {
	silent = true,
	noremap = true,
	desc = "JDT LS: Update Config",
})
