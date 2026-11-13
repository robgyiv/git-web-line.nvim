local M = {}

function M.is_available()
  return vim.fn.executable('git') == 1
end

-- Run a git command and return trimmed stdout, or nil and an error message
function M.run(args, cwd)
  local cmd = vim.list_extend({ 'git' }, args)
  local ok, result = pcall(function()
    return vim.system(cmd, { cwd = cwd, text = true }):wait()
  end)
  if not ok then
    return nil, tostring(result)
  end
  if result.code ~= 0 then
    return nil, vim.trim(result.stderr or '')
  end
  return vim.trim(result.stdout or '')
end

-- Returns the current branch name, or nil when HEAD is detached
function M.branch_name(cwd)
  local branch = M.run({ 'branch', '--show-current' }, cwd)
  if branch == '' then
    return nil
  end
  return branch
end

function M.head_sha(cwd)
  return M.run({ 'rev-parse', 'HEAD' }, cwd)
end

-- Path of `file_path` relative to the root of the repository containing it.
-- Uses git's own prefix so symlinked directories resolve the same way git sees them.
function M.repo_relative_path(file_path)
  local dir = vim.fs.dirname(file_path)
  local prefix, err = M.run({ 'rev-parse', '--show-prefix' }, dir)
  if not prefix then
    return nil, err
  end
  return prefix .. vim.fs.basename(file_path)
end

function M.remotes(cwd)
  local out = M.run({ 'remote' }, cwd)
  if not out or out == '' then
    return {}
  end
  return vim.split(out, '\n')
end

-- Remote the branch tracks, or nil when it has no upstream (or tracks a local branch)
function M.upstream_remote(branch, cwd)
  if not branch then
    return nil
  end
  local name = M.run({ 'config', '--get', 'branch.' .. branch .. '.remote' }, cwd)
  if not name or name == '' or name == '.' then
    return nil
  end
  return name
end

function M.remote_url(remote, cwd)
  return M.run({ 'remote', 'get-url', remote }, cwd)
end

return M
