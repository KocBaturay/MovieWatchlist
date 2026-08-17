//
//  MovieDetailView.swift
//  MovieWatchlist
//
//  Created by Baturay Koc on 16.08.26.
//

import SwiftUI

struct MovieDetailView: View {
    let viewModel: MovieDetailViewModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                header

                Button(viewModel.isInWatchlist ? "Remove from Watchlist" : "Add to Watchlist") {
                    viewModel.toggleWatchlist()
                }
                .buttonStyle(.borderedProminent)

                Divider()

                switch viewModel.state {
                case .idle, .loading:
                    ProgressView()
                        .frame(maxWidth: .infinity)

                case .loaded(let detail):
                    details(detail)

                case .failed(let message):
                    VStack(alignment: .leading, spacing: 12) {
                        Text(message)
                            .foregroundStyle(.secondary)
                        Button("Try Again") {
                            Task { await viewModel.load() }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .task { await viewModel.load() }
    }

    private var header: some View {
        HStack(alignment: .top, spacing: 16) {
            AsyncImage(url: viewModel.movie.posterURL) { image in
                image.resizable().aspectRatio(contentMode: .fill)
            } placeholder: {
                Color.secondary.opacity(0.15)
            }
            .frame(width: 100, height: 150)
            .clipShape(RoundedRectangle(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 6) {
                Text(viewModel.movie.title)
                    .font(.title2.bold())
                if let year = viewModel.movie.releaseYear {
                    Text(year).foregroundStyle(.secondary)
                }
                if let rating = viewModel.movie.voteAverage {
                    Text(String(format: "★ %.1f", rating)).foregroundStyle(.secondary)
                }
            }
        }
    }

    @ViewBuilder
    private func details(_ detail: MovieDetail) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            if let tagline = detail.tagline, !tagline.isEmpty {
                Text(tagline).font(.subheadline.italic())
            }
            if let genres = detail.genreNames {
                Text(genres).font(.subheadline).foregroundStyle(.secondary)
            }
            if let runtime = detail.runtime {
                Text("\(runtime) min").font(.subheadline).foregroundStyle(.secondary)
            }
            if let overview = detail.overview, !overview.isEmpty {
                Text(overview).font(.body)
            }
        }
    }
}
