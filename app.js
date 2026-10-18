import { fields, frame, HIGH } from './jjy.js';

const $ = id => document.getElementById(id);

const lang = document.documentElement.lang;
const T = JSON.parse($('t').textContent);
try { localStorage.lang = lang; } catch {} // root page redirects to the last language seen

// --- cities ---
// [IANA zone, lat, lon, ko, en, ja], west to east
const CITIES = [
  ['Pacific/Pago_Pago', -14.28, -170.7, '아메리칸사모아', 'Pago Pago', 'パゴパゴ'],
  ['Pacific/Honolulu', 21.31, -157.86, '호놀룰루', 'Honolulu', 'ホノルル'],
  ['America/Anchorage', 61.22, -149.9, '앵커리지', 'Anchorage', 'アンカレッジ'],
  ['America/Vancouver', 49.28, -123.12, '밴쿠버', 'Vancouver', 'バンクーバー'],
  ['America/Los_Angeles', 34.05, -118.24, '로스앤젤레스', 'Los Angeles', 'ロサンゼルス'],
  ['America/Phoenix', 33.45, -112.07, '피닉스', 'Phoenix', 'フェニックス'],
  ['America/Denver', 39.74, -104.99, '덴버', 'Denver', 'デンバー'],
  ['America/Mexico_City', 19.43, -99.13, '멕시코시티', 'Mexico City', 'メキシコシティ'],
  ['America/Chicago', 41.88, -87.63, '시카고', 'Chicago', 'シカゴ'],
  ['America/Cancun', 21.16, -86.85, '칸쿤', 'Cancún', 'カンクン'],
  ['America/Toronto', 43.65, -79.38, '토론토', 'Toronto', 'トロント'],
  ['America/Lima', -12.05, -77.04, '리마', 'Lima', 'リマ'],
  ['America/New_York', 40.71, -74.01, '뉴욕', 'New York', 'ニューヨーク'],
  ['America/Bogota', 4.71, -74.07, '보고타', 'Bogotá', 'ボゴタ'],
  ['America/Santiago', -33.45, -70.67, '산티아고', 'Santiago', 'サンティアゴ'],
  ['America/Halifax', 44.65, -63.57, '핼리팩스', 'Halifax', 'ハリファックス'],
  ['America/Argentina/Buenos_Aires', -34.6, -58.38, '부에노스아이레스', 'Buenos Aires', 'ブエノスアイレス'],
  ['America/Sao_Paulo', -23.55, -46.63, '상파울루', 'São Paulo', 'サンパウロ'],
  ['Atlantic/Reykjavik', 64.15, -21.94, '레이캬비크', 'Reykjavík', 'レイキャビク'],
  ['Europe/Lisbon', 38.72, -9.14, '리스본', 'Lisbon', 'リスボン'],
  ['Europe/London', 51.51, -0.13, '런던', 'London', 'ロンドン'],
  ['Europe/Madrid', 40.42, -3.7, '마드리드', 'Madrid', 'マドリード'],
  ['Europe/Paris', 48.86, 2.35, '파리', 'Paris', 'パリ'],
  ['Africa/Lagos', 6.52, 3.38, '라고스', 'Lagos', 'ラゴス'],
  ['Europe/Rome', 41.9, 12.5, '로마', 'Rome', 'ローマ'],
  ['Europe/Berlin', 52.52, 13.4, '베를린', 'Berlin', 'ベルリン'],
  ['Europe/Athens', 37.98, 23.73, '아테네', 'Athens', 'アテネ'],
  ['Europe/Helsinki', 60.17, 24.94, '헬싱키', 'Helsinki', 'ヘルシンキ'],
  ['Africa/Johannesburg', -26.2, 28.05, '요하네스버그', 'Johannesburg', 'ヨハネスブルグ'],
  ['Europe/Istanbul', 41.01, 28.98, '이스탄불', 'Istanbul', 'イスタンブール'],
  ['Africa/Cairo', 30.04, 31.24, '카이로', 'Cairo', 'カイロ'],
  ['Africa/Nairobi', -1.29, 36.82, '나이로비', 'Nairobi', 'ナイロビ'],
  ['Europe/Moscow', 55.76, 37.62, '모스크바', 'Moscow', 'モスクワ'],
  ['Asia/Tehran', 35.69, 51.39, '테헤란', 'Tehran', 'テヘラン'],
  ['Asia/Dubai', 25.2, 55.27, '두바이', 'Dubai', 'ドバイ'],
  ['Asia/Karachi', 24.86, 67.01, '카라치', 'Karachi', 'カラチ'],
  ['Asia/Almaty', 43.24, 76.89, '알마티', 'Almaty', 'アルマトイ'],
  ['Asia/Kolkata', 28.61, 77.21, '델리', 'Delhi', 'デリー'],
  ['Asia/Kathmandu', 27.72, 85.32, '카트만두', 'Kathmandu', 'カトマンズ'],
  ['Asia/Dhaka', 23.81, 90.41, '다카', 'Dhaka', 'ダッカ'],
  ['Asia/Bangkok', 13.76, 100.5, '방콕', 'Bangkok', 'バンコク'],
  ['Asia/Singapore', 1.35, 103.82, '싱가포르', 'Singapore', 'シンガポール'],
  ['Asia/Ho_Chi_Minh', 10.82, 106.63, '호찌민', 'Ho Chi Minh City', 'ホーチミン'],
  ['Asia/Jakarta', -6.21, 106.85, '자카르타', 'Jakarta', 'ジャカルタ'],
  ['Asia/Ulaanbaatar', 47.89, 106.91, '울란바토르', 'Ulaanbaatar', 'ウランバートル'],
  ['Asia/Hong_Kong', 22.32, 114.17, '홍콩', 'Hong Kong', '香港'],
  ['Asia/Makassar', -8.65, 115.22, '발리', 'Bali', 'バリ'],
  ['Australia/Perth', -31.95, 115.86, '퍼스', 'Perth', 'パース'],
  ['Asia/Shanghai', 39.9, 116.4, '베이징', 'Beijing', '北京'],
  ['Asia/Manila', 14.6, 120.98, '마닐라', 'Manila', 'マニラ'],
  ['Asia/Taipei', 25.03, 121.57, '타이베이', 'Taipei', '台北'],
  ['Asia/Seoul', 37.57, 126.98, '서울', 'Seoul', 'ソウル'],
  ['Australia/Darwin', -12.46, 130.84, '다윈', 'Darwin', 'ダーウィン'],
  ['Asia/Vladivostok', 43.12, 131.89, '블라디보스토크', 'Vladivostok', 'ウラジオストク'],
  ['Australia/Adelaide', -34.93, 138.6, '애들레이드', 'Adelaide', 'アデレード'],
  ['Asia/Tokyo', 35.68, 139.69, '도쿄', 'Tokyo', '東京'],
  ['Pacific/Guam', 13.44, 144.79, '괌', 'Guam', 'グアム'],
  ['Pacific/Saipan', 15.18, 145.75, '사이판', 'Saipan', 'サイパン'],
  ['Australia/Sydney', -33.87, 151.21, '시드니', 'Sydney', 'シドニー'],
  ['Australia/Brisbane', -27.47, 153.03, '브리즈번', 'Brisbane', 'ブリスベン'],
  ['Pacific/Auckland', -36.85, 174.76, '오클랜드', 'Auckland', 'オークランド'],
  ['Pacific/Fiji', -18.14, 178.44, '피지', 'Fiji', 'フィジー'],
];
const NAME = 3 + ['ko', 'en', 'ja'].indexOf(lang);
const city = z => CITIES.find(c => c[0] === z);
const nameOf = z => city(z)?.[NAME] ?? z.split('/').pop().replace(/_/g, ' ');
const device = Intl.DateTimeFormat().resolvedOptions().timeZone;

