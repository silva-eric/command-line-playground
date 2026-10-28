#!/usr/bin/env node
'use strict';
/*
 * Test runner for the command line playground (index.html).
 * No dependencies: Node 24 (built-in WebSocket) and Google Chrome, driven over the DevTools protocol.
 * Every scenario gets a freshly loaded page; text goes in with Input.insertText and keys with
 * Input.dispatchKeyEvent, so the page sees the same events as when a student types.
 *
 *   node tests/run.js [options] [suite[:filter] ...]
 *
 * Suites (default: all three)
 *   regression   golden captures of the terminal, the tree and the status line  (tests/regression)
 *   posix        tests/posix/cases/NAME.sh (expected.json) and tests/posix/syntax/NAME.sh
 *                (expected-syntax.json, names syntax/NAME) run with `sh t.sh`, compared with dash
 *   posix-bash   the same cases run with `bash t.sh`, compared with bash (cases with "differs": false)
 * A filter is a comma-separated list of names where * matches anything, for example
 *   regression:ls/*,cd/*   regression:rm/interactive@mac   posix:quoting-*
 * A regression name without @ubuntu or @mac matches both.
 *
 * Options
 *   --page FILE        the page to test (default: index.html at the repo root)
 *   --update           write the goldens of the selected regression scenarios from this run
 *   --jobs N           tabs that run in parallel (default 6)
 *   --timeout MS       how long one step may take (default 15000)
 *   --case-timeout MS  how long `sh t.sh` may take in the POSIX suites (default 20000)
 *   --ignore-stderr    POSIX suites: a case whose stdout and status match passes even if stderr differs
 *   --posix-dir DIR    where the POSIX cases live (default tests/posix)
 *   --details N        print the details of at most N failures (default 40; 0 = all)
 *   --verbose          print every result, not only failures
 *   --list             print the selected scenario and case names, then exit
 *   --headed           show the browser windows (for debugging)
 *   CHROME=/path/to/chrome overrides the browser.
 */

const fs = require('fs');
const path = require('path');
const os = require('os');
const { spawn } = require('child_process');
const { pathToFileURL } = require('url');

const TESTS = __dirname;
const REPO = path.resolve(TESTS, '..');
const SCENARIOS = path.join(TESTS, 'regression', 'scenarios.json');
const GOLDEN = path.join(TESTS, 'regression', 'golden.json');
const VIEWPORT = [1400, 900];
const FAIL_FAST_MS = 1500;     // a step that settles in the wrong state (pager instead of prompt...) fails after this long
const SETTLE_POLLS = 3;        // a state counts once it has been seen this many polls in a row (20 ms apart)
// `date` reads a clock that starts at Tue 3 Nov 2026, 09:05:00 UTC and then runs at normal speed
const FIXED_EPOCH = Date.UTC(2026, 10, 3, 9, 5, 0);
const SUITE_NAMES = ['regression', 'posix', 'posix-bash'];

const sleep = (ms) => new Promise((r) => setTimeout(r, ms));
class StepError extends Error {}
function die(msg) { console.error(`run.js: ${msg}`); process.exit(2); }

/* ---------------------------------------------------------------- command line */

function parseArgs(argv) {
  const o = { page: path.join(REPO, 'index.html'), update: false, jobs: 6, timeout: 15000, caseTimeout: 20000,
    ignoreStderr: false, verbose: false, list: false, headed: false, posixDir: path.join(TESTS, 'posix'), select: new Map(), details: 40 };
  for (let i = 0; i < argv.length; i++) {
    const a = argv[i];
    const value = () => { if (i + 1 >= argv.length) die(`${a} needs a value`); return argv[++i]; };
    const num = () => { const n = parseInt(value(), 10); if (!(n > 0)) die(`${a} needs a positive number`); return n; };
    if (a === '--page') o.page = path.resolve(value());
    else if (a === '--update') o.update = true;
    else if (a === '--jobs' || a === '-j') o.jobs = num();
    else if (a === '--timeout') o.timeout = num();
    else if (a === '--case-timeout') o.caseTimeout = num();
    else if (a === '--ignore-stderr') o.ignoreStderr = true;
    else if (a === '--posix-dir') o.posixDir = path.resolve(value());
    else if (a === '--details') { const n = parseInt(value(), 10); if (!(n >= 0)) die('--details needs a number'); o.details = n; }
    else if (a === '--verbose' || a === '-v') o.verbose = true;
    else if (a === '--list') o.list = true;
    else if (a === '--headed') o.headed = true;
    else if (a === '--help' || a === '-h') { console.log(fs.readFileSync(__filename, 'utf8').split('*/')[0].replace(/^[\s\S]*?\/\*\n?/, '').replace(/^ \* ?/gm, '')); process.exit(0); }
    else if (a.startsWith('-')) die(`unknown option ${a} (try --help)`);
    else {
      const [suite, filter] = a.split(/:(.*)/s);
      if (!SUITE_NAMES.includes(suite)) die(`unknown suite "${suite}" (suites: ${SUITE_NAMES.join(', ')})`);
      const pats = filter ? filter.split(',').filter(Boolean) : null;
      if (o.select.has(suite) && (o.select.get(suite) === null || pats === null)) o.select.set(suite, null);
      else o.select.set(suite, pats ? [...(o.select.get(suite) || []), ...pats] : null);
    }
  }
  // --update on its own means the regression suite: the POSIX expectations come from real shells, not from this page
  if (!o.select.size) (o.update ? ['regression'] : SUITE_NAMES).forEach((s) => o.select.set(s, null));
  if (!fs.existsSync(o.page)) die(`no page at ${o.page}`);
  return o;
}

const globRe = (g) => new RegExp('^' + g.replace(/[.+^${}()|[\]\\?]/g, '\\$&').replace(/\*/g, '.*') + '$');
function matches(name, pats) {
  if (!pats) return true;
  const base = name.replace(/@(ubuntu|mac)$/, '');
  return pats.some((p) => { const re = globRe(p); return re.test(name) || re.test(base); });
}

/* ---------------------------------------------------------------- Chrome and the DevTools protocol */

function findChrome() {
  const candidates = [process.env.CHROME, '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    '/Applications/Chromium.app/Contents/MacOS/Chromium', '/usr/bin/google-chrome', '/usr/bin/google-chrome-stable',
    '/usr/bin/chromium', '/usr/bin/chromium-browser'].filter(Boolean);
  const found = candidates.find((c) => fs.existsSync(c));
  if (!found) die('cannot find Google Chrome; set CHROME=/path/to/chrome');
  return found;
}

