local assert = require('luassert')
local helpers = require('test.helpers')

describe(':GitWebLine', function()
  local captured, root

  before_each(function()
    captured = helpers.capture()
    root = helpers.create_repo()
    helpers.git({ 'remote', 'add', 'upstream', 'https://gitlab.com/org/repo.git' }, root)
    helpers.push(root)
    helpers.push(root, { remote = 'upstream' })
    vim.cmd.edit(root .. '/README.md')
  end)

  after_each(function()
    captured.restore()
    vim.cmd('silent! %bwipeout!')
  end)

  it('should open the URL for the default remote', function()
    vim.cmd('GitWebLine')
    assert.same({}, captured.errors)
    assert.same({ 'https://github.com/user/repo/blob/main/README.md#L1' }, captured.urls)
  end)

  it('should pass the remote argument through', function()
    vim.cmd('GitWebLine upstream')
    assert.same({}, captured.errors)
    assert.same({ 'https://gitlab.com/org/repo/-/blob/main/README.md#L1' }, captured.urls)
  end)

  it('should complete remote names on the command line', function()
    assert.same({ 'upstream' }, vim.fn.getcompletion('GitWebLine up', 'cmdline'))
  end)

  it('should treat extra words as an unknown remote', function()
    vim.cmd('GitWebLine origin upstream')
    assert.same({}, captured.urls)
    assert.truthy(captured.errors[1]:match("'origin upstream' does not exist"))
  end)
end)
