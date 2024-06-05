//
//  DraggableRectangleView.swift
//  GameGuessr
//
//  Created by BAHATTIN KOC on 2.06.2024.
//

import SwiftUI

enum DragDirection {
    case top, bottom, left, right
}

struct DraggableRectangleView: View {

    @State private var games: [Game] = []
    @State private var game: Game = Game()
    @State private var imageUrl: URL = URL(string: "https://images.igdb.com/igdb/image/upload/t_1080p_2x/co290t.jpg")!
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
                AsyncImage(url: imageUrl)
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
                                    DispatchQueue.main.async {
                                        changeGame()
                                        isDragging = false
                                        dragDirection = nil
                                        offset = .zero
                                        rotationAngle = .zero
                                        hasVibrated = false
                                    }
                                }
                            }
                    )

                if dragDirection == .top || !isDragging {
                    ChooseView(direction: .top,
                               title: "Top",
                               color: .blue,
                               offset: CGSize(width: offset.width * 0.5, height: offset.height * 0.5 - 250),
                               hasVibrated: hasVibrated,
                               rotationAngle: rotationAngle)
                }

                if dragDirection == .right || !isDragging {
                    ChooseView(direction: .right,
                               title: "Right",
                               color: .green,
                               offset: CGSize(width: maxDragDistance, height: 0),
                               hasVibrated: hasVibrated,
                               rotationAngle: rotationAngle)
                }

                if dragDirection == .left || !isDragging {
                    ChooseView(direction: .left,
                               title: "Left",
                               color: .red,
                               offset: CGSize(width: -maxDragDistance, height: 0),
                               hasVibrated: hasVibrated,
                               rotationAngle: rotationAngle)
                }

                if dragDirection == .bottom || !isDragging {
                    ChooseView(direction: .bottom,
                               title: "Bottom",
                               color: .orange,
                               offset: CGSize(width: offset.width * 0.5, height: offset.height * 0.5 + 250),
                               hasVibrated: hasVibrated,
                               rotationAngle: rotationAngle)
                }
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .onAppear {
                loadGames()
            }
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

    func changeGame() {
        game = games.randomElement()!
        imageUrl = URL(string: "https://images.igdb.com/igdb/image/upload/t_1080p_2x/\(game.url ?? "co290t.jpg")")!
        print(imageUrl.absoluteURL)
    }

    func loadGames() {
        if let url = Bundle.main.url(forResource: "gameList", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                games = try decoder.decode([Game].self, from: data)
                changeGame()
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }
    }
}

#Preview {
    DraggableRectangleView()
}
