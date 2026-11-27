# App Store Connect Metadata (v1.0)

App Store Connect에 바로 복사·붙여넣기 할 수 있도록 정리한 3개 언어(`한국어`, `English (U.S.)`, `日本語`) 메타데이터입니다.
개별 파일은 fastlane `deliver` 구조에 맞춰 `ios/AppStore/metadata/{ko,en-US,ja}/`에도 함께 저장되어 있습니다.

## 공통 설정 (App Information)
- **Primary Category**: `Utilities` (유틸리티)
- **Secondary Category**: `Travel` (여행)
- **Age Rating**: `4+` (모든 항목 '없음 / None')
- **Price**: `Free` (무료)
- **App Privacy (개인정보 보호)**: `Data Not Collected` (데이터 수집 안 함 — `PrivacyInfo.xcprivacy` 포함 완료)
- **Export Compliance (수출 규정)**: `ITSAppUsesNonExemptEncryption = false` (`Info.plist`에 반영 완료)
- **Support URL**: `https://github.com/MJ-best/JJY-simulator/issues`
- **Privacy Policy URL**: `https://mj-best.github.io/JJY-simulator/privacy.html`

---

## 한국어 (`ko`)

| 항목 | 제한 | 입력값 |
|---|---|---|
| **앱 이름 (Name)** | 9 / 30자 | `JJY 시뮬레이터` |
| **부제 (Subtitle)** | 17 / 30자 | `유선 이어폰으로 전파시계 맞추기` |
| **프로모션 텍스트 (Promotional Text)** | 80 / 170자 | `유선 이어폰으로 일본 JJY(40/60kHz) 전파를 흉내 내 전파시계를 맞춥니다. 오프라인 세계 지도로 해외 현지 시각까지 바로 동기화하세요.` |
| **키워드 (Keywords)** | 79 / 100자 | `JJY,전파시계,시티즌,PMD,세이코,카시오,라디오컨트롤,표준전파,시계동기화,시간맞추기,40kHz,60kHz,세계시간,시간대,해외여행,일본시계` |
| **마케팅 URL (Marketing URL)** | — | `https://mj-best.github.io/JJY-simulator/ko/` |

### 설명 (Description · 1,315 / 4,000자)
```text
유선 이어폰을 통해 일본 표준전파 JJY(40kHz / 60kHz) 타임코드를 시뮬레이션해 전파시계의 시각을 맞추는 앱입니다.

JJY 전파가 닿지 않는 한국·미국·유럽 등 해외나, 전파 수신이 어려운 실내에서도 시계 시간을 정확하게 동기화할 수 있습니다.

■ 주요 기능
• 40kHz / 60kHz JJY 표준전파 시뮬레이션
  13.333kHz(40kHz용) 또는 20kHz(60kHz용) 사인파를 NICT JJY 타임코드 규격에 맞춰 정밀하게 ON/OFF 합니다. 이어폰 케이블에서 발생하는 3배음(40/60kHz)을 시계 안테나가 수신합니다.
• 해외 현지 시각 강제 송신 (서머타임 자동 반영)
  일본 내수용 JJY 전파시계는 수신한 시각을 무조건 일본 시각(JST)으로 표시합니다. 지도나 목록에서 원하는 도시를 선택하면 그곳의 현지 시각을 대신 송신하므로, 시계의 시차 설정을 바꾸지 않고도 현지 시각으로 맞출 수 있습니다.
• 완전 오프라인 내장 세계 지도
  지도 데이터가 앱 안에 내장되어 있어 비행기 모드나 해외 로밍이 꺼진 환경에서도 세계 지도를 보고 시간대를 바로 고를 수 있습니다.
• 전 세계 시간대 빠른 검색
  주요 62개 도시와 전체 IANA 시간대를 지원하며, 기본값은 현재 기기 시간대로 설정되어 해외 도착 후 앱을 열고 바로 시작할 수 있습니다.
• 실시간 60초 타임코드 시각화
  현재 송신 중인 60초 JJY 펄스 패턴(0 / 1 / 마커)과 캐리어 램프를 실시간으로 확인할 수 있습니다.
• iPhone 및 iPad 최적화
  iPhone과 iPad(가로·세로 2컬럼 레이아웃) 및 다크 모드를 지원하며, 송신 중 화면이 꺼지지 않도록 유지합니다.

■ 사용 방법
1. 유선 이어폰을 연결하고 기기 볼륨을 최대로 올립니다.
2. 시계를 이어폰 케이블 바로 옆(수 cm)에 둡니다. 케이블을 시계에 몇 바퀴 감으면 수신율이 높아집니다.
3. 앱에서 '송신 시작'을 누른 뒤 시계를 강제 수신 모드로 전환합니다. (수신에 보통 2~10분 소요)
4. 수신이 잘 되지 않으면 40kHz와 60kHz를 번갈아 시도해 보세요.

■ 주의 사항 및 호환 안내
• 고음이 크게 출력되므로 송신 중 이어폰을 절대 귀에 꽂지 마세요.
• 블루투스 이어폰에서는 동작하지 않으며, 유선 이어폰(USB-C / Lightning 어댑터 포함)이 필요합니다.
• 시티즌(PMD 시리즈 기준), 세이코, 카시오 등 일본 JJY(40/60kHz) 수신 지원 전파시계용입니다. WWVB·DCF77·MSF 신호는 지원하지 않습니다.
• 광고, 회원가입, 개인정보 수집이 전혀 없으며 모든 처리는 기기 내에서 오프라인으로 이루어집니다.
```