class Connection {
  constructor(url) { this.url = url; this.nextId = 0; this.calls = new Map(); this.sessions = new Map(); this.closed = false; }
  async open() {
    this.ws = new WebSocket(this.url);
    await new Promise((resolve, reject) => {
      this.ws.addEventListener('open', resolve, { once: true });
      this.ws.addEventListener('error', () => reject(new Error(`cannot connect to Chrome at ${this.url}`)), { once: true });
    });
    this.ws.addEventListener('message', (ev) => this.onMessage(JSON.parse(typeof ev.data === 'string' ? ev.data : Buffer.from(ev.data).toString())));
    this.ws.addEventListener('close', () => {
      this.closed = true;
      for (const c of this.calls.values()) { clearTimeout(c.timer); c.reject(new Error('the connection to Chrome closed')); }
      this.calls.clear();
    });
  }
  onMessage(msg) {
    if (msg.id !== undefined) {
      const c = this.calls.get(msg.id); if (!c) return;
      this.calls.delete(msg.id); clearTimeout(c.timer);
      if (msg.error) c.reject(new Error(`${c.method}: ${msg.error.message}`)); else c.resolve(msg.result);
      return;
    }
    const handler = this.sessions.get(msg.sessionId || ''); if (handler) handler(msg.method, msg.params);
  }
  send(method, params = {}, sessionId, timeout = 30000) {
    if (this.closed) return Promise.reject(new Error('the connection to Chrome closed'));
    const id = ++this.nextId;
    return new Promise((resolve, reject) => {
      const timer = setTimeout(() => { this.calls.delete(id); reject(new Error(`${method}: no answer after ${timeout} ms (is the page stuck in a loop?)`)); }, timeout);
      this.calls.set(id, { resolve, reject, method, timer });
      this.ws.send(JSON.stringify(sessionId ? { id, method, params, sessionId } : { id, method, params }));
    });
  }
}

class Browser {
  static async launch({ headed }) {
    const b = new Browser();
    b.profile = fs.mkdtempSync(path.join(os.tmpdir(), 'clp-tests-'));
    const args = [headed ? null : '--headless=new', '--remote-debugging-port=0', `--user-data-dir=${b.profile}`,
      '--no-first-run', '--no-default-browser-check', '--disable-extensions', '--disable-component-update',
      '--disable-background-networking', '--disable-sync', '--disable-default-apps', '--mute-audio',
      '--disable-background-timer-throttling', '--disable-renderer-backgrounding', '--disable-backgrounding-occluded-windows',
      '--hide-scrollbars', '--force-device-scale-factor=1', `--window-size=${VIEWPORT.join(',')}`, 'about:blank'].filter(Boolean);
    b.proc = spawn(findChrome(), args, { stdio: ['ignore', 'ignore', 'pipe'] });
    let stderr = '';
    b.proc.stderr.on('data', (d) => { stderr = (stderr + d).slice(-3000); });
    b.exited = new Promise((r) => b.proc.on('exit', r));
    const portFile = path.join(b.profile, 'DevToolsActivePort'), t0 = Date.now();
    let port, wsPath;
    while (!port) {
      try { const [p, w] = fs.readFileSync(portFile, 'utf8').split('\n'); if (p && w) { port = p; wsPath = w; } } catch {}
      if (b.proc.exitCode !== null || Date.now() - t0 > 20000) { b.cleanup(); die(`Chrome did not start:\n${stderr}`); }
      if (!port) await sleep(50);
    }
    b.conn = new Connection(`ws://127.0.0.1:${port}${wsPath.trim()}`);
    await b.conn.open();
    return b;
  }
  async close() {
    try { await this.conn.send('Browser.close', {}, undefined, 5000); } catch {}
    await Promise.race([this.exited, sleep(5000)]);
    this.cleanup();
  }
  cleanup() {
    if (this.proc && this.proc.exitCode === null) { try { this.proc.kill('SIGKILL'); } catch {} }
    if (this.profile) { for (let i = 0; i < 5; i++) { try { fs.rmSync(this.profile, { recursive: true, force: true }); break; } catch {} } this.profile = null; }
  }
}

// Runs in the page before its own script, on every load: empty storage, and a clock with a fixed start.
const INIT_SCRIPT = `(() => {
  try { localStorage.clear(); sessionStorage.clear(); } catch (e) {}
  const RealDate = Date, t0 = RealDate.now(), now = () => ${FIXED_EPOCH} + (RealDate.now() - t0);
  function FixedDate(...a) { if (!new.target) return new RealDate(now()).toString(); return a.length ? new RealDate(...a) : new RealDate(now()); }
  FixedDate.prototype = RealDate.prototype; FixedDate.now = now; FixedDate.parse = RealDate.parse; FixedDate.UTC = RealDate.UTC;
  window.Date = FixedDate;
})();`;

const FONTS_READY = `(async () => {
  await Promise.all(['400 18px "JetBrains Mono"', '700 18px "JetBrains Mono"', '400 16px Inter', '700 16px Inter']
    .map((f) => document.fonts.load(f).catch(() => null)));
  await document.fonts.ready;
  await new Promise((r) => requestAnimationFrame(() => requestAnimationFrame(r)));
  return document.fonts.check('18px "JetBrains Mono"');
})()`;

// What the terminal is doing: 'idle' (prompt showing), 'busy' (prompt hidden: sleep...), 'pager', 'editor'.
const STATE_FN = `function __pgState() {
  const term = document.getElementById('term'), ps = document.getElementById('ps');
  if (!term || !ps) return 'loading';
  if (term.querySelector('.pager')) return 'pager';
  if (term.querySelector('.editor')) return 'editor';
  return getComputedStyle(ps).visibility === 'visible' ? 'idle' : 'busy';
}`;

const TREE_SETTLED_FN = `function __pgTreeSettled() {
  const t = document.getElementById('tree'); if (!t) return true;
  const dot = t.querySelector('circle.dot');
  return !(dot && getComputedStyle(dot).visibility === 'visible') && !t.querySelector('path.trail') && !t.querySelector('.leaving');
}`;

const CAPTURE_FN = `function __pgCapture() {
  const out = document.getElementById('out'), $ = (id) => document.getElementById(id);
  const terminal = out ? [...out.children].map((d) => {
    const line = { cls: [...d.classList].filter((c) => c !== 'l').join(' '), text: d.textContent };
    const dirs = [...d.querySelectorAll('span.d')].map((s) => s.textContent);
    if (dirs.length) line.d = dirs;
    return line;
  }) : [];
  const nodes = [...document.querySelectorAll('#tree g.node')];
  const y = (g) => { const r = g.querySelector('rect'); return r ? Math.round(parseFloat(r.getAttribute('y'))) : 0; };
  const ys = [...new Set(nodes.map(y))].sort((a, b) => a - b);
  const tree = nodes.map((g) => {
    const texts = [...g.querySelectorAll('text')], main = texts.find((t) => !t.classList.contains('perm')), perm = texts.find((t) => t.classList.contains('perm'));
    const n = { depth: ys.indexOf(y(g)), label: main ? main.textContent : '',
      cls: [...g.classList].filter((c) => !['node', 'new', 'changed', 'leaving'].includes(c)).join(' ') };
    if (perm) n.perm = perm.textContent;
    return n;
  });
  const ps = $('ps'), cmd = $('cmd'), last = $('last');
  return { terminal, tree, last: last ? last.textContent : null, lastClass: last ? last.className : '', prompt: ps ? ps.textContent : null, input: cmd ? cmd.value : null };
}`;

