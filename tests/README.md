# Tests

Everything runs from one script with no dependencies: Node 24 and Google Chrome (set `CHROME=/path/to/chrome` if it is not in `/Applications`). `tests/run.js` starts headless Chrome on a temporary profile, opens the page from `file://`, types into the terminal with real key events over the DevTools protocol, and compares what the page shows with the stored expectations.

```
node tests/run.js                      # every suite, against ./index.html
node tests/run.js regression           # one suite
node tests/run.js 'regression:ls/*,cd/dash'   # some scenarios (* matches anything; no @os = both)
node tests/run.js --page /path/to/index.html regression
node tests/run.js --help               # all options (--jobs, --timeout, --verbose, --details, --list...)
```

It exits with 0 when everything passes, 1 when something fails and 2 when it cannot run, for example when the page throws while loading (it checks one load before running anything). Failures are listed as they happen. The details come at the end, as diffs where `-` is expected and `+` is actual. A full run of the regression suite takes about 85 s on 6 tabs. Most of that is waiting for the tree's dot and trail after each `cd`.

## regression: today's behaviour, captured

`regression/scenarios.json` holds 256 scenarios. Most run in both modes, Ubuntu (`name@ubuntu`) and Mac (`name@mac`), which makes 425 runs. Together they cover every command and option, every error and its wording, the one-time sudo note, jobs, the pager keys, Tab completion, ↑ history, Ctrl + C and Ctrl + L, the Your name field, Show permissions, Start again, switching laptop, dark mode, and the checks listed in CLAUDE.md. The format is explained at the top of the file. A step is a command string, or `{"type"}`, `{"key"}`, `{"click"}`, `{"name"}`, `{"wait"}`, `{"snap"}` or `{"check"}`.

Each scenario starts with a freshly loaded page. After every step the runner waits until the prompt is showing again, with no `.pager` and no `.editor` open, unless the step says to wait for something else. At the end it waits until the dot and its trail have gone. Then it records:

- the terminal: each line of `#out` as its class (`""`, `err`, `note`, `cmdl`) and text, plus the folder names drawn in colour (`d`)
- the tree: each box in order, with its depth, its label and its classes (`dir`/`file`, `sys`, `here`), and its permissions when they are shown
- the status line (`#last`), the prompt and the text left on the command line
- any snapshots taken on the way: pager screens, the tree, the screen

A run fails on any difference, on any page error or `console.error`, and on any request that leaves the machine.

Some things change from run to run, and the runner pins or removes them:

- `date` reads a clock that starts at Tue 3 Nov 2026 09:05 UTC, and the time of day is replaced by `hh:mm:ss`.
- The tree's flash classes (`new`, `changed`, `leaving`) are not recorded.
- The window is 1400 × 900, the colour scheme is light unless a scenario asks for dark, and the fonts are loaded before the first step.

**Updating goldens.** Read the diff first. If the change is intended, re-record just those scenarios:

```
node tests/run.js --update 'regression:help/*,ls/root'
```

Running `node tests/run.js --update` on its own re-records everything. A run that fails a check, throws a page error or times out is never saved. Goldens must be recorded against a known-good page. The baseline was recorded from `git show HEAD:index.html` at 66b8717 and then passed twice more without changes.

**When the shell became POSIX-compliant** (the commit after the baseline), 36 scenarios were re-recorded after their diffs were read. In each, the old shell had simplified something that bash, dash, zsh or the real program does differently:

- `~` is expanded before a command sees it, so `find ~`, `mv` and `rmdir` show `/home/yourname`. `/*/c` expands across folders.
- `echo -n` and `printf` without `\n` leave the line open (zsh marks it with `%`); multi-line output is one line element per line.
- zsh: `echo` reads `\n`, an unmatched `[]` is "no matches found", continuation prompts are `dquote>`, `quote>`, `pipe>`, and a parse error gives `$?` 1.
- `>` empties or creates the file before the command runs, so `tree > t.txt` lists `t.txt`.
- A missing command gives status 127, `./run` says "No such file or directory", `man nosuch` exits 16 on Ubuntu.
- `cat` with no file reads the keyboard until Ctrl + D, `nano` is an editor, `export` lists like `export -p`, `grep` patterns are basic regular expressions (`p+` is literal), GNU and BSD `sleep` and `printf` complain about bad numbers.
- New programs change `ls /bin`, `tree /`, `which`, `help` and Tab completion; zsh is not on Ubuntu.

The `shell/*` scenarios were added then: scripts written in `nano`, `read`, continuation lines, Ctrl + C, Ctrl + D, jobs and `wait`, script errors, dash versus bash, `set -x`.

Also, at HEAD a Start again or laptop switch made while the dot is still moving leaves no box marked "here". Scenarios wait for the tree (`{"wait": "tree"}`) before such clicks, so this does not show up in the goldens.

## posix and posix-bash: the shell against real shells

The cases live in `posix/cases/NAME.sh` and `posix/syntax/NAME.sh` (named `syntax/NAME`). The expectations were recorded from real `dash` and `bash` by `posix/generate.js` into `posix/expected.json` and `posix/expected-syntax.json`. For each case, the runner loads a fresh page in Ubuntu mode and makes two submits:

```
cat > t.sh <<'__PG_EOF__'
...the case file...
__PG_EOF__
```

and then `sh t.sh; echo "__STATUS=$?"`. From the second step, stdout is every line that is not `err`, `note` or `cmdl`, minus the `__STATUS` marker. Text printed just before the marker on its line counts as output without a final newline. stdout and the status must equal `dash.stdout` and `dash.status` exactly. stderr is the `err` lines and is compared separately: a case where only stderr differs is reported as `STDERR`, not `FAIL`, and `--ignore-stderr` lets those pass. `posix-bash` runs `bash t.sh` against the `bash` results, only for cases marked `"differs": false`. Each case has a timeout (`--case-timeout`, 20 s by default), and a page that stops responding is replaced, so the suite never hangs. The playground's `bash` follows bash 5.2, as on Ubuntu, while the expectations come from the Mac's bash 3.2; `posix/bash5.json` lists the cases where the two differ, with the reason, and `posix-bash` uses those results instead. The generator does not touch that file.
