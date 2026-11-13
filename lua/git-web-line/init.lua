local config = require('git-web-line.config')
local git = require('git-web-line.git')
local hosts = require('git-web-line.hosts')
local remote = require('git-web-line.remote')

local M = {}

local DEFAULT_REMOTE = 'origin'

function M.setup(opts)
  config.setup(opts)
end

function M.activate(opts)
  opts = opts or {}
  if not git.is_available() then
    vim.notify('git-web-line: `git` executable not found in $PATH', vim.log.levels.ERROR)
    return
  end

  local remote_name = opts.remote or config.options.remote or DEFAULT_REMOTE

  local git_remote_str = git.remote_url(remote_name)
  if not git_remote_str then
    vim.notify(
      "Failed to get git remote URL. Are you in a git repository with a '"
        .. remote_name
        .. "' remote?",
      vim.log.levels.ERROR
    )
    return
  end

  local branch_name = git.branch_name()
  if not branch_name then
    vim.notify('Failed to get current branch. Are you in a git repository?', vim.log.levels.ERROR)
    return
  end

  local ok, repository = pcall(remote.parse, git_remote_str)
  if not ok then
    vim.notify(repository, vim.log.levels.ERROR)
    return
  end

  local line_number = vim.api.nvim_win_get_cursor(0)[1]
  local file_path = vim.fn.expand('%:~:.')
  local url = hosts.build_url(repository, branch_name, file_path, line_number)

  vim.notify('Opening: ' .. url, vim.log.levels.INFO)
  vim.ui.open(url)
end

return M
