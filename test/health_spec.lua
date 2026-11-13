local assert = require('luassert')
local helpers = require('test.helpers')

local function run_health()
  vim.cmd('checkhealth git-web-line')
  local text = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\n')
  vim.cmd('bwipeout!')
  return text
end

describe('health', function()
  local original_cwd = vim.fn.getcwd()
  local executable = vim.fn.executable

  after_each(function()
    vim.fn.executable = executable
    vim.cmd.cd(original_cwd)
  end)

  it('should report git and the repository remotes', function()
    local root = helpers.create_repo()
    vim.cmd.cd(root)
    local text = run_health()
    assert.truthy(text:find('git version', 1, true))
    assert.truthy(text:find('Git repository: ' .. root, 1, true))
    assert.truthy(text:find('Remotes: origin', 1, true))
  end)

  it('should report a missing git executable', function()
    vim.fn.executable = function()
      return 0
    end
    local text = run_health()
    assert.truthy(text:find('`git` executable not found', 1, true))
  end)
end)
