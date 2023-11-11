local M = {}

function M.current_line_number()
  -- gets the current line number
  return vim.api.nvim_win_get_cursor(0)[1]
end

function M.git_branch_name()
  -- gets the name of the current git branch
  local branch_name = vim.fn.system("git rev-parse --abbrev-ref HEAD | tr -d '\n'")
  return branch_name
end

function M.git_remote_host()
  -- gets the domain name of the remote host repo
  -- e.g. github.com
  local remote_host =
    vim.fn.system("git config --get remote.origin.url | sed -n 's/.*@//;s/:.*//p' | tr -d '\n'")
  return remote_host
end

function M.git_remote_repo()
  -- gets the name of the remote repo
  -- e.g. dotfiles
  local remote_repo_name = vim.fn.system(
    "git config --get remote.origin.url | sed -n 's/.*\\///;s/.git.*//p' | tr -d '\n'"
  )
  return remote_repo_name
end

function M.git_remote_username()
  -- gets the username from the remote repo
  -- e.g. torvalds
  local remote_repo_username =
    vim.fn.system("git config --get remote.origin.url | sed -n 's/.*://;s/\\/.*//p' | tr -d '\n'")
  return remote_repo_username
end

function M.current_filepath()
  -- gets the relative path of the open file
  local filepath = vim.fn.expand('%:~:.')
  return filepath
end

-- Command to activate the plugin
function M.activate()
  local current_line = M.current_line_number()
  local branch_name = M.git_branch_name()
  local remote_host = M.git_remote_host()
  local remote_repo_name = M.git_remote_repo()
  local remote_repo_username = M.git_remote_username()
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
