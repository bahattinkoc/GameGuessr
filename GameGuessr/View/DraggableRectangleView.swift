//
//  DraggableRectangleView.swift
//  GameGuessr
//
//  Created by BAHATTIN KOC on 2.06.2024.
//

import SwiftUI
import Pow

enum DragDirection: String {
    case top, bottom, left, right
}

struct DraggableRectangleView: View {

    @ObservedObject private var gameCenterManager = GameCenterManager.shared
    @State private var games: [Game] = []
    @State private var correctGame: Game = Game()
    @State private var imageUrl: URL = URL(string: "https://images.igdb.com/igdb/image/upload/t_1080p_2x/co7dw9.jpg")!
    @State private var offset = CGSize.zero
    @State private var rotationAngle: Angle = .zero
    @State private var hasVibrated = false
    @State private var isDragging = false
    @State private var dragDirection: DragDirection? = nil
    @State private var options: [Game] = Array(repeating: Game(), count: 4)
    @State private var pixelSize: CGFloat = 60.0
    @State private var isWiggle: Bool = false
    @State private var score: Int = 0
    @State private var remainingScore: Int = 3
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.background
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    HStack {
                        HStack {
                            Text("\(LocalizationContants.DraggableRectangleView.currentScore)")
                                .fontWeight(.heavy)
                                .font(.system(size: 20.0))
                                .foregroundStyle(.gray)
                            Text("\(score)")
                                .fontWeight(.heavy)
                                .font(.system(size: 20.0))
                                .foregroundStyle(.yellow)
                            Spacer()
                        }
                        .padding()
                        Spacer()
                        Button(action: {
                            gameCenterManager.showLeaderboard()
                        }) {
                            Image(systemName: "trophy.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.yellow)
                                .padding()
                        }
                    }
                    Spacer()
                }
                .padding()
                .padding(.top, 40)
                .edgesIgnoringSafeArea(.all)

                VStack {
                    Spacer()
                    HStack {
                        Text("\(LocalizationContants.DraggableRectangleView.remainingScore)\(remainingScore)")
                            .fontWeight(.heavy)
                            .foregroundStyle(.gray)
                            .padding()
                    }
                }
                .padding()
                .padding(.bottom, 40)
                .edgesIgnoringSafeArea(.all)

                AsyncImage(url: imageUrl, pixelSize: $pixelSize)
                    .frame(width: geometry.size.width - 60, height: geometry.size.height / 1.5)
                    .cornerRadius(24.0)
                    .offset(x: offset.width, y: offset.height)
                    .rotationEffect(rotationAngle, anchor: .bottom)
                    .shadow(radius: 8.0)
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
                                defer { isWiggle = false }
                                if dragDirection != nil {
                                    didChoose()
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
                    .changeEffect(.shake(rate: .phaseLength(0.5)), value: isWiggle)
                    .conditionalEffect(
                        .repeat(
                            .glow(color: .red, radius: 50),
                            every: 1.5
                        ),
                        condition: isWiggle
                    )

                ChooseView(direction: .top,
                           title: options[0].name ?? "",
                           color: .blue,
                           offset: CGSize(width: offset.width * 0.5, height: offset.height * 0.5 - geometry.size.height / 1.5 / 2),
                           hasVibrated: hasVibrated && dragDirection != nil,
                           rotationAngle: rotationAngle,
                           visibility: dragDirection == .top || !isDragging || (isDragging && dragDirection == nil))

                ChooseView(direction: .right,
                           title: options[1].name ?? "",
                           color: .green,
                           offset: CGSize(width: min(offset.width * 0.5 + 160, geometry.size.width / 2.3 - 30.0), height: 0),
                           hasVibrated: hasVibrated && dragDirection != nil,
                           rotationAngle: rotationAngle,
                           visibility: dragDirection == .right || !isDragging || (isDragging && dragDirection == nil))

                ChooseView(direction: .left,
                           title: options[2].name ?? "",
                           color: .red,
                           offset: CGSize(width: max(offset.width * 0.5 - 160, -(geometry.size.width / 2.3) + 30.0), height: 0),
                           hasVibrated: hasVibrated && dragDirection != nil,
                           rotationAngle: rotationAngle,
                           visibility: dragDirection == .left || !isDragging || (isDragging && dragDirection == nil))

                ChooseView(direction: .bottom,
                           title: options[3].name ?? "",
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

    private func didChoose() {
        let selectedIndex = options.firstIndex { $0.name == correctGame.name }
        if selectedIndex == 0 && dragDirection == .top ||
            selectedIndex == 1 && dragDirection == .right ||
            selectedIndex == 2 && dragDirection == .left ||
            selectedIndex == 3 && dragDirection == .bottom {
            DispatchQueue.main.async {
                changeGame()
                score += remainingScore
                remainingScore = 3
                gameCenterManager.reportScore(score: score)
            }
        } else {
            if remainingScore - 1 == 0 {
                remainingScore = 3
                score = 0
                changeGame()
            } else {
                remainingScore -= 1
            }
            isWiggle = true
            if pixelSize - 19 >= 1 {
                pixelSize -= 19
            } else {
                // TODO: - Kaybettin
            }
        }
    }

    private func changeGame() {
        var randomIndexes = Set<Int>()
        while randomIndexes.count < 4 {
            let rastgeleIndeks = Int.random(in: 0..<games.count)
            randomIndexes.insert(rastgeleIndeks)
        }
        options = randomIndexes.map { games[$0] }
        options.shuffle()
        correctGame = options.randomElement()!
        imageUrl = URL(string: "https://images.igdb.com/igdb/image/upload/t_1080p_2x/\(correctGame.url ?? "co290t.jpg")")!
    }

    private func loadGames() {
        if let url = Bundle.main.url(forResource: "gameList", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                games = try decoder.decode([Game].self, from: data)
                games.shuffle()
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
