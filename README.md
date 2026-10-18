# JJY Simulator

https://mj-best.github.io/JJY-simulator/

스마트폰/PC 유선 이어폰으로 JJY 표준전파를 흉내 내 전파시계(시티즌 PMD 기준)를 맞추는 웹페이지.

- 13.333kHz(또는 20kHz) 사인파를 JJY 타임코드로 ON/OFF. 이어폰 케이블에서 새는 3배음(40kHz/60kHz)을 시계가 수신.
- **시간대 강제**: 시계는 JJY를 무조건 JST로 해석하므로, 선택한 시간대의 현지 시각을 JST 자리에 넣어 보낸다. 미국에서 열면 기기 시간대가 기본값이라 그냥 시작만 누르면 됨.

사용법은 페이지에 있음. 이어폰을 귀에 꽂지 말 것.

테스트: `node test.mjs`
