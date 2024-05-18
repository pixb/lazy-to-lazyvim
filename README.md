# lazy-to-lazyvim
这个项目用来进行从[lazy.nvim](https://github.com/folke/lazy.nvim)进化到[LazyVim](https://github.com/LazyVim/LazyVim)从而学习如何配置`neovim`
用分支来记录演进过程

# v1

第一版，先加入两个功能一个是显示行号，一个是映射ESC键
- 行号和相对行号
- 映射ESC按键

## 显示行号和相对行号

参考：[使用元访问器](https://github.com/glepnir/nvim-lua-guide-zh#%E4%BD%BF%E7%94%A8%E5%85%83%E8%AE%BF%E9%97%AE%E5%99%A8)

```lua
vim.o.number = true
vim.o.relativenumber = true
```
## 按键映射

参考: [定义映射](https://github.com/glepnir/nvim-lua-guide-zh#%E5%AE%9A%E4%B9%89%E6%98%A0%E5%B0%84)
```lua
vim.api.nvim_set_keymap('i', 'jk', '<ESC>', { noremap = true, silent = true })
```