### 새로운 기능 (What's New · v1.0)
```text
JJY 시뮬레이터 iPhone 및 iPad 첫 번째 버전입니다.
• 40kHz / 60kHz JJY 표준전파 정밀 오디오 송신
• 오프라인 세계 지도 및 62개 주요 도시 / 전체 IANA 시간대 지원
• 실시간 60초 JJY 타임코드 시각화 및 iPhone·iPad 다크 모드 지원
```

---

## English (`en-US`)

| Field | Length | Value |
|---|---|---|
| **Name** | 13 / 30 | `JJY Simulator` |
| **Subtitle** | 27 / 30 | `Sync Radio Watches Anywhere` |
| **Promotional Text** | 153 / 170 | `Simulate Japan's JJY 40/60 kHz time signal through wired earphones. Tap the offline world map to sync your radio-controlled watch to local time anywhere.` |
| **Keywords** | 97 / 100 | `JJY,radio,watch,atomic,clock,sync,Citizen,PMD,Seiko,Casio,time,signal,40kHz,60kHz,timezone,travel` |
| **Marketing URL** | — | `https://mj-best.github.io/JJY-simulator/` |

### Description (2,701 / 4,000)
```text
Simulate Japan's JJY standard time signal (40 kHz / 60 kHz) through wired earphones to synchronize your Japanese radio-controlled (atomic) watch anywhere in the world.

Whether you are traveling outside Japan where JJY does not reach, or indoors where radio reception is weak, JJY Simulator lets you sync your watch reliably in minutes.

KEY FEATURES
• 40 kHz & 60 kHz JJY Time-Code Synthesis
  Generates a sample-accurate 13.333 kHz (for 40 kHz) or 20 kHz (for 60 kHz) sine wave keyed to the official NICT JJY pulse pattern. The third harmonic (40 / 60 kHz) emitted from the wired earphone cable is picked up by the watch antenna from a few centimeters away.
• Time-Zone Override with Automatic DST
  JJY watches always interpret received signals as Japan Standard Time (JST). Select any city on the map or list and the app transmits that city's local time in JST's place—so your watch displays local time abroad without changing watch settings. Daylight saving time is applied automatically.
• Built-In Offline World Map
  Natural Earth vector map data is bundled directly in the app, so tapping your destination works completely offline—even in airplane mode or abroad without data roaming.
• Global Time-Zone Search
  Includes 62 curated major cities on the map plus every IANA time zone. Defaults to your device's current time zone so abroad you can simply open the app and tap Start.
• Live 60-Second Time-Code Visualizer
  Watch the blinking carrier indicator and all 60 pulse bars (0, 1, and Marker symbols) update in real time.
• Designed for iPhone & iPad
  Adaptive single-column iPhone layout and two-column iPad layout with full Light and Dark Mode support. Keeps the screen awake while transmitting and safely stops if headphones are unplugged.

HOW TO USE
1. Plug in wired earphones (including USB-C or Lightning adapters) and turn volume all the way up.
2. Place the watch right next to the earphone cable (a few cm). Wrapping the cable loosely around the watch a few times helps.
3. Tap Start, then place your watch into manual (forced) reception mode (refer to your watch manual). Syncing typically takes 2–10 minutes.
4. Keep the screen on while transmitting. If reception does not lock, try switching between 40 kHz and 60 kHz.

SAFETY & COMPATIBILITY
• Loud high-pitched tone: NEVER put the earphones in your ears while transmitting.
• Bluetooth earphones do not work; wired earphones are required.
• Compatible with JJY (40/60 kHz) radio-controlled watches such as Citizen (built and tuned for the Citizen PMD series), Seiko, and Casio Japan domestic models. Does not emulate WWVB, DCF77, or MSF.
• Completely private: no ads, no accounts, no analytics, and zero data collection.
```

---

## 日本語 (`ja`)

| 項目 | 文字数 | 内容 |
|---|---|---|
| **アプリ名 (Name)** | 10 / 30 | `JJYシミュレーター` |
| **サブタイトル (Subtitle)** | 15 / 30 | `イヤホンで電波時計を現地時刻に` |
| **プロモーションテキスト** | 73 / 170 | `有線イヤホンからJJY(40/60kHz)標準電波を模擬して電波時計を時刻合わせ。内蔵オフライン世界地図で海外の現地時刻にもそのまま同期できます。` |
| **キーワード (Keywords)** | 76 / 100 | `JJY,電波時計,時刻合わせ,シチズン,PMD,セイコー,カシオ,標準電波,40kHz,60kHz,タイムゾーン,海外旅行,時差,同期,時計,オフライン` |
| **マーケティングURL** | — | `https://mj-best.github.io/JJY-simulator/ja/` |

