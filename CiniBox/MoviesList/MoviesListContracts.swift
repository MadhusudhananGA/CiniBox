//
//  MoviesListContracts.swift
//  CiniBox
//
//

import UIKit

protocol MoviesListViewProtocol: AnyObject {
    var controller: UIViewController { get }

    func reloadMovies()
    func showError(_ message: String)
}

protocol MoviesListPresenterProtocol: AnyObject {
    var numberOfRows: Int { get }

    func viewDidLoad()
    func segmentChanged(to index: Int)
    func searchQueryChanged(_ query: String)
    func searchCancelled()

    func configure(cell: MovieTableViewCell, at index: Int)
    func didSelectRow(at index: Int)
    func trailingSwipeActionsConfiguration(for index: Int) -> UISwipeActionsConfiguration?
}

protocol MoviesListInteractorInputProtocol: AnyObject {
    func fetchPopular(reset: Bool)
    func searchMovies(query: String)
    func fetchRuntime(for movie: Movie)
    func toggleFavorite(for movie: Movie)
    func allFavorites() -> [Movie]
    func isFavorite(_ movie: Movie) -> Bool
}

protocol MoviesListInteractorOutputProtocol: AnyObject {
    func didFetchPopular(movies: [Movie], reset: Bool)
    func didFailToFetchPopular(error: TMDbError)

    func didFetchSearchResults(movies: [Movie], forQuery: String)
    func didFailToSearch(error: TMDbError)

    func didFetchRuntime(for movie: Movie, runtime: Int)
    func didToggleFavorite(for movie: Movie)
}

protocol MoviesListRouterProtocol: AnyObject {
    static func getMovieListViewController() -> UIViewController
    func navigateToMovieDetail(from view: MoviesListViewProtocol, movie: Movie)
}

