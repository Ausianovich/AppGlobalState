# AppGlobalState

AppGlobalState is a small Swift package for tracking app-wide lifecycle state with the Composable Architecture and Sharing.

The package currently focuses on a persisted launch counter. It stores the last background timestamp and increments the counter when the app returns to the active scene phase after spending at least 3 seconds in the background.

## Products

- `AppGlobalState`: Core reducer, state, shared keys, and scene-phase model.
- `AppGlobalStateUI`: SwiftUI integration for observing `ScenePhase` and forwarding changes to `AppGlobalStateStore`.

## Requirements

- Swift 6.3 or later
- iOS 26 or later
- macOS 26 or later

## Installation

Add the package dependency to your app or package:

```swift
.package(url: "https://github.com/Ausianovich/AppGlobalState.git", from: "1.0.0")
```

Then add the products you need to your target. Use `AppGlobalStateUI` when the target contains SwiftUI views that should observe `ScenePhase`:

```swift
.target(
    name: "MyApp",
    dependencies: [
        .product(name: "AppGlobalState", package: "AppGlobalState"),
        .product(name: "AppGlobalStateUI", package: "AppGlobalState"),
    ]
)
```

## Usage

### Observe Scene Phase in a SwiftUI App

The simplest integration is to attach `launchCounterObserver()` near the root of your SwiftUI hierarchy. The modifier creates an internal `StoreOf<AppGlobalStateStore>` and sends scene-phase updates automatically.

```swift
import AppGlobalStateUI
import SwiftUI

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .launchCounterObserver()
        }
    }
}
```

You can also attach the modifier inside your root view:

```swift
import AppGlobalStateUI
import SwiftUI

struct RootView: View {
    var body: some View {
        NavigationStack {
            HomeView()
        }
        .launchCounterObserver()
    }
}
```

### Read the Launch Count in SwiftUI

The launch counter is stored with Sharing under the `.launchCount` shared key. Use `@Shared` when a view needs to display the persisted value.

```swift
import AppGlobalState
import Sharing
import SwiftUI

struct HomeView: View {
    @Shared(.launchCount) private var launchCount

    var body: some View {
        Text("Launch count: \(launchCount)")
    }
}
```

### Use the Reducer Directly

If you already have a Composable Architecture root store and want to own scene-phase forwarding yourself, create an `AppGlobalStateStore` and send `updateState` actions.

```swift
import AppGlobalState
import ComposableArchitecture

let store = Store(initialState: AppGlobalStateStore.State()) {
    AppGlobalStateStore()
}

store.send(.updateState(.background))
store.send(.updateState(.active))
```

In SwiftUI, map `ScenePhase` changes to the reducer action:

```swift
import AppGlobalState
import ComposableArchitecture
import SwiftUI

struct RootView: View {
    @Environment(\.scenePhase) private var scenePhase
    let store: StoreOf<AppGlobalStateStore>

    var body: some View {
        ContentView()
            .onChange(of: scenePhase) { _, newValue in
                switch newValue {
                case .active:
                    store.send(.updateState(.active))
                case .background:
                    store.send(.updateState(.background))
                case .inactive:
                    store.send(.updateState(.inactive))
                @unknown default:
                    break
                }
            }
    }
}
```

### Compose with a Larger TCA App

Embed `AppGlobalStateStore.State` in your app state when other features need to read or test the lifecycle state alongside their own state.

```swift
import AppGlobalState
import ComposableArchitecture

@Reducer
struct AppFeature {
    @ObservableState
    struct State: Equatable {
        var globalState = AppGlobalStateStore.State()
    }

    enum Action {
        case globalState(AppGlobalStateStore.Action)
    }

    var body: some Reducer<State, Action> {
        Scope(state: \.globalState, action: \.globalState) {
            AppGlobalStateStore()
        }
    }
}
```

Forward scene-phase changes from your root view:

```swift
import AppGlobalState
import ComposableArchitecture
import SwiftUI

struct AppView: View {
    @Environment(\.scenePhase) private var scenePhase
    let store: StoreOf<AppFeature>

    var body: some View {
        ContentView()
            .onChange(of: scenePhase) { _, newValue in
                let phase: AppGlobalStateStore.Phase

                switch newValue {
                case .active:
                    phase = .active
                case .background:
                    phase = .background
                case .inactive:
                    phase = .inactive
                @unknown default:
                    return
                }

                store.send(.globalState(.updateState(phase)))
            }
    }
}
```

### Reset Values During Tests

The values are persisted through app storage, so tests that touch them should reset shared state and run serially.

```swift
import AppGlobalState
import Sharing
import Testing

@Suite(.serialized)
struct MyFeatureTests {
    @Test
    func startsFromKnownLaunchCount() {
        @Shared(.launchCount) var launchCount = 0
        $launchCount.withLock { $0 = 0 }

        #expect(launchCount == 0)
    }
}
```

## Development

Run tests from the package root:

```sh
swift test
```

Use Xcode or Swift Package Manager to build the package. Keep platform and Swift language versions aligned with `Package.swift`.
