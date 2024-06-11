//
//  OnboardingView.swift
//  GameGuessr
//
//  Created by BAHATTIN KOC on 8.06.2024.
//

import SwiftUI

struct OnboardingView: View {
    @ObservedObject private var gameCenterManager = GameCenterManager.shared
    private let image = Image("onboarding")
    private let texts = [LocalizationContants.OnboardingView.onboarding1,
                         LocalizationContants.OnboardingView.onboarding2,
                         LocalizationContants.OnboardingView.onboarding3]

    @State private var currentPage = 0
    @State private var progressBarHeight: CGFloat = 8
    @State private var isNavigationActive: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                TabView(selection: $currentPage) {
                    ForEach(0..<3) { index in
                        OnboardingPage(image: image,
                                       text: texts[index],
                                       pageIndex: index,
                                       totalPages: 3)
                        .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .indexViewStyle(.page(backgroundDisplayMode: .never))

                VStack {
                    Spacer()

                    ProgressBar(value: $currentPage, isNavigationActive: $isNavigationActive, total: texts.count)
                        .frame(height: progressBarHeight)
                        .padding([.top, .leading, .trailing])
                        .onChange(of: currentPage) { oldValue, newValue in
                            withAnimation {
                                DispatchQueue.main.asyncAfter(deadline: .now() + (oldValue > newValue ? 0.0 : 1.0)) {
                                    progressBarHeight = currentPage == texts.count - 1 ? 50.0 : 8.0
                                }
                            }
                        }
                        .animation(.smooth, value: progressBarHeight)
                        .padding([.top, .bottom])
                }
            }
            .navigationDestination(isPresented: $isNavigationActive) {
                DraggableRectangleView()
                    .navigationBarBackButtonHidden()
                    .onAppear {
                        gameCenterManager.authenticateLocalPlayer()
                    }
            }
        }
    }
}

#Preview {
    OnboardingView()
}
