local config = require('git-web-line.config')
local git = require('git-web-line.git')
local hosts = require('git-web-line.hosts')
local remote = require('git-web-line.remote')

local M = {}

local DEFAULT_REMOTE = 'origin'

local function notify_error(msg)
  vim.notify('git-web-line: ' .. msg, vim.log.levels.ERROR)
end

function M.setup(opts)
  config.setup(opts)
end

function M.activate(opts)
  opts = opts or {}
  if not git.is_available() then
    notify_error('`git` executable not found in $PATH')
    return
  end

  local buf_path = vim.api.nvim_buf_get_name(0)
  if buf_path == '' or vim.bo.buftype ~= '' then
    notify_error('Current buffer is not a file')
    return
  end
  local cwd = vim.fs.dirname(buf_path)

  local file_path = git.repo_relative_path(buf_path)
  if not file_path then
    notify_error('File is not inside a git repository')
    return
  end

  local remote_name = opts.remote or config.options.remote or DEFAULT_REMOTE
  local git_remote_str = git.remote_url(remote_name, cwd)
  if not git_remote_str then
    notify_error("Failed to get git remote URL. Does the '" .. remote_name .. "' remote exist?")
    return
  end

  local ok, repository = pcall(remote.parse, git_remote_str)
  if not ok then
    notify_error(repository)
    return
  end

  -- On a detached HEAD there is no branch, so link to the commit instead
  local ref = git.branch_name(cwd) or git.head_sha(cwd)
  if not ref then
    notify_error('Failed to determine the current branch or commit')
    return
  end

  local line_number = vim.api.nvim_win_get_cursor(0)[1]
  local url = hosts.build_url(repository, ref, file_path, line_number)

  vim.notify('Opening: ' .. url, vim.log.levels.INFO)
  vim.ui.open(url)
end

return M
