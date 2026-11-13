local assert = require('luassert')
local git_web_line = require('git-web-line')
local config = require('git-web-line.config')
local helpers = require('test.helpers')

describe('action', function()
  local URL = 'https://github.com/user/repo/blob/main/file.txt#L1'
  local captured

  before_each(function()
    captured = helpers.capture()
    local root = helpers.create_repo()
    helpers.push(root)
    vim.cmd.edit(root .. '/file.txt')
  end)

  after_each(function()
    captured.restore()
    config.setup()
    vim.cmd('silent! %bwipeout!')
  end)

  it('should open by default', function()
    assert.equals(URL, git_web_line.activate())
    assert.same({ URL }, captured.urls)
    assert.same({}, captured.registers)
  end)

  it('should copy to the clipboard with action = copy', function()
    git_web_line.setup({ action = 'copy' })
    git_web_line.activate()
    assert.same({}, captured.urls)
    assert.same({ ['+'] = URL }, captured.registers)
  end)

  it('should open and copy with action = both', function()
    git_web_line.setup({ action = 'both' })
    git_web_line.activate()
    assert.same({ URL }, captured.urls)
    assert.same({ ['+'] = URL }, captured.registers)
  end)

  it('should prefer the action passed to activate over setup()', function()
    git_web_line.setup({ action = 'open' })
    git_web_line.activate({ action = 'copy' })
    assert.same({}, captured.urls)
    assert.same({ ['+'] = URL }, captured.registers)
  end)

  it('should fall back to the unnamed register without a clipboard provider', function()
    captured.clipboard = false
    git_web_line.activate({ action = 'copy' })
    assert.same({ ['"'] = URL }, captured.registers)
    assert.truthy(captured.warnings[1]:match('no clipboard provider'))
  end)

  it('should suggest copying when the URL cannot be opened', function()
    vim.ui.open = function()
      return nil, 'no handler found'
    end
    git_web_line.activate()
    assert.truthy(captured.errors[1]:match('no handler found'))
    assert.truthy(captured.errors[1]:match('GitWebLine!'))
  end)

  it('should reject an invalid action', function()
    assert.has_error(function()
      config.setup({ action = 'print' })
    end)
  end)
end)
