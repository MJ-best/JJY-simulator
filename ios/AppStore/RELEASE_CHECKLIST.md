# iOS / iPadOS 빌드 및 App Store 배포 체크리스트

## 1. 사전 준비 (최초 1회)
1. **GitHub Pages 배포**: 저장소 루트의 `privacy.html`을 `main` 브랜치에 push하면 아래 개인정보 처리방침 URL이 자동으로 활성화됩니다.
   - `https://mj-best.github.io/JJY-simulator/privacy.html`
2. **Apple Developer Program 등록 확인** (연간 멤버십 활성 상태).
3. **Bundle Identifier 등록** ([developer.apple.com/account/resources/identifiers](https://developer.apple.com/account/resources/identifiers)):
   - 기본값: `com.mjbest.jjysimulator` (이미 사용 중이면 Xcode에서 원하는 고유 ID로 변경)
   - 별도 Capability(Push, iCloud 등)는 필요 없습니다.
4. **App Store Connect 앱 생성** ([appstoreconnect.apple.com](https://appstoreconnect.apple.com)):
   - Platform: `iOS` (iPhone & iPad 유니버설)
   - Primary Language: `Korean` (또는 `English (U.S.)`)
   - Bundle ID: 위에서 등록한 ID 선택
   - SKU: 예) `jjy-simulator-ios`

## 2. 로컬 빌드 및 테스트 (macOS + Xcode 15 이상)
### 방법 A — Xcode GUI (가장 간편)
1. `ios/JJYSimulator.xcodeproj` 열기
2. `JJYSimulator` 타깃 → **Signing & Capabilities** → **Team**에 본인 Apple Developer 팀 선택 (필요 시 Bundle Identifier 수정)
3. 단위 테스트 실행: **⌘U** (`JJYCodeTests` 전체 통과 확인)
4. 실기기(iPhone/iPad)에 유선 이어폰(USB-C / Lightning 어댑터) 연결 후 **⌘R**로 실제 송신·시계 수신 확인
5. 상단 기기 대상을 **Any iOS Device (arm64)** 로 선택 → 메뉴 **Product → Archive**
6. **Xcode Organizer** 창에서 **Distribute App → App Store Connect → Upload** 클릭

### 방법 B — CLI 자동화 스크립트 (`ios/scripts/archive.sh`)
```bash
cd ios

# 테스트 + Release Archive + IPA Export
DEVELOPMENT_TEAM=YOUR_10CHAR_TEAM_ID ./scripts/archive.sh

# App Store Connect로 바로 업로드까지 실행
DEVELOPMENT_TEAM=YOUR_10CHAR_TEAM_ID \
BUNDLE_ID=com.mjbest.jjysimulator \
MARKETING_VERSION=1.0 \
BUILD_NUMBER=1 \
./scripts/archive.sh --upload
```

## 3. App Store Connect 정보 입력
1. **App Information**
   - Category: Primary `Utilities` / Secondary `Travel`
   - Content Rights: 제3자 콘텐츠 미포함 (`No`)
   - Age Rating: 모든 항목 `None` → **`4+`**
2. **Pricing and Availability**
   - 가격: `Free ($0)` / 배포 국가: 전체 지역
3. **App Privacy**
   - Privacy Policy URL: `https://mj-best.github.io/JJY-simulator/privacy.html`
   - Data Collection: **"No, we do not collect data from this app"** (`PrivacyInfo.xcprivacy` 포함 완료)
4. **버전 1.0 메타데이터 입력** (`APP_STORE_METADATA.md` 참고)
   - 한국어 (`ko`), 영어 (`en-US`), 일본어 (`ja`) 로컬라이제이션 추가
   - 이름, 부제, 프로모션 텍스트, 설명, 키워드, 지원 URL, 마케팅 URL 입력
5. **스크린샷 업로드** (`ios/AppStore/screenshots/{ko,en-US,ja}/`)
   - **iPhone 6.9" Display** (`1320 × 2868 px`): `iphone-6.9-01-*.png` ~ `04-*.png` 업로드 (하위 iPhone 크기는 App Store Connect가 자동 스케일링)
   - **iPad 13" Display** (`2752 × 2064 px`): `ipad-13-01-*.png` ~ `03-*.png` 업로드 (하위 iPad 크기는 자동 스케일링)
   - *(선택)* 실제 Xcode 시뮬레이터 화면을 직접 쓰고 싶다면 `iPhone 16 Pro Max` 및 `iPad Pro 13-inch (M4)` 시뮬레이터에서 **⌘S**로 캡처해 교체할 수 있습니다.
6. **빌드 선택 및 심사 제출**
   - TestFlight에서 업로드된 빌드 처리 완료 확인 → 실기기 설치 테스트
   - **App Review Information**에 연락처 입력 + Sign-in required 체크 해제 + `metadata/review_information/notes.txt` 내용 붙여넣기
   - **Add for Review → Submit to App Review** 클릭!

## 4. 자동 CI (GitHub Actions)
- `.github/workflows/ios-ci.yml`이 포함되어 있어 `ios/` 변경을 GitHub에 push할 때마다 macOS 러너에서 Xcode 빌드와 `JJYSimulatorTests`가 자동으로 실행됩니다.
