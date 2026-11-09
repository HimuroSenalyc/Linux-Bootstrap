-- ==========================================
-- 0. 极简插件管理器 (mini.deps)
-- ==========================================
-- 强制 Neovim 使用 Wayland 系统的剪贴板工具
-- 彻底不要用 vim.opt.clipboard = "unnamedplus"，这玩意儿在 Konsole 下会抽风

-- 普通模式和可视模式下：按 y 复制到系统剪贴板
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
  ensure_installed = { "c", "cpp", "lua", "vim", "bash", "cmake" },
  highlight = { enable = true },
})

-- 3. 文件树 (极轻量)
add('nvim-tree/nvim-tree.lua')
require('nvim-tree').setup()
-- 按 Ctrl+n 开关文件树
vim.keymap.set('n', '<C-n>', ':NvimTreeToggle<CR>', { silent = true })

-- 4. 极速搜索 (Telescope)
add('nvim-lua/plenary.nvim')
add('nvim-telescope/telescope.nvim')
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, {}) -- 搜索文件
vim.keymap.set('n', '<C-f>', builtin.live_grep, {})  -- 搜索内容

-- ==========================================
-- 基础极客设置
-- ==========================================
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.termguicolors = true
vim.opt.mouse = "a"
vim.opt.completeopt = { "menuone", "noselect" }

-- ==========================================
-- Neovide 专属配置 (如果不用 Neovide 会自动忽略)
-- ==========================================
vim.g.neovide_opacity = 0.85 -- 悬浮透明度
vim.g.neovide_cursor_animation_length = 0.08 -- 光标平滑度
vim.o.guifont = "JetBrains Mono:h14" -- 如果你有 JetBrains Mono 字体的话

-- ==========================================
-- 原生 LSP 配置 (clangd & cmake) & 手动补全
-- ==========================================
vim.lsp.config('clangd', {
  cmd = { 'clangd' },
  filetypes = { 'c', 'cpp' },
  root_markers = { 'compile_commands.json', 'compile_flags.txt', '.git' },
})
vim.lsp.enable('clangd')

vim.lsp.config('cmake', {
  cmd = { 'cmake-language-server' },
  filetypes = { 'cmake' },
  root_markers = { 'CMakeLists.txt', '.git' },
})
vim.lsp.enable('cmake')

-- ==========================================
-- 极客版：Ctrl+n 常驻补全模式 & 原生括号联携
-- ==========================================
local completion_mode = false

-- LSP 挂载后的键位
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
  local opts = { buffer = args.buf }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
  end,
})

-- 切换常驻补全模式
vim.keymap.set('i', '<C-n>', function()
completion_mode = not completion_mode
if completion_mode then
  vim.lsp.buf.completion()
  else
    if vim.fn.pumvisible() == 1 then
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-e>', true, false, true), 'n', false)
      end
      end
      end, { desc = "切换常驻补全模式" })

-- 自动触发补全
vim.api.nvim_create_autocmd('TextChangedI', {
  callback = function()
  if completion_mode then
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<C-n>', true, false, true), 'n', false)
    end
    end,
})

-- 原生括号联携
vim.keymap.set('i', '(', '()<Left>', { noremap = true, silent = true })
vim.keymap.set('i', '[', '[]<Left>', { noremap = true, silent = true })
vim.keymap.set('i', '{', '{}<Left>', { noremap = true, silent = true })
vim.keymap.set('i', '"', '""<Left>', { noremap = true, silent = true })
vim.keymap.set('i', "'", "''<Left>", { noremap = true, silent = true })

-- 优雅跳过右括号
vim.keymap.set('i', ')', function()
local line = vim.api.nvim_get_current_line()
local col = vim.api.nvim_win_get_cursor(0)[2]
if line:sub(col + 1, col + 1) == ')' then return '<Right>' else return ')' end
  end, { expr = true, replace_keycodes = false })

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

-- 万能的 Tab 键
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
vim.cmd("w")
local filename = vim.fn.expand("%:t")
local outname = vim.fn.expand("%:r")
vim.cmd("belowright 12split | terminal g++ " .. filename .. " -o " .. outname .. " -O2 -Wall && ./" .. outname)
vim.cmd("startinsert")
end, { desc = "编译并运行 C++ 代码" })