// --- zone list ---
for (const [label, zones] of [
  [T.major, new Set([device, ...CITIES.map(c => c[0])])],
  [T.all, Intl.supportedValuesOf('timeZone')],
]) {
  const g = document.createElement('optgroup');
  g.label = label;
  for (const z of zones) g.append(new Option(`${nameOf(z)}${z === device ? ` · ${T.device}` : ''} (${z})`, z));
  $('tz').append(g);
}
$('tz').value = device;

// --- map ---
const W = 1000, H = 500, NS = 'http://www.w3.org/2000/svg';
const X = lon => (lon + 180) / 360 * W, Y = lat => (90 - lat) / 180 * H;
const el = (tag, attrs, parent) => {
  const e = document.createElementNS(NS, tag);
  for (const k in attrs) e.setAttribute(k, attrs[k]);
  return parent.appendChild(e);
};
for (let k = -12; k <= 12; k++) {
  if (k < 12) el('line', { x1: X(k * 15 + 7.5), x2: X(k * 15 + 7.5), y1: 0, y2: H }, $('grid'));
  el('text', { x: X(k * 15), y: 36 }, $('grid')).textContent = (k > 0 ? '+' : '') + k;
}
for (const c of CITIES)
  el('circle', { cx: X(c[2]), cy: Y(c[1]), r: 4, 'data-zone': c[0] }, $('dots'))
    .appendChild(document.createElementNS(NS, 'title')).textContent = c[NAME];

Promise.all([
  import('https://cdn.jsdelivr.net/npm/d3-geo@3.1.1/+esm'),
  import('https://cdn.jsdelivr.net/npm/topojson-client@3.1.0/+esm'),
  fetch('https://cdn.jsdelivr.net/npm/world-atlas@2.0.2/land-110m.json').then(r => r.json()),
]).then(([d3, topo, world]) => {
  const proj = d3.geoEquirectangular().scale(W / 2 / Math.PI).translate([W / 2, H / 2]); // same as X/Y
  $('land').setAttribute('d', d3.geoPath(proj)(topo.feature(world, world.objects.land)));
}).catch(e => console.warn('map unavailable, list still works', e));

