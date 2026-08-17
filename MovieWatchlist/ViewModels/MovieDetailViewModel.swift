//
//  MovieDetailViewModel.swift
//  MovieWatchlist
//
//  Created by Baturay Koc on 16.08.26.
//

import Foundation
import Observation

@Observable
@MainActor
final class MovieDetailViewModel {
    let movie: Movie
    private(set) var state: ViewState<MovieDetail> = .idle
    private let service: MovieServiceProtocol
    private let watchlist: WatchlistStore

    init(movie: Movie, service: MovieServiceProtocol, watchlist: WatchlistStore) {
        self.movie = movie
        self.service = service
        self.watchlist = watchlist
    }

    var isInWatchlist: Bool {
        watchlist.contains(movie)
    }

    func toggleWatchlist() {
        watchlist.toggle(movie)
    }

    func load() async {
        state = .loading

        do {
            state = .loaded(try await service.movieDetail(id: movie.id))
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
