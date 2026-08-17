//
//  AppCoordinator.swift
//  MovieWatchlist
//
//  Created by Baturay Koc on 16.08.26.
//

import SwiftUI
import UIKit

@MainActor
final class AppCoordinator {
    private let window: UIWindow
    private let dependencies: AppDependencies
    private var children: [Coordinator] = []

    init(window: UIWindow, dependencies: AppDependencies) {
        self.window = window
        self.dependencies = dependencies
    }

    func start() {
        let coordinators: [Coordinator] = [
            MoviesCoordinator(dependencies: dependencies),
            WatchlistCoordinator(dependencies: dependencies)
        ]
        coordinators.forEach { $0.start() }
        children = coordinators

        let tabBarController = UITabBarController()
        tabBarController.viewControllers = coordinators.map(\.navigationController)

        window.rootViewController = tabBarController
        window.makeKeyAndVisible()
    }
}

final class MoviesCoordinator: Coordinator {
    let navigationController = UINavigationController()
    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    func start() {
        let viewModel = MovieListViewModel(service: dependencies.movieService)
        let rootView = MovieListView(viewModel: viewModel) { [weak self] movie in
            guard let self else { return }
            showMovieDetail(movie, dependencies: dependencies)
        }

        let rootController = UIHostingController(rootView: rootView)
        rootController.title = "Movies"

        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.setViewControllers([rootController], animated: false)
        navigationController.tabBarItem = UITabBarItem(
            title: "Movies",
            image: UIImage(systemName: "film"),
            tag: 0
        )
    }
}

final class WatchlistCoordinator: Coordinator {
    let navigationController = UINavigationController()
    private let dependencies: AppDependencies

    init(dependencies: AppDependencies) {
        self.dependencies = dependencies
    }

    func start() {
        let viewModel = WatchlistViewModel(watchlist: dependencies.watchlistStore)
        let rootView = WatchlistView(viewModel: viewModel) { [weak self] movie in
            guard let self else { return }
            showMovieDetail(movie, dependencies: dependencies)
        }

        let rootController = UIHostingController(rootView: rootView)
        rootController.title = "Watchlist"

        navigationController.navigationBar.prefersLargeTitles = true
        navigationController.setViewControllers([rootController], animated: false)
        navigationController.tabBarItem = UITabBarItem(
            title: "Watchlist",
            image: UIImage(systemName: "bookmark"),
            tag: 1
        )
    }
}
