#!/usr/bin/env node
// Records the expected results of the POSIX shell conformance corpus by running
// every script in REAL shells: /bin/dash, /bin/bash and /bin/bash --posix.
//
//   node tests/posix/generate.js            regenerate expected.json and expected-syntax.json
//   node tests/posix/generate.js --check    rerun everything and compare with the stored JSON
//                                           (writes nothing; exit status 1 on any difference)
//   node tests/posix/generate.js '01*'      only rerun the scripts whose name matches; the stored
//                                           entries of the other scripts are kept
//   --jobs N                                run N scripts at a time (default: number of CPUs)
//
// Each script runs twice per shell (the two runs must agree), each time in a fresh empty
// temporary directory (under os.tmpdir(), so TMPDIR is honoured), copied there as t.sh, as:
//
//   env -i HOME=/home/yourname USER=yourname LOGNAME=yourname PATH=/usr/bin:/bin SHELL=/bin/sh \
//       LANG=en_US.UTF-8 TERM=xterm-256color <shell> t.sh < /dev/null
//
// Notes come from the comment header at the top of each script (the first block of lines
// that start with '#'):
//   # <what the case checks>          (may span several lines)
//   # differs: <why dash and bash differ>
//   # note: <anything else worth knowing, e.g. about bash --posix or bash 5.2 on Ubuntu>
// "differs" is computed: true when dash and bash differ in stdout or exit status.
'use strict';
const fs = require('fs');
const os = require('os');
const path = require('path');
const cp = require('child_process');

const ROOT = __dirname;
const SETS = [
  { dir: 'cases', out: 'expected.json' },
  { dir: 'syntax', out: 'expected-syntax.json' },
];
const SHELLS = {
  dash: ['/bin/dash'],
  bash: ['/bin/bash'],
  bashPosix: ['/bin/bash', '--posix'],
};
const ENV = [
  'HOME=/home/yourname', 'USER=yourname', 'LOGNAME=yourname', 'PATH=/usr/bin:/bin',
  'SHELL=/bin/sh', 'LANG=en_US.UTF-8', 'TERM=xterm-256color',
];
const RUNS = 2;
const TIMEOUT_MS = 10000;
const SLOW_MS = 1000;
// Notes for scripts that cannot carry a comment header (keyed by name without the number).
const NOTES_FALLBACK = {
  'status-empty-script': 'A completely empty script (zero bytes) prints nothing and exits with status 0.',
};

const argv = process.argv.slice(2);
const check = argv.includes('--check');
let jobs = Math.max(2, os.cpus().length);
const filters = [];
for (let i = 0; i < argv.length; i++) {
  if (argv[i] === '--check') continue;
  if (argv[i] === '--jobs') { jobs = Math.max(1, parseInt(argv[++i], 10) || 1); continue; }
  filters.push(argv[i]);
}
const globToRe = (g) => new RegExp('^' + g.replace(/[.+^${}()|\\]/g, '\\$&').replace(/\*/g, '.*').replace(/\?/g, '.') + '$');
const match = (name) => !filters.length || filters.some(f => globToRe(f).test(name));

// Cases may leave mode 000 files or directories behind: make everything removable first.
function makeRemovable(p) {
  let st;
  try { st = fs.lstatSync(p); } catch { return; }
  if (st.isSymbolicLink()) return;
  try { fs.chmodSync(p, 0o700); } catch { /* ignore */ }
  if (st.isDirectory()) for (const e of fs.readdirSync(p)) makeRemovable(path.join(p, e));
}

function runOnce(file, shell) {
  return new Promise((resolve) => {
    const dir = fs.mkdtempSync(path.join(os.tmpdir(), 'posix-case-'));
    fs.copyFileSync(file, path.join(dir, 't.sh'));
    const stdin = fs.openSync('/dev/null', 'r');
    const t0 = Date.now();
    const child = cp.spawn('/usr/bin/env', ['-i', ...ENV, ...shell, 't.sh'], {
      cwd: dir, stdio: [stdin, 'pipe', 'pipe'],
    });
    fs.closeSync(stdin);
    const out = [], err = [];
    child.stdout.on('data', (d) => out.push(d));
    child.stderr.on('data', (d) => err.push(d));
    let timedOut = false;
    const timer = setTimeout(() => { timedOut = true; child.kill('SIGKILL'); }, TIMEOUT_MS);
    child.on('close', (code, signal) => {
      clearTimeout(timer);
      const ms = Date.now() - t0;
      makeRemovable(dir);
      fs.rmSync(dir, { recursive: true, force: true });
      const status = code !== null ? code : 128 + (os.constants.signals[signal] || 0);
      resolve({
        result: { stdout: Buffer.concat(out).toString('utf8'), stderr: Buffer.concat(err).toString('utf8'), status },
        timedOut, ms,
      });
    });
  });
}

async function pool(tasks, n) {
  const results = new Array(tasks.length);
  let next = 0;
  async function worker() { while (next < tasks.length) { const i = next++; results[i] = await tasks[i](); } }
  await Promise.all(Array.from({ length: Math.min(n, tasks.length) }, worker));
  return results;
}

