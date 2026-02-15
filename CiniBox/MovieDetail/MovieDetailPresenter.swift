//
//  MovieDetailPresenter.swift
//  CiniBox
//
//

import Foundation

final class MovieDetailPresenter {
    private weak var view: MovieDetailViewProtocol?
    private let interactor: MovieDetailInteractorInputProtocol

    private let movie: Movie
    private var trailerURL: URL?

    init(view: MovieDetailViewProtocol,
         interactor: MovieDetailInteractorInputProtocol,
         movie: Movie) {
        self.view = view
        self.interactor = interactor
        self.movie = movie
    }
}

extension MovieDetailPresenter: MovieDetailPresenterProtocol {
    func viewDidLoad() {
        view?.showBasicInfo(for: movie)
        view?.updateFavorite(isFavorite: interactor.isFavorite())
        interactor.fetchDetails()
    }

    func didTapFavorite() {
        interactor.toggleFavorite()
    }

    func didTapTrailer() {
        view?.showNoTrailerAlert()
    }
}

// MARK: - MovieDetailInteractorOutputProtocol

extension MovieDetailPresenter: MovieDetailInteractorOutputProtocol {
    func didFetchDetails(_ detail: MovieDetail) {
        // Subtitle: year + duration
        var metaParts: [String] = []
        if let year = detail.formattedReleaseYear {
            metaParts.append(year)
        }
        if let runtime = detail.runtime {
            let hours = runtime / 60
            let minutes = runtime % 60
            if hours > 0 {
                metaParts.append("\(hours)h \(minutes)m")
            } else {
                metaParts.append("\(minutes)m")
            }
        }
        let subtitle = metaParts.joined(separator: " • ")

        let rating = "★ \(detail.formattedRating)"
        let overview = detail.overview.isEmpty ? "No overview available." : detail.overview

        // Genres
        let genresText: String
        if detail.genres.isEmpty {
            genresText = "Genres: —"
        } else {
            let names = detail.genres.map { $0.name }.joined(separator: ", ")
            genresText = "Genres: \(names)"
        }

        // Cast (top 5)
        let castText: String
        if let cast = detail.credits?.cast, !cast.isEmpty {
            let topCast = cast.prefix(5)
            let castStrings = topCast.map { member -> String in
                if let character = member.character, !character.isEmpty {
                    return "\(member.name) (\(character))"
                } else {
                    return member.name
                }
            }
            castText = "Cast: " + castStrings.joined(separator: ", ")
        } else {
            castText = "Cast: —"
        }

        // Trailer URL (YouTube trailer if available)
        // Debug: Check if videos exist
        if let videosResponse = detail.videos {
            print("DEBUG: Found videos response with \(videosResponse.results.count) videos")
            for video in videosResponse.results {
                print("DEBUG: Video - site: \(video.site), type: \(video.type), key: \(video.key)")
            }
        } else {
            print("DEBUG: No videos response found")
        }
        
        // Try to find a trailer first, then fall back to teaser, then any YouTube video
        let videos = detail.videos?.results ?? []
        let trailerVideo = videos.first(where: { video in
            let site = video.site.lowercased()
            let type = video.type.lowercased()
            return site == "youtube" && (type == "trailer" || type == "teaser")
        }) ?? videos.first(where: { $0.site.lowercased() == "youtube" })
        
        if let video = trailerVideo {
            let urlString = "https://www.youtube.com/watch?v=\(video.key)"
            print("DEBUG: Found trailer video, creating URL: \(urlString)")
            trailerURL = URL(string: urlString)
            view?.setTrailerEnabled(true, url: trailerURL)
        } else {
            print("DEBUG: No trailer video found. Total videos: \(videos.count)")
            trailerURL = nil
            view?.setTrailerEnabled(false, url: nil)
        }

        view?.showDetails(
            subtitle: subtitle,
            rating: rating,
            genres: genresText,
            cast: castText,
            overview: overview
        )
    }

    func didFailToFetchDetails(error: TMDbError) {
        // Keep basic info; just disable trailer.
        trailerURL = nil
        view?.setTrailerEnabled(false, url: nil)
    }

    func didToggleFavorite(isFavorite: Bool) {
        view?.updateFavorite(isFavorite: isFavorite)
    }
}