const PAGER_FN = `function __pgPager() {
  const p = document.querySelector('#term .pager'); if (!p) return null;
  const pre = p.querySelector('pre'), bar = p.querySelector('.bar');
  const lines = pre ? [...pre.childNodes].map((n) => { const t = n.textContent.replace(/\\n$/, ''); return n.nodeName === 'B' ? '<b>' + t + '</b>' : t; }) : [];
  return { lines, bar: bar ? bar.textContent : null };
}`;

const CLICK = { mac: '.seg button[data-os="mac"]', ubuntu: '.seg button[data-os="ubuntu"]', perms: '#perms', reset: '#reset', term: '#term', name: '#user' };

const KEYS = {
  Enter: { key: 'Enter', code: 'Enter', keyCode: 13, text: '\r' }, Tab: { key: 'Tab', code: 'Tab', keyCode: 9 },
  Escape: { key: 'Escape', code: 'Escape', keyCode: 27 }, Backspace: { key: 'Backspace', code: 'Backspace', keyCode: 8 },
  Delete: { key: 'Delete', code: 'Delete', keyCode: 46 }, Space: { key: ' ', code: 'Space', keyCode: 32, text: ' ' },
  ArrowUp: { key: 'ArrowUp', code: 'ArrowUp', keyCode: 38 }, ArrowDown: { key: 'ArrowDown', code: 'ArrowDown', keyCode: 40 },
  ArrowLeft: { key: 'ArrowLeft', code: 'ArrowLeft', keyCode: 37 }, ArrowRight: { key: 'ArrowRight', code: 'ArrowRight', keyCode: 39 },
  Home: { key: 'Home', code: 'Home', keyCode: 36 }, End: { key: 'End', code: 'End', keyCode: 35 },
  PageUp: { key: 'PageUp', code: 'PageUp', keyCode: 33 }, PageDown: { key: 'PageDown', code: 'PageDown', keyCode: 34 },
};
const MODS = { Alt: 1, Ctrl: 2, Control: 2, Meta: 4, Cmd: 4, Shift: 8 };
// "Enter", "Tab", "Ctrl+C", "Shift+G", "G", "q", "Space", " "
function keySpec(name) {
  const parts = name.length > 1 ? name.split('+') : [name];
  let k = parts.pop(), mods = 0;
  if (k === '' && name.endsWith('+')) k = '+';
  for (const m of parts) { if (!MODS[m]) throw new StepError(`unknown key modifier "${m}" in "${name}"`); mods |= MODS[m]; }
  if (KEYS[k]) return { ...KEYS[k], mods, text: mods & (MODS.Ctrl | MODS.Meta | MODS.Alt) ? undefined : KEYS[k].text };
  if ([...k].length !== 1) throw new StepError(`unknown key "${name}"`);
  const up = k.toUpperCase(), letter = /^[a-z]$/i.test(k), digit = /^[0-9]$/.test(k);
  if (letter && k === up) mods |= MODS.Shift;
  const ctrl = mods & (MODS.Ctrl | MODS.Meta | MODS.Alt);
  return { key: ctrl && letter ? k.toLowerCase() : k, code: letter ? 'Key' + up : digit ? 'Digit' + k : '',
    keyCode: letter ? up.charCodeAt(0) : digit ? k.charCodeAt(0) : 0, mods, text: ctrl ? undefined : k };
}

