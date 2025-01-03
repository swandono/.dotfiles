local project_name = "gps" .. vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:gs?/?-?")

local config = {
	filetype = { "java" },
	cmd = {
		"/root/.sdkman/candidates/java/current/bin/java",
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xmx16G",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"-javaagent:/root/.local/share/jdtls/lombok.jar",
		"-jar",
		"/root/.local/share/jdtls/plugins/org.eclipse.equinox.launcher_1.6.900.v20240613-2009.jar",
		"-configuration",
		"/root/.local/share/jdtls/config_linux",
		"-data",
		"/root/.local/share/jdtls/workspace/" .. project_name,
	},
	root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew" }),
	init_options = {
		bundles = {
			vim.fn.glob(
				"/root/.local/share/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-0.53.1.jar",
				1
			),
		},
	},
}

require("jdtls").start_or_attach(config)
vim.keymap.set(
	"n",
	"<leader>dg",
	[[<CMD> JdtUpdateDebugConfig<CR>]],
	{ silent = true, noremap = true, desc = "Update Debug Config" }
)
vim.keymap.set(
	"n",
	"<leader>dG",
	[[<CMD> JdtUpdateConfig<CR>]],
	{ silent = true, noremap = true, desc = "Update Config" }
)
