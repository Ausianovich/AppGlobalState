@testable import AppGlobalState
import ComposableArchitecture
import ConcurrencyExtras
import Dependencies
import Foundation
import Sharing
import Testing

@Suite(.serialized)
struct AppGlobalStateStoreTests {
    @Test
    @MainActor
    func backgroundStoresCurrentTime() async {
        prepareAppStorage(timeStamp: Date(timeIntervalSince1970: 900))

        let now = Date(timeIntervalSince1970: 1_000)
        let store = TestStore(initialState: AppGlobalStateStore.State()) {
            AppGlobalStateStore()
        } withDependencies: {
            $0.date.now = now
        }

        await store.send(.updateState(.background)) {
            $0.$timeStamp.withLock { $0 = now }
            $0.isReturningFromBackground = true
        }
    }

    @Test
    @MainActor
    func activeIncrementsLaunchCountWhenAtLeastThreeSecondsPassedSinceBackground() async {
        let now = LockIsolated(Date(timeIntervalSince1970: 1_000))
        prepareAppStorage(
            launchCount: 2,
            timeStamp: Date(timeIntervalSince1970: 900)
        )

        let store = TestStore(initialState: AppGlobalStateStore.State()) {
            AppGlobalStateStore()
        } withDependencies: {
            $0.date = DateGenerator { now.value }
        }

        await store.send(.updateState(.active)) {
            $0.$launchCount.withLock { $0 = 3 }
            $0.hasActivated = true
        }
        await store.send(.updateState(.background)) {
            $0.$timeStamp.withLock {
                $0 = Date(timeIntervalSince1970: 1_000)
            }
            $0.isReturningFromBackground = true
        }

        now.setValue(Date(timeIntervalSince1970: 1_003))

        await store.send(.updateState(.active)) {
            $0.$launchCount.withLock { $0 = 4 }
            $0.isReturningFromBackground = false
        }
    }

    @Test
    @MainActor
    func activeDoesNotIncrementLaunchCountBeforeThreeSecondsPassedSinceBackground() async {
        let now = LockIsolated(Date(timeIntervalSince1970: 1_000))
        prepareAppStorage(
            launchCount: 2,
            timeStamp: Date(timeIntervalSince1970: 900)
        )

        let store = TestStore(initialState: AppGlobalStateStore.State()) {
            AppGlobalStateStore()
        } withDependencies: {
            $0.date = DateGenerator { now.value }
        }

        await store.send(.updateState(.active)) {
            $0.$launchCount.withLock { $0 = 3 }
            $0.hasActivated = true
        }
        await store.send(.updateState(.background)) {
            $0.$timeStamp.withLock {
                $0 = Date(timeIntervalSince1970: 1_000)
            }
            $0.isReturningFromBackground = true
        }

        now.setValue(Date(timeIntervalSince1970: 1_002.999))

        await store.send(.updateState(.active)) {
            $0.isReturningFromBackground = false
        }
    }

    @Test
    @MainActor
    func inactiveDoesNotChangeState() async {
        let backgroundTime = Date(timeIntervalSince1970: 1_000)
        prepareAppStorage(launchCount: 2, timeStamp: backgroundTime)

        let store = TestStore(initialState: AppGlobalStateStore.State()) {
            AppGlobalStateStore()
        } withDependencies: {
            $0.date.now = Date(timeIntervalSince1970: 2_000)
        }

        await store.send(.updateState(.inactive))
    }

    @Test
    @MainActor
    func firstActiveIncrementsLaunchCountOnColdStart() async {
        let now = Date(timeIntervalSince1970: 1_000)
        prepareAppStorage(launchCount: 2, timeStamp: now)

        let store = TestStore(initialState: AppGlobalStateStore.State()) {
            AppGlobalStateStore()
        } withDependencies: {
            $0.date.now = now
        }

        await store.send(.updateState(.active)) {
            $0.$launchCount.withLock { $0 = 3 }
            $0.hasActivated = true
        }
    }

    @Test
    @MainActor
    func repeatedActiveAfterInactiveDoesNotIncrementLaunchCountAgain() async {
        prepareAppStorage(
            launchCount: 0,
            timeStamp: Date(timeIntervalSince1970: 1_000)
        )

        let store = TestStore(initialState: AppGlobalStateStore.State()) {
            AppGlobalStateStore()
        } withDependencies: {
            $0.date.now = Date(timeIntervalSince1970: 2_000)
        }

        await store.send(.updateState(.active)) {
            $0.$launchCount.withLock { $0 = 1 }
            $0.hasActivated = true
        }
        await store.send(.updateState(.inactive))
        await store.send(.updateState(.active))
    }
}

private func prepareAppStorage(
    launchCount: Int = 0,
    timeStamp: Date = Date(timeIntervalSince1970: 0)
) {
    @Shared(.launchCount) var sharedLaunchCount = launchCount
    @Shared(.backgroundTimeStamp) var sharedTimeStamp = timeStamp

    $sharedLaunchCount.withLock { $0 = launchCount }
    $sharedTimeStamp.withLock { $0 = timeStamp }
}
