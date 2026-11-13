local M = {}

local function strip_suffix(name)
  return (name:gsub('/$', ''):gsub('%.git$', ''))
end

function M.detect_protocol(git_remote_str)
  if git_remote_str:match('^git@') or git_remote_str:match('^ssh://') then
    return 'ssh'
  elseif git_remote_str:match('^https://') then
    return 'https'
  else
    return nil
  end
end

function M.parse_https(git_remote_str)
  -- Drop any credentials (https://user:token@host/...)
  local rest = git_remote_str:gsub('^https://', ''):gsub('^[^@/]+@', '')
  local domain, username, name = rest:match('^([^/]+)/([^/]+)/(.+)$')
  return {
    protocol = 'https',
    domain = domain,
    username = username,
    name = name and strip_suffix(name),
  }
end

function M.parse_ssh(git_remote_str)
  local domain, username, name
  if git_remote_str:match('^ssh://') then
    -- ssh://[user@]host[:port]/owner/repo(.git)
    local rest = git_remote_str:gsub('^ssh://', ''):gsub('^[^@/]+@', '')
    domain, username, name = rest:match('^([^/:]+)[^/]*/([^/]+)/(.+)$')
  else
    -- git@host:owner/repo(.git)
    domain, username, name = git_remote_str:match('^git@([^:]+):([^/]+)/(.+)$')
  end
  return {
    protocol = 'ssh',
    domain = domain,
    username = username,
    name = name and strip_suffix(name),
  }
end

function M.parse(git_remote_str)
  local protocol = M.detect_protocol(git_remote_str or '')
  local repository
  if protocol == 'https' then
    repository = M.parse_https(git_remote_str)
  elseif protocol == 'ssh' then
    repository = M.parse_ssh(git_remote_str)
  end
  if not repository or not repository.domain or not repository.name then
    error('Unsupported git remote: ' .. (git_remote_str or 'nil'), 0)
  end
  return repository
end

return M
