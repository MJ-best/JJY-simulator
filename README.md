# JJY Simulator

**https://mj-best.github.io/JJY-simulator/** · [한국어](https://mj-best.github.io/JJY-simulator/?lang=ko) · [English](https://mj-best.github.io/JJY-simulator/?lang=en) · [日本語](https://mj-best.github.io/JJY-simulator/?lang=ja)

## 한국어
유선 이어폰으로 JJY 표준전파를 흉내 내 전파시계(시티즌 PMD 기준)를 맞추는 웹페이지.
- 13.333kHz(또는 20kHz) 사인파를 JJY 타임코드로 ON/OFF. 이어폰 케이블에서 새는 3배음(40/60kHz)을 시계가 수신.
- **시간대 강제**: 시계는 JJY를 무조건 JST로 해석하므로, 지도에서 고른 곳의 현지 시각을 JST 자리에 넣어 보낸다. 기본값은 기기 시간대라 해외에서 열고 시작만 누르면 됨.
- ⚠ 이어폰을 귀에 꽂지 말 것.

## English
A web page that imitates the JJY time signal through wired earphones to set a radio-controlled watch (built for Citizen PMD).
- A 13.333 kHz (or 20 kHz) sine is keyed with the JJY time code; its 3rd harmonic (40/60 kHz) leaking from the earphone cable is picked up by the watch.
- **Time-zone override**: JJY watches always read the signal as JST, so the page sends the local time of the place you tap on the map in its place. Defaults to the device's time zone — abroad, just open and press Start.
- ⚠ Do not put the earphones in your ears.

## 日本語
有線イヤホンからJJY標準電波を模擬して電波時計(シチズン PMD 基準)を合わせるWebページ。
- 13.333kHz(または20kHz)の正弦波をJJYタイムコードでON/OFF。イヤホンケーブルから漏れる第3高調波(40/60kHz)を時計が受信。
- **タイムゾーン変更**: 時計はJJYを常にJSTとして解釈するため、地図で選んだ場所の現地時刻をJSTの代わりに送信。初期値は端末のタイムゾーンなので、海外では開いて送信開始を押すだけ。
- ⚠ イヤホンを耳に入れないでください。

Test: `node test.mjs`