function header(text) {
  const parts = { desc: [], differs: [], note: [] };
  let cur = 'desc';
  for (const l of text.split('\n')) {
    if (!l.startsWith('#')) break;
    let s = l.replace(/^#/, '').trim();
    const m = /^(differs|note):\s*(.*)$/i.exec(s);
    if (m) { cur = m[1].toLowerCase(); s = m[2]; }
    if (s) parts[cur].push(s);
  }
  return { desc: parts.desc.join(' '), differs: parts.differs.join(' '), note: parts.note.join(' ') };
}

const same = (a, b) => a.stdout === b.stdout && a.stderr === b.stderr && a.status === b.status;

async function main() {
  let problems = 0;
  const warn = (m) => { problems++; console.error('  ! ' + m); };
  const info = (m) => console.error('  - ' + m);
  for (const set of SETS) {
    const dir = path.join(ROOT, set.dir);
    if (!fs.existsSync(dir)) continue;
    const outFile = path.join(ROOT, set.out);
    const stored = fs.existsSync(outFile) ? JSON.parse(fs.readFileSync(outFile, 'utf8')) : {};
    const files = fs.readdirSync(dir).filter(f => f.endsWith('.sh')).sort();
    const names = files.map(f => f.replace(/\.sh$/, ''));
    const todo = names.filter(match);
    console.error(`${set.dir}: ${files.length} scripts, running ${todo.length} in ${Object.keys(SHELLS).length} shells x ${RUNS} runs`);
    const tasks = [];
    for (const name of todo) for (const key of Object.keys(SHELLS)) for (let r = 0; r < RUNS; r++) {
      tasks.push(async () => ({ name, key, r, ...(await runOnce(path.join(dir, name + '.sh'), SHELLS[key])) }));
    }
    const runs = await pool(tasks, jobs);
    const byCase = {};
    for (const x of runs) ((byCase[x.name] ||= {})[x.key] ||= [])[x.r] = x;
    const out = {};
    // A filtered regeneration keeps the stored entries of the scripts it does not run.
    for (const name of names) if (!match(name) && stored[name]) out[name] = stored[name];
    for (const name of todo) {
      const text = fs.readFileSync(path.join(dir, name + '.sh'), 'utf8');
      const entry = {};
      for (const key of Object.keys(SHELLS)) {
        const rs = byCase[name][key];
        if (rs.some(x => x.timedOut)) warn(`${name} [${key}]: timed out after ${TIMEOUT_MS} ms`);
        const slowest = Math.max(...rs.map(x => x.ms));
        if (slowest > SLOW_MS) info(`${name} [${key}]: took ${slowest} ms`);
        if (rs.some(x => !same(x.result, rs[0].result))) warn(`${name} [${key}]: not deterministic (the runs differ)`);
        if (/[^\x00-\x7f]/.test(rs[0].result.stdout + rs[0].result.stderr)) warn(`${name} [${key}]: non-ASCII output`);
        entry[key] = rs[0].result;
      }
      entry.differs = entry.dash.stdout !== entry.bash.stdout || entry.dash.status !== entry.bash.status;
      const h = header(text);
      let notes = h.desc || NOTES_FALLBACK[name.replace(/^\d+-/, '')] || '';
      if (!notes) warn(`${name}: no description comment`);
      if (entry.differs) {
        if (h.differs) notes += ' Differs: ' + h.differs;
        else warn(`${name}: dash and bash differ but there is no '# differs:' explanation`);
      } else if (h.differs) {
        warn(`${name}: has a '# differs:' line but dash and bash agree on stdout and status`);
      }
      if (h.note) notes += ' Note: ' + h.note;
      entry.notes = notes;
      if (check) {
        const old = stored[name];
        if (!old) warn(`${name}: not in ${set.out}`);
        else {
          for (const key of Object.keys(SHELLS)) {
            if (!old[key] || !same(old[key], entry[key])) warn(`${name} [${key}]: result differs from ${set.out}`);
          }
          if (old.notes !== entry.notes || old.differs !== entry.differs) warn(`${name}: notes or differs flag differ from ${set.out}`);
        }
      }
      out[name] = entry;
    }
    if (check) {
      for (const k of Object.keys(stored)) if (!names.includes(k)) warn(`${k}: in ${set.out} but there is no ${set.dir}/${k}.sh`);
    } else {
      const sorted = {};
      for (const k of Object.keys(out).sort()) sorted[k] = out[k];
      fs.writeFileSync(outFile, JSON.stringify(sorted, null, 2) + '\n');
      const n = Object.keys(sorted).length, d = Object.values(sorted).filter(e => e.differs).length;
      console.error(`  wrote ${set.out}: ${n} cases, ${d} where dash and bash differ`);
    }
  }
  if (problems) { console.error(`${problems} problem(s)`); process.exit(1); }
  console.error(check ? 'check passed: the results match the stored expectations' : 'done');
}

main().catch((e) => { console.error(e); process.exit(1); });
