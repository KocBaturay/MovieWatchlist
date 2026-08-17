//
//  MovieListViewModel.swift
//  MovieWatchlist
//
//  Created by Baturay Koc on 16.08.26.
//

import Foundation
import Observation

@Observable
@MainActor
final class MovieListViewModel {
    private(set) var state: ViewState<[Movie]> = .idle
    private let service: MovieServiceProtocol

    init(service: MovieServiceProtocol) {
        self.service = service
    }

    func loadIfNeeded() async {
        guard case .idle = state else { return }
        await load()
    }

    func load() async {
        if state.value == nil {
            state = .loading
        }

        do {
            state = .loaded(try await service.popularMovies())
        } catch {
            state = .failed(error.localizedDescription)
        }
    }
}
