local M = {}

function M.current_line_number()
  return vim.api.nvim_win_get_cursor(0)[1]
end

function M.git_branch_name()
  return vim.fn.system("git branch --show-current | tr -d '\n'")
end

function M.git_remote_host(git_remote_string)
  return vim.fn.system('echo ' .. git_remote_string .. " | sed -n 's/.*@//;s/:.*//p' | tr -d '\n'")
end

function M.git_repo_path(git_remote_string)
  return vim.fn.system(
    'echo ' .. git_remote_string .. " | sed -e 's/^[^:]*:[^/]*\\///' -e 's/\\.git$//' | tr -d '\n'"
  )
end

function M.git_remote_username(git_remote_string)
  return vim.fn.system(
    'echo ' .. git_remote_string .. " | sed -n 's/.*://;s/\\/.*//p' | tr -d '\n'"
  )
end

function M.current_filepath()
  return vim.fn.expand('%:~:.')
end

function M.activate()
  local git_remote_string = vim.fn.system("git config --get remote.origin.url | tr -d '\n'")
  local current_line = M.current_line_number()
  local branch_name = M.git_branch_name()
  local remote_host = M.git_remote_host(git_remote_string)
  local repo_path = M.git_repo_path(git_remote_string)
  local remote_repo_username = M.git_remote_username(git_remote_string)
  local file_path = M.current_filepath()

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

  print('Opening ' .. url)

  -- Open the url in system browser
  vim.fn.system('open ' .. url)
end

return M
