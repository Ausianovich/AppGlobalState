import Dependencies
import Sharing

public struct AppGlobalState: Sendable {
    public var launchCount: @Sendable () -> Int

    public init(launchCount: @escaping @Sendable () -> Int) {
        self.launchCount = launchCount
    }
}

extension AppGlobalState: DependencyKey {
    public static var liveValue: AppGlobalState {
        AppGlobalState(
            launchCount: {
                @Shared(.appStorage("launchCount")) var launchCount = 0
                return launchCount
            }
        )
    }

    public static var testValue: AppGlobalState {
        AppGlobalState(
            launchCount: unimplemented("\(Self.self).launchCount", placeholder: 0)
        )
    }
}

extension DependencyValues {
    public var appGlobalState: AppGlobalState {
        get { self[AppGlobalState.self] }
        set { self[AppGlobalState.self] = newValue }
    }
}
