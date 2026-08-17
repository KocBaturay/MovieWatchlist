//
//  WatchlistView.swift
//  MovieWatchlist
//
//  Created by Baturay Koc on 16.08.26.
//

import SwiftUI

struct WatchlistView: View {
    let viewModel: WatchlistViewModel
    let onSelectMovie: (Movie) -> Void
    var body: some View {
        if viewModel.movies.isEmpty {
            ContentUnavailableView(
                "Nothing saved yet",
                systemImage: "bookmark",
                description: Text("Movies you add from a movie's details show up here.")
            )
        } else {
            List {
                ForEach(viewModel.movies) { movie in
                    Button {
                        onSelectMovie(movie)
                    } label: {
                        MovieRow(movie: movie)
                    }
                    .buttonStyle(.plain)
                }
                .onDelete(perform: viewModel.remove)
            }
            .listStyle(.plain)
        }
    }
}
