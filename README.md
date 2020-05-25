# Arkku's .dotfiles

This repository contains my "public" shell configuration files. The ones in this
repository are not in any way specific to me, and could theoretically be used
by others who share similar preferences.

However, possibly the most interesting thing here is the `link_files` script,
which is used to hard-link the files from this repository into the home
directory, while allowing platform-specific files and local overrides. See
`link_files --help`.

~ [Kimmo Kulovesi](https://arkku.dev/)

## Additional Things to Install

This is a checklist for me when I set up a new machine.

* [ArkkuDvorak](https://arkku.com/dvorak/)
* [XCode](https://developer.apple.com/download/)
* [Homebrew](https://brew.sh)
* [gpg](https://gnupg.org/download/)
    - also pinentry program and config
* [tmux](https://neovim.io)
    - [tmux plugins](https://github.com/arkku/tmux-plugin-collection)
* [neovim](https://neovim.io)
    - [vim plugins](https://github.com/arkku/vim-plugin-collection)
* [mosh](https://mosh.org)
* [VS Code](https://code.visualstudio.com)
    - [VS Code colour theme](https://github.com/arkku/arkku-vscode-theme)
    - [File Icons](https://github.com/file-icons/vscode)
    - [Auto Dark Mode](https://github.com/LinusU/vscode-auto-dark-mode)
    - extensions for C, Swift, Ruby, Awk, zsh, Assembler, Jekyll, Liquid, etc.
* [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
* [hub](https://hub.github.com)
* [fzf](https://github.com/junegunn/fzf)
* [fasd](https://github.com/clvv/fasd)
    - in my config, remember to `touch ~/.fasd-init-zsh`
* [ripgrep](https://github.com/BurntSushi/ripgrep)
* [fd](https://github.com/sharkdp/fd)
    - on some systems may have to `ln -s /usr/bin/fdfind ~/bin/fd`
* [bat](https://github.com/sharkdp/bat)
    - on some systems may have to `ln -s /usr/bin/batcat ~/bin/bat`
    - need to run `bat cache --build` for themes to be detected
* [rvm](https://rvm.io)
* SF Mono font
    - `/System/Applications/Utilities/Terminal.app/Contents/Resources/Fonts`
* `~/.ssh` (keys, permissions, authorized keys, include shared config)
* `~/.gitconfig` (account, signing, editor, merge tool, shared config)
* `~/.profile` (source `~/.profile_shared`)
* `/etc/locale.gen`

## Features

This is an incomplete set of features, mainly as a reminder for myself when
some years later I have forgotten what I set up. =)

### Vim

Configuration and colour scheme (imaginatively named `arkku`) for Vim and
Neovim. The colour scheme supports both light and dark backgrounds, and works in
an EGA/VGA text-mode terminal. Even if the background is mistakenly set as
light, the colour scheme is still usable, allowing me to keep light background
as the default.

Some other general settings done:

* if `rg` is installed, use it instead of `grep` (also in plugins), otherwise
  use `ag` if that is installed
* if `fzf` is installed (via `brew`, `apt`, or in `~./fzf`), load its plugin,
  and use the first of `fd`, `rg` or `ag` that is installed to power the search
* `g:markdown_fenced_languages` is set to contain a variety of popular
  languages but only if the filetype is known (e.g., `swift` is not currently
  shipped with Vim, so it would cause an error if added without the plugin
  installed)
* formatting of markdown lists is fixed
* the Neovim configuration tries to detect the background colour from the
  environment variables `$BACKGROUND` (`dark` or `light`) and `$COLORFGBG`
  (`<fgcolor>;<bgcolor>`, e.g., `7;0` is gray on black)

Many settings assume that my [plugin
collection](https://github.com/arkku/vim-plugin-collection/) is installed, and
some plugin-related settings are in that collection (and not duplicated here
anymore).

#### General Bindings

* `p` – in visual mode, put (paste) over the selection without yanking the
  replaced text
* `K` – show documentation for word under cursor (using `coc` or `ale` if
  available, otherwise the normal Vim behaviour)
* arrows (with Ctrl and Alt) escape sequences explicitly bound for various
  different terminals (not in Neovim)
* <kbd>Alt</kbd>-<kbd>arrow</kbd> mapped the same way as in macOS, i.e., skip
  words left/right, or to beginning/end of line
* <kbd>Ctrl</kbd>–<kbd>left</kbd> and <kbd>Ctrl</kbd>–<kbd>right</kbd> mapped
  the same way as in macOS, i.e., line beginning/end
* <kbd>Ctrl</kbd>–<kbd>up</kbd> and <kbd>Ctrl</kbd>–<kbd>down</kbd> move
  visually, i.e., lines on screen instead of lines in file
* <kbd>Ctrl</kbd>-<kbd>A</kbd> – go to the beginning of line
* <kbd>Ctrl</kbd>-<kbd>E</kbd> – go to the end of line (unless pop-up
  completion menu is open, in which case close it)
* <kbd>Ctrl</kbd>–<kbd>B</kbd> – in insert mode, insert the character below the
  cursor (the default mapping for <kbd>Ctrl</kbd>–<kbd>E</kbd>, but even the
  mnemonic makes more sense now)
* <kbd>Ctrl</kbd>–<kbd>B</kbd> – toggle paste mode, paste, and toggle paste
  mode again (Vim only)
* <kbd>Esc</kbd> – exit integrated terminal (press twice quickly to send to
* <kbd>Esc</kbd> <kbd>Esc</kbd> – in insert mode, clear highlighting of
  previous search
* <kbd>Ctrl</kbd>-<kbd>\_</kbd> – various bindings in different modes, not
  settled on a final choice yet
* <kbd>Ctrl</kbd>–<kbd>J</kbd> and <kbd>Ctrl</kbd>–<kbd>K</kbd> right after
  putting text in normal change the text that was put by cycling put history
  (depends on Yoink plugin)
* <kbd>Ctrl</kbd>-<kbd>Q</kbd> – in normal mode works as the original
  <kbd>Tab</kbd> binding (since usually I use a configuration that rebinds it),
  i.e., jump to newer cursor position (such as after jumping to an older
  position with <kbd>Ctrl</kbd>–<kbd>O</kbd>, which is also conveniently
  adjacent in Dvorak)
* <kbd>Ctrl</kbd>-<kbd>Q</kbd> – in insert mode inserts the previously inserted
  text, i.e., the original behaviour of <kbd>Ctrl</kbd>–<kbd>A</kbd>

#### Unimpaired-style Bindings

Some additional bindings in the style of the "unimpaired" plugin:

* `[oa` / `]oa` – turn auto-formatting (`formatoptions+=a`) on/off
* `[ot` / `]ot` – turn text formatting (`formatoptions+=t`) on/off
* `]w`, `[w` – jump to next/previous warning/error (using coc, ale, or the
  location list, in that order)

#### Leader Bindings

These bindings are for the normal mode, preceded by the leader (<kbd>\\</kbd>):

* `1` – `0` – switch to vim-buffet buffer 1–10
* `f` – open quickfix if there are warnings/errors
* `F` – close quickfix
* `l` – open location list
* `L` – close location list
* `q` – delete buffer
* `x` – wipeout buffer
* `d` – jump to definition of thing under cursor (if coc installed)
* `r` – show references to the thing under cursor (if coc installed)
* `c` – coc code action (if installed)
* `cf` – coc autofix (if installed)
* `R` or `cr` – coc rename (if installed)
* `s` – run [Syntastic](https://github.com/vim-syntastic/syntastic) check, and
  open the location list if there are errors
* `S` – reset Syntastic, clearing all errors
* `t` – toggle a split terminal console (the session remains even if toggled
  away from view) – Neovim only
* `T` – split and open a terminal with the given command
* `u` – open function search
* `/` – open `fzf` search for lines in open buffers (if plugin installed)
* <kbd>Tab</kbd> – create a new tab
* <kbd>Shift</kbd> + <kbd>Tab</kbd> – close tab

#### Local Leader Bindings

These bindings are for the normal mode, preceded by the local leader (<kbd>Space</kbd>):

* `1` – `0` – switch to tab 1–10
* `q` – close tab
* `x` – force close tab
* <kbd>Tab</kbd> – go to next tab
* <kbd>Shift</kbd> + <kbd>Tab</kbd> – go to previous tab
* `w` – open warnings/errors list (coc, or location list)
* `W` – close warnings/errors list
* `h` – open `fzf` fuzzy search for "recently opened files" (if plugin installed)
* `/` – open `fzf` search for lines in this buffer
* `t` – open tag search (if fzf plugin is installed)
* `T` – open tag search (if CtrlP plugin is installed)
* `z` – open `fzf` fuzzy search for files (powered by `fd` if installed)

#### Commands

* `CD` – change the current window's working directory to that of the current
  file
* `CD!` – change every window's working directory to that of the current file

### Shell

I have switched my default shell on most computers from `bash` to `zsh`. Many
of the features described here work specifically on `zsh`, but many also work
on `bash`, especially if they were configured in the 20 years before I made the
switch.

Configuration exists for `.inputrc` and `ls` colours for both GNU and BSD
variants. The autocompletion suggestions for `zsh` are also coloured. If
`zsh-syntax-highlighting` is installed, it is loaded. The colours somewhat
match my Vim colour scheme where applicable (although there is no separate dark
variant so some exceptions had to be made).

There is also my `.profile_shared` configuration, which is meant to be sourced
from `.profile` and `.zprofile`. The settings are quite specific to me, so if
anyone else uses these config files, they probably shouldn't use it. But, to do
so, simply:

    . "$HOME/.profile_shared"

It sets `EDITOR` and `VISUAL` to `nvim`, `vim`, or `vi`, whichever is installed
(in that order). Flow control is disabled for the terminal, allowing
<kbd>Ctrl</kbd>–<kbd>S</kbd> and <kbd>Ctrl</kbd>–<kbd>Q</kbd> to be used for
keyboard shortcuts.

The profiles generally ensure that `rvm` is loaded if installed, and that
`PATH` contains `rvm` directories in the correct order. `~/bin` and
`/usr/local/bin` are also added to the path, in that order, so that things
installed in `/usr/local/bin` override older versions shipped with the OS, and
`~/bin` can be used to override both.

On machines where I set `umask 027` (i.e., no default permissions for others),
it is also helpful to add to `sudoers` or `/etc/sudoers.d`:

```
Defaults umask_override
Defaults umask=0022
```

#### Prompt

* the prompt truncates the current working directory in various ways, e.g., the
  home directory is replaced by `~`, any long path before the root of the
  current git repository (if any) is truncated, if there are more than four
  directories remaining, only the first and last two are kept, and then the
  remaining is truncated from the left according to available space
* the current git repository and branch are shown on the right-hand side (zsh
  `RPROMPT` feature – it disappears if input comes too close to it), and there
  are little `+~` characters to indicate staged/unstaged changes to the
  repository
* the repository name is truncated from the left according to available space,
  and removed entirely if it is already visible in the working directory
  (which is true most of the time since the repository root is used as the path
  root)
* the branch name on the prompt is truncated according to various rules, e.g.,
  `master` often becomes `m` (but in a different colour to distinguish from
  a hypothetical `m` branch)
* there is a single line above the prompt, which contains the current history
  number (`$!`), and the exit status of the previous command _if it failed_
  (i.e., a non-zero `$?`)
* git merge/rebase/patch status is also show on this line
* the vi command-mode is shown with a `(vi)` indicator on the above line

#### Autocompletion

Autocompletion is set to be case-, hyphen-, and underscore-insensitive. If
`fzf` is installed, autocompletion is also made fuzzy.

#### Title

* the window/screen/tmux title shows `user@host` when idle, followed by the git
  repository and branch (if any)
* when executing a command, the title shows the command line, but precedes it
  with the username if `sudo` has been used and the hostname if it is an `ssh`
  session
* the file URL for `Terminal.app` is set if not in tmux and `$TERM_PROGRAM` is
  `Apple_Terminal`

#### Directory Jumping

If `fasd` or `z.sh` is installed (in that order) _and_ the initially empty file
`~/.fasd-init-zsh` (or `~/.z` for `z.sh`) exists, then it is loaded and its
aliases setup. Both include at least `z`, which jumps to a directory matching
the partial name, e.g., `z dot` probably jumps to `~/.dotfiles` if you have
been using that directory.

If `fasd` and `fzf` are both enabled, then all interactive selections in `fzf`
are replaced by `fzf`.

For `fasd`, the set of aliases is:

* `z dir` – jump from anywhere to directory matching the partial name `dir`
* `zz dir` – as `z`, but interactively select the directory if there are
  multiple matches
* `zzz file` – interactively select a file or directory, and jump to the
  directory _containing_ it (even if it is a directory in itself)
* `d dir` – print the directory matching the partial name `dir`
* `sd dir` – as above, but interactively disambiguate
* `f file` – print the file matching the partial name `file`
* `sf dir` – as above, but interactively disambiguate
* `a any` – print the directory or file matching the partial name `any`
* `any any` – print the directory or file matching the partial name `any`
* `v file` – edit the file in vi
* `vv file` – as above, but interactively disambiguate

#### Key Bindings

* `.inputrc` has bindings for a large selection of terminals
* arrow keys with alt are bound as per macOS defaults
* <kbd>Ctrl</kbd>–<kbd>A</kbd> and <kbd>Ctrl</kbd>–<kbd>E</kbd> go to the
  beginning/end of the line
* <kbd>Alt</kbd>-<kbd>arrow</kbd> mapped the same way as in macOS, i.e., skip
  words left/right, or to beginning/end of line
* <kbd>Ctrl</kbd>–<kbd>left</kbd> and <kbd>Ctrl</kbd>–<kbd>right</kbd> mapped
  the same way as in macOS, i.e., line beginning/end
* <kbd>Ctrl</kbd>-<kbd>Space</kbd> – opens the current command line in an
  editor
* <kbd>Ctrl</kbd>-<kbd>Q</kbd> – `push-line-or-edit`, if you are in
  a multi-line command it makes all prior lines editable again, otherwise it
  kills the line and pastes it back on the next empty prompt (e.g., use this to
  get rid of an unfinished command while you look at `man`, then it comes back
  automatically on the next prompt)
* <kbd>Ctrl</kbd>-<kbd>R</kbd> in zsh Vi insert mode activates a fuzzy command
  history search with the current command-line's contents and replaces the
  command-line with the selection (mnemonic: Repeat command)
* <kbd>Ctrl</kbd>-<kbd>S</kbd> in zsh Vi insert mode toggles `sudo` at the
  beginning of the command-line (also toggles the alias `please` on an empty
  line, and between `vi`/`$EDITOR` and the alias `svi` )
* <kbd>Ctrl</kbd>-<kbd>Z</kbd> on an empty prompt in insert mode – if the
  on the first line, execute `fg` (i.e., bring suspended process to
  foreground, allowing to toggle suspend/resume with the same keystroke),
  otherwise make previous lines of the multi-line prompt editable again
* <kbd>Ctrl</kbd>-<kbd>U</kbd> – kills the whole line (not just backwards from
  the cursor, as is the default)
* <kbd>Ctrl</kbd>-<kbd>Y</kbd> – yanks (or, more accurately, puts) the
  previously-killed line
* <kbd>Ctrl</kbd>-<kbd>F</kbd> – in zsh Vi insert mode starts a fuzzy file
  finder (requires fzf and fd), with keyboard shortcuts to change the list to
  show everything, only directories, only the current directory, or Git
  repository contents (including submodules)
* <kbd>Ctrl</kbd>-<kbd>G</kbd> – in zsh Vi insert mode shows a prompt to choose
  from Git commits, branches, tags, or files (not including submodules), or
  GitHub issues or pull requests, and starts a fuzzy finder for the choice,
  with live preview
* `S` + surround – in visual selection mode surrounds the selection with the
  given quotes, e.g., `v$S"` in vi command mode selects to the end of the line
  and surrounds the selection with `" "` quotes

#### Aliases

* `ls` – `ls` with color options
* `ll` – `ls -l`
* `la` – `la`
* `l.` – list hidden files only
* `md` – make a directory, including the parent directories (`mkdir -p`) and
  `cd` to it
* `fcd` – `cd` to the directory containing the argument file
* `please` – re-run the entire previous command with `sudo` (note: this is
  _not_ just putting `sudo ` in front of the command, but rather the entire
  command is executed under `sudo` so any pipes and redirects also gain
  privileges)
* `clc` – copy the last command to system clipboard
* `clct` – copy the last command to tmux buffer
* `plc` – paste command-line from system clipboard (but do not execute it)
* `plct` – paste command-line from tmux buffer (but do not execute it)
* `cpwd` – copy the current working directory to system clipboard
* `cpath` – copy the current path, with symlinks expanded, to system clipboard
* `gr` – `grep`, excluding `.git`
* `vi` – `nvim` (if installed)
* `nvis` – `nvim -S Session.vim` (if installed and the file exists)
* `svi` – `sudo -e`
* `psg` – `grep` the output of `ps`
* `hgrep` – `grep` history
* `agrep` – `grep` aliases
* `cdf` – open `fzf` to fuzzily search for directories and `cd` to the selected
  one (can take arguments, e.g., `cdf /` will search from the root instead of
  from the current directory)
* `cdff` – as `cdf`, but select a file and `cd` to the directory containing it
* `fzh` – use `fzf` to fuzzily search command history, and paste the selection
  on the command-line (but do not execute it)
* `fzk` – use `fzf` to fuzzily search running processes, and pass them (and any
  arguments) to `kill`

Also adds the following reusable `zsh` aliases that just print the selection to
`stdout`:

* `ffz` – fuzzily find a file or directory
* `fff` – fuzzily find a find a file
* `ff.` – fuzzily find a file in the current directory
* `ffd` – fuzzily find a directory

Each of these can take a path as an argument, e.g., `ffz /` will seach from the
root instead of from the current directory. Remember that <kbd>Tab</kbd> can
complete the search in zsh when pressed after the closing backtick
<code>\`</code>. But also note that <kbd>Ctrl</kbd>–<kbd>F</kbd> is bound to
these same features in my zsh configuration…

#### Aliases for Git

* `cdr` – `cd` to the root of the repository
* `cdrr` – `cd` to the root of the outermost repository (from submodules at any
  depth)
* `gs` – `git status`
* `glast` – show the last commit
* `ggl` – `git log` with a branching graph
* `gcl` – `git clone --recurse-submodules`
* `gpull` – `git pull`
* `gupdate` – `git pull --rebase --autostash -v`
* `gpush` – `git push`
* `gpusht` – `git push && git push --tags`
* `gpusha` – `git push --all && git push --tags`
* `gsubu` – `git submodule update --init --recursive`
* `gsubr` – `git submodule update --remote --recursive`
* `gls` – `git ls-files --exclude-standard`
* `glsm` – `git ls-files -m -o --exclude-standard` (modified files)
* `gbranch` – `git checkout -b`
* `gfeature` – make a new branch, prefixing the name given as argument with
  `feature/`, and push the branch to upstream (default `origin`, but may be
  given as the second argument)
* `gfeaturedone` – push and then delete the current branch if its name starts
  with `feature/` and check out `master` (or the branch given as argument)
* `gtag` – create a new signed tag, and push tags
* `gresetmb` – `git reset` to merge base of `HEAD` and the commit or branch
  (default `master`) given as argument (e.g., `gresetmb develop` will reset the
  current feature branch to the point where it diverged from the branch
  `develop`, and all changes since will show as changes to the working copy)

The following aliases have an interactive, fuzzy-searchable selection which
requires `fzf`, and most are only for zsh. Where applicable, there
is an additional binding of <kbd>Ctrl</kbd>–<kbd>A</kbd> to select
all. Pressing <kbd>Esc</kbd> leaves the selection (e.g., for `gdf` which
intentionally doesn't close after selection).

* `gcommit` – interactively select files to commit, stage, unstage, edit, diff,
  etc
* `gdf` – view the diff of modified files without leaving the selection, with
  a live preview of the diff (this supports multiple keyboard shortcuts, shown
  on the screen, to perform various actions, such as staging/unstaging files,
  opening them in the editor or difftool, etc.)
* `gdfs` or `gstaged` – view staged files and diff, unstage, or commit them
* `ge` – open a file in `$EDITOR`
* `gadd` – select modified files to stage (`git add`)
* `gunstage` – select staged files to unstage (`git restore --staged`)
* `gdiscard` – select modified files to discard changes of (`git restore`)
* `gdt` – select modified files to open in `git difftool`
* `gmt` – select unmerged files to open in `git mergetool`
* `gstash` – view stashes and diff them; there are also keyboard shortcuts to
  apply/pop the stash (<kbd>Ctrl</kbd>–<kbd>A</kbd>), and to
  branch the stash (<kbd>Ctrl</kbd>–<kbd>B</kbd>)
* `gcheckout` or `gco` – check out a branch or tag
* `gcheckoutb` or `gcobranch` – check out a branch
* `gcheckoutt` or `gcotag` – check out a tag
* `gcheckoutc` or `gcocommit` – check out a commit
* `grebase` – select branch and rebase
* `grebasei` – select branch and rebase interactively
* `grebasec` – select commit and rebase interactively
* `gmerge` – select branch and merge
* `gmergef` – select branch and merge, no fast forward (e.g., merge a feature
  branch and force there to be a new commit)
* `greset` – select a branch and reset to its state
* `glog` – view individual commits and their logs
* `gcherry` – cherry-pick an individual commit (this can take a branch as the
  first argument, other arguments are passed to the `git commit` command)
* `gfixup` – select a commit to fix-up with a new commit
* `grevert` – select a commit to revert
* `gbranchdel` – select a branch to remove
* `gmovetobranch newbranch` – move the current state to the new branch
  `newbranch` (also stashing any changes to working copy and moving them),
  then interactively pick a commit and _hard reset_ the current branch to that
  commit (i.e., the chosen commit is the last one to _keep_ on the current
  branch), then switch to the new branch (e.g., realize that the most
  recent commits should have been on a new feature branch, and retroactively
  move them to one)
* `gtagdel` – select a tag to remove
* `gissues` – view GitHub issues interactively (requires `hub`)
* `gissuecommit` – select an issue and pre-populate "Closes #" into the message
  of a new commit (requires `hub`)
* `gpullrs` – view GitHub pull requests interactively (requires `hub`)
* `gcistatus` – select a commit and view its CI status (requires `hub`)
* `fzc` – select one or more commits and print their hashes (e.g., to be used
  as part of other commands, like: <code>git rebase --onto \`fzc\`<kbd>Tab</kbd></code>)
* `fzbr` – select a branch and print its name (e.g., to be used as part of
  other commands)
* `fzbrr` – select a branch, including remotes, and print its name (e.g., to
  be used as part of other commands)
* `fztag` – select a tag and print its name (e.g., to be used as part of other
  commands)
* `fzbrt` – select a branch or tag and print its name (e.g., to be used as
  part of other commands)
* `fzgf` – select a file from the git repository and print its name
* `fzgcf` – select from changed files in the git repository and print its name
* `fzgfr` – select a file from the git repository, or its submodules, and print
  its name
* `fziss` – select a GitHub issue and print its number (e.g., to be used as
  part of other commands)
* `fzpullr` – select a GitHub pull request and print its number (e.g., to be
  used as part of other commands)

Most of the commands will take arguments, which will generally be passed on to
the eventual git command (e.g., `gmerge --squash` will result in `git merge
--squash`). Most of commands that select a commit can take a branch name to
choose commits from a branch other than the current, e.g., `gcherry master`
would cherry-pick from commits on `master`. In cases where the argument doesn't
make sense otherwise, it is used as the initial search, e.g., `gco origin`
would start the branch selection with `origin` already written into the
search. This is handy when you know that a given search term will only give one
result, then you can just do `gco f/bar`<kbd>Enter</kbd><kbd>Enter</kbd>
(although it is identical to `gco`<kbd>Enter</kbd>`f/bar`<kbd>Enter</kbd>, the
former retains the search string in shell command history).

#### Global Aliases

Global aliases are a `zsh` feature that allows alias expansions anywhere on the
command-line. All of mine are uppercase and begin with a `:` to make accidental
use unlikely. The command-line is configured to expand such aliases immediately
when pressing space, e.g., `cat file :H1 ` will expand the `:H1` to `| head -1`
so that it may be edited or followed by more pipes.

* `:L` – `| less`
* `:LE` - `|& less`
* `:G` – `| grep`
* `:FG` – `| grep -F`
* `:EG` – `| egrep`
* `:GR` – `|& grep`
* `:FGR` – `|& grep -F`
* `:H1` – `| head -1`
* `:T1` – `| tail -1`
* `:H` – `| head`
* `:T` – `| tail`
* `:S` – `| sort`
* `:SN` – `| sort -n`
* `:SU` – `| sort -u`
* `:N` – `>/dev/null`
* `:NUL` – `>/dev/null 2>&1`
* `:WC` – `| wc -l`
* `:VL` – `| viless` (an included script for use of `vim` or `nvim` as `less`)
* `:VI` – `| vim -R -`
* `:VIM` – `|& vim -R -`
* `:AG` – `| ag`

#### Additional Plugins

Plugins that need extensive external utilities or configuration are not
included in [my plugin collection](https://github.com/arkku/vim-plugin-collection/).
Some that I may use include:

* [coc](https://github.com/neoclide/coc.nvim) – intellisense engine
* [ale](https://github.com/dense-analysis/ale) – automatic linting and syntax
  checking on the fly

Also note that coc has various extensions that it can install by itself, e.g.:

``` vim
:CocInstall coc-tag
:CocInstall coc-emoji
```

### Clipboard

The scripts `clipcopy` and `clippaste` copy and paste to/from the system
clipboard (trying to auto-detect macOS, X11, etc.). They fall back to the tmux
buffer if no known system clipboard is available.

### tmux

The tmux configuration enables sensible modern defaults (e.g., mouse, focus
events), status bar, window titles, on-demand pane titles and borders.

#### Bindings

Unless otherwise noted, the following bindings are all after the prefix
(<kbd>Ctrl</kbd>–<kbd>T</kbd> in my configuration):

* `r` – reload configuration from disk
* `|` – split the window horizontally, opening in the current directory
* `\` – split the window horizontally at full width
* `-` – split the window horizontally, opening in the current directory
* `_` – split the window horizontally at full width
* `h` – split the window vertically at full width, opening in the current
  directory (yes, the `h` splits vertically and `v` horizontally in tmux
  terminology, to match the Vim terminology where the direction describes the
  new pane and not the split)
* `v` – split the window horizontally at full width, opening in the current
  directory
* `V` – split the window horizontally and select another pane to place in the
  split
* `H` – split the window vertically and select another pane to place in the
  split
* `M` – choose a window to move to (swap with) the current
* `<` – swap the pane left
* `>` – swap the pane right
* `!` – break the current pane into a new window (tab)
* `A` – rename the current window
* `O` – toggle mouse on/off
* `R` – refresh the screen
* `S` – toggle synchronize panes (i.e., all panes get the same keyboard input)
* `x` – kill the current pane
* `X` – kill the current window
* `y` – in copy mode, copies to the system clipboard

#### tmx

The included `bin/tmx` script is useful for launching `tmux`. If creates
separate "master" and "slave" sessions, which allows multiple computers on the
same master session to have their individual state in their private slave
session. Running it without arguments generally does the correct thing, i.e.,
creates a new slave session and attaches it to any existing master, or creates
the master if it doesn't exit.

A master session name can be given as the argument, e.g., `tmx foo` uses the
session `foo` instead of the default (`0`), and creates the `foo` master if it
doesn't already exist, and attaches a new slave to it. If the master session
name is given, a slave session name may be given as the second argument. This
will detach and recycle any existing slave session of that name, e.g.,
a network connection can use the same slave session to detach any hanging old
connections on reconnect.

As a special case, `tmx ls` simply does `tmux ls` and exits. Also, if the first
argument is `prefix`, the prefix is set to the second argument, and then the
two first arguments are discarded. For example, `tmx prefix '^a' foo` would use
`foo` as the master session name and set the prefix to <kbd>Ctrl</kbd>-<kbd>A</kbd>.

### Git

The included `.gitconfig_shared` is not used by default, it needs to be
included by copying this to `.gitconfig`:

    [include]
    	path = .gitconfig_shared

The shared configuration enables a global ignorefile `~/.gitignore_global`
(which ignores some common rubbish). The following aliases are added:

* `unstage` – unstage staged changes
* `last` – show the last commit
* `l` – pretty-print the log with colors
* `ll` – pretty-print the log
* `gl` – log with branching graph
* `dt` – difftool
* `mt` – mergetool
* `pur` – `pull --rebase`
* `pura` – `pull --rebase --autostash`
* `puf` – `push --force-with-lease`
* `put` – `push --tags`
* `subu` – `submodule update --init --recursive`
* `subr` – `submodule update --remote --recursive`
* `pushu` – `push -u origin HEAD`

The `.gitconfig_shared` also contains a difftool and mergetool definitions for
`nvim`, as well as an additional mergetool definition for `nvimfugitive` for
`nvim` using the `fugitive.vim` plugin. The tools are not enabled in this
configuration, rather copy the following to your `.gitconfig`:

    [diff]
    	tool = nvim
    [merge]
    	tool = nvimfugitive

### ssh

The configuration `.ssh/config_shared` sets up some defaults. It is not used by
default, i.e., it needs to be included from `~/.ssh/config` with:

    Include config_shared

### X11

The included `.XResources` sets up `xterm` with my light background colour
scheme.

### Terminal.app

The files `~/Documents/Arkku.terminal` and `~/Documents/Arkku Dark.terminal`
(on macOS only) contain settings for Terminal.app, including keyboard bindings
and colour schemes (the light is almost the same as my ancient `xterm` theme
and the dark is the same as my Neovim colour scheme). These files need to be
opened and imported into Terminal settings to take effect.

### Screen

A legacy configuration for `screen` is included, since `screen` is still useful
as a serial port terminal.

### indent

Settings are provided in `.indent.pro` for sensible C indentation.

### lldb and gdb

Settings are provided for lldb and gdb, that both simply set Intel syntax for
assembly.

### radare2

Settings are provided for radare2, mainly to set Intel syntax for assembly and
to enable fancy UTF-8.

### XCode

Colour schemes and key bindings are included for XCode. They need to be
selected from preferences to be active.

* [Swift development snapshots](https://swift.org/download/#snapshots)

To use the Swift development toolchain:

``` sh
export PATH="/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:$PATH"
```

### Additional Development Tools

* [sourcekit-lsp](https://github.com/apple/sourcekit-lsp)
* [universal-ctags](https://github.com/universal-ctags/ctags)
* [ccls](https://github.com/MaskRay/ccls)
* [solargraph](https://github.com/castwide/solargraph) (gem)

``` vim
:CocInstall coc-json
:CocInstall coc-html
:CocInstall coc-css
:CocInstall coc-yaml
:CocInstall coc-sourcekit
:CocInstall coc-tsserver
:CocInstall coc-solargraph
```

