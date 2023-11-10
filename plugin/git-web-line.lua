vim.api.nvim_create_user_command(
  'GitWebLine',
  "lua require('git-web-line').activate()",
  { nargs = 0 }
)
