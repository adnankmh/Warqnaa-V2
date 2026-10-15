// Run the shipped progress script against controlled GitHub responses.
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const source = fs.readFileSync(path.join(__dirname, '../backend-laravel/resources/views/home.blade.php'), 'utf8');
const script = [...source.matchAll(/<script>([\s\S]*?)<\/script>/g)]
  .map(match => match[1]).find(text => text.includes('w36-live-progress'));
assert.ok(script, 'Real admin progress script is present');
const workflows = ['Backend CI and Security Foundation', 'Build Android APK and AAB',
  'Build and deploy Flutter Web', 'Production Release Gate', 'R7 isolated runtime and visual review'];
const headA = 'a'.repeat(40), headB = 'b'.repeat(40);
const tick = () => new Promise(resolve => setImmediate(resolve));

async function verify(language) {
  const elements = new Map();
  const element = id => {
    if (!elements.has(id)) elements.set(id, {dataset: {}, style: {}, textContent: '', attributes: {},
      disabled: false, events: new Map(),
      setAttribute(name, value) { this.attributes[name] = value; },
      addEventListener(name, callback) { this.events.set(name, callback); },
      replaceChildren() {}});
    return elements.get(id);
  };
  const gates = workflows.map(name => ({dataset: {}, href: '', state: element(name),
    getAttribute: () => name, querySelector() { return this.state; }}));
  const root = element('w36-live-progress'); root.querySelectorAll = () => gates;
  let phase = 0, interval;
  const fetch = async url => {
    if (url.includes('/pulls/29')) {
      if (phase === 4) throw Error('Network unavailable');
      return {ok: true, json: async () => ({head: {sha: phase === 0 ? headA : headB}, draft: true, commits: 1})};
    }
    if (url.includes('/commits?')) return {ok: true, json: async () => []};
    if (phase === 1) return {ok: false};
    const sha = phase === 0 || phase === 2 ? headA : headB;
    const workflow_runs = workflows.map((name, index) => ({name, head_sha: sha,
      status: 'completed', conclusion: phase === 3 && index === 0 ? 'failure' : 'success',
      created_at: '2026-10-13T21:00:00Z', html_url: 'https://github.com/adnankmh/Warqnaa-V2/actions/runs/2'}));
    // An older green run on the same SHA must not hide a newer red run.
    if (phase === 3) workflow_runs.push({...workflow_runs[0], conclusion: 'success', created_at: '2026-10-13T20:00:00Z'});
    return {ok: true, json: async () => ({workflow_runs})};
  };
  vm.runInNewContext(script, {fetch, Date, Number, String, Array,
    document: {hidden: false, documentElement: {lang: language}, getElementById: element,
      createDocumentFragment: () => ({appendChild() {}})},
    window: {fetch, setInterval(callback) { interval = callback; }}});
  await tick();
  assert.equal(element('w36-progress-passed').textContent, '5 / 5');
  assert.equal(element('w36-progress-download').disabled, false);
  phase = 1; interval(); await tick();
  assert.equal(element('w36-progress-passed').textContent, '— / 5');
  assert.ok(gates.every(gate => gate.dataset.status === 'unknown'));
  assert.equal(element('w36-progress-fill').style.width, '0%');
  assert.equal(element('w36-progress-track').attributes['aria-valuenow'], '0');
  assert.equal(element('w36-progress-download').disabled, true);
  phase = 2; interval(); await tick();
  assert.equal(element('w36-progress-passed').textContent, '0 / 5');
  assert.ok(gates.every(gate => gate.dataset.status === 'unknown'));
  phase = 3; interval(); await tick();
  assert.equal(element('w36-progress-passed').textContent, '4 / 5');
  assert.equal(gates[0].dataset.status, 'failed');
  assert.equal(element('w36-progress-download').disabled, false);
  phase = 4; interval(); await tick();
  assert.equal(element('w36-progress-passed').textContent, '— / 5');
  assert.equal(element('w36-progress-download').disabled, true);
}
(async () => {
  await verify('ar'); await verify('en');
  console.log('R36 exact-head progress: stale success, API errors, mismatched SHAs and latest failed run: PASS');
})().catch(error => {console.error(error); process.exitCode = 1;});
