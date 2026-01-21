import XCTest
@testable import MovieQuiz

class NetworkClientMock: NetworkRouting {
    enum TestScenario {
        case success(Data)
        case failure(Error)
    }
    
    let scenario: TestScenario
    
    init(scenario: TestScenario) {
        self.scenario = scenario
    }
    
    func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
            switch self.scenario {
            case .success(let data):
                handler(.success(data))
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}

final class MoviesLoaderTests: XCTestCase {
    
    func testSuccessLoading() {
        // Given
        let jsonData = """
        {
            "errorMessage": "",
            "items": [
                {
                    "fullTitle": "The Godfather (1972)",
                    "imDbRating": "9.2",
                    "image": "https://m.media-amazon.com/images/M/MV5BM2MyNjYxNmUtYTAwNi00MTYxLWJmNWYtYzZlODY3ZTk3OTFlXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_UX128_CR0,1,128,176_AL_.jpg"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let networkClient = NetworkClientMock(scenario: .success(jsonData))
        let loader = MoviesLoader(networkClient: networkClient)
        
        // When
        let expectation = expectation(description: "Loading expectation")
        
        var result: Result<MostPopularMovies, Error>?
        
        loader.loadMovies { response in
            result = response
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 2.0)
        
        guard case .success(let movies) = result else {
            XCTFail("Expected success but got failure")
            return
        }
        
        XCTAssertEqual(movies.items.count, 1)
        
        let movie = movies.items.first!
        XCTAssertEqual(movie.title, "The Godfather (1972)")
        XCTAssertEqual(movie.rating, "9.2")
        XCTAssertEqual(movie.imageURL.absoluteString, "https://m.media-amazon.com/images/M/MV5BM2MyNjYxNmUtYTAwNi00MTYxLWJmNWYtYzZlODY3ZTk3OTFlXkEyXkFqcGdeQXVyNzkwMjQ5NzM@._V1_UX128_CR0,1,128,176_AL_.jpg")
        
        // Проверяем resizedImageURL
        let resizedURLString = movie.resizedImageURL.absoluteString
        XCTAssertTrue(resizedURLString.contains("._V0_UX600_.jpg"))
        XCTAssertFalse(resizedURLString.contains("._V1_UX128_CR0,1,128,176_AL_.jpg"))
    }
    
    func testFailureLoading() {
        // Given
        let expectedError = NSError(
            domain: "test",
            code: 404,
            userInfo: [NSLocalizedDescriptionKey: "Not Found"]
        )
        
        let networkClient = NetworkClientMock(scenario: .failure(expectedError))
        let loader = MoviesLoader(networkClient: networkClient)
        
        // When
        let expectation = expectation(description: "Loading expectation")
        
        var result: Result<MostPopularMovies, Error>?
        
        loader.loadMovies { response in
            result = response
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 2.0)
        
        guard case .failure(let error) = result else {
            XCTFail("Expected failure but got success")
            return
        }
        
        XCTAssertEqual(error.localizedDescription, "Not Found")
    }
    
    func testEmptyMoviesList() {
        // Given
        let jsonData = """
        {
            "errorMessage": "",
            "items": []
        }
        """.data(using: .utf8)!
        
        let networkClient = NetworkClientMock(scenario: .success(jsonData))
        let loader = MoviesLoader(networkClient: networkClient)
        
        // When
        let expectation = expectation(description: "Loading expectation")
        
        var result: Result<MostPopularMovies, Error>?
        
        loader.loadMovies { response in
            result = response
            expectation.fulfill()
        }
        
        // Then
        waitForExpectations(timeout: 2.0)
        
        guard case .success(let movies) = result else {
            XCTFail("Expected success but got failure")
            return
        }
        
        XCTAssertTrue(movies.items.isEmpty)
    }
    
    // Упрощенный тест для отладки
    func testSimpleSuccess() {
        let jsonData = """
        {
            "errorMessage": "",
            "items": [
                {
                    "fullTitle": "Simple Test Movie",
                    "imDbRating": "7.5",
                    "image": "https://simple.test/poster.jpg"
                }
            ]
        }
        """.data(using: .utf8)!
        
        let networkClient = NetworkClientMock(scenario: .success(jsonData))
        let loader = MoviesLoader(networkClient: networkClient)
        
        let expectation = expectation(description: "Simple test")
        
        loader.loadMovies { result in
            switch result {
            case .success(let movies):
                XCTAssertEqual(movies.items.count, 1)
                XCTAssertEqual(movies.items.first?.title, "Simple Test Movie")
            case .failure:
                XCTFail("Should succeed")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 2.0)
    }
}
