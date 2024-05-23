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
## `nvim/lua/lazyvim/plugins/init.lua`
```lua
if vim.fn.has("nvim-0.9.0") == 0 then
  vim.api.nvim_echo({
    { "LazyVim requires Neovim >= 0.9.0\n", "ErrorMsg" },
    { "Press any key to exit", "MoreMsg" },
  }, true, {})
  vim.fn.getchar()
  vim.cmd([[quit]])
  return {}
end

require("lazyvim.config").init()

return {
  { "folke/lazy.nvim", version = "*" },
  { "LazyVim/LazyVim", priority = 10000, lazy = false, config = true, cond = true, version = "*" },
}
```

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

## nvim/lua/lazyvim/config/init.lua
定义一些默认选项

```c
local Util = require("lazyvim.util")
---@class LazyVimConfig: LazyVimOptions
local M = {}

---@class LazyVimOptions
local defaults = {
  -- colorscheme can be a string like `catppuccin` or a function that will load the colorscheme
  ---@type string|fun()
  colorscheme = function()
    require("tokyonight").load()
  end,
  -- load the default settings
  defaults = {
    autocmds = true, -- lazyvim.config.autocmds
    keymaps = true, -- lazyvim.config.keymaps
    -- lazyvim.config.options can't be configured here since that's loaded before lazyvim setup
    -- if you want to disable loading options, add `package.loaded["lazyvim.config.options"] = true` to the top of your init.lua
  },
  news = {
    -- When enabled, NEWS.md will be shown when changed.
    -- This only contains big new features and breaking changes.
    lazyvim = true,
    -- Same but for Neovim's news.txt
    neovim = false,
  },
  -- icons used by other plugins
  -- stylua: ignore
  icons = {
    misc = {
      dots = "󰇘",
    },
    dap = {
      Stopped             = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
      Breakpoint          = " ",
      BreakpointCondition = " ",
      BreakpointRejected  = { " ", "DiagnosticError" },
      LogPoint            = ".>",
    },
    diagnostics = {
      Error = " ",
      Warn  = " ",
      Hint  = " ",
      Info  = " ",
    },
    git = {
      added    = " ",
      modified = " ",
      removed  = " ",
    },
    kinds = {
      Array         = " ",
      Boolean       = "󰨙 ",
      Class         = " ",
      Codeium       = "󰘦 ",
      Color         = " ",
      Control       = " ",
      Collapsed     = " ",
      Constant      = "󰏿 ",
      Constructor   = " ",
      Copilot       = " ",
      Enum          = " ",
      EnumMember    = " ",
      Event         = " ",
      Field         = " ",
      File          = " ",
      Folder        = " ",
      Function      = "󰊕 ",
      Interface     = " ",
      Key           = " ",
      Keyword       = " ",
      Method        = "󰊕 ",
      Module        = " ",
      Namespace     = "󰦮 ",
      Null          = " ",
      Number        = "󰎠 ",
      Object        = " ",
      Operator      = " ",
      Package       = " ",
      Property      = " ",
      Reference     = " ",
      Snippet       = " ",
      String        = " ",
      Struct        = "󰆼 ",
      TabNine       = "󰏚 ",
      Text          = " ",
      TypeParameter = " ",
      Unit          = " ",
      Value         = " ",
      Variable      = "󰀫 ",
    },
  },
  ---@type table<string, string[]|boolean>?
  kind_filter = {
    default = {
      "Class",
      "Constructor",
      "Enum",
      "Field",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      "Package",
      "Property",
      "Struct",
      "Trait",
    },
    markdown = false,
    help = false,
    -- you can specify a different filter for each filetype
    lua = {
      "Class",
      "Constructor",
      "Enum",
      "Field",
      "Function",
      "Interface",
      "Method",
      "Module",
      "Namespace",
      -- "Package", -- remove package since luals uses it for control flow structures
      "Property",
      "Struct",
      "Trait",
    },
  },
}





---@type LazyVimOptions
local options

---@param opts? LazyVimOptions
function M.setup(opts)
        print("lua/lazyvim/config/init.lua setup() start===>")
        options = vim.tbl_deep_extend("force", defaults, opts or {}) or {}
	  -- autocmds can be loaded lazily when not opening a file
	  local lazy_autocmds = vim.fn.argc(-1) == 0
	  if not lazy_autocmds then
	    M.load("autocmds")
	  end
        print("lua/lazyvim/config/init.lua setup() end<===")
end


---@param name "autocmds" | "options" | "keymaps"
function M.load(name)
  local function _load(mod)
    if require("lazy.core.cache").find(mod)[1] then
      Util.try(function()
        require(mod)
      end, { msg = "Failed loading " .. mod })
    end
  end
  -- always load lazyvim, then user file
  if M.defaults[name] or name == "options" then
    _load("lazyvim.config." .. name)
  end
  _load("config." .. name)
  if vim.bo.filetype == "lazy" then
    -- HACK: LazyVim may have overwritten options of the Lazy ui, so reset this here
    vim.cmd([[do VimResized]])
  end
  local pattern = "LazyVim" .. name:sub(1, 1):upper() .. name:sub(2)
  vim.api.nvim_exec_autocmds("User", { pattern = pattern, modeline = false })
end


function M.init()
        print("lua/lazyvim/config/init.lua init() start===>")
        print("lua/lazyvim/config/init.lua init() end<===")
end

setmetatable(M, {
  __index = function(_, key)
    if options == nil then
      return vim.deepcopy(defaults)[key]
    end
    ---@cast options LazyVimConfig
    return options[key]
  end,
})

return M
```

