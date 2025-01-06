local M = {}

local function current_line_number()
  return vim.api.nvim_win_get_cursor(0)[1]
end

local function git_branch_name()
  return vim.fn.system("git branch --show-current | tr -d '\n'")
end

local function _is_ssh_remote(git_remote_str)
  return git_remote_str:match('^git@') and true or false
end

local function _is_https_remote(git_remote_str)
  return git_remote_str:match('^https://') and true or false
end

local function current_filepath()
  return vim.fn.expand('%:~:.')
end

local function detect_protocol(git_remote_str)
  if _is_ssh_remote(git_remote_str) then
    return 'ssh'
  elseif _is_https_remote(git_remote_str) then
    return 'https'
  else
    return nil
  end
end

local function parse_https(git_remote_str)
  local domain, username, name = git_remote_str:match('https://([^/]+)/([^/]+)/(.+)%.git$')
  return {
    protocol = 'https',
    domain = domain,
    username = username,
    name = name,
  }
end

local function parse_ssh(git_remote_str)
  local domain, username, name = git_remote_str:match('git@([^:]+):([^/]+)/(.+)%.git$')
  return {
    protocol = 'ssh',
    domain = domain,
    username = username,
    name = name,
  }
end

local function parse_remote(git_remote_str)
  local protocol = detect_protocol(git_remote_str)
  if protocol == 'https' then
    return parse_https(git_remote_str)
  elseif protocol == 'ssh' then
    return parse_ssh(git_remote_str)
  else
    error('Unsupported protocol: ' .. (git_remote_str or 'nil'))
  end
end

function M.activate()
  local git_remote_str = vim.fn.system("git remote get-url origin | tr -d '\n'")
  local current_line = current_line_number()
  local file_path = current_filepath()
  local branch_name = git_branch_name()
  local repository = parse_remote(git_remote_str)

  local url = 'https://'
    .. repository.domain
    .. '/'
    .. repository.username
    .. '/'
    .. repository.name
    .. '/blob/'
    .. branch_name
    .. '/'
    .. file_path
    .. '#L'
    .. current_line

  -- TODO: Remove (local dev indicator)
  -- print('Opening ' .. url)
  print('asdk' .. url)

  -- Open the url in system browser
  vim.fn.system('open ' .. url)
end

return M
