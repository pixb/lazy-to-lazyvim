vim.api.nvim_set_keymap('i', 'jk', '<ESC>', { noremap = true, silent = true })
vim.o.number = true
vim.o.relativenumber = true
require("config.lazy")
