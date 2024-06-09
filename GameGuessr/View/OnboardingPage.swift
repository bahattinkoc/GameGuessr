//
//  OnboardingPage.swift
//  GameGuessr
//
//  Created by BAHATTIN KOC on 9.06.2024.
//

import SwiftUI

struct OnboardingPage: View {
    let image: Image
    let text: String
    let pageIndex: Int
    let totalPages: Int

    var body: some View {
        GeometryReader { geometry in
            VStack {
                image
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width * CGFloat(totalPages), height: geometry.size.height * 0.6)
                    .offset(x: -CGFloat(pageIndex - 1) * geometry.size.width)
                    .clipped()

                Spacer()

                Text(text)
                    .bold()
                    .padding()
                    .font(.title)
                    .transition(.opacity)
                    .multilineTextAlignment(.center)
                    .id("onboarding" + text)

                Spacer()
                Spacer()
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
}

#Preview {
    OnboardingPage(
        image: Image(uiImage: UIImage(systemName: "sun")!),
        text: "",
        pageIndex: 0,
        totalPages: 0
    )
}
