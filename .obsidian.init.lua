
-- Ensure any existing j/k insert mappings are safely overwritten
vim.keymap.set('i', 'jk', '<Esc>', {
    noremap = true,
    silent = true
})

-- Optional: Sync your clipboard natively using Lua while you are here
vim.opt.clipboard = "unnamed"
