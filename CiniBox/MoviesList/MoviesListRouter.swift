//
//  MoviesListRouter.swift
//  CiniBox
//
//

import UIKit

final class MoviesListRouter: MoviesListRouterProtocol {
    static func getMovieListViewController() -> UIViewController {
        let view = MoviesListViewController()
        let interactor = MoviesListInteractor()
        let router = MoviesListRouter()
        let presenter = MoviesListPresenter(view: view, interactor: interactor, router: router)

        view.presenter = presenter
        interactor.output = presenter

        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }

    func navigateToMovieDetail(from view: MoviesListViewProtocol, movie: Movie) {
        let detailVC = MovieDetailRouter.createModule(with: movie)
        view.controller.navigationController?.pushViewController(detailVC, animated: true)
    }
}

