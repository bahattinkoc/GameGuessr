//
//  DraggableRectangleView.swift
//  GameGuessr
//
//  Created by BAHATTIN KOC on 2.06.2024.
//

import SwiftUI

enum DragDirection: String {
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
    private let maxDragDistance: CGFloat = 30

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

                                if abs(newOffset.width) > 140 {
                                    dragDirection = newOffset.width > 0 ? .right : .left
                                    if !hasVibrated {
                                        feedbackGenerator.impactOccurred()
                                    }
                                } else if abs(newOffset.height) > 140 {
                                    dragDirection = newOffset.height > 0 ? .bottom : .top
                                    if !hasVibrated {
                                        feedbackGenerator.impactOccurred()
                                    }
                                } else {
                                    dragDirection = nil
                                    hasVibrated = false
                                }

                                offset = newOffset
                                rotationAngle = Angle(degrees: Double(newOffset.width) / 50)

                                if (abs(newOffset.width) > 140 || abs(newOffset.height) > 140) && !hasVibrated {
                                    feedbackGenerator.impactOccurred()
                                    hasVibrated = true
                                }
                            }
                            .onEnded { value in
                                if dragDirection != nil {
                                    changeGame()
                                }
                                isDragging = false
                                dragDirection = nil
                                hasVibrated = false
                                withAnimation(.spring()) {
                                    offset = .zero
                                    rotationAngle = .zero
                                }
                            }
                    )

                ChooseView(direction: .top,
                           title: "Top",
                           color: .blue,
                           offset: CGSize(width: offset.width * 0.5, height: offset.height * 0.5 - geometry.size.height / 1.5 / 2),
                           hasVibrated: hasVibrated && dragDirection != nil,
                           rotationAngle: rotationAngle,
                           visibility: dragDirection == .top || !isDragging || (isDragging && dragDirection == nil))

                ChooseView(direction: .right,
                           title: "Right",
                           color: .green,
                           offset: CGSize(width: min(offset.width * 0.5 + 160, geometry.size.width / 2.3), height: 0),
                           hasVibrated: hasVibrated && dragDirection != nil,
                           rotationAngle: rotationAngle,
                           visibility: dragDirection == .right || !isDragging || (isDragging && dragDirection == nil))

                ChooseView(direction: .left,
                           title: "Left",
                           color: .red,
                           offset: CGSize(width: max(offset.width * 0.5 - 160, -(geometry.size.width / 2.3)), height: 0),
                           hasVibrated: hasVibrated && dragDirection != nil,
                           rotationAngle: rotationAngle,
                           visibility: dragDirection == .left || !isDragging || (isDragging && dragDirection == nil))

                ChooseView(direction: .bottom,
                           title: "Bottom",
                           color: .orange,
                           offset: CGSize(width: offset.width * 0.5, height: offset.height * 0.5 + geometry.size.height / 1.5 / 2),
                           hasVibrated: hasVibrated && dragDirection != nil,
                           rotationAngle: rotationAngle, visibility: dragDirection == .bottom || !isDragging || (isDragging && dragDirection == nil))
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .onAppear {
                loadGames()
            }
        }
    }

    func changeGame() {
        game = games.randomElement()!
        imageUrl = URL(string: "https://images.igdb.com/igdb/image/upload/t_1080p_2x/\(game.url ?? "co290t.jpg")")!
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
