# MovieWatchlist

A two-tab iOS app (Movies / Watchlist) backed by TMDB, built with UIKit navigation + SwiftUI screens, in lightweight MVVM-C.

## Running it

Open MovieWatchlist.xcodeproj, run the MovieWatchlist scheme. iOS 17+. The TMDB token is a plain Swift constant in APIConfig.swift — no setup needed to build and run.

## Folder structure

- App/  -  AppDelegate, SceneDelegate, AppDependencies
- Models/  -  Movie, MoviePage, MovieDetail
- Navigation/  -  Coordinator protocol + AppCoordinator
- Services-Persistance/  -  APIConfig + MovieServiceProtocol + MovieService, APIError, WatchlistStore + WatchlistStorage (UserDefaults)
- ViewModels/  -  MovieDetailViewModel, MovieListViewModel, WatchlistViewModel
- Views/  -  MovieList, MovieDetail, Watchlist

## Architecture

MVVM-C. Views draw, view models hold state and talk to services, coordinators own navigation, AppDependencies builds the real objects once.

## State

ViewState<T> — idle / loading / loaded(T) / failed(String) — one enum instead of separate isLoading/error/data flags, so a spinner and an error can never be on screen together. Views are a switch over it.

## Testability

View models depend on the protocol, never the concrete network/storage type, so tests use hand-written fakes with no network and no real UserDefaults.

Unit tests — the two loading view models, the watchlist store, decoding real TMDB JSON.
UI tests — Movies tab loads real rows; tapping one pushes the detail screen. Proves the coordinators and UIHostingControllers are actually wired together.

## Left out

- Pagination — only page 1 of /movie/popular, with pull-to-refresh.
- Image caching beyond what AsyncImage gives for free.
- Search, sorting, visual polish.
- Moving the token into a more secure place — committed on purpose so this runs straight after a clone; wouldn't be in a real app.
