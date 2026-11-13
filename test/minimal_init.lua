-- Minimal init for testing
local plenary_dir = os.getenv('PLENARY_DIR')
  or os.getenv('HOME') .. '/.local/share/nvim/site/pack/vendor/start/plenary.nvim'

vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:prepend(plenary_dir)

-- Load the plugin
vim.cmd('runtime plugin/*.vim')
vim.cmd('runtime plugin/*.lua')

require('plenary.busted')