### defaults={}
默认属性表
### M.setup()
```c
---@param opts? LazyVimOptions
function M.setup(opts)
  options = vim.tbl_deep_extend("force", defaults, opts or {}) or {}

  -- autocmds can be loaded lazily when not opening a file
  local lazy_autocmds = vim.fn.argc(-1) == 0
  if not lazy_autocmds then
    M.load("autocmds")
  end

  local group = vim.api.nvim_create_augroup("LazyVim", { clear = true })
  vim.api.nvim_create_autocmd("User", {
    group = group,
    pattern = "VeryLazy",
    callback = function()
      if lazy_autocmds then
        M.load("autocmds")
      end
      M.load("keymaps")

      Util.format.setup()
      Util.news.setup()
      Util.root.setup()

      vim.api.nvim_create_user_command("LazyExtras", function()
        Util.extras.show()
      end, { desc = "Manage LazyVim extras" })
    end,
  })

  Util.track("colorscheme")
  Util.try(function()
    if type(M.colorscheme) == "function" then
      M.colorscheme()
    else
      vim.cmd.colorscheme(M.colorscheme)
    end
  end, {
    msg = "Could not load your colorscheme",
    on_error = function(msg)
      Util.error(msg)
      vim.cmd.colorscheme("habamax")
    end,
  })
  Util.track()
end
```
- 将默认选项表和加载选项表融合
	- [[vim.tbl_deep_extend()]]
- 懒加载`autocmds`
	- 如果`nvim`的参数为0个，其实一般就是打开文件时
	- [[vim.fn.argc()]]
- 创建自动命令组`LazyVim`
	- [[vim.api.nvim_create_augroup()]]
	- [[vimscript_自动命令组]]
- 创建自动命令`User`在`LazyVim`组中
	- [[vimscript_自动命令]]
	- [[vim.api.nvim_create_autocmd()]]
- 加载主题
### M.load()
```c
---@param name "autocmds" | "options" | "keymaps"
function M.load(name)
  local function _load(mod)
    if require("lazy.core.cache").find(mod)[1] then
      Util.try(function()
        require(mod)
      end, { msg = "Failed loading " .. mod })
    end
  end
  -- always load lazyvim, then user file
  if M.defaults[name] or name == "options" then
    _load("lazyvim.config." .. name)
  end
  _load("config." .. name)
  if vim.bo.filetype == "lazy" then
    -- HACK: LazyVim may have overwritten options of the Lazy ui, so reset this here
    vim.cmd([[do VimResized]])
  end
  local pattern = "LazyVim" .. name:sub(1, 1):upper() .. name:sub(2)
  vim.api.nvim_exec_autocmds("User", { pattern = pattern, modeline = false })
end
```
#### autocmds
### M.json.load()
加载`json`
```c
M.json = {
  version = 2,
  data = {
    version = nil, ---@type string?
    news = {}, ---@type table<string, string>
    extras = {}, ---@type string[]
  },
}

function M.json.load()
  local path = vim.fn.stdpath("config") .. "/lazyvim.json"
  local f = io.open(path, "r")
  if f then
    local data = f:read("*a")
    f:close()
    local ok, json = pcall(vim.json.decode, data, { luanil = { object = true, array = true } })
    if ok then
      M.json.data = vim.tbl_deep_extend("force", M.json.data, json or {})
      if M.json.data.version ~= M.json.version then
        Util.json.migrate()
      end
    end
  end
end
```


### 元方法`__index`,索引
```c
setmetatable(M, {
  __index = function(_, key)
    if options == nil then
      return vim.deepcopy(defaults)[key]
    end
    ---@cast options LazyVimConfig
    return options[key]
  end,
})
```
参考：[[lua元表与元方法]]
元方法，索引`options`的值