class Page {
  static async open(browser, opts) {
    const { targetId } = await browser.conn.send('Target.createTarget', { url: 'about:blank', newWindow: true });
    const { sessionId } = await browser.conn.send('Target.attachToTarget', { targetId, flatten: true });
    const p = new Page(browser, targetId, sessionId, opts);
    await p.init();
    return p;
  }
  constructor(browser, targetId, sessionId, opts) {
    Object.assign(this, { browser, conn: browser.conn, targetId, sessionId, opts, problems: [], waiters: [] });
    this.conn.sessions.set(sessionId, (m, p) => this.onEvent(m, p));
  }
  onEvent(method, params) {
    if (method === 'Runtime.exceptionThrown') {
      const d = params.exceptionDetails || {};
      this.problems.push(`page error: ${(d.exception && d.exception.description) || d.text}${d.lineNumber !== undefined ? ` (line ${d.lineNumber + 1})` : ''}`);
    } else if (method === 'Runtime.consoleAPICalled' && (params.type === 'error' || params.type === 'assert')) {
      this.problems.push(`console.${params.type}: ${params.args.map((a) => a.value ?? a.description ?? '').join(' ')}`);
    } else if (method === 'Log.entryAdded' && params.entry.level === 'error') {
      this.problems.push(`browser error: ${params.entry.text}${params.entry.url ? ` (${params.entry.url})` : ''}`);
    } else if (method === 'Network.requestWillBeSent' && !/^(file|data|blob|about):/.test(params.request.url)) {
      this.problems.push(`external request: ${params.request.url}`);
    }
    this.waiters = this.waiters.filter((w) => !w(method, params));
  }
  send(method, params = {}, timeout) { return this.conn.send(method, params, this.sessionId, timeout); }
  async init() {
    await Promise.all(['Page.enable', 'Runtime.enable', 'Network.enable', 'Log.enable'].map((m) => this.send(m)));
    await this.send('Page.addScriptToEvaluateOnNewDocument', { source: INIT_SCRIPT });
    await this.send('Emulation.setFocusEmulationEnabled', { enabled: true });
    await this.send('Emulation.setTimezoneOverride', { timezoneId: 'UTC' });
  }
  async close() { try { this.conn.sessions.delete(this.sessionId); await this.conn.send('Target.closeTarget', { targetId: this.targetId }, undefined, 5000); } catch {} }
  async eval(expression, timeout = 30000) {
    const r = await this.send('Runtime.evaluate', { expression, awaitPromise: true, returnByValue: true }, timeout);
    if (r.exceptionDetails) throw new StepError(`script in the page failed: ${(r.exceptionDetails.exception && r.exceptionDetails.exception.description) || r.exceptionDetails.text}`);
    return r.result.value;
  }
  async load(url, viewport, theme = 'light') {
    await this.send('Emulation.setDeviceMetricsOverride', { width: viewport[0], height: viewport[1], deviceScaleFactor: 1, mobile: false });
    await this.send('Emulation.setEmulatedMedia', { features: [{ name: 'prefers-color-scheme', value: theme }, { name: 'prefers-reduced-motion', value: 'no-preference' }] });
    this.problems = [];
    const loaded = new Promise((resolve) => this.waiters.push((m) => { if (m === 'Page.loadEventFired') { resolve(); return true; } return false; }));
    const nav = await this.send('Page.navigate', { url });
    if (nav.errorText) throw new StepError(`cannot open ${url}: ${nav.errorText}`);
    await Promise.race([loaded, sleep(15000).then(() => { throw new StepError('the page did not finish loading in 15 s'); })]);
    if (!(await this.eval(FONTS_READY))) this.problems.push('the JetBrains Mono font did not load (are the fonts next to the page?)');
    await this.waitState('idle');
  }
  // waits until the terminal has been in state `want` for a few polls in a row; 'any' = idle, pager or editor
  async waitState(want, timeout = this.opts.timeout) {
    const r = await this.eval(`new Promise((resolve) => {
      ${STATE_FN}
      const want = ${JSON.stringify(want)}, settled = ['idle', 'pager', 'editor'], t0 = performance.now();
      let streak = 0, other = null, since = 0;
      (function tick() {
        const s = __pgState(), ok = want === 'any' ? settled.includes(s) : s === want;
        if (ok) { if (++streak >= ${SETTLE_POLLS}) return resolve({ ok: true, state: s }); } else streak = 0;
        if (!ok && settled.includes(s)) { if (other !== s) { other = s; since = performance.now(); } else if (performance.now() - since > ${FAIL_FAST_MS}) return resolve({ ok: false, state: s, wrong: true }); } else other = null;
        if (performance.now() - t0 > ${timeout}) return resolve({ ok: false, state: s });
        setTimeout(tick, 20);
      })();
    })`, timeout + 5000);
    if (!r.ok) throw new StepError(r.wrong ? `expected the terminal to be ${want}, but it is ${r.state}` : `timed out after ${timeout} ms waiting for the terminal to be ${want} (it is ${r.state})`);
    return r.state;
  }
  async waitTreeSettled(timeout = 30000) {
    const ok = await this.eval(`new Promise((resolve) => {
      ${TREE_SETTLED_FN}
      const t0 = performance.now(); let streak = 0;
      (function tick() {
        if (__pgTreeSettled()) { if (++streak >= ${SETTLE_POLLS}) return resolve(true); } else streak = 0;
        if (performance.now() - t0 > ${timeout}) return resolve(false);
        setTimeout(tick, 20);
      })();
    })`, timeout + 5000);
    if (!ok) throw new StepError(`the tree was still animating after ${timeout} ms`);
  }
  async focusTerminal() {
    // keep focus on whatever has it inside the terminal (the command line, or an editor); otherwise the command line
    await this.eval(`(() => { const a = document.activeElement, t = document.getElementById('term'), c = document.getElementById('cmd');
      if (t && c && !(a && a !== document.body && t.contains(a))) c.focus(); })()`);
  }
  insertText(text) { return this.send('Input.insertText', { text }); }
  async key(name) {
    const k = keySpec(name);
    const base = { key: k.key, code: k.code, windowsVirtualKeyCode: k.keyCode, nativeVirtualKeyCode: k.keyCode, modifiers: k.mods };
    await this.send('Input.dispatchKeyEvent', k.text ? { ...base, type: 'keyDown', text: k.text, unmodifiedText: k.text } : { ...base, type: 'rawKeyDown' });
    await this.send('Input.dispatchKeyEvent', { ...base, type: 'keyUp' });
  }
  async click(selector) {
    const at = await this.eval(`(() => { const e = document.querySelector(${JSON.stringify(selector)}); if (!e) return null;
      e.scrollIntoView({ block: 'center', inline: 'center' }); const b = e.getBoundingClientRect(); return { x: b.left + b.width / 2, y: b.top + b.height / 2 }; })()`);
    if (!at) throw new StepError(`nothing to click: no element matches ${selector}`);
    await this.send('Input.dispatchMouseEvent', { type: 'mouseMoved', x: at.x, y: at.y, button: 'none' });
    await this.send('Input.dispatchMouseEvent', { type: 'mousePressed', x: at.x, y: at.y, button: 'left', buttons: 1, clickCount: 1 });
    await this.send('Input.dispatchMouseEvent', { type: 'mouseReleased', x: at.x, y: at.y, button: 'left', buttons: 0, clickCount: 1 });
  }
  capture(timeout) { return this.eval(`(${CAPTURE_FN})()`, timeout); }
  pager() { return this.eval(`(${PAGER_FN})()`); }
  async submit(text, wait = 'idle', timeout) {
    await this.focusTerminal();
    if (text) await this.insertText(text);
    await this.key('Enter');
    if (typeof wait === 'number') await sleep(wait); else if (wait !== 'none') await this.waitState(wait, timeout);
  }
}

/* ---------------------------------------------------------------- the worker pool */

// runs jobs on `n` tabs; a tab that hit a timeout is replaced, in case the page is stuck
async function pool(browser, opts, plan, onDone) {
  const jobs = [...plan].sort((a, b) => (b.cost || 0) - (a.cost || 0));
  let next = 0;
  const worker = async () => {
    let page = null;
    while (next < jobs.length) {
      const job = jobs[next++];
      if (!page) page = await Page.open(browser, opts);
      const result = await job.run(page).catch((e) => ({ name: job.name, error: e.message, ms: 0 }));
      result.suite = job.suite;
      onDone(result);
      if (result.replaceTab) { await page.close(); page = null; }
    }
    if (page) await page.close();
  };
  await Promise.all(Array.from({ length: Math.min(opts.jobs, jobs.length) }, worker));
}

/* ---------------------------------------------------------------- regression suite */

function loadScenarios() {
  let data;
  try { data = JSON.parse(fs.readFileSync(SCENARIOS, 'utf8')); } catch (e) { die(`cannot read ${SCENARIOS}: ${e.message}`); }
  const list = [], seen = new Set();
  for (const s of data.scenarios) {
    if (!s.name || !Array.isArray(s.steps)) die(`scenario without a name or steps: ${JSON.stringify(s).slice(0, 120)}`);
    for (const osName of s.os === 'both' ? ['ubuntu', 'mac'] : [s.os || 'ubuntu']) {
      if (!['ubuntu', 'mac'].includes(osName)) die(`${s.name}: os must be ubuntu, mac or both`);
      const name = `${s.name}@${osName}`;
      if (seen.has(name)) die(`two scenarios are called ${name}`);
      seen.add(name);
      list.push({ ...s, name, os: osName });
    }
  }
  return list;
}

const describe = (step) => {
  if (typeof step === 'string') return `$ ${step}`;
  if ('cmd' in step) return `$ ${step.cmd}`;
  if ('type' in step) return `type ${JSON.stringify(step.type)}`;
  if ('key' in step) return `key ${step.key}`;
  if ('click' in step) return `click ${step.click}`;
  if ('name' in step) return `name ${JSON.stringify(step.name)}`;
  if ('snap' in step) return `snap ${step.snap}`;
  if ('check' in step) return `check ${step.check}`;
  if ('wait' in step) return `wait ${step.wait}`;
  return JSON.stringify(step);
};

// a number = pause that long; 'tree' = until the tree has stopped animating; otherwise a terminal state
async function waitAfter(page, wait, dflt) {
  const w = wait ?? dflt;
  if (typeof w === 'number') await sleep(w);
  else if (w === 'tree') await page.waitTreeSettled();
  else if (w !== 'none') await page.waitState(w);
}

