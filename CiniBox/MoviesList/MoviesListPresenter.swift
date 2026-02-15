//
//  MoviesListPresenter.swift
//  CiniBox
//
//

import UIKit

final class MoviesListPresenter {
    private enum Segment: Int {
        case popular = 0
        case favorites = 1
    }

    private weak var view: MoviesListViewProtocol?
    private let interactor: MoviesListInteractorInputProtocol
    private let router: MoviesListRouterProtocol

    private var activeSegment: Segment = .popular
    private var popularMovies: [Movie] = []
    private var searchResults: [Movie] = []
    private var movieRuntimes: [Int: Int] = [:]

    private var isLoading = false
    private var isSearching: Bool = false
    private var currentSearchQuery: String = ""

    init(view: MoviesListViewProtocol,
         interactor: MoviesListInteractorInputProtocol,
         router: MoviesListRouterProtocol) {
        self.view = view
        self.interactor = interactor
        self.router = router

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(favoritesDidChange),
            name: FavoritesManager.favoritesDidChangeNotification,
            object: nil
        )
    }

    private var dataSource: [Movie] {
        switch activeSegment {
        case .popular:
            return isSearching ? searchResults : popularMovies
        case .favorites:
            let favorites = interactor.allFavorites()
            guard isSearching, !currentSearchQuery.isEmpty else { return favorites }
            let query = currentSearchQuery.lowercased()
            return favorites.filter { $0.title.lowercased().contains(query) }
        }
    }

    private func fetchPopular(reset: Bool) {
        guard !isLoading else { return }
        isLoading = true
        interactor.fetchPopular(reset: reset)
    }


    private func ensureRuntimeLoaded(for movie: Movie) {
        guard movieRuntimes[movie.id] == nil else { return }
        interactor.fetchRuntime(for: movie)
    }

    private func removeDuplicateMovies(_ movies: [Movie]) -> [Movie] {
        var seen = Set<Int>()
        return movies.filter { seen.insert($0.id).inserted }
    }

    @objc private func favoritesDidChange() {
        view?.reloadMovies()
    }
}

extension MoviesListPresenter: MoviesListPresenterProtocol {
    
    var numberOfRows: Int {
        dataSource.count
    }

    func viewDidLoad() {
        fetchPopular(reset: true)
    }

    func segmentChanged(to index: Int) {
        activeSegment = Segment(rawValue: index) ?? .popular
        view?.reloadMovies()
    }

    func searchQueryChanged(_ query: String) {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        currentSearchQuery = trimmed
        isSearching = !trimmed.isEmpty

        if activeSegment == .popular {
            if trimmed.isEmpty {
                searchResults = []
                view?.reloadMovies()
            } else {
                interactor.searchMovies(query: trimmed)
            }
        } else {
            view?.reloadMovies()
        }
    }

    func searchCancelled() {
        isSearching = false
        currentSearchQuery = ""
        searchResults = []
        view?.reloadMovies()
    }

    func configure(cell: MovieTableViewCell, at index: Int) {
        guard index < dataSource.count else { return }
        let movie = dataSource[index]
        let isFavorite = interactor.isFavorite(movie)
        let runtime = movieRuntimes[movie.id]
        cell.configure(with: movie, isFavorite: isFavorite, runtimeMinutes: runtime)
        ensureRuntimeLoaded(for: movie)
    }

    func didSelectRow(at index: Int) {
        guard index < dataSource.count else { return }
        let movie = dataSource[index]
        guard let view = view else { return }
        router.navigateToMovieDetail(from: view, movie: movie)
    }

    func trailingSwipeActionsConfiguration(for index: Int) -> UISwipeActionsConfiguration? {
        guard index < dataSource.count else { return nil }
        let movie = dataSource[index]
        let isFavorite = interactor.isFavorite(movie)

        let title = isFavorite ? "Unfavorite" : "Favorite"
        let action = UIContextualAction(style: .normal, title: title) { [weak self] _, _, completion in
            self?.interactor.toggleFavorite(for: movie)
            completion(true)
        }
        action.backgroundColor = isFavorite ? .systemRed : .systemYellow

        return UISwipeActionsConfiguration(actions: [action])
    }

}


extension MoviesListPresenter: MoviesListInteractorOutputProtocol {
    func didFetchPopular(movies: [Movie], reset: Bool) {
        isLoading = false
        let deduped = removeDuplicateMovies(movies)

        if reset {
            popularMovies = deduped
        } else {
            let existingIds = Set(popularMovies.map(\.id))
            let newOnes = deduped.filter { !existingIds.contains($0.id) }
            popularMovies.append(contentsOf: newOnes)
        }

        view?.reloadMovies()
    }

    func didFailToFetchPopular(error: TMDbError) {
        isLoading = false
        view?.showError("Failed to load popular movies.")
    }

    func didFetchSearchResults(movies: [Movie], forQuery: String) {
        guard forQuery == currentSearchQuery else { return }
        searchResults = removeDuplicateMovies(movies)
        view?.reloadMovies()
    }

    func didFailToSearch(error: TMDbError) {
        view?.showError("Failed to search movies.")
    }

    func didFetchRuntime(for movie: Movie, runtime: Int) {
        movieRuntimes[movie.id] = runtime
        view?.reloadMovies()
    }

    func didToggleFavorite(for movie: Movie) {
        view?.reloadMovies()
    }
}

