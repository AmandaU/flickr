//
//  LaunchStateManager.swift
//  flickr
//
//  Created by Amanda Baret on 2022/11/24.
//

import Foundation

enum LaunchScreenStep {
    case firstStep
    case secondStep
    case finished
}

final class LaunchScreenStateManager: ObservableObject {
    @MainActor
    @Published private(set) var state: LaunchScreenStep = .firstStep
    
    @MainActor
    func dismiss() {
        Task {
            state = .secondStep
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            self.state = .finished
        }
    }
}