// the checks that are not a comparison with the golden: they must pass, and a run that fails one is never saved
const CHECKS = {
  // CLAUDE.md: "Dot visible mid-move: sample #tree circle.dot visibility and position every 100 ms after a cd"
  async dot(page, step) {
    const n = step.samples || 12;
    const s = await page.eval(`new Promise((resolve) => { const out = []; const iv = setInterval(() => {
      const d = document.querySelector('#tree circle.dot');
      out.push(d ? [getComputedStyle(d).visibility, Math.round(+d.getAttribute('cx')), Math.round(+d.getAttribute('cy'))] : ['missing', 0, 0]);
      if (out.length >= ${n}) { clearInterval(iv); resolve(out); } }, 100); })`);
    const visible = s.filter((x) => x[0] === 'visible'), places = new Set(visible.map((x) => x[1] + ',' + x[2]));
    if (visible.length < Math.ceil(n * 0.8) || places.size < 3) return `the dot was visible in ${visible.length} of ${n} samples, at ${places.size} different places (want ${Math.ceil(n * 0.8)}+ samples and 3+ places)`;
    return null;
  },
};

async function runStep(page, step, cap, res) {
  if (typeof step === 'string') step = { cmd: step };
  if ('cmd' in step) { await page.submit(step.cmd, 'none'); return waitAfter(page, step.wait, 'idle'); }
  if ('type' in step) { await page.focusTerminal(); await page.insertText(step.type); return waitAfter(page, step.wait, 'any'); }
  if ('key' in step) { await page.focusTerminal(); await page.key(step.key); return waitAfter(page, step.wait, 'any'); }
  if ('click' in step) { await page.click(CLICK[step.click] || step.click); return waitAfter(page, step.wait, 'any'); }
  if ('name' in step) {
    await page.click(CLICK.name);
    await page.eval(`document.getElementById('user').select()`);
    if (step.name) await page.insertText(step.name); else await page.key('Backspace');
    return waitAfter(page, step.wait, 'any');
  }
  if ('snap' in step) {
    const kinds = step.snap === 'all' ? ['screen', 'terminal', 'tree', 'pager'] : String(step.snap).split(',');
    const snap = { after: res.prevAction };
    for (const kind of kinds) {
      if (kind === 'pager') snap.pager = await page.pager();
      else if (kind === 'tree') { await page.waitTreeSettled(); snap.tree = (await page.capture()).tree; }
      else if (kind === 'terminal') snap.terminal = (await page.capture()).terminal;
      else if (kind === 'screen') {
        const c = await page.capture();
        snap.screen = { prompt: c.prompt, promptVisible: await page.eval(`getComputedStyle(document.getElementById('ps')).visibility === 'visible'`), input: c.input, last: c.last };
      } else throw new StepError(`unknown snap "${kind}" (pager, tree, terminal, screen, all)`);
    }
    cap.snaps.push(snap);
    return;
  }
  if ('check' in step) {
    const fn = CHECKS[step.check];
    if (!fn) throw new StepError(`unknown check "${step.check}"`);
    const why = await fn(page, step);
    if (why) res.checkFailures.push(`check ${step.check} after "${res.prevAction}": ${why}`);
    cap.checks.push(`${step.check} after ${res.prevAction}`);
    return;
  }
  if ('wait' in step) return waitAfter(page, step.wait);
  throw new StepError(`unknown step ${JSON.stringify(step)}`);
}

// date output carries the time of day, which changes from run to run
const DATE_RE = /\b((?:Mon|Tue|Wed|Thu|Fri|Sat|Sun) (?:Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec) [ \d]\d )\d\d:\d\d:\d\d( \S+ \d{4})\b/g;
const normText = (t) => t.replace(DATE_RE, '$1hh:mm:ss$2');
function normalise(cap) {
  const fixLines = (ls) => ls && ls.forEach((l) => { l.text = normText(l.text); });
  fixLines(cap.terminal);
  for (const s of cap.snaps || []) { fixLines(s.terminal); if (s.pager) s.pager.lines = s.pager.lines.map(normText); }
  return cap;
}

// a rough guess at how long a scenario takes, so the slow ones (a cd waits for the dot and its trail) start first
const cost = (scn) => scn.steps.reduce((t, st) => {
  const c = typeof st === 'string' ? st : st.cmd;
  if (typeof c === 'string' && /^\s*cd\b/.test(c)) return t + 30;
  if (st && typeof st.wait === 'number') return t + st.wait / 100;
  if (st && (st.wait === 'tree' || st.snap === 'tree' || st.check)) return t + 20;
  return t + 1;
}, 0);

function regressionJobs(opts, pats) {
  const url = pathToFileURL(opts.page).href;
  return loadScenarios().filter((s) => matches(s.name, pats)).map((scn) => ({ suite: 'regression', name: scn.name, cost: cost(scn), run: async (page) => {
    const t0 = Date.now(), res = { name: scn.name, checkFailures: [], lastStep: 'page load', prevAction: 'page load' };
    const cap = { snaps: [], checks: [] };
    try {
      await page.load(url, scn.viewport || VIEWPORT, scn.theme || 'light');
      const steps = (scn.os === 'mac' ? [{ click: 'mac' }] : []).concat(scn.steps);
      for (const step of steps) {
        res.lastStep = describe(step);
        await runStep(page, step, cap, res);
        if (typeof step === 'string' || !('snap' in step || 'check' in step)) res.prevAction = res.lastStep;
      }
      res.lastStep = 'end (waiting for the tree to settle)';
      await page.waitTreeSettled();
      const end = await page.capture();
      res.capture = normalise({ terminal: end.terminal, tree: end.tree, last: end.last, ...(end.lastClass ? { lastClass: end.lastClass } : {}), prompt: end.prompt, input: end.input,
        ...(cap.snaps.length ? { snaps: cap.snaps } : {}), ...(cap.checks.length ? { checks: cap.checks } : {}) });
    } catch (e) {
      res.error = `${e.message} (at: ${res.lastStep})`;
      res.replaceTab = !(e instanceof StepError) || /timed out|did not finish/.test(e.message);
      try { res.partial = normalise({ ...(await page.capture(2000)), snaps: [] }); } catch {}
    }
    res.problems = page.problems.slice();
    res.ms = Date.now() - t0;
    return res;
  } }));
}

/* ---------------------------------------------------------------- POSIX suites */

