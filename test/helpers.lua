local M = {}

local function run(cmd, cwd)
  local result = vim.system(cmd, { cwd = cwd, text = true }):wait()
  assert(result.code == 0, table.concat(cmd, ' ') .. ' failed: ' .. (result.stderr or ''))
  return vim.trim(result.stdout or '')
end

function M.git(args, cwd)
  return run(
    vim.list_extend({ 'git', '-c', 'user.name=Test', '-c', 'user.email=test@example.com' }, args),
    cwd
  )
end

-- Create a temporary repository with an `origin` remote and the given files committed.
-- Returns the repository root.
function M.create_repo(opts)
  opts = opts or {}
  local root = vim.fn.resolve(vim.fn.tempname())
  vim.fn.mkdir(root, 'p')
  M.git({ 'init', '-q', '-b', opts.branch or 'main' }, root)
  M.git({ 'remote', 'add', 'origin', opts.remote_url or 'git@github.com:user/repo.git' }, root)
  for path, content in pairs(opts.files or { ['README.md'] = 'readme' }) do
    local full = root .. '/' .. path
    vim.fn.mkdir(vim.fs.dirname(full), 'p')
    vim.fn.writefile(vim.split(content, '\n'), full)
  end
  M.git({ 'add', '.' }, root)
  M.git({ 'commit', '-q', '-m', 'initial' }, root)
  return root
end

-- Stub vim.ui.open and vim.notify; returns a table that records calls and a restore function.
function M.capture()
  local captured = { urls = {}, errors = {} }
  local open, notify = vim.ui.open, vim.notify
  vim.ui.open = function(url)
    table.insert(captured.urls, url)
  end
  vim.notify = function(msg, level)
    if level == vim.log.levels.ERROR then
      table.insert(captured.errors, msg)
    end
  end
  captured.restore = function()
    vim.ui.open, vim.notify = open, notify
  end
  return captured
end

return M
