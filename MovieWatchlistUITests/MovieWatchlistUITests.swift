//
//  MovieWatchlistUITests.swift
//  MovieWatchlistUITests
//
//  Created by Baturay Koc on 16.08.26.
//

import XCTest

final class MovieWatchlistUITests: XCTestCase {
    
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    func testMoviesTabLoadsRealMovies() {
        XCTAssertTrue(
            app.cells.firstMatch.waitForExistence(timeout: 20),
            "The Movies tab should load a list of rows from TMDB."
        )
    }

    func testSelectingAMovieOpensItsDetailScreen() {
        let firstRow = app.cells.firstMatch
        XCTAssertTrue(firstRow.waitForExistence(timeout: 20))

        firstRow.tap()

        let watchlistButton = app.buttons.matching(
            NSPredicate(format: "label CONTAINS 'Watchlist'")
        ).firstMatch
        XCTAssertTrue(
            watchlistButton.waitForExistence(timeout: 5),
            "Tapping a movie should push the detail screen with its watchlist button."
        )
    }
}
