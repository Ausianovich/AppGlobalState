import AppGlobalState
import ComposableArchitecture
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
        }
    }

    @Test
    @MainActor
    func activeIncrementsLaunchCountWhenAtLeastThreeSecondsPassedSinceBackground() async {
        let backgroundTime = Date(timeIntervalSince1970: 1_000)
        prepareAppStorage(launchCount: 2, timeStamp: backgroundTime)

        let store = TestStore(initialState: AppGlobalStateStore.State()) {
            AppGlobalStateStore()
        } withDependencies: {
            $0.date.now = Date(timeIntervalSince1970: 1_003)
        }

        await store.send(.updateState(.active)) {
            $0.$launchCount.withLock { $0 = 3 }
        }
    }

    @Test
    @MainActor
    func activeDoesNotIncrementLaunchCountBeforeThreeSecondsPassedSinceBackground() async {
        let backgroundTime = Date(timeIntervalSince1970: 1_000)
        prepareAppStorage(launchCount: 2, timeStamp: backgroundTime)

        let store = TestStore(initialState: AppGlobalStateStore.State()) {
            AppGlobalStateStore()
        } withDependencies: {
            $0.date.now = Date(timeIntervalSince1970: 1_002.999)
        }

        await store.send(.updateState(.active))
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