### 概要 (Description · 1,212 / 4,000)
```text
有線イヤホンから日本の標準電波 JJY(40kHz / 60kHz)のタイムコードを模擬発信し、電波時計の時刻を合わせるアプリです。

JJY電波の届かない海外や、鉄筋コンクリートの室内など電波が入りにくい環境でも、手軽に電波時計を正確な時刻へ同期できます。

■ 主な機能
• 40kHz / 60kHz JJY標準電波シミュレート
  13.333kHz(40kHz局用)または20kHz(60kHz局用)の正弦波を、NICT JJYタイムコード規格に沿って高精度にON/OFFします。イヤホンケーブルから漏れる第3高調波(40kHz / 60kHz)を時計のアンテナが受信します。
• 海外の現地時刻にそのまま同期(サマータイム自動対応)
  JJY電波時計は受信した時刻を常に日本時間(JST)として表示します。地図や一覧から都市を選ぶと、その現地時刻をJSTの代わりに送信するため、時計側の設定を変えずに現地時刻に合わせられます。
• 完全オフライン内蔵世界地図
  世界地図データをアプリ内に内蔵しているため、機内モードや海外ローミングオフの状態でも地図をタップしてタイムゾーンを選択できます。
• 世界中のタイムゾーンを素早く検索
  地図上の主要62都市に加え、すべてのIANAタイムゾーンに対応。初期値は端末のタイムゾーンに設定されるため、海外に着いたら開いて送信開始を押すだけです。
• 60秒JJYタイムコードのリアルタイム表示
  送信中のキャリアランプ点滅と60秒分のパルス幅(0 / 1 / マーカー)をリアルタイムで確認できます。
• iPhone・iPad最適化
  iPhone向けの縦レイアウトとiPad向けの2カラムレイアウト、ライト/ダークモードに対応。送信中の画面スリープ防止や、イヤホン抜去時の自動停止にも対応しています。

■ 使い方
1. 有線イヤホン(USB-C / Lightning変換アダプタ含む)を接続し、音量を最大にします。
2. 時計をイヤホンケーブルのすぐ近く(数cm)に置きます。ケーブルを時計に数回巻くと受信しやすくなります。
3. 「送信開始」を押した後、時計を強制受信モードにします(操作方法は時計の取扱説明書をご確認ください)。受信には通常2〜10分かかります。
4. 受信できない場合は40kHzと60kHzを切り替えてお試しください。

■ ご注意・対応機種
• 大きな高音が出ますので、送信中は絶対にイヤホンを耳に入れないでください。
• Bluetoothイヤホンでは動作しません。必ず有線イヤホンをご使用ください。
• シチズン(PMDシリーズ基準)、セイコー、カシオなどJJY(40/60kHz)対応の国内電波時計向けです。WWVB・DCF77・MSF形式には対応していません。
• 広告・アカウント登録・個人情報の収集は一切ありません。
```

---

## App Review 심사 메모 (App Review Information → Notes)

> 심사관이 일본 전파시계 실물 없이도 앱 동작과 안전장치를 즉시 이해하고 통과시킬 수 있도록 App Store Connect의 **App Review Information → Notes**에 아래 내용을 그대로 붙여넣으세요. (`metadata/review_information/notes.txt`와 동일)

```text
App Review Notes for JJY Simulator:

1. Purpose & Audio Behavior:
This utility simulates Japan's NICT JJY radio time signal (40 kHz or 60 kHz) for setting Japanese radio-controlled watches (such as Citizen PMD, Seiko, and Casio) when outdoors reception is unavailable or while traveling abroad. Because mobile devices cannot directly output 40 kHz / 60 kHz, the app intentionally outputs a 13.333 kHz (or 20 kHz) sine wave modulated on/off in the 60-second JJY pulse-width pattern (0.8s / 0.5s / 0.2s). The third harmonic leaking from wired earphones is received by the watch's internal antenna placed next to the cable.

2. Ear Safety & Hardware Safeguards:
- A prominent red warning instructs users never to place earphones in their ears while transmitting and notes that Bluetooth earphones are unsupported.
- Transmission automatically stops if wired headphones are disconnected (AVAudioSession.routeChangeNotification .oldDeviceUnavailable) or if an audio interruption begins (e.g., incoming call).

3. How to Test Without a Radio-Controlled Watch:
- Launch the app (no sign-in or network connection required; the world map is bundled offline).
- Tap any region on the world map or open the Time Zone selector to verify local time, UTC offset, DST handling, and map centering.
- Toggle between 40kHz and 60kHz and tap Start to observe the live blinking carrier lamp, active 60-second JJY time-code pulse visualization, and audio output (please keep earphones out of ears when testing audio).
- Rotate or test on iPad to verify the adaptive two-column layout and Light/Dark Mode.
```
