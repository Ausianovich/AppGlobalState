import ComposableArchitecture
import Sharing

public struct AppGlobalStateFeature: Reducer {
    public init() {
    }

    public struct State: Equatable {
        @Shared(.appStorage("launchCount")) public var launchCount = 0
        var wasInBackground = false

        public init() {
        }
    }

    public enum Action {
        case appStarted
        case scenePhaseChanged(AppGlobalStateScenePhase)
    }

    public var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .appStarted:
                incrementLaunchCount(&state)
                return .none

            case let .scenePhaseChanged(scenePhase):
                switch scenePhase {
                case .active:
                    if state.wasInBackground {
                        state.wasInBackground = false
                        incrementLaunchCount(&state)
                    }

                case .background:
                    state.wasInBackground = true

                case .inactive:
                    return .none
                }
                return .none
            }
        }
    }

    private func incrementLaunchCount(_ state: inout State) {
        state.$launchCount.withLock {
            $0 += 1
        }
    }
}
