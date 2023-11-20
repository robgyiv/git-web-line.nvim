local M = {}

function M.current_line_number()
  return vim.api.nvim_win_get_cursor(0)[1]
end

function M.git_branch_name(git_remote_string)
  print(git_remote_string)
  local branch_name = vim.fn.system("git rev-parse --abbrev-ref HEAD | tr -d '\n'")
  return branch_name
end

function M.git_remote_host(git_remote_string)
  local remote_host =
    vim.fn.system("echo " .. git_remote_string .. " | sed -n 's/.*@//;s/:.*//p' | tr -d '\n'")
  return remote_host
end

function M.git_remote_repo(git_remote_string)
  local remote_repo_name = vim.fn.system(
    "echo " .. git_remote_string .. " | sed -n 's/.*\\///;s/.git.*//p' | tr -d '\n'"
  )
  return remote_repo_name
end

function M.git_remote_username(git_remote_string)
  local remote_repo_username =
    vim.fn.system("echo " .. git_remote_string .. "| sed -n 's/.*://;s/\\/.*//p' | tr -d '\n'")
  return remote_repo_username
end

function M.current_filepath()
  local filepath = vim.fn.expand('%:~:.')
  return filepath
end

-- Command to activate the plugin
function M.activate()
  local git_remote_string = vim.fn.system("git config --get remote.origin.url | tr -d '\n'")
  local current_line = M.current_line_number()
  local branch_name = M.git_branch_name(git_remote_string)
  local remote_host = M.git_remote_host(git_remote_string)
  local remote_repo_name = M.git_remote_repo(git_remote_string)
  local remote_repo_username = M.git_remote_username(git_remote_string)
  local file_path = M.current_filepath()

  local url = 'https://'
    .. remote_host
    .. '/'
    .. remote_repo_username
    .. '/'
    .. remote_repo_name
    .. '/blob/'
    .. branch_name
    .. '/'
    .. file_path
    .. '#L'
    .. current_line

  print('Opening ' .. url)

  -- open the url in the browser
  vim.fn.system('open ' .. url)
end

return M
