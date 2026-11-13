local assert = require('luassert')
local git_web_line = require('git-web-line')
local config = require('git-web-line.config')

describe('git-web-line', function()
  after_each(function()
    config.setup()
  end)

  it('should expose activate', function()
    assert.is_function(git_web_line.activate)
  end)

  it('should register the GitWebLine command', function()
    assert.equals(2, vim.fn.exists(':GitWebLine'))
  end)

  describe('setup', function()
    it('should use defaults when called without options', function()
      git_web_line.setup()
      assert.is_nil(config.options.remote)
    end)

    it('should merge user options', function()
      git_web_line.setup({ remote = 'upstream' })
      assert.equals('upstream', config.options.remote)
    end)
  end)
end)
