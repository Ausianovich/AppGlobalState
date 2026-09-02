import AppGlobalState
import ComposableArchitecture
import SwiftUI

private struct AppGlobalStateObserverModifier: ViewModifier {
    @Environment(\.scenePhase) private var scenePhase

    let store: StoreOf<AppGlobalStateFeature>

    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { oldValue, newValue in
                store.send(.scenePhaseChanged(AppGlobalStateScenePhase(newValue)))
                _ = oldValue
            }
    }
}

extension View {
    public func observeAppGlobalState(_ store: StoreOf<AppGlobalStateFeature>) -> some View {
        modifier(AppGlobalStateObserverModifier(store: store))
    }
}

private extension AppGlobalStateScenePhase {
    init(_ scenePhase: ScenePhase) {
        switch scenePhase {
        case .active:
            self = .active

        case .background:
            self = .background

        case .inactive:
            self = .inactive

        @unknown default:
            self = .inactive
        }
    }
}
