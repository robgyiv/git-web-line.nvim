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

  describe('activate', function()
    local executable = vim.fn.executable
    local notify = vim.notify
    local open = vim.ui.open

    after_each(function()
      vim.fn.executable = executable
      vim.notify = notify
      vim.ui.open = open
    end)

    it('should error and not open a URL when git is missing', function()
      local messages, opened = {}, false
      vim.fn.executable = function()
        return 0
      end
      vim.notify = function(msg, level)
        table.insert(messages, { msg = msg, level = level })
      end
      vim.ui.open = function()
        opened = true
      end

      git_web_line.activate()

      assert.is_false(opened)
      assert.equals(1, #messages)
      assert.equals(vim.log.levels.ERROR, messages[1].level)
      assert.truthy(messages[1].msg:match('git'))
    end)
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
