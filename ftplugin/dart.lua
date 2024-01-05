require("flutter-tools").setup {
    ui = {
        notification_style = "native",
    },
    lsp = {
        color = { -- show the derived colours for dart variables
            enabled = true,
            background = false, -- highlight the background
            background_color = { r = 0, g = 0, b = 0 },
            foreground = true, -- highlight the foreground
            virtual_text = false, -- show the highlight using virtual text
            virtual_text_str = "■", -- the virtual text character to highlight
        },
        on_attach = function(client, bufnr)
            require("config.lsp.handlers").on_attach(client, bufnr)
            vim.cmd "highlight FlutterWidgetGuides ctermfg=9 guifg=grey"
        end,
        settings = {
            renameFilesWithClasses = "always",
            analysisExcludedFolders = {
                ".dart",
                ".dart-tool",
                ".dartServer",
            },
            completeFunctionCalls = true,
            experimentalRefactors = true,
        },
    },
    debugger = {
        enabled = true,
        run_via_dap = true,
        -- don't pause on exception in flutter
        exception_breakpoints = {},
    },
    fvm = true,
    widget_guides = {
        enabled = true,
    },
    dev_log = {
        enabled = true,
        open_cmd = "15split", -- command to use to open the log buffer
    },
    decorations = {
        statusline = {
            project_config = true,
        },
    },
}
