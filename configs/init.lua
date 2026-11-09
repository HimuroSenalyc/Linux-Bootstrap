-- ==========================================
-- 0. 极简插件管理器 (mini.deps)
-- ==========================================
-- 强制 Neovim 使用 Wayland 系统的剪贴板工具
-- 彻底不要用 vim.opt.clipboard = "unnamedplus"，这玩意儿在 Konsole 下会抽风
-- 直接映射键盘，通过系统管道直接调用 wl-copy 和 wl-paste

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
vim.lsp.config('clangd', {
  cmd = { 'clangd' },
  filetypes = { 'c', 'cpp' },
  root_markers = { 'compile_commands.json', 'compile_flags.txt', '.git' },
})
vim.lsp.enable('clangd')

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local opts = { buffer = args.buf }
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts) -- gd: 跳转定义
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)       -- K: 查看文档

    -- 极客手感：按 Ctrl+n 召唤补全（避开输入法的 Ctrl+Space）
    vim.keymap.set('i', '<C-n>', vim.lsp.buf.completion, opts)
  end,
})

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