## nvim/lua/lazyvim/util/init.lua
```c
local LazyUtil = require("lazy.core.util")

---@class lazyvim.util: LazyUtilCore
---@field ui lazyvim.util.ui
---@field lsp lazyvim.util.lsp
---@field root lazyvim.util.root
---@field telescope lazyvim.util.telescope
---@field terminal lazyvim.util.terminal
---@field toggle lazyvim.util.toggle
---@field format lazyvim.util.format
---@field plugin lazyvim.util.plugin
---@field extras lazyvim.util.extras
---@field inject lazyvim.util.inject
---@field news lazyvim.util.news
---@field json lazyvim.util.json
---@field lualine lazyvim.util.lualine
local M = {}

---@type table<string, string|string[]>
local deprecated = {
  get_clients = "lsp",
  on_attach = "lsp",
  on_rename = "lsp",
  root_patterns = { "root", "patterns" },
  get_root = { "root", "get" },
  float_term = { "terminal", "open" },
  toggle_diagnostics = { "toggle", "diagnostics" },
  toggle_number = { "toggle", "number" },
  fg = "ui",
}

setmetatable(M, {
  __index = function(t, k)
    if LazyUtil[k] then
      return LazyUtil[k]
    end
    local dep = deprecated[k]
    if dep then
      local mod = type(dep) == "table" and dep[1] or dep
      local key = type(dep) == "table" and dep[2] or k
      M.deprecate([[require("lazyvim.util").]] .. k, [[require("lazyvim.util").]] .. mod .. "." .. key)
      ---@diagnostic disable-next-line: no-unknown
      t[mod] = require("lazyvim.util." .. mod) -- load here to prevent loops
      return t[mod][key]
    end
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require("lazyvim.util." .. k)
    return t[k]
  end,
})

function M.is_win()
  return vim.loop.os_uname().sysname:find("Windows") ~= nil
end

---@param plugin string
function M.has(plugin)
  return require("lazy.core.config").spec.plugins[plugin] ~= nil
end

---@param fn fun()
function M.on_very_lazy(fn)
  vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
      fn()
    end,
  })
end

---@param name string
function M.opts(name)
  local plugin = require("lazy.core.config").plugins[name]
  if not plugin then
    return {}
  end
  local Plugin = require("lazy.core.plugin")
  return Plugin.values(plugin, "opts", false)
end

function M.deprecate(old, new)
  M.warn(("`%s` is deprecated. Please use `%s` instead"):format(old, new), {
    title = "LazyVim",
    once = true,
    stacktrace = true,
    stacklevel = 6,
  })
end

-- delay notifications till vim.notify was replaced or after 500ms
function M.lazy_notify()
  local notifs = {}
  local function temp(...)
    table.insert(notifs, vim.F.pack_len(...))
  end

  local orig = vim.notify
  vim.notify = temp

  local timer = vim.loop.new_timer()
  local check = assert(vim.loop.new_check())

  local replay = function()
    timer:stop()
    check:stop()
    if vim.notify == temp then
      vim.notify = orig -- put back the original notify if needed
    end
    vim.schedule(function()
      ---@diagnostic disable-next-line: no-unknown
      for _, notif in ipairs(notifs) do
        vim.notify(vim.F.unpack_len(notif))
      end
    end)
  end

  -- wait till vim.notify has been replaced
  check:start(function()
    if vim.notify ~= temp then
      replay()
    end
  end)
  -- or if it took more than 500ms, then something went wrong
  timer:start(500, 0, replay)
end

---@param name string
---@param fn fun(name:string)
function M.on_load(name, fn)
  local Config = require("lazy.core.config")
  if Config.plugins[name] and Config.plugins[name]._.loaded then
    fn(name)
  else
    vim.api.nvim_create_autocmd("User", {
      pattern = "LazyLoad",
      callback = function(event)
        if event.data == name then
          fn(name)
          return true
        end
      end,
    })
  end
end

-- Wrapper around vim.keymap.set that will
-- not create a keymap if a lazy key handler exists.
-- It will also set `silent` to true by default.
function M.safe_keymap_set(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  local modes = type(mode) == "string" and { mode } or mode

  ---@param m string
  modes = vim.tbl_filter(function(m)
    return not (keys.have and keys:have(lhs, m))
  end, modes)

  -- do not create the keymap if a lazy keys handler exists
  if #modes > 0 then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      ---@diagnostic disable-next-line: no-unknown
      opts.remap = nil
    end
    vim.keymap.set(modes, lhs, rhs, opts)
  end
end

return M
```

### 元方法

```c
setmetatable(M, {
  __index = function(t, k)
    if LazyUtil[k] then
      return LazyUtil[k]
    end
    local dep = deprecated[k]
    if dep then
      local mod = type(dep) == "table" and dep[1] or dep
      local key = type(dep) == "table" and dep[2] or k
      M.deprecate([[require("lazyvim.util").]] .. k, [[require("lazyvim.util").]] .. mod .. "." .. key)
      ---@diagnostic disable-next-line: no-unknown
      t[mod] = require("lazyvim.util." .. mod) -- load here to prevent loops
      return t[mod][key]
    end
    ---@diagnostic disable-next-line: no-unknown
    t[k] = require("lazyvim.util." .. k)
    return t[k]
  end,
})
```
#### M.try()
- 调用`M.try()`方法
	- 调用`lazy.core.util.try()`方法
### M.notify()
delay notifications till vim.notify was replaced or after 500ms
延迟通知直到 vim.notify 被替换或 500 毫秒后
```c
-- delay notifications till vim.notify was replaced or after 500ms
function M.lazy_notify()
  local notifs = {}
  local function temp(...)
    table.insert(notifs, vim.F.pack_len(...))
  end

  local orig = vim.notify
  vim.notify = temp

  local timer = vim.loop.new_timer()
  local check = assert(vim.loop.new_check())

  local replay = function()
    timer:stop()
    check:stop()
    if vim.notify == temp then
      vim.notify = orig -- put back the original notify if needed
    end
    vim.schedule(function()
      ---@diagnostic disable-next-line: no-unknown
      for _, notif in ipairs(notifs) do
        vim.notify(vim.F.unpack_len(notif))
      end
    end)
  end

  -- wait till vim.notify has been replaced
  check:start(function()
    if vim.notify ~= temp then
      replay()
    end
  end)
  -- or if it took more than 500ms, then something went wrong
  timer:start(500, 0, replay)
end
```

### M.safe_keymap_set()

```c
-- Wrapper around vim.keymap.set that will
-- not create a keymap if a lazy key handler exists.
-- It will also set `silent` to true by default.
function M.safe_keymap_set(mode, lhs, rhs, opts)
  local keys = require("lazy.core.handler").handlers.keys
  ---@cast keys LazyKeysHandler
  local modes = type(mode) == "string" and { mode } or mode

  ---@param m string
  modes = vim.tbl_filter(function(m)
    return not (keys.have and keys:have(lhs, m))
  end, modes)

  -- do not create the keymap if a lazy keys handler exists
  if #modes > 0 then
    opts = opts or {}
    opts.silent = opts.silent ~= false
    if opts.remap and not vim.g.vscode then
      ---@diagnostic disable-next-line: no-unknown
      opts.remap = nil
    end
    vim.keymap.set(modes, lhs, rhs, opts)
  end
end
```

