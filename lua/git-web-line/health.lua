local git = require('git-web-line.git')

local M = {}

function M.check()
  vim.health.start('git-web-line')

  if vim.fn.has('nvim-0.10') == 1 then
    vim.health.ok('Neovim >= 0.10')
  else
    vim.health.error('Neovim >= 0.10 is required')
  end

  if not git.is_available() then
    vim.health.error(
      '`git` executable not found',
      { 'Install git and make sure it is on your $PATH' }
    )
    return
  end
  vim.health.ok(git.run({ '--version' }) or 'git found')

  local root = git.run({ 'rev-parse', '--show-toplevel' })
  if not root then
    vim.health.info('Current directory is not inside a git repository')
    return
  end
  vim.health.ok('Git repository: ' .. root)

  local remotes = git.remotes()
  if #remotes == 0 then
    vim.health.warn('No git remotes configured', { 'Add one with `git remote add origin <url>`' })
  else
    vim.health.ok('Remotes: ' .. table.concat(remotes, ', '))
  end
end

return M
