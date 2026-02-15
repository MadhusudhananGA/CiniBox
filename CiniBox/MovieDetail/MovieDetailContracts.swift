//
//  MovieDetailContracts.swift
//  CiniBox
//
//

import UIKit

protocol MovieDetailViewProtocol: AnyObject {
    var controller: UIViewController { get }

    func showBasicInfo(for movie: Movie)
    func showDetails(subtitle: String, rating: String, genres: String, cast: String, overview: String)
    func setTrailerEnabled(_ enabled: Bool, url: URL?)
    func updateFavorite(isFavorite: Bool)
    func showNoTrailerAlert()
}

protocol MovieDetailPresenterProtocol: AnyObject {
    func viewDidLoad()
    func didTapFavorite()
    func didTapTrailer()
}

protocol MovieDetailInteractorInputProtocol: AnyObject {
    func fetchDetails()
    func toggleFavorite()
    func isFavorite() -> Bool
}

protocol MovieDetailInteractorOutputProtocol: AnyObject {
    func didFetchDetails(_ detail: MovieDetail)
    func didFailToFetchDetails(error: TMDbError)
    func didToggleFavorite(isFavorite: Bool)
}

protocol MovieDetailRouterProtocol: AnyObject {
    static func createModule(with movie: Movie) -> UIViewController
}

