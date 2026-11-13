-- Compares local state against the remote-tracking refs of a remote.
-- Only local refs are used, so results are as fresh as the last `git fetch`.
local git = require('git-web-line.git')

local M = {}

local function ref_exists(ref, cwd)
  return git.run({ 'rev-parse', '--verify', '--quiet', ref }, cwd) ~= nil
end

-- Remote-tracking ref for `branch` on `remote`, preferring the configured upstream
function M.remote_ref(remote, branch, cwd)
  local prefix = 'refs/remotes/' .. remote .. '/'
  local upstream = git.run({ 'for-each-ref', '--format=%(upstream)', 'refs/heads/' .. branch }, cwd)
  if upstream and vim.startswith(upstream, prefix) and ref_exists(upstream, cwd) then
    return upstream
  end
  if ref_exists(prefix .. branch, cwd) then
    return prefix .. branch
  end
  return nil
end

function M.has_remote_refs(remote, cwd)
  local ref =
    git.run({ 'for-each-ref', '--count=1', '--format=%(refname)', 'refs/remotes/' .. remote }, cwd)
  return ref ~= nil and ref ~= ''
end

-- Whether `path` (relative to the repository root) exists at `rev`
function M.file_exists(rev, path, cwd)
  return git.run({ 'cat-file', '-e', rev .. ':' .. path }, cwd) ~= nil
end

-- Returns { problems = { string... }, pushed_sha = string|nil }.
-- `pushed_sha` is the newest commit in HEAD's history known to be on the remote.
function M.check(ctx)
  local problems = {}
  local pushed_sha
  -- Revision on the remote that the opened URL will show
  local remote_rev

  if not M.has_remote_refs(ctx.remote, ctx.cwd) then
    table.insert(
      problems,
      "no refs found for remote '"
        .. ctx.remote
        .. "' (run `git fetch`, or check the repository exists)"
    )
  elseif ctx.branch then
    local ref = M.remote_ref(ctx.remote, ctx.branch, ctx.cwd)
    remote_rev = ref
    if not ref then
      table.insert(
        problems,
        "branch '" .. ctx.branch .. "' has not been pushed to '" .. ctx.remote .. "'"
      )
    else
      pushed_sha = git.run({ 'merge-base', 'HEAD', ref }, ctx.cwd)
      local ahead = tonumber(git.run({ 'rev-list', '--count', ref .. '..HEAD' }, ctx.cwd) or '0')
      if ahead > 0 then
        table.insert(problems, ahead .. " commit(s) not pushed to '" .. ctx.remote .. "'")
      end
    end
  else
    local containing = git.run({
      'for-each-ref',
      '--contains',
      'HEAD',
      '--count=1',
      '--format=%(refname)',
      'refs/remotes/' .. ctx.remote,
    }, ctx.cwd)
    if containing and containing ~= '' then
      pushed_sha = git.head_sha(ctx.cwd)
      remote_rev = pushed_sha
    else
      table.insert(problems, "commit has not been pushed to '" .. ctx.remote .. "'")
    end
  end

  if remote_rev and not M.file_exists(remote_rev, ctx.file_path, ctx.cwd) then
    table.insert(problems, "file does not exist on '" .. ctx.remote .. "'")
  end

  local committed = git.run({ 'diff', '--quiet', 'HEAD', '--', ctx.file_path }, ctx.root)
  if ctx.modified or not committed then
    table.insert(problems, 'file has uncommitted changes')
  end

  return { problems = problems, pushed_sha = pushed_sha }
end

return M
