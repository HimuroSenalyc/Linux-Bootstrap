-- ==========================================
-- 0. 极简插件管理器 (mini.deps)
-- ==========================================
-- 强制 Neovim 使用 Wayland 系统的剪贴板工具
-- 彻底不要用 vim.opt.clipboard = "unnamedplus"，这玩意儿在 Konsole 下会抽风
-- 直接映射键盘，通过系统管道直接调用 wl-copy 和 wl-paste
-- 开启半透明，融入你的 KDE 桌面
vim.g.neovide_opacity = 0.85
-- 字体稍微放大一点
vim.o.guifont = "JetBrains Mono:h14"
-- 开启光标平滑动画
vim.g.neovide_cursor_animation_length = 0.08
-- 普通模式和可视模式下：
-- 按 y 复制到系统剪贴板
vim.keymap.set({"n", "v"}, "y", '"+y', { noremap = true })
-- 按 p 从系统剪贴板粘贴
vim.keymap.set({"n", "v"}, "p", '"+p', { noremap = true })

-- 暴力拦截：可视模式下按 Ctrl+C，直接调用 shell 命令
vim.keymap.set("v", "<C-c>", 'y:call system("wl-copy", @")<CR>', { silent = true })

-- 暴力拦截：普通模式下按 Ctrl+V，直接从系统剪贴板粘贴
vim.keymap.set("n", "<C-v>", ':call system("wl-paste -n")<CR>', { silent = true })
local MiniDeps = require('mini.deps')
MiniDeps.setup()
local add = MiniDeps.add

-- 1. 极简状态栏
add('nvim-lualine/lualine.nvim')
require('lualine').setup({
  options = { theme = 'auto', section_separators = '', component_separators = '' }
})

-- 2. 语法高亮增强 (Treesitter)
add({ source = 'nvim-treesitter/nvim-treesitter', checkout = 'master' })
require("nvim-treesitter.install").prefer_git = true
require('nvim-treesitter.configs').setup({
  ensure_installed = { "c", "cpp", "lua", "vim", "bash" },
  highlight = { enable = true },
})

-- 3. 文件树 (极轻量)
add('nvim-tree/nvim-tree.lua')
require('nvim-tree').setup()
-- 按 Ctrl+n 开关文件树
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { silent = true })

-- 4. 极速搜索 (Telescope)
-- 先装 Telescope 的底层依赖
add('nvim-lua/plenary.nvim')
-- 然后再装 Telescope
add('nvim-telescope/telescope.nvim')
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, {}) -- 搜索文件
vim.keymap.set('n', '<C-f>', builtin.live_grep, {})  -- 搜索内容

-- ==========================================
-- 基础极客设置
-- ==========================================
vim.opt.number = true           -- 绝对行号
vim.opt.relativenumber = true   -- 相对行号 (邪门指法最爱)
vim.opt.tabstop = 4             -- Tab 宽度
vim.opt.shiftwidth = 4          -- 缩进宽度
vim.opt.expandtab = true        -- Tab 转空格
vim.opt.termguicolors = true    -- 开启真彩色
vim.opt.mouse = "a"             -- 允许鼠标操作
vim.opt.completeopt = { "menuone", "noselect" }

-- ==========================================
-- 原生 LSP 配置 (clangd) & 手动补全
-- ==========================================
--vim.lsp.config('clangd', {
--  cmd = { 'clangd' },
--  filetypes = { 'c', 'cpp' },
--  root_markers = { 'compile_commands.json', 'compile_flags.txt', '.git' },
--})
--vim.lsp.enable('clangd')

--vim.api.nvim_create_autocmd('LspAttach', {
--  callback = function(args)
--    local opts = { buffer = args.buf }
--    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts) -- gd: 跳转定义
--    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)       -- K: 查看文档

    -- 极客手感：按 Ctrl+n 召唤补全（避开输入法的 Ctrl+Space）
--    vim.keymap.set('i', '<C-n>', vim.lsp.buf.completion, opts)
--  end,
--})

-- 万能的 Tab 键：没补全时正常缩进，有补全时直接吃进去
vim.keymap.set('i', '<Tab>', function()
  if vim.fn.pumvisible() == 0 then 
    return vim.api.nvim_replace_termcodes('<Tab>', true, false, true) 
  end
  return vim.api.nvim_replace_termcodes('<C-n>', true, false, true)
end, { expr = true })

