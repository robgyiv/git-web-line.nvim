local assert = require('luassert')
local remote = require('git-web-line.remote')

local function assert_repo(result, protocol, domain)
  assert.equals(protocol, result.protocol)
  assert.equals(domain, result.domain)
  assert.equals('user', result.username)
  assert.equals('repo', result.name)
end

describe('remote', function()
  describe('detect_protocol', function()
    it('should detect HTTPS protocol', function()
      assert.equals('https', remote.detect_protocol('https://github.com/user/repo.git'))
    end)

    it('should detect SSH protocol', function()
      assert.equals('ssh', remote.detect_protocol('git@github.com:user/repo.git'))
    end)

    it('should detect ssh:// protocol', function()
      assert.equals('ssh', remote.detect_protocol('ssh://git@github.com/user/repo.git'))
    end)

    it('should return nil for unsupported protocol', function()
      assert.is_nil(remote.detect_protocol('ftp://example.com/repo.git'))
    end)
  end)

  describe('parse_https', function()
    it('should parse GitHub HTTPS URL', function()
      assert_repo(remote.parse_https('https://github.com/user/repo.git'), 'https', 'github.com')
    end)

    it('should parse GitLab HTTPS URL', function()
      assert_repo(remote.parse_https('https://gitlab.com/user/repo.git'), 'https', 'gitlab.com')
    end)

    it('should parse URL without .git suffix', function()
      assert_repo(remote.parse_https('https://github.com/user/repo'), 'https', 'github.com')
    end)

    it('should strip credentials', function()
      assert_repo(
        remote.parse_https('https://user:token@github.com/user/repo.git'),
        'https',
        'github.com'
      )
    end)
  end)

  describe('parse_ssh', function()
    it('should parse GitHub SSH URL', function()
      assert_repo(remote.parse_ssh('git@github.com:user/repo.git'), 'ssh', 'github.com')
    end)

    it('should parse GitLab SSH URL', function()
      assert_repo(remote.parse_ssh('git@gitlab.com:user/repo.git'), 'ssh', 'gitlab.com')
    end)

    it('should parse URL without .git suffix', function()
      assert_repo(remote.parse_ssh('git@github.com:user/repo'), 'ssh', 'github.com')
    end)

    it('should parse ssh:// URL with port', function()
      assert_repo(remote.parse_ssh('ssh://git@github.com:22/user/repo.git'), 'ssh', 'github.com')
    end)
  end)

  describe('parse', function()
    it('should parse HTTPS remote URLs', function()
      assert_repo(remote.parse('https://github.com/user/repo.git'), 'https', 'github.com')
    end)

    it('should parse SSH remote URLs', function()
      assert_repo(remote.parse('git@github.com:user/repo.git'), 'ssh', 'github.com')
    end)

    it('should error on unsupported protocol', function()
      assert.has_error(function()
        remote.parse('ftp://example.com/repo.git')
      end)
    end)

    it('should error on malformed URL', function()
      assert.has_error(function()
        remote.parse('https://github.com/')
      end)
    end)
  end)
end)
