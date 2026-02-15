//
//  MovieDetailRouter.swift
//  CiniBox
//
//

import UIKit

final class MovieDetailRouter: MovieDetailRouterProtocol {
    static func createModule(with movie: Movie) -> UIViewController {
        let view = MovieDetailViewController(movie: movie)
        let interactor = MovieDetailInteractor(movie: movie)
        let presenter = MovieDetailPresenter(view: view, interactor: interactor, movie: movie)

        view.presenter = presenter
        interactor.output = presenter

        return view
    }
}

