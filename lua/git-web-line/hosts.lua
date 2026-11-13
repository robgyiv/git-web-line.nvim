local M = {}

local patterns = {
  github = { blob = '/blob/%s/%s', line = '#L%d' },
  gitlab = { blob = '/-/blob/%s/%s', line = '#L%d' },
  bitbucket = { blob = '/src/%s/%s', line = '#lines-%d' },
  sourcehut = { blob = '/tree/%s/item/%s', line = '#L%d' },
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

-- `ref` may be a branch name or a commit SHA
function M.build_url(repository, ref, file_path, line_number)
  local pattern = patterns[M.detect(repository.domain)]
  local base_url = 'https://'
    .. repository.domain
    .. '/'
    .. repository.username
    .. '/'
    .. repository.name
  return base_url .. pattern.blob:format(ref, file_path) .. pattern.line:format(line_number)
end

return M
