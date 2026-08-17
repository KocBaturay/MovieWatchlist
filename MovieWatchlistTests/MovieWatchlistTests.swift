//
//  MovieWatchlistTests.swift
//  MovieWatchlistTests
//
//  Created by Baturay Koc on 16.08.26.
//

import XCTest
@testable import MovieWatchlist

final class MovieWatchlistTests: XCTestCase {
    ///MovieListViewModelTests
    @MainActor
    func testLoadPutsMoviesIntoLoadedState() async {
        let service = MovieServiceStub()
        service.popularResult = .success([.stub(id: 1), .stub(id: 2)])
        let viewModel = MovieListViewModel(service: service)

        await viewModel.load()

        XCTAssertEqual(viewModel.state, .loaded([.stub(id: 1), .stub(id: 2)]))
    }
    
    @MainActor
    func testLoadFailureMovesToFailedStateWithMessage() async {
        let service = MovieServiceStub()
        service.popularResult = .failure(TestError())
        let viewModel = MovieListViewModel(service: service)

        await viewModel.load()

        XCTAssertEqual(viewModel.state, .failed("Something went wrong."))
    }
    
    @MainActor
    func testLoadIfNeededDoesNotRefetchOnceLoaded() async {
        let service = MovieServiceStub()
        service.popularResult = .success([.stub(id: 1)])
        let viewModel = MovieListViewModel(service: service)

        await viewModel.loadIfNeeded()
        await viewModel.loadIfNeeded()

        XCTAssertEqual(service.popularCallCount, 1)
    }
    
    @MainActor
    func testRetryAfterFailureLoadsMovies() async {
        let service = MovieServiceStub()
        service.popularResult = .failure(TestError())
        let viewModel = MovieListViewModel(service: service)
        await viewModel.load()

        service.popularResult = .success([.stub(id: 3)])
        await viewModel.load()

        XCTAssertEqual(viewModel.state.value, [.stub(id: 3)])
    }
    
    ///MovieDetailViewModelTests
    @MainActor private func makeViewModel(
        movie: Movie,
        service: MovieServiceStub,
        store: WatchlistStore
    ) -> MovieDetailViewModel {
        MovieDetailViewModel(movie: movie, service: service, watchlist: store)
    }

    @MainActor private func makeStore() -> WatchlistStore {
        WatchlistStore(storage: InMemoryWatchlistStorage())
    }
    
    @MainActor
    func testLoadPutsDetailIntoLoadedState() async {
        let service = MovieServiceStub()
        service.detailResult = .success(.stub(id: 1, runtime: 145))
        let viewModel = makeViewModel(movie: .stub(id: 1), service: service, store: makeStore())

        await viewModel.load()

        XCTAssertEqual(viewModel.state.value?.runtime, 145)
    }
    
    @MainActor
    func testLoadFailureMovesToFailedState() async {
        let service = MovieServiceStub()
        service.detailResult = .failure(TestError())
        let viewModel = makeViewModel(movie: .stub(id: 1), service: service, store: makeStore())

        await viewModel.load()

        XCTAssertEqual(viewModel.state, .failed("Something went wrong."))
    }
    
    @MainActor
    func testTogglingAddsThenRemovesTheMovie() {
        let store = makeStore()
        let viewModel = makeViewModel(movie: .stub(id: 1), service: MovieServiceStub(), store: store)

        viewModel.toggleWatchlist()
        XCTAssertTrue(viewModel.isInWatchlist)
        XCTAssertEqual(store.movies.count, 1)

        viewModel.toggleWatchlist()
        XCTAssertFalse(viewModel.isInWatchlist)
        XCTAssertTrue(store.movies.isEmpty)
    }
    
    @MainActor
    func testIsInWatchlistReflectsChangesMadeElsewhere() {
        let movie = Movie.stub(id: 42)
        let store = makeStore()
        let viewModel = makeViewModel(movie: movie, service: MovieServiceStub(), store: store)

        XCTAssertFalse(viewModel.isInWatchlist)

        store.add(movie)

        XCTAssertTrue(viewModel.isInWatchlist)
    }
    
