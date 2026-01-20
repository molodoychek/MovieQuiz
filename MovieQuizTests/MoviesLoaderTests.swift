import Testing
@testable import MovieQuiz

struct MoviesLoaderTests {
    
    // Простой тест без сложных заглушек
    @Test func testLoaderInitialization() {
        // Просто проверяем, что можем создать загрузчик
        let loader = MoviesLoader()
        #expect(loader != nil)
    }
    
    // Тест с моковыми данными
    @Test func testWithMockData() async throws {
        // Создаем простую заглушку прямо в тесте
        struct MockNetworkClient: NetworkRouting {
            func fetch(url: URL, handler: @escaping (Result<Data, Error>) -> Void) {
                let testData = """
                {
                    "errorMessage": "",
                    "items": [
                        {
                            "id": "tt123",
                            "title": "Test Movie",
                            "imDbRating": "8.5",
                            "image": "https://example.com/test.jpg"
                        }
                    ]
                }
                """.data(using: .utf8)!
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    handler(.success(testData))
                }
            }
        }
        
        let loader = MoviesLoader(networkClient: MockNetworkClient())
        let expectation = Expectation()
        var resultCount = 0
        
        loader.loadMovies { result in
            if case .success(let movies) = result {
                resultCount = movies.items.count
            }
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
        #expect(resultCount == 1)
    }
}
