// Exercise the actual game-hall browser script without adding runtime packages.
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');

class Element {
  constructor(dataset = {}) {
    this.dataset = dataset; this.hidden = false; this.value = '';
    this.events = new Map(); this.classes = new Set(); this.attributes = {};
    this.classList = {
      contains: value => this.classes.has(value),
      toggle: (value, force) => {
        const selected = force === undefined ? !this.classes.has(value) : force;
        if (selected) this.classes.add(value); else this.classes.delete(value);
        return selected;
      },
      remove: value => this.classes.delete(value),
    };
  }
  addEventListener(event, callback) { this.events.set(event, callback); }
  setAttribute(name, value) { this.attributes[name] = value; }
  focus() { this.focused = true; }
  fire(event) { this.events.get(event)?.(); }
}

const fixture = [
  ['tarneeb', 'طرنيب Tarneeb', 'tarneeb', '1'],
  ['syrian_tarneeb', 'طرنيب سوري Syrian Tarneeb', 'tarneeb', '0'],
  ['tarneeb_400', 'طرنيب 400 Tarneeb 400', 'tarneeb', '0'],
  ['trix', 'تركس Trix', 'trix', '0'],
  ['trix_partner', 'تركس شراكة Partner Trix', 'trix', '0'],
  ['trix_complex', 'تركس كمبلكس Trix Complex', 'trix', '1'],
  ['hand', 'هاند Hand', 'meld', '1'],
  ['hand_partner', 'هاند شراكة Hand Partner', 'meld', '0'],
  ['saudi_hand', 'هاند سعودي Saudi Hand', 'meld', '0'],
  ['banakil', 'بناكل Banakil', 'meld', '0'],
  ['baloot', 'بلوت Baloot', 'gulf', '1'],
  ['basra', 'باصرة بصرة بصره باصره Basra basrah', 'basra', '0'],
];
const file = path.join(__dirname, '../backend-laravel/resources/views/games/index.blade.php');
const script = fs.readFileSync(file, 'utf8').match(/<script>([\s\S]*?)<\/script>/)[1];

for (const language of ['ar', 'en']) {
  const search = new Element(), compact = new Element(), featured = new Element();
  const results = new Element(), empty = new Element(), clear = new Element(), root = new Element();
  const tabs = ['all', 'tarneeb', 'trix', 'meld', 'gulf', 'basra'].map(family => new Element({familyFilterV130: family}));
  tabs[0].classes.add('active');
  const cards = fixture.map(([id, name, family, flag]) => new Element({id, name: `${id} ${name}`, family, featured: flag}));
  const lookup = {'#gameSearchV130': search, '#compactGamesV130': compact,
    '#showFeaturedV130': featured, '#w36GamesResults': results,
    '#w36GamesEmpty': empty, '#w36ClearGameFilters': clear};
  root.querySelector = selector => lookup[selector];
  root.querySelectorAll = selector => selector === '[data-family-filter-v130]' ? tabs : cards;
  vm.runInNewContext(script, {document: {documentElement: {lang: language}, getElementById: () => root}, Map});
  const visible = () => cards.filter(card => !card.hidden).map(card => card.dataset.id);
  const query = value => { search.value = value; search.fire('input'); };
  assert.equal(visible().length, 12);
  query('  طَـرْنِيب   ');
  assert.deepEqual(visible(), ['tarneeb', 'syrian_tarneeb', 'tarneeb_400']);
  query('Partner Trix'); assert.deepEqual(visible(), ['trix_partner']);
  query('بصرة'); assert.deepEqual(visible(), ['basra']);
  query('TARNEEB_400'); assert.deepEqual(visible(), ['tarneeb_400']);
  query(''); tabs[3].fire('click'); assert.equal(visible().length, 4);
  featured.fire('click'); assert.deepEqual(visible(), ['hand']);
  query('غير موجود'); assert.equal(visible().length, 0); assert.equal(empty.hidden, false);
  clear.fire('click'); assert.equal(visible().length, 12); assert.equal(empty.hidden, true);
  assert.equal(search.focused, true); assert.equal(featured.attributes['aria-pressed'], 'false');
  assert.equal(results.textContent, (language === 'ar' ? 'النتائج: ' : 'Results: ') + '12 / 12');
  compact.fire('click'); assert.equal(compact.attributes['aria-pressed'], 'true');
}
console.log('R36 bilingual discovery, combined filters, reset and accessible result state: PASS');
