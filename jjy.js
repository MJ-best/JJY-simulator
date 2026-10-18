// JJY time code (NICT spec). The watch assumes the frame is JST,
// so encoding another zone's wall-clock time makes it display that zone.

// Wall-clock fields of `date` in IANA `timeZone` (DST handled by Intl).
export function fields(date, timeZone) {
  const p = Object.fromEntries(new Intl.DateTimeFormat('en-US', {
    timeZone, hourCycle: 'h23', year: 'numeric', month: 'numeric', day: 'numeric', hour: 'numeric', minute: 'numeric',
  }).formatToParts(date).map(x => [x.type, +x.value]));
  const day = Date.UTC(p.year, p.month - 1, p.day);
  return {
    y: p.year,
    doy: (day - Date.UTC(p.year, 0, 1)) / 864e5 + 1,
    h: p.hour,
    m: p.minute,
    wd: new Date(day).getUTCDay(), // 0 = Sunday
  };
}

// 60 symbols for one minute: 0, 1 or 'M' (marker).
export function frame({ y, doy, h, m, wd }) {
  const bcd = (v, ...w) => w.map(x => (v >= x ? (v -= x, 1) : 0));
  const par = a => a.reduce((s, x) => s ^ x, 0);
  const M = 'M';
  const mi = bcd(m, 40, 20, 10, 8, 4, 2, 1);
  const hr = bcd(h, 20, 10, 8, 4, 2, 1);
  const d = bcd(doy, 200, 100, 80, 40, 20, 10, 8, 4, 2, 1);
  return [
    M, ...mi.slice(0, 3), 0, ...mi.slice(3), M,                 // 0-9   minute
    0, 0, ...hr.slice(0, 2), 0, ...hr.slice(2), M,              // 10-19 hour
    0, 0, ...d.slice(0, 2), 0, ...d.slice(2, 6), M,             // 20-29 day of year
    ...d.slice(6), 0, 0, par(hr), par(mi), 0, M,                // 30-39 doy, PA1, PA2, SU1
    0, ...bcd(y % 100, 80, 40, 20, 10, 8, 4, 2, 1), M,          // 40-49 SU2, year
    ...bcd(wd, 4, 2, 1), 0, 0, 0, 0, 0, 0, M,                   // 50-59 weekday, LS1/2
  ];
}

// Seconds the carrier stays high at the start of each second.
export const HIGH = { 0: 0.8, 1: 0.5, M: 0.2 };
