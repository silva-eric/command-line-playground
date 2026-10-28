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

**Pending:** the latest `index.html` (folded-corner files, greyed system folders, "System (look, don't touch)" legend) may not be committed yet. Check `git log`.

## Owner's preferences and decisions (keep these)

- **Lightweight**: one small file (~75 KB), instant start. A real Linux in the browser (v86, Alpine) was considered and rejected: 8 to 14 MB, slow boot, BusyBox has no man pages, and it would break the live tree.
- **Mac and Ubuntu are equals.** Never frame Mac as the exception ("Mac users, imagine /Users"). Show both variants side by side, or use `~` where it's the same everywhere.
- Placeholder username is `yourname` (the deck uses `<yourname>`). There's an editable "Your name" field.
- **Brand (Reduzer)**: red `#FF002E`, black, white, greys only. Fonts Inter + JetBrains Mono; weights 300/400/700 only (no 600/800). British spelling, typographic apostrophes and quotes in UI text (straight quotes only in code).
- **Text must wrap, never be hidden**: the command line wraps at the window edge like a real terminal (`word-break: break-all`); prose notes wrap by word; the man pager wraps with hanging indents.
- **Tree styling** (three kinds must be obviously different): your folders = solid black (white in dark mode); files = page shape with a folded top-right corner and darker outline; system folders/files = grey fill, grey text, dashed outline; current folder = solid red.
- **Dot animation**: constant on-screen speed `PX_PER_SEC = 160` with `PAUSE = 525` ms at each folder passed (owner asked for "50% slower" than 240/350). Never compress long routes into a fixed duration.
- Switching Ubuntu · WSL / Mac must **not** print anything in the terminal.
- `sudo` is always off. You can look anywhere; you can only change things inside your home folder.

## How it works (index.html)

**State**: a single object `S` (os, user, root, home, cwd, shown, keep, prev, hist, cont, asking/rmAsk, sleeping, cap, err, status, vars, exported, jobs, notices, pid, pager, perms...).

**File system**: nodes `{ id, name, dir, kids, text, parent, leaving, flash, open, mode }`.
- `buildRoot()` builds the system tree per OS. Ubuntu/WSL: `/bin /etc /home /mnt/c`. Mac: `/Applications /Library /System /Users(Shared) /bin /etc`. The home node is detached and re-attached when the OS switch flips, so the student's files survive.
- `mine(n)` means "inside home". `can(n, 'r'|'w'|'x')` uses owner bits for home nodes and "other" bits for system nodes (so system writes fail naturally).
- Paths: `split()`, `walk()` (checks `x` on each folder), `resolve()`, `resolveNew()`. `full()` gives absolute paths, `tilde()` gives `~/…` inside home.

**Shell**: `tokenize()` handles quotes, `\` escapes, `$VAR`, `${VAR}`, `$?`, and the operators `| & < > >>`. `glob()` expands `*` and `?` in the last path segment (bash keeps the pattern if nothing matches; zsh errors "no matches found"). `run()` handles pipelines (`S.cap` captures stdout between stages), `<` input, `>`/`>>` via `writeFile()`, `NAME=value`, and a trailing `&`. `line(text, cls)` writes stdout (captured when piping); `'err'` = stderr (red) and sets `$?=1`; `'note'` = grey explanation.

**Commands** (`C.name(args, input, bg)`): help, pwd, clear, whoami, id, date, history, exit, sudo, cd, ls (-a -l -R), mkdir (-p), touch, echo, printf, cat, head, tail, wc, grep (-i -v -n -c), sort (-r -n -u), uniq (-c), cut (-d -f), find (-name -type), which, cp (-r), mv, rm (-i -r -f; asks for write-protected files), rmdir, chmod (octal or `u+x`-style, -R), sleep (fg + `&`), jobs, ps, kill (PID or `%N`), env, export, unset, man, less, more. Unknown `tree/nano/vim/git/python` show Ubuntu's "can be installed with sudo apt install" message.
- Error wording follows the system: GNU/bash on Ubuntu (`rm: cannot remove 'x': Permission denied`), BSD/zsh on Mac (`rm: x: Permission denied`, `zsh: command not found: x`).
- The first Permission denied outside home prints a one-time note explaining sudo.

**Manual pages**: `MAN` (plain-language pages written for this project, not copied from real ones) and `BUILTIN` (cd, export, unset, jobs, history, help). Ubuntu `man cd` says "No manual entry" and suggests `help cd`; Mac `man cd` opens a `builtin(1)` page. The pager (`openPager`/`pagerDraw`/`pagerKey`) supports ↑ ↓ j k Enter, space/f, b, g, G, q.

**Input**: a visually hidden `<textarea id="cmd">` holds the text; `drawTyped()` mirrors it after the prompt with a blinking block cursor so long commands wrap. Tab completes commands and paths, ↑/↓ give history, Ctrl + C cancels, Ctrl + L clears.

**Tree**: `render()` rebuilds the SVG each time. `lay()`/`place()` give a tidy top-down layout. `isOpen()` expands everything inside home, plus the folders on the way to home, to `cwd`, and to `S.keep` (during travel), plus `mnt`. `BOX_H`/`LEVEL` grow when *Show permissions* is on (mode string under each label). Flash classes: `new` (pop), `changed` (ring), `leaving` (fade 850 ms, then detach).
- `travel(from, to)` walks up to the shared ancestor and then down, along the elbow lines. `dotAt` keeps the dot's position so a re-render mid-animation (run() always re-renders) doesn't hide it. A bug where the dot vanished came from exactly this.
- Redraws again on `document.fonts.ready` so box widths are measured with the real font.

## Testing

Tests were run with Playwright (Chromium) against the file, in both themes (`color_scheme` light/dark) and both OS modes. Useful checks:
- `mkdir -p cli-practice/notes`, `cd cli-practice`, `echo Ada >> names.txt` ×N, `sort names.txt | uniq -c` gives `      3 Ada`; `ls / | wc -l` gives `4` (GNU: no padding for a single count).
- `chmod 000 f; cat f` gives Permission denied; `chmod 600 dir; cd dir` gives Permission denied; `chmod 600 /etc/hosts` gives Operation not permitted.
- `sleep 100 &` gives `[1] 1201`; `kill %1` gives `[1]+  Terminated              sleep 100`.
- `touch /etc/x`, `rm /bin/ls` give Permission denied plus the one-time sudo note.
- Dot visible mid-move: sample `#tree circle.dot` visibility and position every 100 ms after a `cd`.
- No page errors and no external requests (apart from none at all on the Pages build).

## Known limitations and ideas

- On a Mac the tree draws smaller (six system folders side by side at the top).
- It's a simulation: no real programs, no scripts, no `./run`, no networking.
- Possible next steps: move to a Reduzer GitHub organisation or a `reduzer.tech` subdomain (Pages can redirect); choose a licence (README currently says "All rights reserved"); add an "About" line; optional privacy-friendly analytics; a Part 2 lesson deck (permissions, processes, environment variables) that uses this playground.
