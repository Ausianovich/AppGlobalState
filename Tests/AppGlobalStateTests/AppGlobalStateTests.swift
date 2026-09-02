import ComposableArchitecture
import Dependencies
import Foundation
import Sharing
import Testing

@testable import AppGlobalState

private final class LaunchCountBox: @unchecked Sendable {
    private let lock = NSLock()
    private var launchCount: Int

    init(_ launchCount: Int) {
        self.launchCount = launchCount
    }

    var value: Int {
        get {
            lock.lock()
            defer { lock.unlock() }
            return launchCount
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            launchCount = newValue
        }
    }
}

@Suite(.serialized)
struct AppGlobalStateTests {
    @Test
    func launchCountReturnsCurrentValueFromClosure() {
        let launchCount = LaunchCountBox(0)
        let appGlobalState = AppGlobalState(
            launchCount: {
                launchCount.value
            }
        )

        #expect(appGlobalState.launchCount() == 0)

        launchCount.value = 2

        #expect(appGlobalState.launchCount() == 2)
    }

    @Test
    func dependencyValuesStoresAppGlobalState() {
        var dependencies = DependencyValues()
        dependencies.appGlobalState = AppGlobalState(
            launchCount: {
                42
            }
        )

        #expect(dependencies.appGlobalState.launchCount() == 42)
    }

    @Test
    func liveValueReadsLaunchCountFromAppStorage() {
        @Shared(.appStorage("launchCount")) var launchCount = 0

        let appGlobalState = AppGlobalState.liveValue

        #expect(appGlobalState.launchCount() == 0)

        $launchCount.withLock {
            $0 = 7
        }

        #expect(appGlobalState.launchCount() == 7)
    }
}

@MainActor
@Suite(.serialized)
struct AppGlobalStateFeatureTests {
    @Test
    func appStartedIncrementsLaunchCount() async {
        let store = TestStore(initialState: AppGlobalStateFeature.State()) {
            AppGlobalStateFeature()
        }

        await store.send(.appStarted) {
            $0.$launchCount.withLock {
                $0 = 1
            }
        }

        #expect(store.state.launchCount == 1)
    }

    @Test
    func activeWithoutBackgroundDoesNotIncrementLaunchCount() async {
        let store = TestStore(initialState: AppGlobalStateFeature.State()) {
            AppGlobalStateFeature()
        }

        await store.send(.scenePhaseChanged(.active))

        #expect(store.state.launchCount == 0)
    }

    @Test
    func backgroundThenActiveIncrementsLaunchCount() async {
        let store = TestStore(initialState: AppGlobalStateFeature.State()) {
            AppGlobalStateFeature()
        }

        await store.send(.scenePhaseChanged(.background)) {
            $0.wasInBackground = true
        }
        await store.send(.scenePhaseChanged(.active)) {
            $0.$launchCount.withLock {
                $0 = 1
            }
            $0.wasInBackground = false
        }

        #expect(store.state.launchCount == 1)
    }

    @Test
    func inactiveDoesNotIncrementLaunchCount() async {
        let store = TestStore(initialState: AppGlobalStateFeature.State()) {
            AppGlobalStateFeature()
        }

        await store.send(.scenePhaseChanged(.inactive))

        #expect(store.state.launchCount == 0)
    }
}