# v5
`v4`版本也没有详解完，有点晕了，先不细纠了，往上看看
这个版本完成了基本的加载流程，下个版本开始配置一些插件。
## nvim/lua/lazyvim/config/init.lua
初始化
```c
M.did_init = false
function M.init()
  if M.did_init then
    return
  end
  M.did_init = true
  local plugin = require("lazy.core.config").spec.plugins.LazyVim
  if plugin then
    vim.opt.rtp:append(plugin.dir)
  end

  package.preload["lazyvim.plugins.lsp.format"] = function()
    Util.deprecate([[require("lazyvim.plugins.lsp.format")]], [[require("lazyvim.util").format]])
    return Util.format
  end

  -- delay notifications till vim.notify was replaced or after 500ms
  require("lazyvim.util").lazy_notify()

  -- load options here, before lazy init while sourcing plugin modules
  -- this is needed to make sure options will be correctly applied
  -- after installing missing plugins
  M.load("options")

  Util.plugin.setup()
  M.json.load()
end
```
### 初始化M.init()
只初始化一次
```c
M.did_init = false
function M.init()
  if M.did_init then
    return
  end
  M.did_init = true
end
```
插件这个加载目录逻辑，经过测试为`nil`
```c
  local plugin = require("lazy.core.config").spec.plugins.LazyVim
  if plugin then
    vim.opt.rtp:append(plugin.dir)
  end
```
添加`format`模块
```c
  package.preload["lazyvim.plugins.lsp.format"] = function()
    Util.deprecate([[require("lazyvim.plugins.lsp.format")]], [[require("lazyvim.util").format]])
    return Util.format
  end
```
延迟通知
```c
-- delay notifications till vim.notify was replaced or after 500ms
  require("lazyvim.util").lazy_notify()
```
加载选项
- 在获取插件模块时在惰性初始化之前加载选项
- 这是为了确保正确应用选项所必需的
- 安装缺少的插件后
```c
-- load options here, before lazy init while sourcing plugin modules
-- this is needed to make sure options will be correctly applied
-- after installing missing plugins
M.load("options")
```
工具类，插件设定setup()
```c
Util.plugin.setup()
```
加载`json`
```c
M.json.load()
```
`nvim/lazyvim.json`
```json
{
  "extras": [

  ],
  "news": {
    "NEWS.md": "2123"
  },
  "version": 2
}
```
## `nvim/lua/lazyvim/config/options.lua`
选项配置
```c
-- This file is automatically loaded by plugins.core
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Enable LazyVim auto format
vim.g.autoformat = true

-- LazyVim root dir detection
-- Each entry can be:
-- * the name of a detector function like `lsp` or `cwd`
-- * a pattern or array of patterns like `.git` or `lua`.
-- * a function with signature `function(buf) -> string|string[]`
vim.g.root_spec = { "lsp", { ".git", "lua" }, "cwd" }

local opt = vim.opt

opt.autowrite = true -- Enable auto write
opt.clipboard = "unnamedplus" -- Sync with system clipboard
opt.completeopt = "menu,menuone,noselect"
opt.conceallevel = 3 -- Hide * markup for bold and italic
opt.confirm = true -- Confirm to save changes before exiting modified buffer
opt.cursorline = true -- Enable highlighting of the current line
opt.expandtab = true -- Use spaces instead of tabs
opt.formatoptions = "jcroqlnt" -- tcqj
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.ignorecase = true -- Ignore case
opt.inccommand = "nosplit" -- preview incremental substitute
opt.laststatus = 3 -- global statusline
opt.list = true -- Show some invisible characters (tabs...
opt.mouse = "a" -- Enable mouse mode
opt.number = true -- Print line number
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.relativenumber = true -- Relative line numbers
opt.scrolloff = 4 -- Lines of context
opt.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
opt.shiftround = true -- Round indent
opt.shiftwidth = 2 -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.showmode = false -- Dont show mode since we have a statusline
opt.sidescrolloff = 8 -- Columns of context
opt.signcolumn = "yes" -- Always show the signcolumn, otherwise it would shift the text each time
opt.smartcase = true -- Don't ignore case with capitals
opt.smartindent = true -- Insert indents automatically
opt.spelllang = { "en" }
opt.splitbelow = true -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true -- Put new windows right of current
opt.tabstop = 2 -- Number of spaces tabs count for
opt.termguicolors = true -- True color support
opt.timeoutlen = 300
opt.undofile = true
opt.undolevels = 10000
opt.updatetime = 200 -- Save swap file and trigger CursorHold
opt.virtualedit = "block" -- Allow cursor to move where there is no text in visual block mode
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.winminwidth = 5 -- Minimum window width
opt.wrap = false -- Disable line wrap
opt.fillchars = {
  foldopen = "",
  foldclose = "",
  -- fold = "⸱",
  fold = " ",
  foldsep = " ",
  diff = "╱",
  eob = " ",
}

if vim.fn.has("nvim-0.10") == 1 then
  opt.smoothscroll = true
end

-- Folding
vim.opt.foldlevel = 99
vim.opt.foldtext = "v:lua.require'lazyvim.util'.ui.foldtext()"

if vim.fn.has("nvim-0.9.0") == 1 then
  vim.opt.statuscolumn = [[%!v:lua.require'lazyvim.util'.ui.statuscolumn()]]
end

-- HACK: causes freezes on <= 0.9, so only enable on >= 0.10 for now
if vim.fn.has("nvim-0.10") == 1 then
  vim.opt.foldmethod = "expr"
  vim.opt.foldexpr = "v:lua.require'lazyvim.util'.ui.foldexpr()"
else
  vim.opt.foldmethod = "indent"
end

vim.o.formatexpr = "v:lua.require'lazyvim.util'.format.formatexpr()"

-- Fix markdown indentation settings
vim.g.markdown_recommended_style = 0
```

## `nvim/lua/lazyvim/util/plugin.lua`

