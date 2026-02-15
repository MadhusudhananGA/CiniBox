//
//  TMDbAPI.swift
//  CiniBox
//
//

import Foundation

enum TMDbError: Error {
    case missingAPIKey
    case invalidURL
    case network(Error)
    case decoding(Error)
    case unknown
}

enum TMDbConfig {
    
    static let apiKey: String = "96fb17065b90836fbdab3052b253a66e"

    static let baseURL = URL(string: "https://api.themoviedb.org/3")!
}

final class TMDbAPI {
    static let shared = TMDbAPI()

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    
    func fetchPopular(completion: @escaping (Result<MovieResponse, TMDbError>) -> Void) {
        request(path: "/movie/popular", completion: completion)
    }

    func fetchMovieDetails(id: Int, completion: @escaping (Result<MovieDetail, TMDbError>) -> Void) {
        let items = [
            URLQueryItem(name: "append_to_response", value: "credits,videos")
        ]
        request(path: "/movie/\(id)", queryItems: items, completion: completion)
    }

    func searchMovies(query: String, completion: @escaping (Result<MovieResponse, TMDbError>) -> Void) {
        request(path: "/search/movie", queryItems: [URLQueryItem(name: "query", value: query)], completion: completion)
    }


    private func request<T: Decodable>(
        path: String,
        queryItems: [URLQueryItem] = [],
        completion: @escaping (Result<T, TMDbError>) -> Void
    ) {
        guard !TMDbConfig.apiKey.isEmpty else {
            completion(.failure(.missingAPIKey))
            return
        }

        var components = URLComponents(url: TMDbConfig.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)
        var items = queryItems
        items.append(URLQueryItem(name: "api_key", value: TMDbConfig.apiKey))
        components?.queryItems = items

        guard let url = components?.url else {
            completion(.failure(.invalidURL))
            return
        }

        let task = session.dataTask(with: url) { data, response, error in
            if let error {
                DispatchQueue.main.async {
                    completion(.failure(.network(error)))
                }
                return
            }

            guard let data else {
                DispatchQueue.main.async {
                    completion(.failure(.unknown))
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                
                let decoded = try decoder.decode(T.self, from: data)
                
                if let movieDetail = decoded as? MovieDetail {
                    if let videos = movieDetail.videos {
                        print("DEBUG: Successfully decoded videos: \(videos.results.count) videos found")
                    } else {
                        print("DEBUG: Videos field is nil in MovieDetail")
                    }
                }
                
                DispatchQueue.main.async {
                    completion(.success(decoded))
                }
            } catch {
                
                if let decodingError = error as? DecodingError {
                    print("DEBUG: Decoding error details:")
                    switch decodingError {
                    case .typeMismatch(let type, let context):
                        print("  Type mismatch: \(type), context: \(context)")
                    case .valueNotFound(let type, let context):
                        print("  Value not found: \(type), context: \(context)")
                    case .keyNotFound(let key, let context):
                        print("  Key not found: \(key.stringValue), context: \(context)")
                    case .dataCorrupted(let context):
                        print("  Data corrupted: \(context)")
                    @unknown default:
                        print("  Unknown error: \(decodingError)")
                    }
                } else {
                    print("DEBUG: Decoding error: \(error)")
                }
                DispatchQueue.main.async {
                    completion(.failure(.decoding(error)))
                }
            }
        }

        task.resume()
    }
}

