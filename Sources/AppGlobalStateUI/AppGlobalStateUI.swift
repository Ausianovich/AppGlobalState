import AppGlobalState
import ComposableArchitecture
import SwiftUI



extension AppGlobalStateStore.Phase {
    init(_ scenePhase: ScenePhase) {
        switch scenePhase {
            case .active:
            self = .active
        case .background:
            self = .background
        case .inactive:
            self = .inactive
        @unknown default:
            fatalError()
        }
    }
}

public extension View {
    public func launchCounterObserver() -> some View {
        modifier(AppGlobalStateViewModifier())
    }
}

struct AppGlobalStateViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        AppGlobalStateContainer(store: Store(initialState: AppGlobalStateStore.State(), reducer: { AppGlobalStateStore() })) {
            content
        }
    }
}


struct AppGlobalStateContainer<Content: View>: View {
    @Environment(\.scenePhase) var scenePhase
    let store: StoreOf<AppGlobalStateStore>
    let content: Content
    
    init(store: StoreOf<AppGlobalStateStore>, @ViewBuilder content: () -> Content) {
        self.store = store
        self.content = content()
    }
    
    var body: some View {
        content
            .onChange(of: scenePhase) { oldValue, newValue in
                store.send(.updateState(AppGlobalStateStore.Phase(newValue)))
            }
    }
}
