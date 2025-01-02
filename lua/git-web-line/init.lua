local M = {}

local function current_line_number()
  return vim.api.nvim_win_get_cursor(0)[1]
end

local function git_branch_name()
  return vim.fn.system("git branch --show-current | tr -d '\n'")
end

local function _is_ssh_remote(git_remote_string)
  return string.match(git_remote_string, 'git@')
end

local function git_remote_host(git_remote_string)
  if _is_ssh_remote(git_remote_host(git_remote_string)) then
    return vim.fn.system(
      'echo ' .. git_remote_string .. " | sed -n 's/.*@//;s/:.*//p' | tr -d '\n'"
    )
  end
  -- return domain for https remotes
  return vim.fn.system(
    'echo ' .. git_remote_string .. " | sed -n 's/.*\\/\\///;s/\\/.*//p' | tr -d '\n'"
  )
end

local function git_repo_path(git_remote_string)
  return vim.fn.system(
    'echo ' .. git_remote_string .. " | sed -e 's/^[^:]*:[^/]*\\///' -e 's/\\.git$//' | tr -d '\n'"
  )
end

local function git_remote_username(git_remote_string)
  return vim.fn.system(
    'echo ' .. git_remote_string .. " | sed -n 's/.*://;s/\\/.*//p' | tr -d '\n'"
  )
end

local function current_filepath()
  return vim.fn.expand('%:~:.')
end

function M.activate()
  local git_remote_string = vim.fn.system("git remote get-url origin | tr -d '\n'")
  local current_line = current_line_number()
  local branch_name = git_branch_name()
  local remote_host = git_remote_host(git_remote_string)
  local repo_path = git_repo_path(git_remote_string)
  local remote_repo_username = git_remote_username(git_remote_string)
  local file_path = current_filepath()

  local url = 'https://'
    .. remote_host
    .. '/'
    .. remote_repo_username
    .. '/'
    .. repo_path
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
