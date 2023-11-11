# git-web-line.nvim

neovim plugin to open the current line on GitHub in a browser for easier sharing with others.

When I'm doing a code review or exploring a new codebase I prefer to do it in my own editor. Clicking through a web UI to find the right file/line to share a link with someone takes too long, so this is an attempt to speed things up a bit.

This project is a learning exercise in lua and neovim plugins.

## Usage

Assuming your remote is up to date with your local git repo, navigate to the line you want to share in a file and run `:GitWebLine` to open the GitHub UI in your browser.

## TODO

- Support other providers like GitLab
- Tests
- Functionality to check a git repo exists at all
- Docs
