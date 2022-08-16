# NeoVim Config

Make NeoVim best IDE


## Customize

### Bufferline

Remove `force = true` to make unsaved buffer not force close.

**Path** `lua/bufferline/commands.lua`

**Before**
```lua
local function delete_element(id)
  if config:is_tabline() then
    vim.cmd("tabclose " .. id)
  else
    api.nvim_buf_delete(id, { force = true })
  end
end
```

**After**
```lua
local function delete_element(id)
  if config:is_tabline() then
    vim.cmd("tabclose " .. id)
  else
    api.nvim_buf_delete(id, {})
  end
end
```
