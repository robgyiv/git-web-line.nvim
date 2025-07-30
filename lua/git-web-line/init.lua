local M = {}

-- Constants
local DEFAULT_REMOTE = 'origin'
local GIT_BRANCH_CMD = "git branch --show-current | tr -d '\n'"
local GIT_REMOTE_CMD = 'git remote get-url ' .. DEFAULT_REMOTE .. " | tr -d '\n'"

-- Neovim helper functions
local function current_line_number()
  return vim.api.nvim_win_get_cursor(0)[1]
end

local function current_filepath()
  return vim.fn.expand('%:~:.')
end

-- Git utility functions
local function git_branch_name()
  local branch = vim.fn.system(GIT_BRANCH_CMD)
  if vim.v.shell_error ~= 0 then
    error('Failed to get current branch. Are you in a git repository?')
  end
  return branch
end

-- Host detection and URL building functions
local function detect_host(domain)
  if domain:match('github%.com') then
    return 'github'
  elseif domain:match('gitlab%.com') or domain:match('gitlab%.') then
    return 'gitlab'
  elseif domain:match('bitbucket%.org') then
    return 'bitbucket'
  elseif domain:match('git%.sr%.ht') then
    return 'sourcehut'
  else
    return 'github' -- Default fallback
  end
end

local function build_url(repository, branch_name, file_path, line_number)
  local host_type = detect_host(repository.domain)
  local base_url = 'https://'
    .. repository.domain
    .. '/'
    .. repository.username
    .. '/'
    .. repository.name

  if host_type == 'github' then
    return base_url .. '/blob/' .. branch_name .. '/' .. file_path .. '#L' .. line_number
  elseif host_type == 'gitlab' then
    return base_url .. '/-/blob/' .. branch_name .. '/' .. file_path .. '#L' .. line_number
  elseif host_type == 'bitbucket' then
    return base_url .. '/src/' .. branch_name .. '/' .. file_path .. '#lines-' .. line_number
  elseif host_type == 'sourcehut' then
    return base_url .. '/tree/' .. branch_name .. '/item/' .. file_path .. '#L' .. line_number
  else
    -- Fallback to GitHub format
    return base_url .. '/blob/' .. branch_name .. '/' .. file_path .. '#L' .. line_number
  end
end

-- Remote URL parsing functions
local function _is_ssh_remote(git_remote_str)
  return git_remote_str:match('^git@') and true or false
end

local function _is_https_remote(git_remote_str)
  return git_remote_str:match('^https://') and true or false
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

-- System integration functions
local function open_url(url)
  local cmd
  if vim.fn.has('mac') == 1 then
    cmd = 'open'
  elseif vim.fn.has('unix') == 1 then
    cmd = 'xdg-open'
  elseif vim.fn.has('win32') == 1 then
    cmd = 'start'
  else
    vim.notify('Unsupported platform for opening URLs', vim.log.levels.ERROR)
    return
  end

  vim.fn.system(cmd .. ' ' .. vim.fn.shellescape(url))
end

function M.activate()
  local git_remote_str = vim.fn.system(GIT_REMOTE_CMD)
  if vim.v.shell_error ~= 0 then
    vim.notify(
      "Failed to get git remote URL. Are you in a git repository with a '"
        .. DEFAULT_REMOTE
        .. "' remote?",
      vim.log.levels.ERROR
    )
    return
  end

  local current_line = current_line_number()
  local file_path = current_filepath()
  local branch_name = git_branch_name()
  local repository = parse_remote(git_remote_str)

  local url = build_url(repository, branch_name, file_path, current_line)

  vim.notify('Opening: ' .. url, vim.log.levels.INFO)

  -- Open the url in system browser
  open_url(url)
end

-- Export functions for testing
M._test = {
  detect_host = detect_host,
  build_url = build_url,
  parse_remote = parse_remote,
  detect_protocol = detect_protocol,
  parse_https = parse_https,
  parse_ssh = parse_ssh,
}

return M
