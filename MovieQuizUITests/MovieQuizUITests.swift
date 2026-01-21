import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UITesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app.terminate()
        app = nil
        
        try super.tearDownWithError()
    }

    // Тест 1: Кнопка "Да" меняет вопрос
    func testYesButton() {
        // Ждем загрузки
        sleep(3)
        
        // Проверяем существование элементов
        let poster = app.images["Poster"]
        XCTAssertTrue(poster.waitForExistence(timeout: 5), "Постер не найден")
        
        let yesButton = app.buttons["Yes"]
        XCTAssertTrue(yesButton.waitForExistence(timeout: 5), "Кнопка 'Yes' не найдена")
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5), "Label 'Index' не найден")
        
        // Запоминаем начальное состояние
        let firstPosterData = poster.screenshot().pngRepresentation
        let initialIndex = indexLabel.label
        
        // Нажимаем кнопку "Да"
        yesButton.tap()
        sleep(3)
        
        // Проверяем изменения
        let secondPosterData = poster.screenshot().pngRepresentation
        let newIndex = indexLabel.label
        
        XCTAssertNotEqual(firstPosterData, secondPosterData, "Постер должен измениться")
        XCTAssertNotEqual(newIndex, initialIndex, "Индекс должен измениться")
        XCTAssertEqual(newIndex, "2/10", "После первого ответа должно быть 2/10")
    }
    
    // Тест 2: Кнопка "Нет" меняет вопрос
    func testNoButton() {
        sleep(3)
        
        let poster = app.images["Poster"]
        XCTAssertTrue(poster.waitForExistence(timeout: 5))
        
        let noButton = app.buttons["No"]
        XCTAssertTrue(noButton.waitForExistence(timeout: 5))
        
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5))
        
        let firstPosterData = poster.screenshot().pngRepresentation
        let initialIndex = indexLabel.label
        
        noButton.tap()
        sleep(3)
        
        let secondPosterData = poster.screenshot().pngRepresentation
        let newIndex = indexLabel.label
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertNotEqual(newIndex, initialIndex)
        XCTAssertEqual(newIndex, "2/10")
    }
    
    // Тест 3: Появление алерта после раунда
    func testGameFinish() {
        sleep(2)
        
        let noButton = app.buttons["No"]
        XCTAssertTrue(noButton.waitForExistence(timeout: 5))
        
        // Отвечаем на 10 вопросов
        for i in 1...10 {
            noButton.tap()
            sleep(2)
            
            // Можно проверить прогресс
            if i < 10 {
                let indexLabel = app.staticTexts["Index"]
                XCTAssertEqual(indexLabel.label, "\(i+1)/10", "После \(i)-го вопроса должно быть \(i+1)/10")
            }
        }

        // Проверяем алерт
        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5), "Алерт не появился")
        
        XCTAssertEqual(alert.label, "Этот раунд окончен!", "Неверный заголовок алерта")
        
        let playAgainButton = alert.buttons["Сыграть ещё раз"]
        XCTAssertTrue(playAgainButton.exists, "Кнопка 'Сыграть ещё раз' не найдена")
    }

    // Тест 4: Скрытие алерта и перезапуск игры
    func testAlertDismiss() {
        sleep(2)
        
        let noButton = app.buttons["No"]
        XCTAssertTrue(noButton.waitForExistence(timeout: 5))
        
        // Проходим раунд
        for _ in 1...10 {
            noButton.tap()
            sleep(2)
        }
        
        // Нажимаем кнопку в алерте
        let alert = app.alerts["Этот раунд окончен!"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))
        
        let playAgainButton = alert.buttons["Сыграть ещё раз"]
        playAgainButton.tap()
        
        sleep(2)
        
        // Проверяем сброс игры
        let indexLabel = app.staticTexts["Index"]
        XCTAssertTrue(indexLabel.waitForExistence(timeout: 5))
        
        XCTAssertFalse(alert.exists, "Алерт должен скрыться после нажатия")
        XCTAssertEqual(indexLabel.label, "1/10", "Игра должна перезапуститься с 1/10")
    }
}