-- ==========================================
-- 信奥神器：F5 一键编译并运行 C++
-- ==========================================
vim.keymap.set('n', '<F5>', function()
  vim.cmd("w") -- 先保存
  local filename = vim.fn.expand("%:t") -- 获取当前文件名
  local outname = vim.fn.expand("%:r") -- 获取不带后缀的文件名
  -- 在底部开启一个终端，执行 g++ 编译和运行 (开启O2优化并显示所有警告)
  vim.cmd("belowright 12split | terminal g++ " .. filename .. " -o " .. outname .. " -O2 -Wall && ./" .. outname)
  -- 自动进入插入模式，方便你输入测试数据
  vim.cmd("startinsert")
end, { desc = "编译并运行 C++ 代码" })
-- ==========================================
-- 基础括号联携 (原生手搓)
-- ==========================================
local pairs_map = {
    ['('] = ')',
    ['['] = ']',
    ['{'] = '}',
    ['"'] = '"',
    ["'"] = "'",
}

-- 插入模式下按左括号，自动补全右括号，并把光标放在中间
vim.keymap.set('i', '(', '()<Left>', { noremap = true, silent = true })
vim.keymap.set('i', '[', '[]<Left>', { noremap = true, silent = true })
vim.keymap.set('i', '{', '{}<Left>', { noremap = true, silent = true })
vim.keymap.set('i', '"', '""<Left>', { noremap = true, silent = true })
vim.keymap.set('i', "'", "''<Left>", { noremap = true, silent = true })

-- 优雅地跳过右括号：如果光标后面已经是右括号，直接按右括号键就跳过，不再重复输入
vim.keymap.set('i', ')', function()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    if line:sub(col + 1, col + 1) == ')' then
        return '<Right>'
    else
        return ')'
    end
end, { expr = true, replace_keycodes = false })

-- 同理处理 ] 和 }
vim.keymap.set('i', ']', function()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    if line:sub(col + 1, col + 1) == ']' then return '<Right>' else return ']' end
end, { expr = true, replace_keycodes = false })

vim.keymap.set('i', '}', function()
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    if line:sub(col + 1, col + 1) == '}' then return '<Right>' else return '}' end
end, { expr = true, replace_keycodes = false })
vim.lsp.config('cmake', {
  cmd = { 'cmake-language-server' },
  filetypes = { 'cmake' },
  root_markers = { 'CMakeLists.txt', '.git' },
})
vim.lsp.enable('cmake')
-- ==========================================
-- 极简 CMake 模板生成器
-- ==========================================
vim.keymap.set('n', '<F6>', function()
  local filename = "CMakeLists.txt"
  -- 检查当前目录是否存在
  if vim.fn.filereadable(filename) == 1 then
    vim.notify("CMakeLists.txt 已经存在啦！", vim.log.levels.WARN)
    return
  end

  -- 获取当前目录名作为项目名
  local cwd = vim.fn.getcwd()
  local proj_name = vim.fn.fnamemodify(cwd, ":t")

  -- 极简 C++ 模板
  local template = {
    "cmake_minimum_required(VERSION 3.10)",
    "project(" .. proj_name .. " LANGUAGES CXX)",
    "",
    "set(CMAKE_CXX_STANDARD 17)",
    "set(CMAKE_CXX_STANDARD_REQUIRED ON)",
    "set(CMAKE_EXPORT_COMPILE_COMMANDS ON)",
    "",
    "# 自动收集当前目录下的所有 .cpp 文件",
    "file(GLOB_RECURSE SOURCES \"*.cpp\")",
    "add_executable(${PROJECT_NAME} ${SOURCES})",
  }

  -- 写入文件
  vim.fn.writefile(template, filename)
  vim.cmd("edit " .. filename)
  vim.notify("CMakeLists.txt 模板已生成！", vim.log.levels.INFO)
end, { desc = "生成极简 CMakeLists.txt" })

-- ==========================================
-- 极客版：Ctrl+n 常驻补全模式
-- ==========================================
local completion_mode = false

-- 1. 设置一个状态切换快捷键
vim.keymap.set('i', '<C-n>', function()
  completion_mode = not completion_mode
  if completion_mode then
    -- 开启补全模式，并且立刻弹一次菜单
    vim.lsp.buf.completion()
    vim.notify("补全模式: 开启", vim.log.levels.INFO)
  else
    -- 关闭补全模式，并且收起菜单
    vim.notify("补全模式: 关闭", vim.log.levels.INFO)
    -- 如果菜单开着，按 <C-e> 可以关掉
    if vim.fn.pumvisible() == 1 then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-e>', true, false, true), 'n', false)
    end
  end
end, { desc = "切换常驻补全模式" })

-- 2. 核心：只有在开启模式下，打字才自动唤出补全
vim.api.nvim_create_autocmd('TextChangedI', {
  callback = function()
    if completion_mode then
      -- 不要用 vim.lsp.buf.completion()，那会强制全量刷新
      -- 用 <C-n> 触发原生补全，体验最丝滑，且不会打断你打字
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, false, true), 'n', false)
    end
  end,
})