    ///MovieDecodingTests
    @MainActor
    func testDecodesPopularResponse() throws {
        let json = """
        {
          "page": 1,
          "results": [
            {
              "id": 1061474,
              "title": "Superman",
              "overview": "Superman must reconcile his heritage.",
              "poster_path": "/ombsmhYUqR4qqOLOxAyr5V8hbyv.jpg",
              "release_date": "2025-07-09",
              "vote_average": 7.324
            }
          ]
        }
        """

        let page = try JSONDecoder().decode(MoviePage.self, from: Data(json.utf8))
        let movie = try XCTUnwrap(page.results.first)

        XCTAssertEqual(movie.id, 1061474)
        XCTAssertEqual(movie.title, "Superman")
        XCTAssertEqual(movie.releaseYear, "2025")
        XCTAssertEqual(
            movie.posterURL?.absoluteString,
            "https://image.tmdb.org/t/p/w342/ombsmhYUqR4qqOLOxAyr5V8hbyv.jpg"
        )
    }
    
    @MainActor
    func testDecodesSparseMovieWithMissingAndEmptyFields() throws {
        let json = """
        { "id": 5, "title": "Sparse", "poster_path": null, "release_date": "" }
        """

        let movie = try JSONDecoder().decode(Movie.self, from: Data(json.utf8))

        XCTAssertNil(movie.posterURL)
        XCTAssertNil(movie.releaseYear)
        XCTAssertNil(movie.overview)
        XCTAssertNil(movie.voteAverage)
    }
    
    ///WatchlistStoreTests
    @MainActor
    func testAddAppendsMovie() {
        let store = WatchlistStore(storage: InMemoryWatchlistStorage())
        store.add(.stub(id: 1))

        XCTAssertEqual(store.movies, [.stub(id: 1)])
        XCTAssertTrue(store.contains(.stub(id: 1)))
    }
    
    @MainActor
    func testRemoveDeletesMovie() {
        let store = WatchlistStore(storage: InMemoryWatchlistStorage())
        store.add(.stub(id: 1))
        store.add(.stub(id: 2))
        store.remove(.stub(id: 1))

        XCTAssertEqual(store.movies, [.stub(id: 2)])
    }
    
    @MainActor
    func testAddingTheSameMovieTwiceKeepsOneCopy() {
        let store = WatchlistStore(storage: InMemoryWatchlistStorage())
        store.add(.stub(id: 1))
        store.add(.stub(id: 1, title: "Same Movie, Different Title"))

        XCTAssertEqual(store.movies.count, 1)
    }
    
    @MainActor
    func testChangesArePersistedAndReloadedOnNextLaunch() {
        let storage = InMemoryWatchlistStorage()
        let store = WatchlistStore(storage: storage)
        store.add(.stub(id: 7))
        let reloaded = WatchlistStore(storage: storage)

        XCTAssertEqual(reloaded.movies, [.stub(id: 7)])
    }
}

@MainActor
final class MovieServiceStub: MovieServiceProtocol {

    var popularResult: Result<[Movie], Error> = .success([])
    var detailResult: Result<MovieDetail, Error> = .success(MovieDetail.stub())

    private(set) var popularCallCount = 0

    func popularMovies() async throws -> [Movie] {
        popularCallCount += 1
        return try popularResult.get()
    }

    func movieDetail(id: Int) async throws -> MovieDetail {
        try detailResult.get()
    }
}

extension Movie {
    static func stub(id: Int, title: String = "A Movie") -> Movie {
        Movie(
            id: id,
            title: title,
            overview: "An overview.",
            posterPath: "/poster.jpg",
            releaseDate: "2025-07-09",
            voteAverage: 7.5
        )
    }
}

extension MovieDetail {
    static func stub(id: Int = 1, runtime: Int? = 130) -> MovieDetail {
        MovieDetail(
            id: id,
            title: "A Movie",
            overview: "An overview.",
            posterPath: "/poster.jpg",
            releaseDate: "2025-07-09",
            voteAverage: 7.5,
            runtime: runtime,
            tagline: "Look up.",
            genres: [MovieDetail.Genre(id: 878, name: "Science Fiction")]
        )
    }
}

struct TestError: Error, LocalizedError {
    var errorDescription: String? { "Something went wrong." }
}

@MainActor
final class InMemoryWatchlistStorage: WatchlistStorage {

    private var movies: [Movie]

    init(movies: [Movie] = []) {
        self.movies = movies
    }

    func load() -> [Movie] { movies }

    func save(_ movies: [Movie]) { self.movies = movies }
}
