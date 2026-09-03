import ComposableArchitecture
import Sharing
import Foundation

public extension SharedReaderKey where Self == AppStorageKey<Int>.Default {
    static var launchCount: Self {
        Self[.appStorage("contentLaunchCount"), default: 0]
    }
}

public extension SharedReaderKey where Self == AppStorageKey<Date>.Default {
    static var backgroundTimeStamp: Self {
        Self[.appStorage("backgroundTimeStamp"), default: .now]
    }
}

@Reducer
public struct AppGlobalStateStore {
    @Dependency(\.date.now) var now
    
    public enum Phase {
        case active
        case background
        case inactive
    }
    
    public init() {}
    
    @ObservableState
    public struct State: Equatable {
        @Shared(.launchCount) public var launchCount: Int
        @Shared(.backgroundTimeStamp) public var timeStamp: Date
        
        public init() {}
    }
    
    public enum Action {
        case updateState(Phase)
    }
    
    public var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .updateState(let phase):
                switch phase {
                case .active:
                    guard (now.timeIntervalSince1970 - state.timeStamp.timeIntervalSince1970) >= 3 else { break }
                    state.$launchCount.withLock { $0 += 1 }
                case .background:
                    state.$timeStamp.withLock { $0 = now }
                case .inactive:
                    break
                }
                
                return .none
            }
        }
    }
}
