//
//  DraggableRectangleView.swift
//  GameGuessr
//
//  Created by BAHATTIN KOC on 2.06.2024.
//

import SwiftUI

struct DraggableRectangleView: View {

    @State private var offset = CGSize.zero
    @State private var rotationAngle: Angle = .zero
    @State private var hasVibrated = false
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.gray)
                    .frame(width: geometry.size.width - 60, height: geometry.size.height / 1.5 )
                    .cornerRadius(24.0)
                    .offset(x: offset.width, y: offset.height)
                    .rotationEffect(rotationAngle, anchor: .bottom)
                    .gesture(
                        DragGesture(coordinateSpace: .global)
                            .onChanged { value in
                                offset = value.translation
                                rotationAngle = Angle(degrees: Double(value.translation.width) / 50)

                                if (abs(value.translation.width) > 50 || value.translation.height < -50) && !hasVibrated {
                                    feedbackGenerator.impactOccurred()
                                    hasVibrated = true
                                }
                            }
                            .onEnded { value in
                                withAnimation(.spring) {
                                    offset = .zero
                                    rotationAngle = .zero
                                    hasVibrated = false
                                }
                            }
                    )

                Text("Top")
                    .offset(x: offset.width * 0.5, y: offset.height * 0.5 - 250)
                    .rotationEffect(rotationAngle, anchor: .bottom)

                Text("Right")
                    .offset(x: offset.width * 0.5 + 160, y: offset.height * 0.5)
                    .rotationEffect(rotationAngle, anchor: .bottom)

                Text("Left")
                    .offset(x: offset.width * 0.5 - 160, y: offset.height * 0.5)
                    .rotationEffect(rotationAngle, anchor: .bottom)

                Text("Bottom")
                    .offset(x: offset.width * 0.5, y: offset.height * 0.5 + 250)
                    .rotationEffect(rotationAngle, anchor: .bottom)
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

#Preview {
    DraggableRectangleView()
}
