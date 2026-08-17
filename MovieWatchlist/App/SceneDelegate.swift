//
//  SceneDelegate.swift
//  MovieWatchlist
//
//  Created by Baturay Koc on 16.08.26.
//

import UIKit

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    private var appCoordinator: AppCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        let coordinator = AppCoordinator(window: window, dependencies: AppDependencies())
        coordinator.start()

        self.window = window
        self.appCoordinator = coordinator
    }
}

@MainActor
struct AppDependencies {
    let movieService: MovieServiceProtocol = MovieService()
    let watchlistStore = WatchlistStore(storage: UserDefaultsWatchlistStorage())
}
