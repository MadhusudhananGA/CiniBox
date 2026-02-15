//
//  MoviesListInteractor.swift
//  CiniBox
//
//

import Foundation

final class MoviesListInteractor: MoviesListInteractorInputProtocol {
    weak var output: MoviesListInteractorOutputProtocol?

    private let api: TMDbAPI
    private let favoritesManager: FavoritesManager

    init(api: TMDbAPI = .shared, favoritesManager: FavoritesManager = .shared) {
        self.api = api
        self.favoritesManager = favoritesManager
    }

    func fetchPopular(reset: Bool) {
        api.fetchPopular { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                self.output?.didFetchPopular(movies: response.results, reset: reset)
            case .failure(let error):
                self.output?.didFailToFetchPopular(error: error)
            }
        }
    }

    func searchMovies(query: String) {
        let queryToReport = query.trimmingCharacters(in: .whitespacesAndNewlines)
        api.searchMovies(query: query) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let response):
                self.output?.didFetchSearchResults(movies: response.results, forQuery: queryToReport)
            case .failure(let error):
                self.output?.didFailToSearch(error: error)
            }
        }
    }

    func fetchRuntime(for movie: Movie) {
        api.fetchMovieDetails(id: movie.id) { [weak self] result in
            guard let self else { return }
            if case let .success(detail) = result, let runtime = detail.runtime {
                self.output?.didFetchRuntime(for: movie, runtime: runtime)
            }
        }
    }

    func toggleFavorite(for movie: Movie) {
        favoritesManager.toggleFavorite(movie)
        output?.didToggleFavorite(for: movie)
    }

    func allFavorites() -> [Movie] {
        favoritesManager.allFavorites()
    }

    func isFavorite(_ movie: Movie) -> Bool {
        favoritesManager.isFavorite(movie)
    }
}

