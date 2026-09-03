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
        AppGlobalStateContainer {
            content
        }
    }
}

private struct AppGlobalStateContainer<Content: View>: View {
    @Environment(\.scenePhase) var scenePhase
    @State private var store = Store(initialState: AppGlobalStateStore.State()) {
        AppGlobalStateStore()
    }
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .onChange(of: scenePhase) { oldValue, newValue in
                store.send(.updateState(AppGlobalStateStore.Phase(newValue)))
            }
    }
}