```c
local Plugin = require("lazy.core.plugin")
local Util = require("lazyvim.util")

---@class lazyvim.util.plugin
local M = {}

M.use_lazy_file = true
M.lazy_file_events = { "BufReadPost", "BufNewFile", "BufWritePre" }

---@type table<string, string>
M.deprecated_extras = {
  ["lazyvim.plugins.extras.formatting.conform"] = "`conform.nvim` is now the default **LazyVim** formatter.",
  ["lazyvim.plugins.extras.linting.nvim-lint"] = "`nvim-lint` is now the default **LazyVim** linter.",
  ["lazyvim.plugins.extras.ui.dashboard"] = "`dashboard.nvim` is now the default **LazyVim** starter.",
}

M.deprecated_modules = {
  ["null-ls"] = "lsp.none-ls",
  ["nvim-navic.lib"] = "editor.navic",
  ["nvim-navic"] = "editor.navic",
}

---@type table<string, string>
M.renames = {
  ["windwp/nvim-spectre"] = "nvim-pack/nvim-spectre",
  ["jose-elias-alvarez/null-ls.nvim"] = "nvimtools/none-ls.nvim",
  ["null-ls.nvim"] = "none-ls.nvim",
  ["romgrk/nvim-treesitter-context"] = "nvim-treesitter/nvim-treesitter-context",
  ["glepnir/dashboard-nvim"] = "nvimdev/dashboard-nvim",
}

function M.setup()
  M.fix_imports()
  M.fix_renames()
  M.lazy_file()
  table.insert(package.loaders, function(module)
    if M.deprecated_modules[module] then
      Util.warn(
        ("`%s` is no longer included by default in **LazyVim**.\nPlease install the `%s` extra if you still want to use it."):format(
          module,
          M.deprecated_modules[module]
        ),
        { title = "LazyVim" }
      )
      return function() end
    end
  end)
end

function M.extra_idx(name)
  local Config = require("lazy.core.config")
  for i, extra in ipairs(Config.spec.modules) do
    if extra == "lazyvim.plugins.extras." .. name then
      return i
    end
  end
end

-- Properly load file based plugins without blocking the UI
function M.lazy_file()
  M.use_lazy_file = M.use_lazy_file and vim.fn.argc(-1) > 0

  -- Add support for the LazyFile event
  local Event = require("lazy.core.handler.event")

  if M.use_lazy_file then
    -- We'll handle delayed execution of events ourselves
    Event.mappings.LazyFile = { id = "LazyFile", event = "User", pattern = "LazyFile" }
    Event.mappings["User LazyFile"] = Event.mappings.LazyFile
  else
    -- Don't delay execution of LazyFile events, but let lazy know about the mapping
    Event.mappings.LazyFile = { id = "LazyFile", event = { "BufReadPost", "BufNewFile", "BufWritePre" } }
    Event.mappings["User LazyFile"] = Event.mappings.LazyFile
    return
  end

  local events = {} ---@type {event: string, buf: number, data?: any}[]

  local done = false
  local function load()
    if #events == 0 or done then
      return
    end
    done = true
    vim.api.nvim_del_augroup_by_name("lazy_file")

    ---@type table<string,string[]>
    local skips = {}
    for _, event in ipairs(events) do
      skips[event.event] = skips[event.event] or Event.get_augroups(event.event)
    end

    vim.api.nvim_exec_autocmds("User", { pattern = "LazyFile", modeline = false })
    for _, event in ipairs(events) do
      if vim.api.nvim_buf_is_valid(event.buf) then
        Event.trigger({
          event = event.event,
          exclude = skips[event.event],
          data = event.data,
          buf = event.buf,
        })
        if vim.bo[event.buf].filetype then
          Event.trigger({
            event = "FileType",
            buf = event.buf,
          })
        end
      end
    end
    vim.api.nvim_exec_autocmds("CursorMoved", { modeline = false })
    events = {}
  end

  -- schedule wrap so that nested autocmds are executed
  -- and the UI can continue rendering without blocking
  load = vim.schedule_wrap(load)

  vim.api.nvim_create_autocmd(M.lazy_file_events, {
    group = vim.api.nvim_create_augroup("lazy_file", { clear = true }),
    callback = function(event)
      table.insert(events, event)
      load()
    end,
  })
end

function M.fix_imports()
  Plugin.Spec.import = Util.inject.args(Plugin.Spec.import, function(_, spec)
    local dep = M.deprecated_extras[spec and spec.import]
    if dep then
      dep = dep .. "\n" .. "Please remove the extra to hide this warning."
      Util.warn(dep, { title = "LazyVim", once = true, stacktrace = true, stacklevel = 6 })
      return false
    end
  end)
end

function M.fix_renames()
  Plugin.Spec.add = Util.inject.args(Plugin.Spec.add, function(self, plugin)
    if type(plugin) == "table" then
      if M.renames[plugin[1]] then
        Util.warn(
          ("Plugin `%s` was renamed to `%s`.\nPlease update your config for `%s`"):format(
            plugin[1],
            M.renames[plugin[1]],
            self.importing or "LazyVim"
          ),
          { title = "LazyVim" }
        )
        plugin[1] = M.renames[plugin[1]]
      end
    end
  end)
end

return M
```

