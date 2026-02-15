//
//  ImageLoader.swift
//  CiniBox
//
//

import UIKit

final class ImageLoader {
    static let shared = ImageLoader()

    private let cache = NSCache<NSString, UIImage>()
    private let queue = DispatchQueue(label: "ImageLoader", qos: .userInitiated)

   
    func loadImage(from url: URL?, into imageView: UIImageView, placeholder: UIImage? = nil, completion: ((URL, UIImage) -> Void)? = nil) {
        imageView.image = placeholder

        guard let url else { return }

        let cacheKey = NSString(string: url.absoluteString)
        if let cached = cache.object(forKey: cacheKey) {
            if let completion {
                DispatchQueue.main.async { completion(url, cached) }
            } else {
                imageView.image = cached
            }
            return
        }

        queue.async { [weak self] in
            guard let self else { return }

            if let data = try? Data(contentsOf: url),
               let image = UIImage(data: data) {
                self.cache.setObject(image, forKey: cacheKey)
                DispatchQueue.main.async {
                    if let completion {
                        completion(url, image)
                    } else {
                        imageView.image = image
                    }
                }
            }
        }
    }
}

