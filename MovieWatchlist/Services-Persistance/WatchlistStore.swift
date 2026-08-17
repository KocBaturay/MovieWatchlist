//
//  WatchlistStore.swift
//  MovieWatchlist
//
//  Created by Baturay Koc on 16.08.26.
//

import Foundation
import Observation

protocol WatchlistStorage {
    func load() -> [Movie]
    func save(_ movies: [Movie])
}

struct UserDefaultsWatchlistStorage: WatchlistStorage {
    private static let key = "watchlist"
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func load() -> [Movie] {
        guard let data = defaults.data(forKey: Self.key),
              let movies = try? JSONDecoder().decode([Movie].self, from: data) else {
            return []
        }
        return movies
    }

    func save(_ movies: [Movie]) {
        guard let data = try? JSONEncoder().encode(movies) else { return }
        defaults.set(data, forKey: Self.key)
    }
}

@Observable
@MainActor
final class WatchlistStore {
    private(set) var movies: [Movie] = []
    private let storage: WatchlistStorage

    init(storage: WatchlistStorage) {
        self.storage = storage
        self.movies = storage.load()
    }

    func contains(_ movie: Movie) -> Bool {
        movies.contains { $0.id == movie.id }
    }

    func add(_ movie: Movie) {
        guard !contains(movie) else { return }
        movies.append(movie)
        storage.save(movies)
    }

    func remove(_ movie: Movie) {
        movies.removeAll { $0.id == movie.id }
        storage.save(movies)
    }

    func toggle(_ movie: Movie) {
        if contains(movie) {
            remove(movie)
        } else {
            add(movie)
        }
    }
}
