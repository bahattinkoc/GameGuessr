//
//  ProgressBar.swift
//  GameGuessr
//
//  Created by BAHATTIN KOC on 9.06.2024.
//

import SwiftUI

struct ProgressBar: View {
    @Binding var value: Int
    @Binding var isNavigationActive: Bool
    let total: Int
    @State private var buttonTitle = ""

    var body: some View {
        GeometryReader { geometry in
            Button(action: {
                CacheManager.shared.saveData(false, forKey: .willShowOnboarding)
                isNavigationActive.toggle()
            }) {
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .opacity(0.3)
                        .foregroundColor(Color(UIColor.systemTeal))

                    LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .leading, endPoint: .trailing)
                        .frame(width: min(CGFloat(self.value + 1) / CGFloat(self.total) * geometry.size.width, geometry.size.width),
                               height: geometry.size.height)
                        .animation(.linear(duration: 1.0), value: value)

                    Text(buttonTitle)
                        .bold()
                        .foregroundColor(.white)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .transition(.scale)
                        .onChange(of: value) { oldValue, newValue in
                            DispatchQueue.main.asyncAfter(deadline: .now() + (oldValue > newValue ? 0.0 : 0.75)) {
                                buttonTitle = value == total - 1 ? "START" : ""
                            }
                        }
                }
                .cornerRadius(45.0)
            }
        }
    }
}

#Preview {
    ProgressBar(value: .constant(0), isNavigationActive: .constant(true), total: 3)
}
