local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")

local config = {
	filetype = { "java" },
	cmd = {
		"/Users/swandono/.sdkman/candidates/java/current/bin/java",
		"-Dlog.protocol=true",
		"-Dlog.level=ALL",
		"-Xms2G",
		"-Xmx2G",
		"-javaagent:/Users/swandono/.local/share/jdtls/lombok.jar",
		"-jar",
		"/Users/swandono/.local/share/jdtls/plugins/org.eclipse.equinox.launcher_1.6.900.v20240613-2009.jar",
		"-configuration",
		"/Users/swandono/.local/share/jdtls/config_mac_arm",
		"-data",
		"/Users/swandono/.local/share/jdtls/workspace/" .. project_name,
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
	},
	root_dir = require("jdtls.setup").find_root({ ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }),
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