// the corpus has two sets: cases/NAME.sh with expected.json, and syntax/NAME.sh with expected-syntax.json
const POSIX_SETS = [{ dir: 'cases', file: 'expected.json', prefix: '' }, { dir: 'syntax', file: 'expected-syntax.json', prefix: 'syntax/' }];
function loadPosix(opts) {
  const items = [], problems = [], rel = (f) => path.relative(REPO, f) || f;
  let found = 0;
  for (const set of POSIX_SETS) {
    const dir = path.join(opts.posixDir, set.dir), expFile = path.join(opts.posixDir, set.file);
    const files = fs.existsSync(dir) ? fs.readdirSync(dir).filter((f) => f.endsWith('.sh')).sort() : [];
    found += files.length;
    let expected = {};
    if (fs.existsSync(expFile)) { try { expected = JSON.parse(fs.readFileSync(expFile, 'utf8')); } catch (e) { problems.push(`cannot read ${rel(expFile)}: ${e.message}`); continue; } }
    else if (files.length) { problems.push(`${rel(dir)} has ${files.length} cases but there is no ${rel(expFile)} (run node tests/posix/generate.js)`); continue; }
    for (const f of files) items.push({ name: set.prefix + f.slice(0, -3), file: path.join(dir, f), exp: expected[f.slice(0, -3)] });
    for (const k of Object.keys(expected)) if (!files.includes(k + '.sh')) items.push({ name: set.prefix + k, file: null, exp: expected[k], expFile: rel(expFile) });
  }
  return { items, problems, found };
}

// turns the lines a command printed into stdout, stderr and the __STATUS=N that follows them
function splitRun(lines) {
  const body = lines.filter((l) => !l.cls.split(' ').includes('cmdl'));
  const isErr = (l) => l.cls.split(' ').includes('err'), isNote = (l) => l.cls.split(' ').includes('note');
  let si = -1;
  for (let i = body.length - 1; i >= 0; i--) if (!isErr(body[i]) && !isNote(body[i]) && /__STATUS=\d+\s*$/.test(body[i].text)) { si = i; break; }
  let stdout = '', stderr = '', status = null;
  const notes = [];
  body.forEach((l, i) => {
    if (isErr(l)) stderr += l.text + '\n';
    else if (isNote(l)) notes.push(l.text);
    else if (i === si) { const m = /^([\s\S]*?)__STATUS=(\d+)\s*$/.exec(l.text); stdout += m[1]; status = parseInt(m[2], 10); }
    else stdout += l.text + '\n';
  });
  return { stdout, stderr, status, notes };
}

function posixJobs(opts, pats, shell) {
  const b5 = path.join(opts.posixDir, 'bash5.json'), BASH5 = fs.existsSync(b5) ? JSON.parse(fs.readFileSync(b5, 'utf8')) : {};
  const suite = shell === 'sh' ? 'posix' : 'posix-bash', variant = shell === 'sh' ? 'dash' : 'bash';
  const url = pathToFileURL(opts.page).href;
  const { items, problems, found } = loadPosix(opts);
  const jobs = [], skipped = [];
  const broken = (name, error) => jobs.push({ suite, name, cost: 0, run: async () => ({ name, error, ms: 0 }) });
  problems.forEach((p, i) => broken(`(setup ${i + 1})`, p));
  if (!found && !items.length) skipped.push(`everything: no cases in ${path.relative(REPO, opts.posixDir) || opts.posixDir}`);
  for (const c of items.filter((x) => matches(x.name, pats))) {
    const e = c.exp;
    if (!c.file) { broken(c.name, `${c.expFile} has an entry for it but there is no .sh file`); continue; }
    if (!e) { broken(c.name, 'no entry in the expected JSON'); continue; }
    if (e.skip) { skipped.push(`${c.name}: ${e.skip}`); continue; }
    if (shell === 'bash' && e.differs !== false) { skipped.push(`${c.name}: dash and bash differ`); continue; }
    const want = shell === 'bash' && BASH5[c.name] ? { ...e.bash, ...BASH5[c.name] } : e[variant];   // bash 5.2 where it differs from the recording bash 3.2
    if (!want) { broken(c.name, `the expected JSON has no "${variant}" result`); continue; }
    jobs.push({ suite, name: c.name, cost: 5, run: async (page) => {
      const t0 = Date.now(), res = { name: c.name, notes: e.notes, want };
      let stage = 'page load', base = 0;
      try {
        await page.load(url, VIEWPORT);
        let text = fs.readFileSync(c.file, 'utf8'); if (!text.endsWith('\n')) text += '\n';
        stage = 'writing t.sh with a here-doc';
        const n0 = (await page.capture()).terminal.length;
        await page.submit(`cat > t.sh <<'__PG_EOF__'\n${text}__PG_EOF__`, 'idle');
        const after = (await page.capture()).terminal;
        res.setup = after.slice(n0).filter((l) => l.cls !== 'cmdl');
        base = after.length;
        stage = `${shell} t.sh`;
        await page.submit(`${shell} t.sh; echo "__STATUS=$?"`, 'idle', opts.caseTimeout);
        const got = splitRun((await page.capture()).terminal.slice(base));
        res.got = got;
        res.stdoutOk = got.stdout === want.stdout && got.status === want.status;
        res.stderrOk = got.stderr === (want.stderr ?? '');
      } catch (err) {
        res.error = `${err.message} (while: ${stage})`;
        res.timeout = /timed out|no answer/.test(err.message);
        res.replaceTab = true;
        if (base) { try { res.got = splitRun((await page.capture(2000)).terminal.slice(base)); } catch {} }
      }
      res.problems = page.problems.slice();
      res.ms = Date.now() - t0;
      return res;
    } });
  }
  return { jobs, skipped };
}

/* ---------------------------------------------------------------- reporting */

function diffLines(a, b) {
  const n = a.length, m = b.length;
  let s = 0; while (s < n && s < m && a[s] === b[s]) s++;
  let e = 0; while (e < n - s && e < m - s && a[n - 1 - e] === b[m - 1 - e]) e++;
  const A = a.slice(s, n - e), B = b.slice(s, m - e);
  const dp = Array.from({ length: A.length + 1 }, () => new Uint32Array(B.length + 1));
  for (let i = A.length - 1; i >= 0; i--) for (let j = B.length - 1; j >= 0; j--) dp[i][j] = A[i] === B[j] ? dp[i + 1][j + 1] + 1 : Math.max(dp[i + 1][j], dp[i][j + 1]);
  const ops = a.slice(0, s).map((x) => [' ', x]);
  let i = 0, j = 0;
  while (i < A.length && j < B.length) {
    if (A[i] === B[j]) { ops.push([' ', A[i]]); i++; j++; } else if (dp[i + 1][j] >= dp[i][j + 1]) ops.push(['-', A[i++]]); else ops.push(['+', B[j++]]);
  }
  while (i < A.length) ops.push(['-', A[i++]]);
  while (j < B.length) ops.push(['+', B[j++]]);
  return ops.concat(a.slice(n - e).map((x) => [' ', x]));
}

