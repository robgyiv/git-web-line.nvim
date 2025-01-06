# git-web-line.nvim

**Navigate your code in Neovim, share it on GitHub instantly.**

`git-web-line.nvim` is a lightweight Neovim plugin designed to streamline the process of sharing specific parts of your code. Perfect for code reviews or when you're exploring a new codebase, this plugin lets you generate a GitHub URL for the current line in your Neovim editor, opening it directly in the browser. Say goodbye to the tedious process of navigating through GitHub's web UI to share a piece of code!

This project is not only a handy tool for developers but also serves as a personal learning journey into Lua and Neovim plugin development.

## Features

- **Quick Link Generation:** Instantly get a sharable GitHub link for the line you're on in Neovim.
- **Seamless Integration:** Works within your Neovim workflow, making code sharing as simple as a command execution.
- **Speeds Up Reviews:** Ideal for code reviews, saving time and enhancing productivity.

## Installation

To install `git-web-line.nvim`, use your favorite package manager:

```vim
" If you are using Vim-Plug
Plug 'robgyiv/git-web-line.nvim'

" If you are using Dein
call dein#add('robgyiv/git-web-line.nvim')

" If you are using Packer
use 'robgyiv/git-web-line.nvim'
```

## Usage

0. Ensure your git remote is up to date with your local git repo, otherwise a link can't be shared.
1. Navigate to the line in a file you want to share.
2. Run `:GitWebLine`.
3. Your default web browser will open the GitHub page displaying that specific line.

## Roadmap

- [x] Add support for other git providers like GitLab and Bitbucket.
- [ ] Write unit tests to ensure reliability and maintainability.
- [ ] Implement functionality to verify the existence of a git repository.
- [x] Comprehensive documentation for users and contributors.
- [ ] Support multiple remotes, not just `origin`.
- [ ] Check file exists in a UI before opening in the browser.
- [x] Support HTTPS git remotes.
- [ ] Check `git` exists; add to requirements.
- [ ] Check branch is pushed to remote.

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
