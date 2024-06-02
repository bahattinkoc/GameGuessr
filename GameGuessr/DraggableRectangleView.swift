//
//  DraggableRectangleView.swift
//  GameGuessr
//
//  Created by BAHATTIN KOC on 2.06.2024.
//

import SwiftUI
import Combine

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
                                offset = value.translation
                                rotationAngle = Angle(degrees: Double(value.translation.width) / 50)

                                // Yön belirleme
                                if abs(value.translation.width) > abs(value.translation.height) {
                                    dragDirection = value.translation.width > 0 ? .right : .left
                                } else {
                                    dragDirection = value.translation.height > 0 ? .bottom : .top
                                }

                                if (abs(value.translation.width) > 50 || value.translation.height < -50) && !hasVibrated {
                                    feedbackGenerator.impactOccurred()
                                    hasVibrated = true
                                }
                            }
                            .onEnded { value in
                                withAnimation(.spring) {
                                    isDragging = false
                                    offset = .zero
                                    rotationAngle = .zero
                                    hasVibrated = false
                                    // Sürükleme bittikten sonra yönü koruyoruz
                                }
                            }
                    )

                if dragDirection == .top || !isDragging {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.blue)
                        .frame(width: 100, height: 50)
                        .overlay(
                            Text("Top")
                                .foregroundColor(.white)
                        )
                        .offset(x: offset.width * 0.5, y: offset.height * 0.5 - 250)
                        .rotationEffect(rotationAngle, anchor: .bottom)
                }

                if dragDirection == .right || !isDragging {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.green)
                        .frame(width: 100, height: 50)
                        .overlay(
                            Text("Right")
                                .foregroundColor(.white)
                        )
                        .offset(x: offset.width * 0.5 + 160, y: offset.height * 0.5)
                        .rotationEffect(rotationAngle, anchor: .bottom)
                }

                if dragDirection == .left || !isDragging {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.red)
                        .frame(width: 100, height: 50)
                        .overlay(
                            Text("Left")
                                .foregroundColor(.white)
                        )
                        .offset(x: offset.width * 0.5 - 160, y: offset.height * 0.5)
                        .rotationEffect(rotationAngle, anchor: .bottom)
                }

                if dragDirection == .bottom || !isDragging {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.orange)
                        .frame(width: 100, height: 50)
                        .overlay(
                            Text("Bottom")
                                .foregroundColor(.white)
                        )
                        .offset(x: offset.width * 0.5, y: offset.height * 0.5 + 250)
                        .rotationEffect(rotationAngle, anchor: .bottom)
                }
            }
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

#Preview {
    DraggableRectangleView()
}

class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?

    func load(from url: URL) {
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }

    deinit {
        cancellable?.cancel()
    }
}

struct AsyncImage: View {
    @StateObject private var loader = ImageLoader()
    let url: URL

    var body: some View {
        Group {
            if let image = loader.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            loader.load(from: url)
        }
    }
}
