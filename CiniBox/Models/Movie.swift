//
//  Movie.swift
//  CiniBox
//
//

import Foundation

struct MovieResponse: Codable {
    let results: [Movie]
}

struct Movie: Codable, Equatable, Hashable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let voteAverage: Double
    let releaseDate: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath
        case backdropPath
        case voteAverage
        case releaseDate
    }

    var posterURL: URL? {
        guard let posterPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w500\(posterPath)")
    }

    var backdropURL: URL? {
        guard let backdropPath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w780\(backdropPath)")
    }

    var formattedRating: String {
        String(format: "%.1f", voteAverage)
    }

    var formattedReleaseYear: String? {
        guard let releaseDate, releaseDate.count >= 4 else { return nil }
        return String(releaseDate.prefix(4))
    }
}

struct MovieVideosResponse: Codable {
    let id: Int?
    let results: [MovieVideo]
}

struct MovieVideo: Codable {
    let id: String
    let key: String
    let name: String
    let site: String
    let type: String
}

