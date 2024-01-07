local A = {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    -- config = function()
    --     local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ':p:h:t')
    --
    --     local config = {
    --         filetype = { 'java' },
    --         cmd = {
    --             '/users/gunawan/.jenv/shims/java',
    --             '-declipse.application=org.eclipse.jdt.ls.core.id1',
    --             '-dosgi.bundles.defaultstartlevel=4',
    --             '-declipse.product=org.eclipse.jdt.ls.core.product',
    --             '-dlog.protocol=true',
    --             '-dlog.level=all',
    --             '-xms2g',
    --             '-xmx2g',
    --             '-javaagent:/users/gunawan/.local/share/jdtls/lombok.jar',
    --             '-jar',
    --             '/users/gunawan/.local/share/jdtls/plugins/org.eclipse.equinox.launcher_1.6.500.v20230622-2056.jar',
    --             '-configuration', '/users/gunawan/.local/share/jdtls/config_mac',
    --             '-data', '/users/gunawan/.local/share/jdtls/workspace/' .. project_name,
    --             '--add-modules=all-system',
    --             '--add-opens', 'java.base/java.util=all-unnamed',
    --             '--add-opens', 'java.base/java.lang=all-unnamed',
    --         },
    --         root_dir = require('jdtls.setup').find_root({ '.git', 'mvnw', 'gradlew', 'pom.xml', 'build.gradle' }),
    --
    --     }
    --     config['init_options'] = {
    --         bundles = {
    --             vim.fn.glob(
    --                 "/users/gunawan/.local/share/java-debug/com.microsoft.java.debug.plugin/target/com.microsoft.java.debug.plugin-0.47.0.jar",
    --                 1)
    --         },
    --     }
    --     require('jdtls').start_or_attach(config)
    --     vim.keymap.set("n", "<leader>dg", [[<cmd> jdtupdatedebugconfig<cr>]],
    --         { silent = true, noremap = true, desc = "update debug config" })
    --     vim.keymap.set("n", "<leader>dg", [[<cmd> jdtupdateconfig<cr>]],
    --         { silent = true, noremap = true, desc = "update config" })
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
