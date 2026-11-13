local M = {}

M.defaults = {
  -- Remote to link to. nil means auto-detect.
  remote = nil,
  -- What to do when the branch, commits or file aren't pushed to the remote:
  --   'warn'      notify, then open the branch URL anyway
  --   'abort'     notify with an error and don't open anything
  --   'permalink' link to the newest pushed commit instead of the branch
  on_unpushed = 'warn',
  -- What to do with the URL: 'open' it in the browser, 'copy' it to the
  -- clipboard, or 'both'. `:GitWebLine!` always copies.
  action = 'open',
}

local allowed = {
  on_unpushed = { 'warn', 'abort', 'permalink' },
  action = { 'open', 'copy', 'both' },
}

M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
  local options = vim.tbl_deep_extend('force', vim.deepcopy(M.defaults), opts or {})
  for key, values in pairs(allowed) do
    if not vim.tbl_contains(values, options[key]) then
      error(
        ('git-web-line: %s must be one of %s, got %s'):format(
          key,
          table.concat(values, ', '),
          vim.inspect(options[key])
        ),
        0
      )
    end
  end
  M.options = options
  return M.options
end

return M