## `nvim/lua/lazyvim/util/ui.lua`
```c
---@class lazyvim.util.ui
local M = {}

---@alias Sign {name:string, text:string, texthl:string, priority:number}

-- Returns a list of regular and extmark signs sorted by priority (low to high)
---@return Sign[]
---@param buf number
---@param lnum number
function M.get_signs(buf, lnum)
  -- Get regular signs
  ---@type Sign[]
  local signs = vim.tbl_map(function(sign)
    ---@type Sign
    local ret = vim.fn.sign_getdefined(sign.name)[1]
    ret.priority = sign.priority
    return ret
  end, vim.fn.sign_getplaced(buf, { group = "*", lnum = lnum })[1].signs)

  -- Get extmark signs
  local extmarks = vim.api.nvim_buf_get_extmarks(
    buf,
    -1,
    { lnum - 1, 0 },
    { lnum - 1, -1 },
    { details = true, type = "sign" }
  )
  for _, extmark in pairs(extmarks) do
    signs[#signs + 1] = {
      name = extmark[4].sign_hl_group or "",
      text = extmark[4].sign_text,
      texthl = extmark[4].sign_hl_group,
      priority = extmark[4].priority,
    }
  end

  -- Sort by priority
  table.sort(signs, function(a, b)
    return (a.priority or 0) < (b.priority or 0)
  end)

  return signs
end

---@return Sign?
---@param buf number
---@param lnum number
function M.get_mark(buf, lnum)
  local marks = vim.fn.getmarklist(buf)
  vim.list_extend(marks, vim.fn.getmarklist())
  for _, mark in ipairs(marks) do
    if mark.pos[1] == buf and mark.pos[2] == lnum and mark.mark:match("[a-zA-Z]") then
      return { text = mark.mark:sub(2), texthl = "DiagnosticHint" }
    end
  end
end

---@param sign? Sign
---@param len? number
function M.icon(sign, len)
  sign = sign or {}
  len = len or 2
  local text = vim.fn.strcharpart(sign.text or "", 0, len) ---@type string
  text = text .. string.rep(" ", len - vim.fn.strchars(text))
  return sign.texthl and ("%#" .. sign.texthl .. "#" .. text .. "%*") or text
end

function M.foldtext()
  local ok = pcall(vim.treesitter.get_parser, vim.api.nvim_get_current_buf())
  local ret = ok and vim.treesitter.foldtext and vim.treesitter.foldtext()
  if not ret or type(ret) == "string" then
    ret = { { vim.api.nvim_buf_get_lines(0, vim.v.lnum - 1, vim.v.lnum, false)[1], {} } }
  end
  table.insert(ret, { " " .. require("lazyvim.config").icons.misc.dots })

  if not vim.treesitter.foldtext then
    return table.concat(
      vim.tbl_map(function(line)
        return line[1]
      end, ret),
      " "
    )
  end
  return ret
end

function M.statuscolumn()
  local win = vim.g.statusline_winid
  local buf = vim.api.nvim_win_get_buf(win)
  local is_file = vim.bo[buf].buftype == ""
  local show_signs = vim.wo[win].signcolumn ~= "no"

  local components = { "", "", "" } -- left, middle, right

  if show_signs then
    ---@type Sign?,Sign?,Sign?
    local left, right, fold
    for _, s in ipairs(M.get_signs(buf, vim.v.lnum)) do
      if s.name and s.name:find("GitSign") then
        right = s
      else
        left = s
      end
    end
    if vim.v.virtnum ~= 0 then
      left = nil
    end
    vim.api.nvim_win_call(win, function()
      if vim.fn.foldclosed(vim.v.lnum) >= 0 then
        fold = { text = vim.opt.fillchars:get().foldclose or "", texthl = "Folded" }
      end
    end)
    -- Left: mark or non-git sign
    components[1] = M.icon(M.get_mark(buf, vim.v.lnum) or left)
    -- Right: fold icon or git sign (only if file)
    components[3] = is_file and M.icon(fold or right) or ""
  end

  -- Numbers in Neovim are weird
  -- They show when either number or relativenumber is true
  local is_num = vim.wo[win].number
  local is_relnum = vim.wo[win].relativenumber
  if (is_num or is_relnum) and vim.v.virtnum == 0 then
    if vim.v.relnum == 0 then
      components[2] = is_num and "%l" or "%r" -- the current line
    else
      components[2] = is_relnum and "%r" or "%l" -- other lines
    end
    components[2] = "%=" .. components[2] .. " " -- right align
  end

  return table.concat(components, "")
end

function M.fg(name)
  ---@type {foreground?:number}?
  ---@diagnostic disable-next-line: deprecated
  local hl = vim.api.nvim_get_hl and vim.api.nvim_get_hl(0, { name = name }) or vim.api.nvim_get_hl_by_name(name, true)
  ---@diagnostic disable-next-line: undefined-field
  local fg = hl and (hl.fg or hl.foreground)
  return fg and { fg = string.format("#%06x", fg) } or nil
end

M.skip_foldexpr = {} ---@type table<number,boolean>
local skip_check = assert(vim.loop.new_check())

function M.foldexpr()
  local buf = vim.api.nvim_get_current_buf()

  -- still in the same tick and no parser
  if M.skip_foldexpr[buf] then
    return "0"
  end

  -- don't use treesitter folds for non-file buffers
  if vim.bo[buf].buftype ~= "" then
    return "0"
  end

  -- as long as we don't have a filetype, don't bother
  -- checking if treesitter is available (it won't)
  if vim.bo[buf].filetype == "" then
    return "0"
  end

  local ok = pcall(vim.treesitter.get_parser, buf)

  if ok then
    return vim.treesitter.foldexpr()
  end

  -- no parser available, so mark it as skip
  -- in the next tick, all skip marks will be reset
  M.skip_foldexpr[buf] = true
  skip_check:start(function()
    M.skip_foldexpr = {}
    skip_check:stop()
  end)
  return "0"
end

return M
```

# v6
引入一些插件
## 颜色主题colorscheme.lua
`nvim/lua/lazyvim/plgins/colorscheme.lua`

```c
return {

  -- tokyonight
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = { style = "moon" },
  },

  -- catppuccin
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    opts = {
      integrations = {
        aerial = true,
        alpha = true,
        cmp = true,
        dashboard = true,
        flash = true,
        gitsigns = true,
        headlines = true,
        illuminate = true,
        indent_blankline = { enabled = true },
        leap = true,
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        navic = { enabled = true, custom_bg = "lualine" },
        neotest = true,
        neotree = true,
        noice = true,
        notify = true,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
    },
  },
}
```

