local M = {}

-- GitHub renders these formats, which hides line anchors unless ?plain=1 is set
local rendered_extensions = {
  md = true,
  markdown = true,
  mdown = true,
  mkdn = true,
  mkd = true,
  rst = true,
  adoc = true,
  asciidoc = true,
  org = true,
  textile = true,
}

local patterns = {
  github = { blob = '/blob/%s/%s', line = '#L%d', range = '#L%d-L%d' },
  gitlab = { blob = '/-/blob/%s/%s', line = '#L%d', range = '#L%d-%d' },
  bitbucket = { blob = '/src/%s/%s', line = '#lines-%d', range = '#lines-%d:%d' },
  sourcehut = { blob = '/tree/%s/item/%s', line = '#L%d', range = '#L%d-%d' },
}

function M.detect(domain)
  if domain:match('github%.com') then
    return 'github'
  elseif domain:match('gitlab%.com') or domain:match('gitlab%.') then
    return 'gitlab'
  elseif domain:match('bitbucket%.org') then
    return 'bitbucket'
  elseif domain:match('git%.sr%.ht') then
    return 'sourcehut'
  else
    return 'github' -- Default fallback
  end
end

-- Percent-encode everything except unreserved characters and `/`
function M.encode_path(path)
  return (path:gsub('[^%w%-%._~/]', function(c)
    return ('%%%02X'):format(c:byte())
  end))
end

-- `ref` may be a branch name or a commit SHA. `end_line` is optional; when it
-- differs from `start_line` the URL highlights the whole range.
function M.build_url(repository, ref, file_path, start_line, end_line)
  local host = M.detect(repository.domain)
  local pattern = patterns[host]
  local base_url = 'https://'
    .. repository.domain
    .. '/'
    .. repository.username
    .. '/'
    .. repository.name
  end_line = end_line or start_line
  if end_line < start_line then
    start_line, end_line = end_line, start_line
  end
  local anchor = start_line == end_line and pattern.line:format(start_line)
    or pattern.range:format(start_line, end_line)
  local extension = (file_path:match('%.([^./]+)$') or ''):lower()
  local query = (host == 'github' and rendered_extensions[extension]) and '?plain=1' or ''
  return base_url
    .. pattern.blob:format(M.encode_path(ref), M.encode_path(file_path))
    .. query
    .. anchor
end

return M
