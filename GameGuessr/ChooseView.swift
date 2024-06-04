//
//  ChooseView.swift
//  GameGuessr
//
//  Created by BAHATTIN KOC on 3.06.2024.
//

import SwiftUI
import Combine

struct ChooseView: View {
    @State private var textHeight: CGFloat = 0
    @State private var showChooseView: Bool = false
    var direction: DragDirection = .top
    var title: String
    var color: Color
    var offset = CGSize.zero
    var hasVibrated: Bool = false
    var rotationAngle: Angle = .zero
    private let feedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        VStack {
            Text(title)
                .padding(8)
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
        .scaleEffect(hasVibrated ? 1.2 : 1.0)
        .offset(offset)
        .rotationEffect(rotationAngle, anchor: .bottom)
        .opacity(showChooseView ? 1 : 0)
        .animation(.easeInOut(duration: 0.6), value: showChooseView)
        .onAppear {
            if hasVibrated {
                feedbackGenerator.impactOccurred()
            }
            withAnimation {
                showChooseView = true
            }
        }
        .onDisappear {
            withAnimation {
                showChooseView = false
            }
        }
    }
}

final class ImageLoader: ObservableObject {
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

#Preview {
    ChooseView(title: "The Last of Us 2", color: .blue)
}
