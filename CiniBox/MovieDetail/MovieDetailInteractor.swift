//
//  MovieDetailInteractor.swift
//  CiniBox
//
//

import Foundation

final class MovieDetailInteractor: MovieDetailInteractorInputProtocol {
    weak var output: MovieDetailInteractorOutputProtocol?

    private let movie: Movie
    private let api: TMDbAPI
    private let favoritesManager: FavoritesManager

    init(movie: Movie, api: TMDbAPI = .shared, favoritesManager: FavoritesManager = .shared) {
        self.movie = movie
        self.api = api
        self.favoritesManager = favoritesManager
    }

    func fetchDetails() {
        api.fetchMovieDetails(id: movie.id) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let detail):
                self.output?.didFetchDetails(detail)
            case .failure(let error):
                self.output?.didFailToFetchDetails(error: error)
            }
        }
    }

    func toggleFavorite() {
        favoritesManager.toggleFavorite(movie)
        output?.didToggleFavorite(isFavorite: favoritesManager.isFavorite(movie))
    }

    func isFavorite() -> Bool {
        favoritesManager.isFavorite(movie)
    }
}

