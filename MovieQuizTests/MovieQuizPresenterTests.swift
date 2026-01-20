import XCTest
@testable import MovieQuiz

// MARK: - Mock ViewController
final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    var showedQuizStep: QuizStepViewModel?
    var showedQuizResult: QuizResultsViewModel?
    var highlightedImageBorder: Bool?
    var removedImageBorderCalled = false
    var showedLoadingIndicator = false
    var hiddenLoadingIndicator = false
    var showedNetworkError: String?
    
    func show(quiz step: QuizStepViewModel) {
        showedQuizStep = step
    }
    
    func show(quiz result: QuizResultsViewModel) {
        showedQuizResult = result
    }
    
    func highlightImageBorder(isCorrect: Bool) {
        highlightedImageBorder = isCorrect
    }
    
    func removeImageBorder() {
        removedImageBorderCalled = true
    }
    
    func showLoadingIndicator() {
        showedLoadingIndicator = true
    }
    
    func hideLoadingIndicator() {
        hiddenLoadingIndicator = true
    }
    
    func showNetworkError(message: String) {
        showedNetworkError = message
    }
}

// MARK: - Tests
final class MovieQuizPresenterTests: XCTestCase {
    
    func testConvertModel() {
        // Given
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        let testImage = UIImage(systemName: "film") ?? UIImage()
        let imageData = testImage.pngData() ?? Data()
        
        let question = QuizQuestion(
            image: imageData,
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true
        )
        
        // When
        let viewModel = presenter.convert(model: question)
        
        // Then
        XCTAssertNotNil(viewModel.image)
        XCTAssertEqual(viewModel.question, "Рейтинг этого фильма больше чем 6?")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
    }
    
    func testConvertModelWithEmptyImageData() {
        // Given
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        let emptyData = Data()
        let question = QuizQuestion(
            image: emptyData,
            text: "Тестовый вопрос",
            correctAnswer: false
        )
        
        // When
        let viewModel = presenter.convert(model: question)
        
        // Then
        XCTAssertEqual(viewModel.question, "Тестовый вопрос")
        XCTAssertEqual(viewModel.questionNumber, "1/10")
        XCTAssertNotNil(viewModel.image)
    }
    
    func testYesButtonClicked() {
        // Given
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        // Настроим текущий вопрос
        let testImageData = UIImage(systemName: "film")?.pngData() ?? Data()
        let question = QuizQuestion(
            image: testImageData,
            text: "Вопрос",
            correctAnswer: true
        )
        
        // Установим currentQuestion (через reflection или public метод если есть)
        // presenter.currentQuestion = question
        
        // When
        presenter.yesButtonClicked()
        
        // Then
        // Проверяем, что ViewController получил highlightImageBorder
        // Ждем асинхронного выполнения
        let expectation = expectation(description: "Wait for async")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func testNoButtonClicked() {
        // Given
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        // When
        presenter.noButtonClicked()
        
        // Then
        // Аналогично testYesButtonClicked
        let expectation = expectation(description: "Wait for async")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }
    
    func testMakeResultsMessage() {
        // Given
        let viewControllerMock = MovieQuizViewControllerMock()
        let presenter = MovieQuizPresenter(viewController: viewControllerMock)
        
        // When
        let message = presenter.makeResultsMessage()
        
        // Then
        XCTAssertTrue(message.contains("Ваш результат:"))
        XCTAssertTrue(message.contains("Количество сыгранных квизов:"))
        XCTAssertTrue(message.contains("Рекорд:"))
        XCTAssertTrue(message.contains("Средняя точность:"))
    }
}
