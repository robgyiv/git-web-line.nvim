-- Minimal init for testing
vim.opt.runtimepath:prepend(vim.fn.getcwd())
vim.opt.runtimepath:prepend(
  os.getenv('HOME') .. '/.local/share/nvim/site/pack/vendor/start/plenary.nvim'
)

-- Load the plugin
vim.cmd('runtime plugin/*.vim')
vim.cmd('runtime plugin/*.lua')

require('plenary.busted')
