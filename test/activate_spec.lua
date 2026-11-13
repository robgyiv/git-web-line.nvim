local assert = require('luassert')
local git_web_line = require('git-web-line')
local helpers = require('test.helpers')

describe('activate', function()
  local captured
  local original_cwd = vim.fn.getcwd()

  before_each(function()
    captured = helpers.capture()
  end)

  after_each(function()
    captured.restore()
    vim.cmd('silent! %bwipeout!')
    vim.cmd.cd(original_cwd)
  end)

  it('should link to the file relative to the repo root', function()
    local root = helpers.create_repo({ files = { ['src/nested/file.lua'] = 'a\nb\nc' } })
    vim.cmd.edit(root .. '/src/nested/file.lua')
    vim.api.nvim_win_set_cursor(0, { 2, 0 })

    git_web_line.activate()

    assert.same({}, captured.errors)
    assert.same({ 'https://github.com/user/repo/blob/main/src/nested/file.lua#L2' }, captured.urls)
  end)

  it('should not depend on the working directory', function()
    local root = helpers.create_repo({ files = { ['src/file.lua'] = 'a' } })
    vim.cmd.cd(root .. '/src')
    vim.cmd.edit(root .. '/src/file.lua')

    git_web_line.activate()

    assert.same({ 'https://github.com/user/repo/blob/main/src/file.lua#L1' }, captured.urls)
  end)

  it('should work when the working directory is outside the repo', function()
    local root = helpers.create_repo({ files = { ['src/file.lua'] = 'a' } })
    vim.cmd.cd(vim.fn.resolve(vim.fn.tempname():match('^(.*)/')))
    vim.cmd.edit(root .. '/src/file.lua')

    git_web_line.activate()

    assert.same({ 'https://github.com/user/repo/blob/main/src/file.lua#L1' }, captured.urls)
  end)

  it('should link to the commit on a detached HEAD', function()
    local root = helpers.create_repo()
    local sha = helpers.git({ 'rev-parse', 'HEAD' }, root)
    helpers.git({ 'checkout', '-q', '--detach' }, root)
    vim.cmd.edit(root .. '/README.md')

    git_web_line.activate()

    assert.same({ 'https://github.com/user/repo/blob/' .. sha .. '/README.md#L1' }, captured.urls)
  end)

  it('should error for a buffer without a file', function()
    vim.cmd.enew()

    git_web_line.activate()

    assert.same({}, captured.urls)
    assert.truthy(captured.errors[1]:match('not a file'))
  end)

  it('should error for a file outside a git repository', function()
    local dir = vim.fn.resolve(vim.fn.tempname())
    vim.fn.mkdir(dir, 'p')
    vim.fn.writefile({ 'x' }, dir .. '/file.txt')
    vim.cmd.edit(dir .. '/file.txt')

    git_web_line.activate()

    assert.same({}, captured.urls)
    assert.truthy(captured.errors[1]:match('not inside a git repository'))
  end)

  it('should error when the remote does not exist', function()
    local root = helpers.create_repo()
    vim.cmd.edit(root .. '/README.md')

    git_web_line.activate({ remote = 'missing' })

    assert.same({}, captured.urls)
    assert.truthy(captured.errors[1]:match("'missing' remote"))
  end)
end)