// a diff with two lines of context around each change, at most `max` lines
function showDiff(title, exp, act, ind = '      ', max = 60) {
  const ops = diffLines(exp, act), keep = new Set();
  ops.forEach((o, i) => { if (o[0] !== ' ') for (let k = i - 2; k <= i + 2; k++) keep.add(k); });
  const out = [`${ind}${title}  (- expected, + actual)`];
  let last = -1, shown = 0;
  for (let i = 0; i < ops.length; i++) {
    if (!keep.has(i)) continue;
    if (shown >= max) { out.push(`${ind}  ... (${[...keep].filter((k) => k > i && k < ops.length).length + 1} more lines)`); break; }
    if (last !== -1 && i > last + 1) out.push(`${ind}  ...`);
    out.push(`${ind}${ops[i][0]} ${ops[i][1]}`); last = i; shown++;
  }
  return out.join('\n');
}

// control characters (tabs...) made visible, so a diff never hides a difference
const visible = (t) => String(t).replace(/[\x00-\x1f\x7f]/g, (c) => ({ '\t': '\\t', '\n': '\\n', '\r': '\\r' }[c] || '\\x' + c.charCodeAt(0).toString(16).padStart(2, '0')));
const esc = visible;
// stdout or stderr as diff lines: escapes, trailing spaces and a missing final newline spelled out
function textLines(t) {
  if (t === null || t === undefined) return ['(nothing)'];
  if (t === '') return [];
  const ls = t.split('\n'), open = ls[ls.length - 1] !== '';
  if (!open) ls.pop();
  const shown = ls.map((l) => visible(l).replace(/( +)$/, (m) => `${m}   (${m.length} trailing space${m.length > 1 ? 's' : ''})`));
  if (open) shown[shown.length - 1] += '   (no newline at the end)';
  return shown;
}
const termLine = (l) => `${l.cls ? `[${l.cls}] ` : ''}${esc(l.text)}${l.d ? `   {folders: ${l.d.join(', ')}}` : ''}`;
const treeLine = (n) => `${'  '.repeat(Math.max(0, n.depth))}${n.label}  (${n.cls})${n.perm ? '  ' + n.perm : ''}`;
// equal as JSON, whatever the order of the keys
const canon = (v) => JSON.stringify(v, (k, x) => (x && typeof x === 'object' && !Array.isArray(x) ? Object.fromEntries(Object.keys(x).sort().map((key) => [key, x[key]])) : x));
const same = (a, b) => canon(a) === canon(b);

function captureDiff(exp, act) {
  const parts = [];
  const lines = (x, f) => (x || []).map(f);
  if (!same(exp.terminal, act.terminal)) parts.push(showDiff('terminal', lines(exp.terminal, termLine), lines(act.terminal, termLine)));
  if (!same(exp.tree, act.tree)) parts.push(showDiff('tree', lines(exp.tree, treeLine), lines(act.tree, treeLine)));
  for (const k of ['last', 'lastClass', 'prompt', 'input']) if (!same(exp[k], act[k])) parts.push(`      ${k}: expected ${JSON.stringify(exp[k])}, actual ${JSON.stringify(act[k])}`);
  if (!same(exp.checks, act.checks)) parts.push(showDiff('checks', exp.checks || [], act.checks || []));
  const es = exp.snaps || [], as = act.snaps || [];
  for (let i = 0; i < Math.max(es.length, as.length); i++) {
    const e = es[i] || {}, a = as[i] || {};
    if (same(e, a)) continue;
    const label = `snapshot ${i + 1} (after ${a.after || e.after})`;
    if (!same(e.after, a.after)) parts.push(`      ${label}: taken after ${JSON.stringify(e.after)} in the golden, ${JSON.stringify(a.after)} now`);
    if (!same(e.pager, a.pager)) {
      if (!e.pager || !a.pager) parts.push(`      ${label}: pager ${e.pager ? 'was open' : 'was closed'} in the golden, ${a.pager ? 'open' : 'closed'} now`);
      else parts.push(showDiff(`${label} pager`, [...e.pager.lines, `[bar] ${e.pager.bar}`], [...a.pager.lines, `[bar] ${a.pager.bar}`]));
    }
    if (!same(e.terminal, a.terminal)) parts.push(showDiff(`${label} terminal`, lines(e.terminal, termLine), lines(a.terminal, termLine)));
    if (!same(e.tree, a.tree)) parts.push(showDiff(`${label} tree`, lines(e.tree, treeLine), lines(a.tree, treeLine)));
    if (!same(e.screen, a.screen)) parts.push(`      ${label} screen: expected ${JSON.stringify(e.screen)}, actual ${JSON.stringify(a.screen)}`);
  }
  return parts.join('\n');
}

// JSON with one entry per line for arrays of small things, so golden files read and diff well
function pretty(v, ind = '') {
  const flat = (x) => x === null || typeof x !== 'object' || Object.values(x).every((y) => y === null || typeof y !== 'object' || (Array.isArray(y) && y.every((z) => z === null || typeof z !== 'object')));
  if (Array.isArray(v)) {
    if (!v.length) return '[]';
    return '[\n' + v.map((x) => ind + '  ' + (flat(x) ? JSON.stringify(x) : pretty(x, ind + '  '))).join(',\n') + '\n' + ind + ']';
  }
  if (v && typeof v === 'object') {
    const ks = Object.keys(v); if (!ks.length) return '{}';
    return '{\n' + ks.map((k) => ind + '  ' + JSON.stringify(k) + ': ' + pretty(v[k], ind + '  ')).join(',\n') + '\n' + ind + '}';
  }
  return JSON.stringify(v);
}

function judgeRegression(r, golden, opts) {
  if (r.error) return { ok: false, kind: 'ERROR', detail: [`      ${r.error}`, ...(r.problems || []).map((p) => '      ' + p)].join('\n') +
    (r.partial ? '\n      last lines on screen:\n' + r.partial.terminal.slice(-8).map((l) => '        ' + termLine(l)).join('\n') : '') };
  const extra = [...r.problems, ...r.checkFailures];
  if (opts.update) return extra.length ? { ok: false, kind: 'FAIL', detail: extra.map((p) => '      ' + p).join('\n') } : { ok: true };
  const exp = golden[r.name];
  if (!exp) return { ok: false, kind: 'NEW', detail: '      no golden yet (run with --update to record one)' };
  const d = same(exp, r.capture) ? '' : captureDiff(exp, r.capture);
  if (!d && !extra.length) return { ok: true };
  return { ok: false, kind: 'FAIL', detail: [...extra.map((p) => '      ' + p), d].filter(Boolean).join('\n') };
}

