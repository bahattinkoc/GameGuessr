//
//  DraggableRectangleView.swift
//  GameGuessr
//
//  Created by BAHATTIN KOC on 2.06.2024.
//

import SwiftUI

struct DraggableRectangleView: View {

    enum DragDirection {
        case top, bottom, left, right
    }

    @State private var offset = CGSize.zero
    @State private var rotationAngle: Angle = .zero
    @State private var hasVibrated = false
    @State private var isDragging = false
    @State private var dragDirection: DragDirection? = nil
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    private let maxDragDistance: CGFloat = 150

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AsyncImage(url: URL(string: "https://media.rawg.io/media/games/20a/20aa03a10cda45239fe22d035c0ebe64.jpg")!)
                    .frame(width: geometry.size.width - 60, height: geometry.size.height / 1.5)
                    .cornerRadius(24.0)
                    .offset(x: offset.width, y: offset.height)
                    .rotationEffect(rotationAngle, anchor: .bottom)
                    .gesture(
                        DragGesture(coordinateSpace: .global)
                            .onChanged { value in
                                isDragging = true
                                let newOffset = value.translation

                                if abs(newOffset.width) > abs(newOffset.height) {
                                    dragDirection = newOffset.width > 0 ? .right : .left
                                } else {
                                    dragDirection = newOffset.height > 0 ? .bottom : .top
                                }

                                offset = newOffset
                                rotationAngle = Angle(degrees: Double(newOffset.width) / 50)

                                if (abs(newOffset.width) > 100 || abs(newOffset.height) > 100) && !hasVibrated {
                                    feedbackGenerator.impactOccurred()
                                    hasVibrated = true
                                }
                            }
                            .onEnded { value in
                                withAnimation(.spring) {
                                    isDragging = false
                                    dragDirection = nil
                                    offset = .zero
                                    rotationAngle = .zero
                                    hasVibrated = false
                                }
                            }
                    )

                if dragDirection == .top || !isDragging {
                    ChooseView(title: "Top",
                               color: .blue,
                               offset: CGSize(width: offset.width * 0.5, height: offset.height * 0.5 - 250),
                               hasVibrated: hasVibrated,
                               rotationAngle: rotationAngle)
                }

                if dragDirection == .right || !isDragging {
                    ChooseView(title: "Right",
                               color: .green,
                               offset: CGSize(width: maxDragDistance, height: 0),
                               hasVibrated: hasVibrated,
                               rotationAngle: rotationAngle)
                }

                if dragDirection == .left || !isDragging {
                    ChooseView(title: "Left",
                               color: .red,
                               offset: CGSize(width: -maxDragDistance, height: 0),
                               hasVibrated: hasVibrated,
                               rotationAngle: rotationAngle)
                }

                if dragDirection == .bottom || !isDragging {
                    ChooseView(title: "Bottom",
                               color: .orange,
                               offset: CGSize(width: offset.width * 0.5, height: offset.height * 0.5 + 250),
                               hasVibrated: hasVibrated,
                               rotationAngle: rotationAngle)
                }
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }

    private func limitDrag(offset: CGSize) -> CGSize {
        var limitedOffset = offset

        if dragDirection == .left || dragDirection == .right {
            limitedOffset.height = 0
            limitedOffset.width = min(max(limitedOffset.width, -maxDragDistance), maxDragDistance)
        } else {
            limitedOffset.width = 0
            limitedOffset.height = min(max(limitedOffset.height, -maxDragDistance), maxDragDistance)
        }

        return limitedOffset
    }
}

#Preview {
    DraggableRectangleView()
}
