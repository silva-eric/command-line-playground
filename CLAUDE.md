# Command line playground: handoff notes

A browser-based practice terminal with a live file-system tree, built for Reduzer School (cohort 2, P01 "Command Line Fundamentals", taught online by Eric). Students are on three kinds of laptop: **Mac**, **Ubuntu Linux**, and **Windows + WSL (Ubuntu)**.

- Repo: https://github.com/silva-eric/command-line-playground (public, branch `main`)
- Live site: https://silva-eric.github.io/command-line-playground/ (GitHub Pages, deploy from `main`, `/ (root)`)
- Earlier copy: a Claude artifact (same page, but loads fonts from Google Fonts). The repo is now the source of truth.

## Files

```
index.html        the whole app: HTML + CSS + JS in one file, no build step, no dependencies
fonts/            Inter (Light 300, Regular 400, Bold 700) + JetBrains Mono (Regular, Bold), woff2, SIL OFL licences
README.md         public description
.nojekyll         stops GitHub Pages running Jekyll
CLAUDE.md         this file
```

Deploy = commit and push to `main`; Pages rebuilds in about a minute. Keep it a single self-contained file: no frameworks, no CDN, no network requests (fonts are local via `@font-face`).

## Owner's preferences and decisions (keep these)

- **Lightweight**: one file (~210 KB, ~66 KB gzipped), no dependencies, instant start. A real Linux in the browser (v86, Alpine) was considered and rejected: 8 to 14 MB, slow boot, BusyBox has no man pages, and it would break the live tree.
- **Mac and Ubuntu are equals.** Never frame Mac as the exception ("Mac users, imagine /Users"). Show both variants side by side, or use `~` where it's the same everywhere.
- Placeholder username is `yourname` (the deck uses `<yourname>`). There's an editable "Your name" field.
- **Brand (Reduzer)**: red `#FF002E`, black, white, greys only. Fonts Inter + JetBrains Mono; weights 300/400/700 only (no 600/800). British spelling, typographic apostrophes and quotes in UI text (straight quotes only in code).
- **Text must wrap, never be hidden**: the command line wraps at the window edge like a real terminal (`word-break: break-all`); prose notes wrap by word; the man pager wraps with hanging indents.
- **Tree styling** (three kinds must be obviously different): every box has an icon before its name, a filled folder for folders and an outlined page with a turned-down corner for files (the legend uses the same icons); your folders = solid black (white in dark mode); files = darker outline; system folders/files = grey fill, grey text and icon, dashed outline; current folder = solid red with a white icon.
- **Dot animation**: constant on-screen speed `PX_PER_SEC = 160` with `PAUSE = 525` ms at each folder passed (owner asked for "50% slower" than 240/350). Never compress long routes into a fixed duration. A red trail line grows behind the dot along the route, stays for `TRAIL_HOLD = 1000` ms after it arrives, then fades over `TRAIL_FADE = 800` ms.
- Switching Ubuntu · WSL / Mac must **not** print anything in the terminal.
- `sudo` is always off. You can look anywhere; you can only change things inside your home folder.

## How it works (index.html)

**State**: `S` holds the page (os, user, root, home, shown, keep, hist, cont/ctx for continuation lines, asking/inputJob, jobs, notices, joiners, fg, pager, editor, perms...). The shell itself is `E`, an environment `{ cwd, prev, vars, exported, status, args, arg0, funcs, opts, ro, traps, aliases, sh, script, line, inter, ... }`; `S.cwd`, `S.prev`, `S.vars`, `S.exported` and `S.status` are getters onto it. `MAIN` is the interactive shell's environment. Subshells, pipeline parts, `$( )` and background jobs get `sub(E)`; scripts get `proc()` (a new process: only exported variables, no functions). `flav()` is `bash`, `zsh` or `dash` (Ubuntu's `sh`; a Mac's `sh` is bash) and decides grammar extras and error wording.

**File system**: nodes `{ id, name, dir, kids, text, parent, leaving, flash, open, mode }`.
- `buildRoot()` builds the system tree per OS. Ubuntu/WSL: `/bin /etc /home /mnt/c`. Mac: `/Applications /Library /System /Users(Shared) /bin /etc`. The home node is detached and re-attached when the OS switch flips, so the student's files survive.
- `mine(n)` means "inside home". `can(n, 'r'|'w'|'x')` uses owner bits for home nodes and "other" bits for system nodes (so system writes fail naturally).
- Paths: `split()`, `walk()` (checks `x` on each folder), `resolve()`, `resolveNew()`. `full()` gives absolute paths, `tilde()` gives `~/…` inside home.

