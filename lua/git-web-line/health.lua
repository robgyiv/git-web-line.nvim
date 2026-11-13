local M = {}

function M.check()
  vim.health.start('git-web-line')
  if vim.fn.has('nvim-0.10') == 1 then
    vim.health.ok('Neovim >= 0.10')
  else
    vim.health.error('Neovim >= 0.10 is required')
  end
end

return M
