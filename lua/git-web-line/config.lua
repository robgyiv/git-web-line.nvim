local M = {}

M.defaults = {
  -- Remote to link to. nil means auto-detect.
  remote = nil,
  -- What to do when the branch, commits or file aren't pushed to the remote:
  --   'warn'      notify, then open the branch URL anyway
  --   'abort'     notify with an error and don't open anything
  --   'permalink' link to the newest pushed commit instead of the branch
  on_unpushed = 'warn',
}

local ON_UNPUSHED = { warn = true, abort = true, permalink = true }

M.options = vim.deepcopy(M.defaults)

function M.setup(opts)
  local options = vim.tbl_deep_extend('force', vim.deepcopy(M.defaults), opts or {})
  if not ON_UNPUSHED[options.on_unpushed] then
    error(
      "git-web-line: on_unpushed must be 'warn', 'abort' or 'permalink', got "
        .. vim.inspect(options.on_unpushed),
      0
    )
  end
  M.options = options
  return M.options
end

return M
