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

function M.branch_name(cwd)
  return M.run({ 'branch', '--show-current' }, cwd)
end

function M.remote_url(remote, cwd)
  return M.run({ 'remote', 'get-url', remote }, cwd)
end

return M
