# AppGlobalState

AppGlobalState is a small Swift package for tracking app-wide lifecycle state with the Composable Architecture and Sharing.

The package currently focuses on a persisted launch count. It increments when the app starts and when the app returns to the active scene phase after being in the background.

## Products

- `AppGlobalState`: Core state, dependency, reducer, and scene-phase model.
- `AppGlobalStateUI`: SwiftUI integration for observing `ScenePhase` and forwarding changes to `AppGlobalStateFeature`.

## Requirements

- Swift 6.3 or later
- iOS 26 or later
- macOS 26 or later

## Installation

Add this package as a dependency in `Package.swift`:

```swift
.package(url: "<repository-url>", from: "0.1.0")
```

Then add the products you need to your target:

```swift
.product(name: "AppGlobalState", package: "AppGlobalState")
.product(name: "AppGlobalStateUI", package: "AppGlobalState")
```

## Usage

Create a store with `AppGlobalStateFeature` and send `.appStarted` during startup:

```swift
import AppGlobalState
import ComposableArchitecture

let store = Store(initialState: AppGlobalStateFeature.State()) {
    AppGlobalStateFeature()
}

store.send(.appStarted)
```

In SwiftUI, import `AppGlobalStateUI` and attach the observer modifier so scene phase changes are forwarded to the store:

```swift
import AppGlobalState
import AppGlobalStateUI
import ComposableArchitecture
import SwiftUI

struct RootView: View {
    let store: StoreOf<AppGlobalStateFeature>

    var body: some View {
        ContentView()
            .observeAppGlobalState(store)
    }
}
```

Read the launch count through the dependency when needed:

```swift
@Dependency(\.appGlobalState) var appGlobalState
let launchCount = appGlobalState.launchCount()
```

## Development

Run tests from the package root:

```sh
swift test
```

Use Xcode or Swift Package Manager to build the package. Keep platform and Swift language versions aligned with `Package.swift`.
