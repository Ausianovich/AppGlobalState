import AppGlobalState
import ComposableArchitecture
import SwiftUI

public extension View {
    func launchCounterObserver() -> some View {
        modifier(AppGlobalStateViewModifier())
    }
}

private struct AppGlobalStateViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        AppGlobalStateContainer(store: Store(initialState: AppGlobalStateStore.State(), reducer: { AppGlobalStateStore() }),
                                content: { content })
    }
}

private struct AppGlobalStateContainer<Content: View>: View {
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