**Shell (POSIX)**: `Lexer` turns text into words (which keep their quoting as parts: `L` literal, `P` parameter, `C` command substitution, `A` arithmetic) and operators; here-document bodies are read at the next newline. `Parser` follows the POSIX grammar: lists, `&&`/`||`, pipelines, `!`, `( )`, `{ }`, `if`, `while`/`until`, `for`, `case`, functions, redirections with fd numbers, plus bash/zsh extras (`[[ ]]`, `(( ))`, `for ((;;))`, `function`, `<<<`, `&>`) that dash doesn't have. An unfinished command throws `Incomplete` (the prompt becomes `> `, or zsh's `for> `, `dquote> `...); bad grammar throws `SynErr`. Expansions run when a command runs, in POSIX order: brace expansion (not in dash), `~`, `$x`/`${x...}` (all POSIX forms plus bash's `/`, `:off:len`, `^^`), `$( )` and backticks, `$(( ))` (`arith()`), field splitting with IFS (not in zsh), pathname expansion (`globPath()`: `*` `?` `[...]` in every path part; zsh errors on no match), quote removal.
- Every command runs as a generator (`exec()`, `simple()`, `invoke()`, ...). Waiting is a `yield`: `{ sleep }`, `{ input }` (read, cat and friends, rm -i), `{ pager }`, `{ editor }`, `{ join }` (wait, fg), `{ tick }` (every 1000 commands, so endless loops don't freeze the page). `pump(job)` resumes a job, swapping `E`, `IO` and `CUR`; `S.fg` is the job you typed, background jobs live in `S.jobs`. Ctrl + C stops the job (or runs a `trap ... INT`), Ctrl + D ends input.
- Output goes through sinks: `TERM` (keeps an unfinished line open, so `printf 'Name: '; read n` stays on one line; zsh marks it with `%`), `buffer()` for pipes and `$( )`, files (`openOut()` empties or creates the file before the command runs), `NUL`. `IO.fd` maps 0/1/2 (and more, via `exec 3>`) to them; stdin `null` is the keyboard. `line(text, cls)`: no cls = stdout, `'err'` = stderr (red, sets `$?=1`), `'note'` = grey explanation, `'trace'` = set -x.
- Scripts: `sh`/`bash`/`dash`/`zsh` FILE or -c, `./file` (needs `chmod +x`; `#!` picks the shell), `.`/`source`. Errors use each shell's own wording via `who()`: `bash`, `t.sh: line 3: x: command not found`, `t.sh: 3: x: not found` (dash), `t.sh:3: command not found: x` (zsh).

**Commands** (`C.name(args, input)`; built-ins are listed in `SPECIAL` and `BI`, programs in `CMDS` and found on `$PATH` by `lookup()`): help, pwd, clear, whoami, id, date, history, exit, sudo, cd, ls (-a -l -R), mkdir (-p), touch, echo, printf, cat, head, tail, wc, grep (-i -v -n -c), sort (-r -n -u), uniq (-c), cut (-d -f), find (-name -type), tree (-a -d -F -L N; real-style `├──` output and the "N directories, M files" count; its man page says how to install it on a real laptop), which, cp (-r), mv, rm (-i -r -f; asks for write-protected files), rmdir, chmod (octal or `u+x`-style, -R), sleep, jobs, ps, kill (PID or `%N`), env, export, unset, man, less, more, nano, sh/bash/dash/zsh, seq, basename, dirname, expr, and the shell built-ins read, test/[, true, false, :, ., source, eval, exec, exit, return, break, continue, shift, set (-e -u -x -f -n -v -a, -o, --), readonly, local, trap (EXIT, INT, ...), wait, fg, type, command, getopts, alias, unalias, umask, let. Unknown `vim/git/python` (and `zsh` on Ubuntu) show Ubuntu's "can be installed with sudo apt install" message.
- Error wording follows the system: GNU/bash on Ubuntu (`rm: cannot remove 'x': Permission denied`), BSD/zsh on Mac (`rm: x: Permission denied`, `zsh: command not found: x`).
- The first Permission denied outside home prints a one-time note explaining sudo.

**Manual pages**: `MAN` (plain-language pages written for this project, not copied from real ones) and `BUILTIN` (cd, export, unset, jobs, history, help). Ubuntu `man cd` says "No manual entry" and suggests `help cd`; Mac `man cd` opens a `builtin(1)` page. The pager (`openPager`/`pagerDraw`/`pagerKey`) supports ↑ ↓ j k Enter, space/f, b, g, G, q.

**Input**: a visually hidden `<textarea id="cmd">` holds the text; `drawTyped()` mirrors it after the prompt with a blinking block cursor so long commands wrap. Tab completes commands and paths, ↑/↓ give history (a command typed over several lines is stored as one, like bash), Ctrl + C cancels, Ctrl + D ends input, Ctrl + L clears. Multi-line text (a paste, or a test) runs line by line, like a real paste.

**nano** (`C.nano`, `editor()`): an overlay with a real textarea. Ubuntu shows GNU nano 7.2, a Mac UW PICO 5.09 (what macOS calls nano). ^O writes out (asks for the name), ^X exits (asks "Save modified buffer?" Y/N/^C), ^K/^U cut and paste lines, ^W searches, ^C shows the position, ^G help, ^S saves (nano). Saving follows the same permission rules as everything else.

**Tree**: `render()` rebuilds the SVG each time. `lay()`/`place()` give a tidy top-down layout. `isOpen()` expands everything inside home, plus the folders on the way to home, to `cwd`, and to `S.keep` (during travel), plus `mnt`. `BOX_H`/`LEVEL` grow when *Show permissions* is on (mode string under each label). Flash classes: `new` (pop), `changed` (ring), `leaving` (fade 850 ms, then detach).
- `travel(from, to)` walks up to the shared ancestor and then down, along the elbow lines (`route()` gives the points). `dotAt` keeps the dot's position so a re-render mid-animation (run() always re-renders) doesn't hide it. A bug where the dot vanished came from exactly this.
- `trail` holds the red line: its points while the dot moves, then `route()` is recomputed on each render while it fades, so it stays on the lines if the layout changes. `S.keep` is only cleared when the trail has gone, so the folders opened for the trip stay open under it. Reduced motion: no dot, no trail.
- Redraws again on `document.fonts.ready` so box widths are measured with the real font.

## Testing

Run `node tests/run.js` before every commit (Node 24 and Google Chrome, no dependencies; `tests/README.md` has the options). It drives the page in headless Chrome with real key events and runs three suites:
- `regression`: 256 scenarios, 425 runs in both modes, compared with recorded goldens (terminal lines and their classes, the tree, the status line, pager screens). After an intended change, read the diff, then re-record only those scenarios with `--update 'regression:NAME,...'`.
- `posix`: 270 scripts in `tests/posix/` run with `sh t.sh` and compared with real dash: stdout, stderr and status, exactly. `node tests/posix/generate.js` re-records the expectations from the real shells.
- `posix-bash`: the same scripts with `bash t.sh`, where dash and bash agree; `tests/posix/bash5.json` holds the few places where Ubuntu's bash 5.2 differs from the Mac's bash 3.2 that recorded them.

Checks the suites include: `sort names.txt | uniq -c` gives `      3 Ada`, `ls / | wc -l` gives `4`; Permission denied for `chmod 000 f; cat f` and `chmod 600 dir; cd dir`, Operation not permitted for `chmod 600 /etc/hosts`; `sleep 100 &` gives `[1] 1201` and `kill %1` `[1]+  Terminated              sleep 100`; the one-time sudo note; the dot moving and its trail fading; switching laptop prints nothing; no page errors and no requests that leave the machine.

## Known limitations and ideas

- On a Mac the tree draws smaller (six system folders side by side at the top).
- It's a simulation: the programs are the ones listed above (no sed, awk, tr, xargs...), no networking.
- Pipelines run one part after another, not at the same time, so an endless loop piped into `head` never stops on its own (Ctrl + C does). No Ctrl + Z / stopped jobs.
- bash is bash 5 as on Ubuntu (POSIX parts checked against real dash and bash); zsh mode covers zsh's main differences (no word splitting, last pipeline part in the shell, `no matches found`, `for>` prompts, `#` not a comment when typed, `%` after a line without newline), not all of zsh.
- Possible next steps: move to a Reduzer GitHub organisation or a `reduzer.tech` subdomain (Pages can redirect); choose a licence (README currently says "All rights reserved"); add an "About" line; optional privacy-friendly analytics; a Part 2 lesson deck (permissions, processes, environment variables) that uses this playground.
