//
//  WatchlistViewModel.swift
//  MovieWatchlist
//
//  Created by Baturay Koc on 16.08.26.
//

import Foundation
import Observation

@Observable
@MainActor
final class WatchlistViewModel {
    private let watchlist: WatchlistStore

    init(watchlist: WatchlistStore) {
        self.watchlist = watchlist
    }

    var movies: [Movie] {
        watchlist.movies
    }

    func remove(at offsets: IndexSet) {
        for movie in offsets.map({ movies[$0] }) {
            watchlist.remove(movie)
        }
    }
}
