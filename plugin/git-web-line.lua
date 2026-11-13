if vim.g.loaded_git_web_line then
  return
end
vim.g.loaded_git_web_line = true

if vim.fn.has('nvim-0.10') ~= 1 then
  vim.notify('git-web-line.nvim requires Neovim >= 0.10', vim.log.levels.ERROR)
  return
end

vim.api.nvim_create_user_command('GitWebLine', function(args)
  require('git-web-line').activate({
    remote = args.fargs[1],
    line1 = args.line1,
    line2 = args.line2,
    action = args.bang and 'copy' or nil,
  })
end, {
  nargs = '?',
  range = true,
  bang = true,
  complete = function(arg_lead)
    return require('git-web-line').complete_remotes(arg_lead)
  end,
  desc = 'Open the current line or range on the git web host',
})
