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

![](https://taengsic.com/img/20240518222428_image.png)

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

