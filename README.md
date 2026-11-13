# git-web-line.nvim

**Navigate your code in Neovim, share it on GitHub, GitLab, Bitbucket or SourceHut instantly.**

`git-web-line.nvim` is a lightweight Neovim plugin designed to streamline the process of sharing specific parts of your code. Perfect for code reviews or when you're exploring a new codebase, this plugin lets you generate a GitHub URL for the current line in your Neovim editor, opening it directly in the browser. Say goodbye to the tedious process of navigating through GitHub's web UI to share a piece of code!

This project is not only a handy tool for developers but also serves as a personal learning journey into Lua and Neovim plugin development.

## Features

- **Quick Link Generation:** Instantly get a sharable GitHub link for the line you're on in Neovim.
- **Seamless Integration:** Works within your Neovim workflow, making code sharing as simple as a command execution.
- **Speeds Up Reviews:** Ideal for code reviews, saving time and enhancing productivity.

## Requirements

- Neovim >= 0.10
- `git` on your `$PATH`

Run `:checkhealth git-web-line` to verify your setup.

## Installation

To install `git-web-line.nvim`, use your favorite package manager:

```lua
-- lazy.nvim
{
  'robgyiv/git-web-line.nvim',
  cmd = 'GitWebLine',
  opts = {},
}
```

```vim
" If you are using Vim-Plug
Plug 'robgyiv/git-web-line.nvim'

" If you are using Dein
call dein#add('robgyiv/git-web-line.nvim')

" If you are using Packer
use 'robgyiv/git-web-line.nvim'
```

## Usage

1. Navigate to the line in a file you want to share, or select lines in visual mode.
2. Run `:GitWebLine`, or `:GitWebLine <remote>` to link to a specific remote (remote names tab-complete).
3. Your default web browser will open the page with that line or range highlighted.

| Command | Result |
| --- | --- |
| `:GitWebLine` | Open the current line |
| `:'<,'>GitWebLine` | Open the selected lines (also works with any range, e.g. `:10,20GitWebLine`) |
| `:GitWebLine!` | Copy the URL to the clipboard instead of opening it |
| `:GitWebLine upstream` | Use the `upstream` remote |

`:GitWebLine!` is handy over SSH, where there's no local browser to open; Neovim 0.10+ copies to your local clipboard through OSC 52 when the terminal supports it. Without a clipboard provider, the URL goes to the unnamed register.

On GitHub, markdown and other rendered formats (reStructuredText, AsciiDoc, Org, Textile) are linked with `?plain=1` so that line anchors work.

Supported hosts are GitHub, GitLab (including self-hosted instances with `gitlab` in the domain), Bitbucket and SourceHut. Unknown hosts use GitHub-style URLs. SSH (`git@host:owner/repo`, `ssh://`) and HTTPS remotes are supported, with or without a `.git` suffix. File paths and branch names are percent-encoded, so spaces and special characters are safe.

### Choosing a remote

When no remote is passed to the command, the first match of the following is used:

1. The `remote` option passed to `setup()`
2. The remote the current branch tracks (its upstream)
3. `origin`
4. The first configured remote

### Unpushed changes

Before opening the browser, the plugin compares your local state with the remote's remote-tracking refs (e.g. `origin/main`) and reports when:

- the remote has no fetched refs (it has never been fetched, or the repository may not exist)
- the current branch has not been pushed, or has commits that aren't pushed
- the file doesn't exist on the remote
- the file has uncommitted or unsaved changes

These checks don't touch the network, so they are only as current as your last `git fetch`. The `on_unpushed` option controls what happens next (see below).

## Configuration

Calling `setup()` is optional. The defaults are:

```lua
require('git-web-line').setup({
  -- Remote to link to. nil picks one automatically (see "Choosing a remote").
  remote = nil,
  -- What to do when the branch, commits or file aren't pushed to the remote:
  --   'warn'      notify, then open the branch URL anyway
  --   'abort'     notify with an error and don't open anything
  --   'permalink' link to the newest pushed commit instead of the branch
  on_unpushed = 'warn',
  -- What to do with the URL: 'open' it in the browser, 'copy' it to the
  -- clipboard, or 'both'. `:GitWebLine!` always copies.
  action = 'open',
})
```

## Health check

Run `:checkhealth git-web-line` to see the Neovim and git versions, the current repository and its remotes.

## Development

Tests use [plenary.nvim](https://github.com/nvim-lua/plenary.nvim). Point `PLENARY_DIR` at a local checkout (it defaults to `~/.local/share/nvim/site/pack/vendor/start/plenary.nvim`) and run:

```sh
PLENARY_DIR=/path/to/plenary.nvim nvim --headless --noplugin -u test/minimal_init.lua \
  -c "PlenaryBustedDirectory test/ {minimal_init = 'test/minimal_init.lua'}"
```

Format with [StyLua](https://github.com/JohnnyMorganz/StyLua): `stylua .`

## Roadmap

- [x] Add support for other git providers like GitLab and Bitbucket.
- [x] Write unit tests to ensure reliability and maintainability.
- [x] Implement functionality to verify the existence of a git repository on cloud host.
- [x] Comprehensive documentation for users and contributors.
- [x] Support multiple remotes, not just `origin`.
- [x] Check file exists in a UI before opening in the browser.
- [x] Support HTTPS git remotes.
- [x] Check `git` exists; add to requirements.
- [x] Check branch is pushed to remote.
- [x] Migrate away from the forked repository's structure to a more vanilla plugin.

## Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/amazing-feature`)
3. Commit your Changes (`git commit -m 'Add some amazing feature'`)
4. Push to the Branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

Distributed under the MIT License. See `LICENSE` for more information.

## Acknowledgments

- Neovim community
- Lua programming language
- ChatGPT for this readme
