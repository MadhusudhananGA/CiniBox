//
//  FavoritesManager.swift
//  CiniBox
//
//

import Foundation

final class FavoritesManager {
    static let shared = FavoritesManager()

    static let favoritesDidChangeNotification = Notification.Name("FavoritesManager.favoritesDidChange")

    private let storageKey = "favorite_movies"
    private var favorites: [Movie] = []

    private init() {
        load()
    }

    // MARK: - Public API

    func allFavorites() -> [Movie] {
        favorites
    }

    func isFavorite(_ movie: Movie) -> Bool {
        favorites.contains(where: { $0.id == movie.id })
    }

    func toggleFavorite(_ movie: Movie) {
        if let index = favorites.firstIndex(where: { $0.id == movie.id }) {
            favorites.remove(at: index)
        } else {
            favorites.append(movie)
        }
        save()
        NotificationCenter.default.post(name: FavoritesManager.favoritesDidChangeNotification, object: nil)
    }

    // MARK: - Persistence

    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            favorites = []
            return
        }

        do {
            favorites = try JSONDecoder().decode([Movie].self, from: data)
        } catch {
            favorites = []
        }
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(favorites)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            // Failing to save favorites is non-fatal; ignore.
        }
    }
}

