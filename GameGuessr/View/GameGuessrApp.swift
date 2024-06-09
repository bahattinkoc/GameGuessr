//
//  GameGuessrApp.swift
//  GameGuessr
//
//  Created by BAHATTIN KOC on 2.06.2024.
//

import SwiftUI

@main
struct GameGuessrApp: App {
    var body: some Scene {
        WindowGroup {
            if (CacheManager.shared.getData(forKey: .willShowOnboarding) as? Bool) ?? true {
                OnboardingView()
            } else {
                DraggableRectangleView()
            }
        }
    }
}
