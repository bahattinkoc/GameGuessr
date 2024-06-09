//
//  ChooseView.swift
//  GameGuessr
//
//  Created by BAHATTIN KOC on 3.06.2024.
//

import SwiftUI

struct ChooseView: View {
    @State private var textHeight: CGFloat = 0
    var direction: DragDirection = .top
    var title: String
    var color: Color
    var offset = CGSize.zero
    var hasVibrated: Bool = false
    var rotationAngle: Angle = .zero
    var visibility: Bool = true

    var body: some View {
        VStack {
            Text(title)
                .bold()
                .padding(8)
                .frame(minWidth: 30, maxWidth: [.top, .bottom].contains(direction) ? 140 : 100)
                .background(
                    GeometryReader { geometry in
                        RoundedRectangle(cornerRadius: textHeight / 2)
                            .fill(color)
                            .onAppear {
                                textHeight = geometry.size.height
                            }
                    }
                )
                .foregroundColor(.white)
        }
        .scaleEffect(hasVibrated ? 1.4 : 1.0)
        .offset(offset)
        .rotationEffect(rotationAngle, anchor: .bottom)
        .opacity(visibility ? 1 : 0)
        .animation(.linear(duration: 0.15), value: visibility)
        .shadow(radius: textHeight / 2)
    }
}

#Preview {
    ChooseView(title: "The Last of Us 2", color: .blue)
}
