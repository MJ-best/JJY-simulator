// node test.mjs
import assert from 'node:assert/strict';
import { fields, frame } from './jjy.js';

const t = new Date('2026-10-18T04:07:00Z');

// 2026-10-18 13:07 JST, Sunday, day 291. Hour 13 and minute 7 both have odd parity.
const tokyo = fields(t, 'Asia/Tokyo');
assert.deepEqual(tokyo, { y: 2026, doy: 291, h: 13, m: 7, wd: 0 });
assert.equal(frame(tokyo).join(''),
  'M00000111M' + '000100011M' + '001001001M' + '000100110M' + '000100110M' + '000000000M');

// New York (EDT, UTC-4) -> 00:07 same day; midnight must be 0, not 24.
assert.deepEqual(fields(t, 'America/New_York'), { y: 2026, doy: 291, h: 0, m: 7, wd: 0 });

// Leap year Dec 31 -> day 366.
assert.equal(fields(new Date('2028-12-31T12:00:00Z'), 'UTC').doy, 366);

console.log('ok');