$('svg').onclick = e => {
  const p = new DOMPoint(e.clientX, e.clientY).matrixTransform($('svg').getScreenCTM().inverse());
  const lon = p.x / W * 360 - 180, lat = 90 - p.y / H * 180, k = Math.cos(lat * Math.PI / 180);
  const dist = c => (c[1] - lat) ** 2 + ((((c[2] - lon) % 360 + 540) % 360 - 180) * k) ** 2;
  $('tz').value = CITIES.reduce((a, b) => (dist(b) < dist(a) ? b : a))[0];
  $('tz').onchange();
};

const offsetMin = (d, tz) => {
  const f = fields(d, tz);
  return (Date.UTC(f.y, 0, f.doy, f.h, f.m) - Math.floor(d / 6e4) * 6e4) / 6e4;
};
const fmtOffset = m => `UTC${m < 0 ? '−' : '+'}${Math.trunc(Math.abs(m) / 60)}${m % 60 ? ':' + String(Math.abs(m % 60)).padStart(2, '0') : ''}`;

let lastSec;
function showZone(behavior = 'smooth') {
  const tz = $('tz').value, off = offsetMin(new Date(), tz), c = city(tz);
  $('band').setAttribute('x', X(off / 4 - 7.5));
  for (const d of $('dots').children) d.classList.toggle('on', d.dataset.zone === tz);
  $('pin').textContent = c ? c[NAME] : '';
  if (c) {
    const east = c[2] > 140;
    $('pin').setAttribute('x', X(c[2]) + (east ? -12 : 12));
    $('pin').setAttribute('y', Y(c[1]) + 6);
    $('pin').setAttribute('text-anchor', east ? 'end' : 'start');
  }
  $('city').textContent = nameOf(tz);
  $('utc').textContent = fmtOffset(off);
  lastSec = null;
  const px = X(c ? c[2] : off / 4) / W * $('svg').clientWidth;
  $('map').scrollTo({ left: px - $('map').clientWidth / 2, behavior });
}

// --- audio ---
let ctx, gain, wake, next;
const freq = () => +document.querySelector('[name=freq]:checked').value;

async function start() {
  if (navigator.audioSession) navigator.audioSession.type = 'playback'; // iOS: ignore silent switch
  ctx = new AudioContext();
  const osc = new OscillatorNode(ctx, { frequency: freq() });
  gain = new GainNode(ctx, { gain: 0 });
  osc.connect(gain).connect(ctx.destination);
  osc.start();
  next = Math.ceil(Date.now() / 1000) * 1000;
  $('go').textContent = T.stop;
  $('go').classList.add('running');
  $('state').textContent = `${T.tx} · ${Math.round(freq() * 3 / 1000)}kHz`;
  wake = await navigator.wakeLock?.request('screen').catch(() => null);
}

function stop() {
  ctx.close();
  wake?.release();
  ctx = wake = null;
  $('go').textContent = T.start;
  $('go').classList.remove('running');
  $('state').textContent = T.idle;
}

// Queue each second's pulse ~3 s ahead on the audio clock.
function schedule() {
  const ts = ctx.getOutputTimestamp?.() ?? {};
  // Output timestamp maps audio time to what is actually leaving the jack (includes latency).
  const [ctxNow, wallNow] = ts.performanceTime
    ? [ts.contextTime, performance.timeOrigin + ts.performanceTime]
    : [ctx.currentTime, Date.now()];
  for (; next < wallNow + 3000; next += 1000) {
    const at = ctxNow + (next - wallNow) / 1000;
    if (at < ctx.currentTime) continue;
    const d = new Date(next);
    const sym = frame(fields(d, $('tz').value))[d.getUTCSeconds()];
    gain.gain.setValueAtTime(1, at);
    gain.gain.setValueAtTime(0, at + HIGH[sym]);
  }
}

// --- display ---
function render() {
  const now = new Date(), tz = $('tz').value, s = now.getUTCSeconds();
  const f = fields(now, tz), bits = frame(f);
  $('lamp').classList.toggle('on', !!ctx && now % 1000 < HIGH[bits[s]] * 1000);
  if (s === lastSec) return;
  lastSec = s;
  const p = n => String(n).padStart(2, '0');
  $('time').textContent = `${p(f.h)}:${p(f.m)}:${p(s)}`;
  $('date').textContent = now.toLocaleDateString(lang, { timeZone: tz, year: 'numeric', month: 'long', day: 'numeric', weekday: 'long' });
  $('bits').innerHTML = bits.map((b, i) =>
    `<i class="${b === 'M' ? 'm' : ''}${i === s && ctx ? ' cur' : ''}" style="height:${HIGH[b] * 100}%"></i>`).join('');
}

setInterval(() => { if (ctx) schedule(); render(); }, 50);
showZone('instant');
render();

const restart = () => ctx && (stop(), start());
$('go').onclick = () => (ctx ? stop() : start());
$('tz').onchange = () => { showZone(); restart(); };
for (const r of document.getElementsByName('freq')) r.onchange = restart;
