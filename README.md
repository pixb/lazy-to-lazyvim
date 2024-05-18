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

# v2

第二版，这个版本的目标时引入`lazy.nvim`包管理器，但配置仍然只写下`init.lua`配置文件中

后面再刨析`LazyVim`项目逐步工程化。并学习其中的知识

## Installation
[lazy.nvim](https://github.com/folke/lazy.nvim#-installation)
You can add the following Lua code to your `init.lua` to bootstrap **lazy.nvim**:

```lua
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)
```
上面配置的解读：
- 获取数据路径拼接lazy存储路径，参考[[stdpath()]]
- 路径不存在，则clone，`lazy.nvim`
	- 参考:[[vim.uv]]
	- 参考:[[vim.loop]]
	- 参考:[[vim.fn]]
	- 参考:[[vim.fn.system()]]
- 设置运行时路径
	- 参考:[[vim_runtimepath]]
	- 参考:[[prepend()]]

Next step is to add **lazy.nvim** below the code added in the prior step in `init.lua`:

```lua
-- 启动
require("lazy").setup(plugins, opts)
```

输入`:Lazy`即可以看到lazy.nvim的管理界面

当然这里我们没有安装别的插件，只安装了`lazy.nvim`本身

![](https://taengsic.com/img/20240518222223_111.png)

