import XCTest
@testable import AsyncButton

final class AsyncButtonTests: XCTestCase {
    func testValidDurationIsPreserved() {
        XCTAssertEqual(
            AsyncButtonConfiguration.normalizedDuration(
                0.5,
                minimum: 0,
                fallback: 0.35
            ),
            0.5,
            accuracy: 0.0001
        )
    }

    func testNegativeDurationIsClampedToMinimum() {
        XCTAssertEqual(
            AsyncButtonConfiguration.normalizedDuration(
                -1,
                minimum: 0,
                fallback: 0.35
            ),
            0,
            accuracy: 0.0001
        )
    }

    func testInfiniteDurationUsesFallback() {
        XCTAssertEqual(
            AsyncButtonConfiguration.normalizedDuration(
                .infinity,
                minimum: 0,
                fallback: 0.35
            ),
            0.35,
            accuracy: 0.0001
        )
    }

    func testNaNDurationUsesFallback() {
        XCTAssertEqual(
            AsyncButtonConfiguration.normalizedDuration(
                .nan,
                minimum: 0,
                fallback: 0.7
            ),
            0.7,
            accuracy: 0.0001
        )
    }
}
