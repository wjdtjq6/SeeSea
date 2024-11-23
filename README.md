# 🌊 SeeSea (씨씨)
> ### 서퍼를 위한 실시간 파도 예보 & 웹캠 앱

<a href="https://apps.apple.com/kr/app/seesea/id6711330853" target="_blank">
  <img width="130" alt="appstore" src="https://user-images.githubusercontent.com/55099365/196023806-5eb7be0f-c7cf-4661-bb39-35a15146c33a.png">
</a>

<br />

## 📱 프로젝트 소개
> **개발 기간** : 2024. 9. 13 (금) ~ 2024. 10. 3 (목)<br />
> **개발 인원** : 1인 (기획/디자인/개발)

<br />

<div align="center">
  <img width="16%" src="https://github.com/user-attachments/assets/4981e5de-f8c4-4318-9644-d07a70180cf1" />
  <img width="16%" src="https://github.com/user-attachments/assets/9bb63bc3-00b8-4fae-9b24-3ce3162e72be" />
  <img width="16%" src="https://github.com/user-attachments/assets/822f0431-3540-4f41-b579-cf417757df0f" />
  <img width="16%" src="https://github.com/user-attachments/assets/db414272-b1f4-4f31-8445-8d82facce2a7" />
  <img width="16%" src="https://github.com/user-attachments/assets/662acaca-322e-4975-901a-a5fc260e1b08" />
  <img width="16%" src="https://github.com/user-attachments/assets/8f213ccc-f4f8-41f5-92ba-23a9a1918b4b" />
</div>

<br /><br />

## 🛠 기술 스택
### iOS
- **Language**: Swift 5.10
- **Framework**: SwiftUI
- **Minimum Target**: iOS 17.0

### 아키텍처 & 디자인 패턴
- **Architecture**: MVVM
- **Design Pattern**: Repository Pattern

### 데이터베이스 & 네트워킹
- **Local Database**: Realm
- **Network**: URLSession

### 외부 라이브러리
- **Media**: YouTubePlayerKit

### 개발 환경
- **IDE**: Xcode 15.3

<br />

## 📋 주요 기능
### Open API 기반 실시간 파도 예보 시스템 구현
-  기상청 API와 URLSession을 활용한 비동기 네트워크 통신으로 실시간 해양 데이터 fetching
-  APIEndPoint enum과 Result type을 활용한 type-safe 네트워킹 레이어 구현
-  Published 프로퍼티와 ObservableObject를 활용한 실시간 데이터 바인딩 및 UI 업데이트

### 멀티 포맷 웹캠 스트리밍 지원
- WKWebView와 YouTubePlayerKit을 활용한 이미지/비디오/유튜브 스트리밍 구현
- URL 패턴 매칭을 통한 자동 포맷 감지 및 적절한 뷰 컴포넌트 전환
- 주기적 데이터 리프레시와 애니메이션 처리로 끊김없는 실시간 영상 제공

### MapKit 기반 위치 트래킹 서비스
- CoreLocation과 MapKit 프레임워크를 활용한 실시간 위치 트래킹
- MKCoordinateRegion과 MapCameraPosition을 활용한 지도 뷰 컨트롤
- MapAnnotation을 활용한 커스텀 마커 및 실시간 파고 정보 구현

### Realm 기반 로컬 데이터 관리 시스템
- Repository Pattern을 활용한 데이터 접근 계층 추상화
- Protocol 기반 의존성 주입으로 테스트 용이성 확보
- Realm DB를 활용한 즐겨찾기 및 다이어리 데이터의 CRUD 작업 구현

<br />


## 🔧 시행착오
### 1. 멀티 엔드포인트 데이터 동기화 최적화
#### 문제
- 파고/수온/예보 데이터를 각각 별도 API로 호출하여 발생하는 **성능 이슈**로 인해 비동기 데이터의 상태 관리와 UI 업데이트 시 Race Condition 발생

#### 해결
```swift
// Swift Concurrency의 TaskGroup을 활용한 동시성 제어
func fetchBeachData() async throws -> BeachData {
    try await withThrowingTaskGroup(of: APIResponse.self) { group in
        group.addTask { await fetchWaveHeight() }
        group.addTask { await fetchWaterTemperature() }
        group.addTask { await fetchForecast() }
        
        return try await group.reduce(into: BeachData()) { result, response in
            result.update(with: response)
        }
    }
}
```
    
### 2. WKWebView 메모리 누수 및 성능 최적화
#### 문제
- 다수의 웹캠 스트림 동시 로드 시 메모리 사용량 급증
- WKWebView 재사용 시 발생하는 리소스 누수
#### 해결
```swift
final class WebViewManager {
    private var webViewPool: [String: WeakWebView] = [:]
    
    func dequeueWebView(for url: URL) -> WKWebView {
        cleanUnusedViews()
        if let weakView = webViewPool[url.absoluteString],
           let view = weakView.view {
            return view
        }
        let view = configureNewWebView()
        webViewPool[url.absoluteString] = WeakWebView(view: view)
        return view
    }
    
    private func configureNewWebView() -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        return WKWebView(frame: .zero, configuration: config)
    }
```

### 3. Realm 데이터 동기화
#### 문제
- Realm 객체 업데이트 시 SwiftUI View 갱신 누락
- 백그라운드 스레드에서 UI 업데이트 시도로 인한 크래시
#### 해결
```swift
class BeachViewModel: ObservableObject {
    private var notificationTokens: [NotificationToken] = []
    
    func observeRealmChanges() {
        let token = realm.objects(Beach.self).observe { [weak self] changes in
            DispatchQueue.main.async {
                self?.objectWillChange.send()
            }
        }
        notificationTokens.append(token)
    }
}

```
<br />

## 📝 회고
### 잘한 점
#### 1. 모듈화된 아키텍처 설계
```swift
protocol DataBase {
    func read<T: Object>(_ object: T.Type) -> Results<T>
    func write<T: Object>(_ object: T)
    func delete<T: Object>(_ object: T)
}

protocol NetworkService {
    func fetch<T: Decodable>(endpoint: APIEndPoint) async throws -> T
}
```
- Protocol을 활용해 모듈 간 결합도 최소화
- Repository Pattern을 통한 데이터 접근 계층 일원화

### 아쉬운 점
#### 1. 테스트 코드 부재
```swift
// 테스트를 고려한 의존성 주입 필요
class BeachViewModel {
    private let networkService: NetworkService
    private let database: DataBase
    
    init(
        networkService: NetworkService = LiveNetworkService(),
        database: DataBase = RealmDatabase()
    ) {
        self.networkService = networkService
        self.database = database
    }
}
```
- Unit Test 및 UI Test 코드 미구현
- Mock 객체를 활용한 테스트 시나리오 부재

#### 2. 에러 처리 체계 미흡
```swift
// 체계적인 에러 타입 정의 필요
enum AppError: Error {
    case network(NetworkError)
    case database(DatabaseError)
    case validation(ValidationError)
    
    var localizedDescription: String {
        // 사용자 친화적인 에러 메시지
    }
}
```
- // 체계적인 에러 타입 정의 필요
- 통합된 에러 처리 시스템 부재

### 시도할 점
#### 1. CI/CD 파이프라인 구축
#### 2.성능 모니터링 시스템 도입
#### 3. 코드 품질 관리 도입
