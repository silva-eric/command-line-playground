# Command line playground

A practice terminal for learning the command line, made for Reduzer School.

Type real commands on the left and watch the file system tree on the right change as you go: new files and folders appear, deleted ones fade away, and a red dot travels along the tree every time you `cd`.

**Try it:** open `index.html` in any browser, or visit the GitHub Pages site for this repository.

## What you can do

- **Move around:** `pwd`, `ls` (`-a`, `-l`, `-R`), `cd` (`..`, `~`, `-`, `/`), `find`, `which`
- **Files and folders:** `mkdir -p`, `touch`, `cp -r`, `mv`, `rm -i -r`, `rmdir`
- **Read and write:** `cat`, `less`, `more`, `head`, `tail`, `echo`, `printf`, with `>`, `>>` and `<`
- **Work with text:** `grep`, `sort`, `uniq`, `wc`, `cut`, pipes (`|`) and `*` wildcards
- **Permissions:** `chmod` (numbers or letters), `id`, `whoami`, and a *Show permissions* switch on the tree
- **Processes:** `sleep`, `sleep 100 &`, `jobs`, `ps`, `kill`, Ctrl + C
- **Settings:** `$HOME`, `$PATH`, `$?`, `export`, `env`, `unset`
- **Help:** `man` for every command, `help` for shell built-ins like `cd`

Switch between **Ubuntu · WSL** and **Mac** to see each system's prompt, home folder and error messages.

## Good to know

- It is a simulation, not a real Linux system: nothing is installed and nothing leaves your browser.
- You can look anywhere, but you can only change things inside your home folder. Outside it, changes need `sudo`, which is switched off.
- Everything resets when you reload the page or press *Start again*.

## Credits

Fonts: [Inter](https://rsms.me/inter/) and [JetBrains Mono](https://www.jetbrains.com/lp/mono/), both under the SIL Open Font License (see `fonts/`).

© 2026 Reduzer Technologies. All rights reserved.
