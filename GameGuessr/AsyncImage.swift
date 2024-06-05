//
//  AsyncImage.swift
//  GameGuessr
//
//  Created by BAHATTIN KOC on 3.06.2024.
//

import SwiftUI
import Combine

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
        .onChange(of: url) { _, newValue in
            loader.image = nil
            loader.load(from: newValue)
        }
    }
}

#Preview {
    AsyncImage(url: URL(string: "")!)
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
