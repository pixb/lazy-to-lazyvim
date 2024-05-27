# lazy-to-lazyvim
这个项目用来进行从[lazy.nvim](https://github.com/folke/lazy.nvim)进化到[LazyVim](https://github.com/LazyVim/LazyVim)从而学习如何配置`neovim` 用分支来记录演进过程
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
参考: [定义映射](https://github.com/glepnir/nvim-lua-guide-zh#%E5%AE%9A%E4%B9%89%E6%98%A0%E5%B0%84)

```lua
vim.api.nvim_set_keymap('i', 'jk', '<ESC>', { noremap = true, silent = true })
```
# v2
第二版，这个版本的目标时引入`lazy.nvim`包管理器，但配置仍然只写下`init.lua`配置文件中
后面再刨析`LazyVim`项目逐步工程化。并学习其中的知识
## Installation
[lazy.nvim](https://github.com/folke/lazy.nvim#-installation) You can add the following Lua code to your `init.lua` to bootstrap **lazy.nvim**:
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

[![](https://camo.githubusercontent.com/8260c1db0fdc5dbcd4e158198da4efcdd9ea8665807ab8cce9616c4920123f31/68747470733a2f2f7461656e677369632e636f6d2f696d672f32303234303531383232323432385f696d6167652e706e67)](https://camo.githubusercontent.com/8260c1db0fdc5dbcd4e158198da4efcdd9ea8665807ab8cce9616c4920123f31/68747470733a2f2f7461656e677369632e636f6d2f696d672f32303234303531383232323432385f696d6167652e706e67)
# v3
第三个版本，开始仿照[LazyVim](https://github.com/LazyVim/LazyVim)结构，逐步细化学习
从[starter](https://github.com/LazyVim/starter)开始
配置的结构如下：
```c
.
├── init.lua
├── LICENSE
├── lua
│   ├── config
│   │   └── lazy.lua
│   ├── lazyvim
│   │   └── plugins
│   │       └── init.lua
│   └── plugins
│       └── init.lua
└── README.md
```
nvim/init.lua ==> nvim/lua/config.lazy.lua

加载本地插件目录`nvim/lua/plugins/init.lua`

加载lazyvim插件目录`nvim/lua/lazyvim/plugins/init.lua`

# v4
这个版本详细了加载的流程。
## [[LazyVim源码分析#plugins#init.lua]]
在这段代码中，它首先检查当前Neovim版本是否大于或等于0.9.0。如果不满足此条件，它将执行以下操作：
1. 使用`vim.api.nvim_echo()`函数显示一个消息，告诉用户LazyVim需要Neovim版本大于等于0.9.0。这个消息将显示在状态栏的ErrorMsg部分。
2. 使用`vim.api.nvim_echo()`函数再次显示一条消息，提示用户按任何键退出。这个消息将显示在MoreMsg部分。
3. 使用`vim.fn.getchar()`函数等待用户按下任何键。
4. 使用`vim.cmd([[quit]])`命令关闭当前Neovim实例。
5. 返回一个空表，表示没有执行任何有效载荷。
如果当前Neovim版本满足0.9.0或更高的要求，则不会执行这些操作，直接继续后面的代码。
加载`lazyvim.config`.init()
加载插件
```c
return {
  { "folke/lazy.nvim", version = "*" },
  { "LazyVim/LazyVim", priority = 10000, lazy = false, config = true, cond = true, version = "*" },
}
```

## [[LazyVim源码分析#config#init.lua]]
定义一些默认选项
## [[LazyVim源码分析#util#init.lua]]
# v5
`v4`版本也没有详解完，有点晕了，先不细纠了，往上看看
这个版本完成了基本的加载流程，下个版本开始配置一些插件。
## [[LazyVim源码分析#config#init.lua]]
初始化
## [[LazyVim源码分析#config#options.lua]]
选项配置
## [[LazyVim源码分析#config#plugin.lua]]
插件配置
## [[LazyVim源码分析#util#ui.lua]]
UI相关工具
# v6
引入一些插件
## 颜色主题colorscheme.lua
### [[tokyonight.nvim]]
### [[catppuccin]]

安装完成发现，并没有显示新的主题。
跟踪发现，是`config/init.lua`的`M.setup()`没有完善。
继续完善[[lazy_to_lazyvim#M.setup()]]
## [[LazyVim源码分析#config#keymaps.lua]]

## [[LazyVim源码分析#util#news.lua]]

## [[LazyVim源码分析#util#json.lua]]

# v7
这个版本来添加一些`ui`相关的插件。
## ui.lua
### 通知插件[[nvim-notify]]
### UI装饰[[dressing.nvim]]
input和select
### TAB插件[[bufferline.nvim]]

### 缩进线插件[[indent-blankline.nvim]]

### 按键提示[[which-key.nvim]]

### 定制UI [[noice.nvim]]
message,cmdline,popupmenu
### [[nvim-web-devicons]]
icon库
### [[nui.nvim]]
组建
### [[alpha-nvim]]
另一个dashboard，默认不用，切换开启
### [[dashboard-nvim]]

## [[LazyVim源码分析#plugins#editor.lua]]
### [[which-key.nvim]]

# v8
## [[LazyVim源码分析#plugins#editor.lua]]
### [[neo-tree.nvim]]文件浏览器
需要环境`nvim-lua/plenary.nvim`
这个配置在`plugins/util.lua`中

### [[nvim-spectre]] 搜索替换
### [[telescope.nvim]] 搜索预览插件

### [[flash.nvim]] 搜索带标签
### 按键导航[[which-key.nvim]]

### [[gitsigns.nvim]] 装饰git状态

### [[trouble.nvim]] 错误诊断

### [[todo-comments.nvim]] todo工具

## util.lua
### 函数库[[plenary.nvim]]


# v9
这个版本来配置`lsp`和语言编码相关的插件
## coding.lua
### [[nvim-cmp]] 代码自动补全
需要[[LazyVim源码分析#util#init.lua#M.create_undo()]]
### [[nvim-snippets]]
这个需要`neovim > 0.10`
### 自动括号 [[mini.pairs]]
### 注释增强 [[ts-comments.nvim]]

### [[mini.ai]] 扩展a/i

## lsp

### [[nvim-lspconfig]] Nvim LSP 的快速入门配置
### [[neoconf.nvim]] 管理全局，本地设置
### [[neodev.nvim]] 插件开发文档，提示，自动补全

### [[mason.nvim]] lsp服务管理器

### [[mason-lspconfig.nvim]] 连接mason和lspconfig更容易配置

### [[LazyVim源码分析#util#lsp.lua]]

### [[LazyVim源码分析#plugins#lsp#keymaps.lua]]