安装完成发现，并没有显示新的主题。
跟踪发现，是`config/init.lua`的`M.setup()`没有完善。
继续完善[[lazy_to_lazyvim#M.setup()]]

## keymaps.lua
`nvim/lua/lazyvim/config/keymaps.lua`

```c
-- This file is automatically loaded by lazyvim.config.init
local Util = require("lazyvim.util")

-- DO NOT USE THIS IN YOU OWN CONFIG!!
-- use `vim.keymap.set` instead
local map = Util.safe_keymap_set

-- better up/down
map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
map("n", "<C-h>", "<C-w>h", { desc = "Go to left window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to lower window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to upper window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to right window", remap = true })

-- Resize window using <ctrl> arrow keys
map("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
map("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- Move Lines
map("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
map("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
map("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
map("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
map("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
map("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- buffers
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<cr>", { desc = "Prev buffer" })
map("n", "]b", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>bb", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<cr>", { desc = "Switch to Other Buffer" })

-- Clear search with <esc>
map({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

-- Clear search, diff update and redraw
-- taken from runtime/lua/_editor.lua
map(
  "n",
  "<leader>ur",
  "<Cmd>nohlsearch<Bar>diffupdate<Bar>normal! <C-L><CR>",
  { desc = "Redraw / clear hlsearch / diff update" }
)

-- https://github.com/mhinz/vim-galore#saner-behavior-of-n-and-n
map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next search result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next search result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev search result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev search result" })

-- Add undo break-points
map("i", ",", ",<c-g>u")
map("i", ".", ".<c-g>u")
map("i", ";", ";<c-g>u")

-- save file
map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

--keywordprg
map("n", "<leader>K", "<cmd>norm! K<cr>", { desc = "Keywordprg" })

-- better indenting
map("v", "<", "<gv")
map("v", ">", ">gv")

-- lazy
map("n", "<leader>l", "<cmd>Lazy<cr>", { desc = "Lazy" })

-- new file
map("n", "<leader>fn", "<cmd>enew<cr>", { desc = "New File" })

map("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
map("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })

map("n", "[q", vim.cmd.cprev, { desc = "Previous quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next quickfix" })

-- formatting
map({ "n", "v" }, "<leader>cf", function()
  Util.format({ force = true })
end, { desc = "Format" })

-- diagnostic
local diagnostic_goto = function(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  severity = severity and vim.diagnostic.severity[severity] or nil
  return function()
    go({ severity = severity })
  end
end
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_goto(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_goto(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_goto(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_goto(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_goto(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_goto(false, "WARN"), { desc = "Prev Warning" })

-- stylua: ignore start

-- toggle options
map("n", "<leader>uf", function() Util.format.toggle() end, { desc = "Toggle auto format (global)" })
map("n", "<leader>uF", function() Util.format.toggle(true) end, { desc = "Toggle auto format (buffer)" })
map("n", "<leader>us", function() Util.toggle("spell") end, { desc = "Toggle Spelling" })
map("n", "<leader>uw", function() Util.toggle("wrap") end, { desc = "Toggle Word Wrap" })
map("n", "<leader>uL", function() Util.toggle("relativenumber") end, { desc = "Toggle Relative Line Numbers" })
map("n", "<leader>ul", function() Util.toggle.number() end, { desc = "Toggle Line Numbers" })
map("n", "<leader>ud", function() Util.toggle.diagnostics() end, { desc = "Toggle Diagnostics" })
local conceallevel = vim.o.conceallevel > 0 and vim.o.conceallevel or 3
map("n", "<leader>uc", function() Util.toggle("conceallevel", false, {0, conceallevel}) end, { desc = "Toggle Conceal" })
if vim.lsp.inlay_hint then
  map("n", "<leader>uh", function() vim.lsp.inlay_hint(0, nil) end, { desc = "Toggle Inlay Hints" })
end
map("n", "<leader>uT", function() if vim.b.ts_highlight then vim.treesitter.stop() else vim.treesitter.start() end end, { desc = "Toggle Treesitter Highlight" })

-- lazygit
map("n", "<leader>gg", function() Util.terminal({ "lazygit" }, { cwd = Util.root(), esc_esc = false, ctrl_hjkl = false }) end, { desc = "Lazygit (root dir)" })
map("n", "<leader>gG", function() Util.terminal({ "lazygit" }, {esc_esc = false, ctrl_hjkl = false}) end, { desc = "Lazygit (cwd)" })

-- quit
map("n", "<leader>qq", "<cmd>qa<cr>", { desc = "Quit all" })

-- highlights under cursor
map("n", "<leader>ui", vim.show_pos, { desc = "Inspect Pos" })

-- LazyVim Changelog
map("n", "<leader>L", function() Util.news.changelog() end, { desc = "LazyVim Changelog" })

-- floating terminal
local lazyterm = function() Util.terminal(nil, { cwd = Util.root() }) end
map("n", "<leader>ft", lazyterm, { desc = "Terminal (root dir)" })
map("n", "<leader>fT", function() Util.terminal() end, { desc = "Terminal (cwd)" })
map("n", "<c-/>", lazyterm, { desc = "Terminal (root dir)" })
map("n", "<c-_>", lazyterm, { desc = "which_key_ignore" })

-- Terminal Mappings
map("t", "<esc><esc>", "<c-\\><c-n>", { desc = "Enter Normal Mode" })
map("t", "<C-h>", "<cmd>wincmd h<cr>", { desc = "Go to left window" })
map("t", "<C-j>", "<cmd>wincmd j<cr>", { desc = "Go to lower window" })
map("t", "<C-k>", "<cmd>wincmd k<cr>", { desc = "Go to upper window" })
map("t", "<C-l>", "<cmd>wincmd l<cr>", { desc = "Go to right window" })
map("t", "<C-/>", "<cmd>close<cr>", { desc = "Hide Terminal" })
map("t", "<c-_>", "<cmd>close<cr>", { desc = "which_key_ignore" })

-- windows
map("n", "<leader>ww", "<C-W>p", { desc = "Other window", remap = true })
map("n", "<leader>wd", "<C-W>c", { desc = "Delete window", remap = true })
map("n", "<leader>w-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>w|", "<C-W>v", { desc = "Split window right", remap = true })
map("n", "<leader>-", "<C-W>s", { desc = "Split window below", remap = true })
map("n", "<leader>|", "<C-W>v", { desc = "Split window right", remap = true })

-- tabs
map("n", "<leader><tab>l", "<cmd>tablast<cr>", { desc = "Last Tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<cr>", { desc = "First Tab" })
map("n", "<leader><tab><tab>", "<cmd>tabnew<cr>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<cr>", { desc = "Next Tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<cr>", { desc = "Close Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<cr>", { desc = "Previous Tab" })
```


## news.lua
`nvim/lua/lazyvim/util/news.lua`

```c
local Config = require("lazyvim.config")
local Util = require("lazyvim.util")

---@class lazyvim.util.news
local M = {}

function M.hash(file)
  local stat = vim.loop.fs_stat(file)
  if not stat then
    return
  end
  return stat.size .. ""
end

function M.setup()
  vim.schedule(function()
    if Config.news.lazyvim then
      if not Config.json.data.news["NEWS.md"] then
        M.welcome()
      end
      M.lazyvim(true)
    end
    if Config.news.neovim then
      M.neovim(true)
    end
  end)
end

function M.welcome()
  Util.info("Welcome to LazyVim!")
end

function M.changelog()
  M.open("CHANGELOG.md", { plugin = "LazyVim" })
end

function M.lazyvim(when_changed)
  M.open("NEWS.md", { plugin = "LazyVim", when_changed = when_changed })
end

function M.neovim(when_changed)
  M.open("doc/news.txt", { rtp = true, when_changed = when_changed })
end

---@param file string
---@param opts? {plugin?:string, rtp?:boolean, when_changed?:boolean}
function M.open(file, opts)
  local ref = file
  opts = opts or {}
  if opts.plugin then
    local plugin = require("lazy.core.config").plugins[opts.plugin] --[[@as LazyPlugin?]]
    if not plugin then
      return Util.error("plugin not found: " .. opts.plugin)
    end
    file = plugin.dir .. "/" .. file
  elseif opts.rtp then
    file = vim.api.nvim_get_runtime_file(file, false)[1]
  end

  if not file then
    return Util.error("File not found")
  end

  if opts.when_changed then
    local is_new = not Config.json.data.news[ref]
    local hash = M.hash(file)
    if hash == Config.json.data.news[ref] then
      return
    end
    Config.json.data.news[ref] = hash
    Util.json.save()
    -- don't open if file has never been opened
    if is_new then
      return
    end
  end

  local float = require("lazy.util").float({
    file = file,
    size = { width = 0.6, height = 0.6 },
  })
  vim.opt_local.spell = false
  vim.opt_local.wrap = false
  vim.opt_local.signcolumn = "yes"
  vim.opt_local.statuscolumn = " "
  vim.opt_local.conceallevel = 3
  vim.diagnostic.disable(float.buf)
end

return M
```


## json.lua
`nvim/lua/lazyvim/util/json.lua`

```c
local Config = require("lazyvim.config")
local Util = require("lazyvim.util")

---@class lazyvim.util.json
local M = {}

---@param value any
---@param indent string
local function encode(value, indent)
  local t = type(value)

  if t == "string" then
    return string.format("%q", value)
  elseif t == "number" or t == "boolean" then
    return tostring(value)
  elseif t == "table" then
    local is_list = Util.is_list(value)
    local parts = {}
    local next_indent = indent .. "  "

    if is_list then
      ---@diagnostic disable-next-line: no-unknown
      for _, v in ipairs(value) do
        local e = encode(v, next_indent)
        if e then
          table.insert(parts, next_indent .. e)
        end
      end
      return "[\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "]"
    else
      local keys = vim.tbl_keys(value)
      table.sort(keys)
      ---@diagnostic disable-next-line: no-unknown
      for _, k in ipairs(keys) do
        local e = encode(value[k], next_indent)
        if e then
          table.insert(parts, next_indent .. string.format("%q", k) .. ": " .. e)
        end
      end
      return "{\n" .. table.concat(parts, ",\n") .. "\n" .. indent .. "}"
    end
  end
end

function M.encode(value)
  return encode(value, "")
end

function M.save()
  Config.json.data.version = Config.json.version
  local path = vim.fn.stdpath("config") .. "/lazyvim.json"
  local f = io.open(path, "w")
  if f then
    f:write(Util.json.encode(Config.json.data))
    f:close()
  end
end

function M.migrate()
  Util.info("Migrating `lazyvim.json` to version `" .. Config.json.version .. "`")
  local json = Config.json

  -- v0
  if not json.data.version then
    if json.data.hashes then
      ---@diagnostic disable-next-line: no-unknown
      json.data.hashes = nil
    end
    json.data.extras = vim.tbl_map(function(extra)
      return "lazyvim.plugins.extras." .. extra
    end, json.data.extras or {})
  elseif json.data.version == 1 then
    json.data.extras = vim.tbl_map(function(extra)
      -- replace double extras module name
      return extra:gsub("^lazyvim%.plugins%.extras%.lazyvim%.plugins%.extras%.", "lazyvim.plugins.extras.")
    end, json.data.extras or {})
  end

  M.save()
end

return M
```

