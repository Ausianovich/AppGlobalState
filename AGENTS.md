# AGENTS.md

Guidance for agents working in this package.

## Scope

This package provides app-wide lifecycle state for Swift apps using the Composable Architecture and Sharing. Keep changes focused on the requested behavior and avoid broad refactors unless they are necessary for the task.

The current public API centers on `AppGlobalStateStore`, `AppGlobalStateStore.State`, `AppGlobalStateStore.Action.updateState`, the `AppGlobalStateStore.Phase` enum, the Sharing keys `.launchCount` and `.backgroundTimeStamp`, and the SwiftUI modifier `launchCounterObserver()`.

## Project Layout

- `Package.swift`: Swift package manifest and product definitions.
- `Sources/AppGlobalState`: Core dependency, reducer, and scene-phase domain types.
- `Sources/AppGlobalStateUI`: SwiftUI integration for observing `ScenePhase`.
- `Tests/AppGlobalStateTests`: Unit tests using the Swift Testing framework and TCA `TestStore`.

## Coding Guidelines

- Use Swift 6 style and preserve 4-space indentation.
- Prefer SwiftUI, async/await, and TCA patterns already present in the package.
- Avoid force unwraps and avoid introducing Combine unless explicitly required.
- Keep public API additions small, documented by clear naming, and backed by tests when behavior changes.
- Preserve thread-safety around shared mutable test state.
- Keep documentation examples aligned with the real exported API. Do not reference older names such as `AppGlobalStateFeature`, `.appStarted`, or `observeAppGlobalState`.

## Integration Examples

Use these snippets as the canonical shape for documentation and sample code.

### SwiftUI Root Integration

Attach `launchCounterObserver()` near the root of the app so `ScenePhase` changes are observed automatically:

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

### Reading the Persisted Counter

Read the persisted launch count through Sharing:

```swift
import AppGlobalState
import Sharing
import SwiftUI

struct CounterView: View {
    @Shared(.launchCount) private var launchCount

    var body: some View {
        Text("Launch count: \(launchCount)")
    }
}
```

### Direct Reducer Integration

When a host app owns scene-phase forwarding, create a TCA store and send `updateState` actions:

```swift
import AppGlobalState
import ComposableArchitecture

let store = Store(initialState: AppGlobalStateStore.State()) {
    AppGlobalStateStore()
}

store.send(.updateState(.background))
store.send(.updateState(.active))
```

### Composing in a TCA App

Embed `AppGlobalStateStore.State` in a larger feature and scope the reducer:

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

### Test State Setup

Tests that mutate app storage or shared global state should be serialized and reset values explicitly:

```swift
import AppGlobalState
import Sharing
import Testing

@Suite(.serialized)
struct AppGlobalStateIntegrationTests {
    @Test
    func resetsLaunchCount() {
        @Shared(.launchCount) var launchCount = 0
        $launchCount.withLock { $0 = 0 }

        #expect(launchCount == 0)
    }
}
```

## Testing

- Add or update tests in `Tests/AppGlobalStateTests` for reducer, dependency, or persistence behavior changes.
- Prefer the Swift Testing framework (`@Suite`, `@Test`, `#expect`).
- Use `.serialized` for tests that touch shared app storage or global state.
- Validate compile-sensitive changes with Xcode diagnostics or a package build when practical.

## Dependencies

The package depends on Point-Free libraries including Composable Architecture, Dependencies, and Sharing. Prefer existing APIs from these dependencies over new local abstractions.
