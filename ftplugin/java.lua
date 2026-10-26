local root_markers = { "pom.xml", "build.gradle", "settings.gradle", "mvnw", "gradlew", ".git" }
local root_dir = require("jdtls.setup").find_root(root_markers)
if not root_dir then
	vim.notify("jdtls: no project root found (need pom.xml/build.gradle/.git)", vim.log.levels.WARN)
	return
end

local project_name = "gps-" .. vim.fn.fnamemodify(root_dir, ":t")
local workspace_dir = vim.fn.expand("/root/.local/share/jdtls/workspace/") .. project_name

local debug_jars = vim.split(
	vim.fn.glob(
		"/root/.local/share/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-*.jar"
	),
	"\n"
)

local jdtls = require("jdtls")

-- Java 21 runs jdtls: mise first (new servers), then sdkman (older hosts).
local java_candidates = {
	"/root/.local/share/mise/installs/java/oracle-21.0.7/bin/java",
	"/root/.sdkman/candidates/java/21.0.7-oracle/bin/java",
}
local java_bin = vim.iter(java_candidates):find(function(path)
	return vim.fn.executable(path) == 1
end) or java_candidates[#java_candidates]

local config = {
	cmd = {
		java_bin,
		"-Declipse.application=org.eclipse.jdt.ls.core.id1",
		"-Dosgi.bundles.defaultStartLevel=4",
		"-Declipse.product=org.eclipse.jdt.ls.core.product",
		"-Dlog.protocol=false",
		"-Dlog.level=WARNING",
		"-Xms1G",
		"-Xmx8G",
		"-XX:+UseG1GC",
		"-XX:+UseStringDeduplication",
		"-XX:MaxGCPauseMillis=200",
		"--add-modules=ALL-SYSTEM",
		"--add-opens",
		"java.base/java.lang=ALL-UNNAMED",
		"--add-opens",
		"java.base/java.util=ALL-UNNAMED",
		"-javaagent:" .. vim.fn.expand("/root/.local/share/jdtls/lombok.jar"),
		"-jar",
		-- vim.fn.expand("/root/.local/share/jdtls/plugins/org.eclipse.equinox.launcher_1.7.0.v20250519-0528.jar"),
		-- vim.fn.expand("/root/.local/share/jdtls/plugins/org.eclipse.equinox.launcher_1.7.100.v20251014-1222.jar"),
		vim.fn.expand("/root/.local/share/jdtls/plugins/org.eclipse.equinox.launcher_1.7.100.v20251111-0406.jar"),
		"-configuration",
		vim.fn.expand("/root/.local/share/jdtls/config_linux"),
		"-data",
		workspace_dir,
	},

	root_dir = root_dir,
	filetype = { "java" },

	init_options = {
		bundles = debug_jars,
		extendedClientCapabilities = vim.tbl_deep_extend("force", jdtls.extendedClientCapabilities, {
			resolveAdditionalTextEditsSupport = false,
			progressReportProvider = false,
			classFileContentsSupport = false,
		}),
	},

	capabilities = vim.tbl_deep_extend("force", require("blink.cmp").get_lsp_capabilities(), {
		textDocument = {
			completion = {
				completionItem = {
					snippetSupport = false,
					documentationFormat = { "plaintext" },
					resolveSupport = { properties = {} },
				},
			},
		},
	}),

	settings = {
		java = {
			project = {
				excludeFolders = { root_dir .. "/target", root_dir .. "/build" },
			},
			referencesCodeLens = { enabled = false },
			implementationsCodeLens = { enabled = false },
			signatureHelp = { enabled = true, description = { enabled = false } },
			contentProvider = { preferred = "fernflower" },
			codeGeneration = {
				toString = { template = "" },
				hashCodeEquals = { useJava7Objects = true },
				useBlocks = true,
			},
			completion = {
				favoriteStaticMembers = {},
				filteredTypes = {
					"com.sun.*",
					"io.micrometer.shaded.*",
					"java.awt.*",
					"jdk.*",
					"sun.*",
				},
				maxResults = 20,
				importOrder = {},
				postfix = { enabled = false },
				chain = { enabled = false },
				guessMethodArguments = false,
				matchCaseSensitive = false,
				lazyResolveTextEdit = true,
				enabled = true,
			},
			sources = {
				organizeImports = {
					starThreshold = 5,
					staticStarThreshold = 3,
				},
			},
			configuration = {
				runtimes = {},
				updateBuildConfiguration = "automatic",
			},
			autobuild = { enabled = true },
			maxConcurrentBuilds = 1,
			recommendations = { dependency = { analytics = { show = false } } },
			references = { includeDecompiledSources = false },
			symbols = { includeSourceMethodDeclarations = false },
			inlayHints = {
				parameterNames = { enabled = "none" },
			},
			edit = {
				validateAllOpenBuffersOnChanges = false,
			},
			-- Critical performance settings for 1.48+
			compile = {
				nullAnalysis = {
					mode = "disabled",
				},
			},
			-- Disable slow semantic highlighting
			semanticHighlighting = { enabled = false },
			-- Disable unused code detection (slow in large files)
			codeAction = {
				sortMembers = { avoidVolatileChanges = true },
			},
		},
	},

	handlers = {
		["textDocument/publishDiagnostics"] = vim.lsp.with(
			vim.lsp.diagnostic.on_publish_diagnostics,
			{ underline = true, virtual_text = false, signs = true, update_in_insert = false, debounce = 500 }
		),
	},

	on_attach = function(client, bufnr)
		jdtls.setup_dap({
			hotcodereplace = "auto",
			bundles = debug_jars,
		})
	end,
}

jdtls.start_or_attach(config)

vim.keymap.set(
	"n",
	"<leader>dg",
	"<CMD>JdtUpdateDebugConfig<CR>",
	{ silent = true, noremap = true, desc = "JDT LS: Update Debug Config" }
)
vim.keymap.set(
	"n",
	"<leader>dG",
	"<CMD>JdtUpdateConfig<CR>",
	{ silent = true, noremap = true, desc = "JDT LS: Update Config" }
)
