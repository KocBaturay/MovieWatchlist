//
//  MovieService.swift
//  MovieWatchlist
//
//  Created by Baturay Koc on 16.08.26.
//

import Foundation

protocol MovieServiceProtocol {
    func popularMovies() async throws -> [Movie]
    func movieDetail(id: Int) async throws -> MovieDetail
}

enum APIError: Error, Equatable {
    case unauthorized
    case server(statusCode: Int)
    case invalidResponse
    case decodingFailed
}

extension APIError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            "The TMDB access token was rejected."
        case .server(let statusCode):
            "The server returned an error (\(statusCode))."
        case .invalidResponse:
            "The server sent an unexpected response."
        case .decodingFailed:
            "Couldn't read the data from the server."
        }
    }
}

struct MovieService: MovieServiceProtocol {
    private static let baseURL = URL(string: "https://api.themoviedb.org/3")!
    private let session: URLSession

    init(session: URLSession = MovieService.makeSession()) {
        self.session = session
    }

    static func makeSession() -> URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        return URLSession(configuration: configuration)
    }

    func popularMovies() async throws -> [Movie] {
        let url = Self.baseURL
            .appending(path: "movie/popular")
            .appending(queryItems: [URLQueryItem(name: "page", value: "1")])
        let page: MoviePage = try await get(url)
        return page.results
    }

    func movieDetail(id: Int) async throws -> MovieDetail {
        try await get(Self.baseURL.appending(path: "movie/\(id)"))
    }

    private func get<Response: Decodable>(_ url: URL) async throws -> Response {
        var request = URLRequest(url: url)
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await session.data(for: request)

        guard let http = response as? HTTPURLResponse else {
            throw APIError.invalidResponse
        }
        guard (200..<300).contains(http.statusCode) else {
            throw http.statusCode == 401 ? APIError.unauthorized : APIError.server(statusCode: http.statusCode)
        }

        do {
            return try JSONDecoder().decode(Response.self, from: data)
        } catch {
            throw APIError.decodingFailed
        }
    }
}
