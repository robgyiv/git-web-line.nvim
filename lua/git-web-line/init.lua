local config = require('git-web-line.config')
local git = require('git-web-line.git')
local hosts = require('git-web-line.hosts')
local remote = require('git-web-line.remote')
local sync = require('git-web-line.sync')

local M = {}

local DEFAULT_REMOTE = 'origin'

local function notify_error(msg)
  vim.notify('git-web-line: ' .. msg, vim.log.levels.ERROR)
end

-- Pick a remote in order: explicit argument, setup() option, the branch's
-- upstream remote, `origin`, then the first configured remote.
local function resolve_remote(requested, branch, cwd)
  local remotes = git.remotes(cwd)
  if #remotes == 0 then
    return nil, 'No git remotes configured'
  end

  local explicit = requested or config.options.remote
  if explicit then
    if not vim.tbl_contains(remotes, explicit) then
      return nil, "Remote '" .. explicit .. "' does not exist"
    end
    return explicit
  end

  local upstream = git.upstream_remote(branch, cwd)
  if upstream and vim.tbl_contains(remotes, upstream) then
    return upstream
  end
  if vim.tbl_contains(remotes, DEFAULT_REMOTE) then
    return DEFAULT_REMOTE
  end
  return remotes[1]
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

  local branch = git.branch_name(cwd)

  local remote_name, remote_err = resolve_remote(opts.remote, branch, cwd)
  if not remote_name then
    notify_error(remote_err)
    return
  end

  local git_remote_str = git.remote_url(remote_name, cwd)
  if not git_remote_str then
    notify_error("Failed to get URL for remote '" .. remote_name .. "'")
    return
  end

  local ok, repository = pcall(remote.parse, git_remote_str)
  if not ok then
    notify_error(repository)
    return
  end

  -- On a detached HEAD there is no branch, so link to the commit instead
  local ref = branch or git.head_sha(cwd)
  if not ref then
    notify_error('Failed to determine the current branch or commit')
    return
  end

  local status = sync.check({
    cwd = cwd,
    root = git.repo_root(cwd),
    remote = remote_name,
    branch = branch,
    file_path = file_path,
    modified = vim.bo.modified,
  })
  if #status.problems > 0 then
    local summary = table.concat(status.problems, '; ')
    local mode = config.options.on_unpushed
    if mode == 'abort' then
      notify_error(summary)
      return
    elseif mode == 'permalink' then
      if not status.pushed_sha then
        notify_error(summary .. '; no pushed commit to link to')
        return
      end
      if not sync.file_exists(status.pushed_sha, file_path, cwd) then
        notify_error(summary .. '; file does not exist in the newest pushed commit')
        return
      end
      ref = status.pushed_sha
      vim.notify(
        'git-web-line: ' .. summary .. '; linking to pushed commit ' .. ref:sub(1, 7),
        vim.log.levels.WARN
      )
    else
      vim.notify(
        'git-web-line: ' .. summary .. '; link may not match your local file',
        vim.log.levels.WARN
      )
    end
  end

  local line_number = vim.api.nvim_win_get_cursor(0)[1]
  local url = hosts.build_url(repository, ref, file_path, line_number)

  vim.notify('Opening: ' .. url, vim.log.levels.INFO)
  vim.ui.open(url)
end

-- Completion for :GitWebLine, using the remotes of the current buffer's repository
function M.complete_remotes(arg_lead)
  local buf_path = vim.api.nvim_buf_get_name(0)
  local cwd = buf_path ~= '' and vim.fs.dirname(buf_path) or nil
  if cwd and not vim.uv.fs_stat(cwd) then
    cwd = nil
  end
  return vim.tbl_filter(function(name)
    return vim.startswith(name, arg_lead)
  end, git.remotes(cwd))
end

return M