function judgePosix(r, opts) {
  const show = () => {
    const out = [];
    if (r.notes) out.push(`      notes: ${r.notes}`);
    if (r.error) out.push(`      ${r.error}`);
    if (r.setup && r.setup.length) out.push('      writing t.sh printed:\n' + r.setup.map((l) => '        ' + termLine(l)).join('\n'));
    const g = r.got, w = r.want;
    if (g && w) {
      if (g.stdout !== w.stdout) out.push(showDiff('stdout', textLines(w.stdout), textLines(g.stdout)));
      if (g.status !== w.status) out.push(`      status: expected ${w.status}, actual ${g.status === null ? '(no __STATUS line)' : g.status}`);
      if (g.stderr !== (w.stderr ?? '')) out.push(showDiff('stderr', textLines(w.stderr ?? ''), textLines(g.stderr)));
    }
    for (const p of r.problems || []) out.push(`      ${p}`);
    return out.join('\n');
  };
  if (r.error) return { ok: false, kind: r.timeout ? 'TIMEOUT' : 'ERROR', detail: show() };
  if (r.problems && r.problems.length) return { ok: false, kind: 'FAIL', detail: show() };
  if (!r.stdoutOk) return { ok: false, kind: 'FAIL', detail: show() };
  if (!r.stderrOk) return opts.ignoreStderr ? { ok: true, note: 'stderr differs' } : { ok: false, kind: 'STDERR', detail: show() };
  return { ok: true };
}

/* ---------------------------------------------------------------- main */

async function main() {
  const opts = parseArgs(process.argv.slice(2));
  const plan = [], skipped = {};
  for (const [suite, pats] of opts.select) {
    if (suite === 'regression') plan.push(...regressionJobs(opts, pats));
    else { const { jobs, skipped: s } = posixJobs(opts, pats, suite === 'posix' ? 'sh' : 'bash'); plan.push(...jobs); skipped[suite] = s; }
  }
  if (opts.list) { for (const j of plan) console.log(`${j.suite}  ${j.name}`); return 0; }
  if (opts.update && !opts.select.has('regression')) die('--update only applies to the regression suite');
  let golden = {};
  if (opts.select.has('regression') && fs.existsSync(GOLDEN)) { try { golden = JSON.parse(fs.readFileSync(GOLDEN, 'utf8')); } catch (e) { die(`cannot read ${GOLDEN}: ${e.message}`); } }
  console.log(`Testing ${path.relative(process.cwd(), opts.page) || opts.page}: ${plan.length} runs on ${Math.min(opts.jobs, plan.length || 1)} tabs` + (opts.update ? ' (updating goldens)' : ''));
  if (!plan.length) { for (const [s, why] of Object.entries(skipped)) why.forEach((w) => console.log(`  ${s}: skipped ${w}`)); console.log('Nothing to run.'); return 0; }

  const t0 = Date.now(), browser = await Browser.launch(opts);
  const stop = () => { browser.cleanup(); process.exit(130); };
  process.on('SIGINT', stop); process.on('SIGTERM', stop);
  // one load first: a page that cannot start (a syntax error half-way through an edit) would otherwise time out in every run
  {
    const page = await Page.open(browser, { ...opts, timeout: 10000 });
    let why = null;
    try { await page.load(pathToFileURL(opts.page).href, VIEWPORT); } catch (e) { why = e.message; }
    const problems = page.problems.filter((p) => !/font did not load/.test(p));
    await page.close();
    if (why || problems.length) {
      await browser.close();
      console.log(`\nThe page does not start${why ? `: ${why}` : ''}`);
      for (const p of problems) console.log(`  ${p}`);
      console.log('\nFAIL (nothing run)');
      return 2;
    }
  }
  const results = [];
  try {
    await pool(browser, opts, plan, (r) => {
      r.verdict = r.suite === 'regression' ? judgeRegression(r, golden, opts) : judgePosix(r, opts);
      results.push(r);
      if (!r.verdict.ok) console.log(`  ${r.verdict.kind.padEnd(7)} ${r.suite} ${r.name}`);
      else if (opts.verbose) console.log(`  PASS    ${r.suite} ${r.name} (${(r.ms / 1000).toFixed(1)} s)${r.verdict.note ? ` [${r.verdict.note}]` : ''}`);
    });
  } finally { await browser.close(); }

  const order = new Map(plan.map((j, i) => [j.suite + '\0' + j.name, i]));
  results.sort((a, b) => order.get(a.suite + '\0' + a.name) - order.get(b.suite + '\0' + b.name));
  const bad = results.filter((r) => !r.verdict.ok);
  if (bad.length) {
    const shown = opts.details ? bad.slice(0, opts.details) : bad;
    console.log('\nDetails');
    for (const r of shown) console.log(`\n  ${r.verdict.kind} ${r.suite} ${r.name}\n${r.verdict.detail}`);
    if (shown.length < bad.length) console.log(`\n  ... and ${bad.length - shown.length} more failures (--details 0 shows them all, or select fewer: SUITE:NAME)`);
  }

  if (opts.update) {
    const ran = results.filter((r) => r.suite === 'regression');
    const all = loadScenarios();
    const next = {};
    let changed = 0, added = 0, unchanged = 0;
    for (const s of all) {
      const r = ran.find((x) => x.name === s.name);
      if (r && r.verdict.ok && r.capture) {
        if (!golden[s.name]) added++; else if (!same(golden[s.name], r.capture)) changed++; else unchanged++;
        next[s.name] = r.capture;
      } else if (golden[s.name]) next[s.name] = golden[s.name];
    }
    fs.writeFileSync(GOLDEN, pretty(next) + '\n');
    const dropped = Object.keys(golden).filter((k) => !(k in next)).length;
    console.log(`\nWrote ${path.relative(process.cwd(), GOLDEN)}: ${added} new, ${changed} changed, ${unchanged} unchanged` + (dropped ? `, ${dropped} removed` : '') + (bad.length ? `; ${bad.length} not saved because they failed` : ''));
  }

  console.log('\nSummary');
  for (const suite of SUITE_NAMES.filter((s) => opts.select.has(s))) {
    const rs = results.filter((r) => r.suite === suite);
    const count = (k) => rs.filter((r) => !r.verdict.ok && r.verdict.kind === k).length;
    const pass = rs.filter((r) => r.verdict.ok).length;
    const kinds = ['FAIL', 'STDERR', 'TIMEOUT', 'ERROR', 'NEW'].map((k) => [k, count(k)]).filter(([, n]) => n);
    const label = { FAIL: suite === 'regression' ? 'failed' : 'stdout/status wrong', STDERR: 'only stderr wrong', TIMEOUT: 'timed out', ERROR: 'errors', NEW: 'without golden' };
    const ms = rs.reduce((t, r) => t + (r.ms || 0), 0);
    console.log(`  ${suite.padEnd(11)} ${String(pass).padStart(4)} passed` + kinds.map(([k, n]) => `, ${n} ${label[k]}`).join('') +
      ((skipped[suite] || []).length ? `, ${skipped[suite].length} skipped` : '') + `   (${(ms / 1000).toFixed(1)} s of tab time)`);
    if (opts.verbose) for (const s of skipped[suite] || []) console.log(`              skipped ${s}`);
  }
  console.log(`  total time ${((Date.now() - t0) / 1000).toFixed(1)} s`);
  console.log(bad.length ? `\nFAIL (${bad.length} of ${results.length})` : `\nPASS (${results.length})`);
  return bad.length ? 1 : 0;
}

main().then((code) => process.exit(code), (e) => { console.error(e && e.stack || e); process.exit(2); });
