//
//  Coordinator.swift
//  MovieWatchlist
//
//  Created by Baturay Koc on 16.08.26.
//

import SwiftUI
import UIKit

@MainActor
protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get }
    func start()
}

extension Coordinator {
    func showMovieDetail(_ movie: Movie, dependencies: AppDependencies) {
        let viewModel = MovieDetailViewModel(
            movie: movie,
            service: dependencies.movieService,
            watchlist: dependencies.watchlistStore
        )
        let detailController = UIHostingController(rootView: MovieDetailView(viewModel: viewModel))
        detailController.title = movie.title
        navigationController.pushViewController(detailController, animated: true)
    }
}
