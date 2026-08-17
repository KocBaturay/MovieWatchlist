//
//  MovieDetail.swift
//  MovieWatchlist
//
//  Created by Baturay Koc on 16.08.26.
//

struct MovieDetail: Decodable, Equatable {
    let id: Int
    let title: String
    let overview: String?
    let posterPath: String?
    let releaseDate: String?
    let voteAverage: Double?
    let runtime: Int?
    let tagline: String?
    let genres: [Genre]?

    struct Genre: Decodable, Equatable {
        let id: Int
        let name: String
    }

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case overview
        case posterPath = "poster_path"
        case releaseDate = "release_date"
        case voteAverage = "vote_average"
        case runtime
        case tagline
        case genres
    }

    var genreNames: String? {
        guard let genres, !genres.isEmpty else { return nil }
        return genres.map(\.name).joined(separator: ", ")
    }
}
