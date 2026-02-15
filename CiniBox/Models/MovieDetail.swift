//
//  MovieDetail.swift
//  CiniBox
//
//

import Foundation

struct MovieDetail: Codable {
    let id: Int
    let title: String
    let overview: String
    let posterPath: String?
    let backdropPath: String?
    let runtime: Int?
    let genres: [Genre]
    let voteAverage: Double
    let credits: CreditsResponse?
    let videos: MovieVideosResponse?
    let releaseDate: String?

    struct Genre: Codable {
        let id: Int
        let name: String
    }

    struct CreditsResponse: Codable {
        let cast: [CastMember]
    }

    struct CastMember: Codable {
        let id: Int
        let name: String
        let character: String?
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath
        case backdropPath
        case runtime
        case genres
        case voteAverage
        case credits
        case videos
        case releaseDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        overview = try container.decode(String.self, forKey: .overview)
        posterPath = try container.decodeIfPresent(String.self, forKey: .posterPath)
        backdropPath = try container.decodeIfPresent(String.self, forKey: .backdropPath)
        runtime = try container.decodeIfPresent(Int.self, forKey: .runtime)
        genres = try container.decode([Genre].self, forKey: .genres)
        releaseDate = try container.decodeIfPresent(String.self, forKey: .releaseDate)
        
        
        if let d = try? container.decode(Double.self, forKey: .voteAverage) {
            voteAverage = d
        } else if let i = try? container.decode(Int.self, forKey: .voteAverage) {
            voteAverage = Double(i)
        } else if let s = try? container.decode(String.self, forKey: .voteAverage), let d = Double(s) {
            voteAverage = d
        } else {
            voteAverage = 0
        }
        
        
        credits = try? container.decode(CreditsResponse.self, forKey: .credits)
        
        
        if container.contains(.videos) {
            do {
                videos = try container.decode(MovieVideosResponse.self, forKey: .videos)
                if let videos = videos {
                    print("DEBUG: Successfully decoded \(videos.results.count) videos")
                    for video in videos.results {
                        print("DEBUG: Video - site: '\(video.site)', type: '\(video.type)', key: '\(video.key)'")
                    }
                }
            } catch let error {
                print("DEBUG: Failed to decode videos field: \(error)")
                if let decodingError = error as? DecodingError {
                    switch decodingError {
                    case .typeMismatch(let type, let context):
                        print("DEBUG: Type mismatch - expected \(type), path: \(context.codingPath)")
                    case .keyNotFound(let key, let context):
                        print("DEBUG: Key not found - '\(key.stringValue)', path: \(context.codingPath)")
                    case .valueNotFound(let type, let context):
                        print("DEBUG: Value not found - \(type), path: \(context.codingPath)")
                    default:
                        break
                    }
                }
                videos = nil
            }
        } else {
            print("DEBUG: Videos key not found in response")
            videos = nil
        }
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

