//
//  AsyncImage.swift
//  GameGuessr
//
//  Created by BAHATTIN KOC on 3.06.2024.
//

import SwiftUI
import Combine

struct AsyncImage: View {
    @StateObject var loader = ImageLoader()
    @State private var pixelatedImage: UIImage?
    let url: URL
    @Binding var pixelSize: CGFloat

    var body: some View {
        Group {
            if let image = pixelatedImage {
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
            pixelSize = 60.0
        }
        .onChange(of: pixelSize) { _, _ in
            if let image = loader.image {
                pixelatedImage = pixelateImage(image, pixelSize: pixelSize)
            }
        }
        .onChange(of: loader.image) { _, _ in
            if let image = loader.image {
                pixelatedImage = pixelateImage(image, pixelSize: 60.0)
            }
        }
    }

    private func pixelateImage(_ image: UIImage, pixelSize: CGFloat) -> UIImage? {
        let size = image.size
        let scale = image.scale

        let context = CGContext(
            data: nil,
            width: Int(size.width / pixelSize),
            height: Int(size.height / pixelSize),
            bitsPerComponent: image.cgImage!.bitsPerComponent,
            bytesPerRow: 0,
            space: image.cgImage!.colorSpace!,
            bitmapInfo: image.cgImage!.bitmapInfo.rawValue
        )

        guard let context = context else { return nil }

        context.interpolationQuality = .none
        context.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: context.width, height: context.height))

        guard let pixelatedCGImage = context.makeImage() else { return nil }

        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context2 = UIGraphicsGetCurrentContext() else { return nil }

        context2.interpolationQuality = .none
        context2.translateBy(x: 0, y: size.height)
        context2.scaleBy(x: 1.0, y: -1.0)

        context2.draw(pixelatedCGImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))

        let pixelatedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return pixelatedImage
    }
}

#Preview {
    AsyncImage(url: URL(string: "")!, pixelSize: .constant(8.0))
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
