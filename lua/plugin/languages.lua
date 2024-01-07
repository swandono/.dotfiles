local A = {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    -- config = function()
    --     local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    --
    --     local config = {
    --         filetype = { 'java' },
    --         cmd = {
    --             '/Users/gunawan/.jenv/shims/java',
    --             '-Declipse.application=org.eclipse.jdt.ls.core.id1',
    --             '-Dosgi.bundles.defaultStartLevel=4',
    --             '-Declipse.product=org.eclipse.jdt.ls.core.product',
    --             '-Dlog.protocol=true',
    --             '-Dlog.level=ALL',
    --             '-Xms2G',
    --             '-Xmx2G',
    --             '-javaagent:/Users/gunawan/.local/share/jdtls/lombok.jar',
    --             '-jar', '/Users/gunawan/.local/share/jdtls/plugins/org.eclipse.equinox.launcher_1.6.500.v20230622-2056.jar',
    --             '-configuration', '/Users/gunawan/.local/share/jdtls/config_mac',
    --             '-data', '/Users/gunawan/.local/share/jdtls/workspace/' .. project_name,
    --             '--add-modules=ALL-SYSTEM',
    --             '--add-opens', 'java.base/java.util=ALL-UNNAMED',
    --             '--add-opens', 'java.base/java.lang=ALL-UNNAMED',
    --         },
    --         root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }),
    --
    --     }
    --     config['init_options'] = {
    --         bundles = {
    --             vim.fn.glob(
    --                 "/Users/gunawan/.local/share/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-0.47.0.jar",
    --                 1)
    --         },
    --     }
    --     require('jdtls').start_or_attach(config)
    --     vim.keymap.set("n", "<leader>dg", [[<CMD> JdtUpdateDebugConfig<CR>]],
    --         { silent = true, noremap = true, desc = "Update Debug Config" })
    --     vim.keymap.set("n", "<leader>dG", [[<CMD> JdtUpdateConfig<CR>]],
    --         { silent = true, noremap = true, desc = "Update Config" })
    -- end
}

local B = {
    'akinsho/flutter-tools.nvim',
    ft = "dart",
    dependencies = {
        'nvim-lua/plenary.nvim',
        'stevearc/dressing.nvim', -- optional for vim.ui.select
    },
    -- config = function()
    --     require("flutter-tools").setup {
    --         ui = {
    --             notification_style = "native",
    --         },
    --         lsp = {
    --             color = { -- show the derived colours for dart variables
    --                 enabled = true,
    --                 background = false, -- highlight the background
    --                 background_color = { r = 0, g = 0, b = 0 },
    --                 foreground = true, -- highlight the foreground
    --                 virtual_text = false, -- show the highlight using virtual text
    --                 virtual_text_str = "■", -- the virtual text character to highlight
    --             },
    --             on_attach = function(client, bufnr)
    --                 require("config.lsp.handlers").on_attach(client, bufnr)
    --                 vim.cmd "highlight FlutterWidgetGuides ctermfg=9 guifg=grey"
    --             end,
    --             settings = {
    --                 renameFilesWithClasses = "always",
    --                 analysisExcludedFolders = {
    --                     ".dart",
    --                     ".dart-tool",
    --                     ".dartServer",
    --                 },
    --                 completeFunctionCalls = true,
    --                 experimentalRefactors = true,
    --             },
    --         },
    --         widget_guides = {
    --             enabled = true,
    --         },
    --         decorations = {
    --             statusline = {
    --                 project_config = true,
    --             },
    --         },
    --     }
    -- end
}

return { A, B }
