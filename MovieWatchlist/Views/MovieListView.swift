//
//  MovieListView.swift
//  MovieWatchlist
//
//  Created by Baturay Koc on 16.08.26.
//

import SwiftUI

struct MovieListView: View {
    let viewModel: MovieListViewModel
    let onSelectMovie: (Movie) -> Void
    var body: some View {
        Group {
            switch viewModel.state {
            case .idle, .loading:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

            case .loaded(let movies):
                List(movies) { movie in
                    Button {
                        onSelectMovie(movie)
                    } label: {
                        MovieRow(movie: movie)
                    }
                    .buttonStyle(.plain)
                }
                .listStyle(.plain)
                .refreshable { await viewModel.load() }

            case .failed(let message):
                VStack(spacing: 12) {
                    Text(message)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                    Button("Try Again") {
                        Task { await viewModel.load() }
                    }
                }
                .padding()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task { await viewModel.loadIfNeeded() }
    }
}
