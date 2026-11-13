local assert = require('luassert')
local hosts = require('git-web-line.hosts')

describe('hosts', function()
  describe('detect', function()
    it('should detect GitHub', function()
      assert.equals('github', hosts.detect('github.com'))
    end)

    it('should detect GitLab.com', function()
      assert.equals('gitlab', hosts.detect('gitlab.com'))
    end)

    it('should detect self-hosted GitLab', function()
      assert.equals('gitlab', hosts.detect('gitlab.example.com'))
    end)

    it('should detect Bitbucket', function()
      assert.equals('bitbucket', hosts.detect('bitbucket.org'))
    end)

    it('should detect SourceHut', function()
      assert.equals('sourcehut', hosts.detect('git.sr.ht'))
    end)

    it('should fallback to GitHub for unknown hosts', function()
      assert.equals('github', hosts.detect('unknown.example.com'))
    end)
  end)

  describe('build_url', function()
    local function repo(domain)
      return { domain = domain, username = 'user', name = 'repo' }
    end

    it('should build GitHub URLs correctly', function()
      local url = hosts.build_url(repo('github.com'), 'main', 'src/file.lua', 42)
      assert.equals('https://github.com/user/repo/blob/main/src/file.lua#L42', url)
    end)

    it('should build GitLab URLs correctly', function()
      local url = hosts.build_url(repo('gitlab.com'), 'main', 'src/file.lua', 42)
      assert.equals('https://gitlab.com/user/repo/-/blob/main/src/file.lua#L42', url)
    end)

    it('should build Bitbucket URLs correctly', function()
      local url = hosts.build_url(repo('bitbucket.org'), 'main', 'src/file.lua', 42)
      assert.equals('https://bitbucket.org/user/repo/src/main/src/file.lua#lines-42', url)
    end)

    it('should build SourceHut URLs correctly', function()
      local url = hosts.build_url(repo('git.sr.ht'), 'main', 'src/file.lua', 42)
      assert.equals('https://git.sr.ht/user/repo/tree/main/item/src/file.lua#L42', url)
    end)

    describe('line ranges', function()
      local cases = {
        { 'github.com', 'https://github.com/user/repo/blob/main/f.lua#L10-L20' },
        { 'gitlab.com', 'https://gitlab.com/user/repo/-/blob/main/f.lua#L10-20' },
        { 'bitbucket.org', 'https://bitbucket.org/user/repo/src/main/f.lua#lines-10:20' },
        { 'git.sr.ht', 'https://git.sr.ht/user/repo/tree/main/item/f.lua#L10-20' },
      }
      for _, case in ipairs(cases) do
        it('should build a range URL for ' .. case[1], function()
          assert.equals(case[2], hosts.build_url(repo(case[1]), 'main', 'f.lua', 10, 20))
        end)
      end

      it('should use a single-line anchor when start and end match', function()
        local url = hosts.build_url(repo('github.com'), 'main', 'f.lua', 7, 7)
        assert.equals('https://github.com/user/repo/blob/main/f.lua#L7', url)
      end)

      it('should order a reversed range', function()
        local url = hosts.build_url(repo('github.com'), 'main', 'f.lua', 20, 10)
        assert.equals('https://github.com/user/repo/blob/main/f.lua#L10-L20', url)
      end)
    end)

    describe('rendered files', function()
      it('should add ?plain=1 for markdown on GitHub', function()
        local url = hosts.build_url(repo('github.com'), 'main', 'docs/README.md', 5)
        assert.equals('https://github.com/user/repo/blob/main/docs/README.md?plain=1#L5', url)
      end)

      it('should match extensions case-insensitively', function()
        local url = hosts.build_url(repo('github.com'), 'main', 'NOTES.RST', 5)
        assert.equals('https://github.com/user/repo/blob/main/NOTES.RST?plain=1#L5', url)
      end)

      it('should not add ?plain=1 for other files', function()
        local url = hosts.build_url(repo('github.com'), 'main', 'md/file.lua', 5)
        assert.equals('https://github.com/user/repo/blob/main/md/file.lua#L5', url)
      end)

      it('should not add ?plain=1 on other hosts', function()
        local url = hosts.build_url(repo('gitlab.com'), 'main', 'README.md', 5)
        assert.equals('https://gitlab.com/user/repo/-/blob/main/README.md#L5', url)
      end)
    end)

    it('should percent-encode special characters in the path', function()
      local url = hosts.build_url(repo('github.com'), 'main', 'docs/my file#1%.txt', 3)
      assert.equals('https://github.com/user/repo/blob/main/docs/my%20file%231%25.txt#L3', url)
    end)

    it('should keep slashes in branch names but encode other characters', function()
      local url = hosts.build_url(repo('github.com'), 'feature/a#b', 'file.lua', 1)
      assert.equals('https://github.com/user/repo/blob/feature/a%23b/file.lua#L1', url)
    end)

    it('should percent-encode non-ASCII characters as UTF-8 bytes', function()
      local url = hosts.build_url(repo('github.com'), 'main', 'café.lua', 1)
      assert.equals('https://github.com/user/repo/blob/main/caf%C3%A9.lua#L1', url)
    end)

    it('should accept a commit SHA as ref', function()
      local url = hosts.build_url(repo('github.com'), 'abc123', 'src/file.lua', 1)
      assert.equals('https://github.com/user/repo/blob/abc123/src/file.lua#L1', url)
    end)
  end)
end)
