local assert = require('luassert')
local git_web_line = require('git-web-line')

describe('git-web-line', function()
  local test_funcs = git_web_line._test

  describe('Protocol detection', function()
    it('should detect HTTPS protocol', function()
      local result = test_funcs.detect_protocol('https://github.com/user/repo.git')
      assert.equals('https', result)
    end)

    it('should detect SSH protocol', function()
      local result = test_funcs.detect_protocol('git@github.com:user/repo.git')
      assert.equals('ssh', result)
    end)

    it('should return nil for unsupported protocol', function()
      local result = test_funcs.detect_protocol('ftp://example.com/repo.git')
      assert.is_nil(result)
    end)
  end)

  describe('HTTPS URL parsing', function()
    it('should parse GitHub HTTPS URL', function()
      local result = test_funcs.parse_https('https://github.com/user/repo.git')
      assert.equals('https', result.protocol)
      assert.equals('github.com', result.domain)
      assert.equals('user', result.username)
      assert.equals('repo', result.name)
    end)

    it('should parse GitLab HTTPS URL', function()
      local result = test_funcs.parse_https('https://gitlab.com/user/repo.git')
      assert.equals('https', result.protocol)
      assert.equals('gitlab.com', result.domain)
      assert.equals('user', result.username)
      assert.equals('repo', result.name)
    end)
  end)

  describe('SSH URL parsing', function()
    it('should parse GitHub SSH URL', function()
      local result = test_funcs.parse_ssh('git@github.com:user/repo.git')
      assert.equals('ssh', result.protocol)
      assert.equals('github.com', result.domain)
      assert.equals('user', result.username)
      assert.equals('repo', result.name)
    end)

    it('should parse GitLab SSH URL', function()
      local result = test_funcs.parse_ssh('git@gitlab.com:user/repo.git')
      assert.equals('ssh', result.protocol)
      assert.equals('gitlab.com', result.domain)
      assert.equals('user', result.username)
      assert.equals('repo', result.name)
    end)
  end)

  describe('Remote URL parsing', function()
    it('should parse HTTPS remote URLs', function()
      local result = test_funcs.parse_remote('https://github.com/user/repo.git')
      assert.equals('https', result.protocol)
      assert.equals('github.com', result.domain)
      assert.equals('user', result.username)
      assert.equals('repo', result.name)
    end)

    it('should parse SSH remote URLs', function()
      local result = test_funcs.parse_remote('git@github.com:user/repo.git')
      assert.equals('ssh', result.protocol)
      assert.equals('github.com', result.domain)
      assert.equals('user', result.username)
      assert.equals('repo', result.name)
    end)

    it('should error on unsupported protocol', function()
      assert.has_error(function()
        test_funcs.parse_remote('ftp://example.com/repo.git')
      end)
    end)
  end)

  describe('Host detection', function()
    it('should detect GitHub', function()
      local result = test_funcs.detect_host('github.com')
      assert.equals('github', result)
    end)

    it('should detect GitLab.com', function()
      local result = test_funcs.detect_host('gitlab.com')
      assert.equals('gitlab', result)
    end)

    it('should detect self-hosted GitLab', function()
      local result = test_funcs.detect_host('gitlab.example.com')
      assert.equals('gitlab', result)
    end)

    it('should detect Bitbucket', function()
      local result = test_funcs.detect_host('bitbucket.org')
      assert.equals('bitbucket', result)
    end)

    it('should detect SourceHut', function()
      local result = test_funcs.detect_host('git.sr.ht')
      assert.equals('sourcehut', result)
    end)

    it('should fallback to GitHub for unknown hosts', function()
      local result = test_funcs.detect_host('unknown.example.com')
      assert.equals('github', result)
    end)
  end)

  describe('URL building', function()
    local repository = {
      domain = 'github.com',
      username = 'user',
      name = 'repo',
    }

    it('should build GitHub URLs correctly', function()
      local url = test_funcs.build_url(repository, 'main', 'src/file.lua', 42)
      assert.equals('https://github.com/user/repo/blob/main/src/file.lua#L42', url)
    end)

    it('should build GitLab URLs correctly', function()
      local gitlab_repo = {
        domain = 'gitlab.com',
        username = 'user',
        name = 'repo',
      }
      local url = test_funcs.build_url(gitlab_repo, 'main', 'src/file.lua', 42)
      assert.equals('https://gitlab.com/user/repo/-/blob/main/src/file.lua#L42', url)
    end)

    it('should build Bitbucket URLs correctly', function()
      local bitbucket_repo = {
        domain = 'bitbucket.org',
        username = 'user',
        name = 'repo',
      }
      local url = test_funcs.build_url(bitbucket_repo, 'main', 'src/file.lua', 42)
      assert.equals('https://bitbucket.org/user/repo/src/main/src/file.lua#lines-42', url)
    end)

    it('should build SourceHut URLs correctly', function()
      local sourcehut_repo = {
        domain = 'git.sr.ht',
        username = 'user',
        name = 'repo',
      }
      local url = test_funcs.build_url(sourcehut_repo, 'main', 'src/file.lua', 42)
      assert.equals('https://git.sr.ht/user/repo/tree/main/item/src/file.lua#L42', url)
    end)
  end)

  describe('activate function', function()
    it('should exist and be callable', function()
      assert.is_function(git_web_line.activate)
    end)
  end)
end)
