import UIKit

final class MovieQuizPresenter: MovieQuizPresenterProtocol, QuestionFactoryDelegate {
    
    // MARK: - Properties
    private let questionsAmount: Int = 10
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private var isButtonEnabled = true
    
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol!
    
    weak var viewController: MovieQuizViewControllerProtocol?
    var currentQuestion: QuizQuestion?
    
    var isLastQuestion: Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private var questionNumberText: String {
        "\(currentQuestionIndex + 1)/\(questionsAmount)"
    }
    
    // MARK: - Initializer
    init(viewController: MovieQuizViewControllerProtocol? = nil) {
        self.viewController = viewController
        self.statisticService = StatisticService()
        setupQuestionFactory()
    }
    
    // MARK: - Private Methods
    private func setupQuestionFactory() {
        let moviesLoader = MoviesLoader()
        questionFactory = QuestionFactory(moviesLoader: moviesLoader, delegate: self)
    }
    
    private func didAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion, isButtonEnabled else { return }
        isButtonEnabled = false
        let isCorrect = (currentQuestion.correctAnswer == isYes)
        showAnswerResult(isCorrect: isCorrect)
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        viewController?.highlightImageBorder(isCorrect: isCorrect)
        
        if isCorrect {
            correctAnswers += 1
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.viewController?.removeImageBorder()
            self.showNextQuestionOrResults()
            self.isButtonEnabled = true
        }
    }
    
    private func showNextQuestionOrResults() {
        if isLastQuestion {
            let message = makeResultsMessage()
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: message,
                buttonText: "Сыграть ещё раз"
            )
            viewController?.show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func showLoadingIndicator() {
        viewController?.showLoadingIndicator()
    }
    
    private func hideLoadingIndicator() {
        viewController?.hideLoadingIndicator()
    }
    
    // MARK: - MovieQuizPresenterProtocol
    func startLoadingQuestions() {
        showLoadingIndicator()
        questionFactory?.loadData()
    }
    
    func requestNextQuestion() {
        questionFactory?.requestNextQuestion()
    }
    
    func yesButtonClicked() {
        didAnswer(isYes: true)
    }
    
    func noButtonClicked() {
        didAnswer(isYes: false)
    }
    
    func convert(model: QuizQuestion) -> QuizStepViewModel {
        let image = UIImage(data: model.image) ?? UIImage()
        return QuizStepViewModel(
            image: image,
            question: model.text,
            questionNumber: questionNumberText
        )
    }
    
    func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        showLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func makeResultsMessage() -> String {
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        
        let bestGame = statisticService.bestGame
        let totalPlays = statisticService.gamesCount
        let totalAccuracy = String(format: "%.2f", statisticService.totalAccuracy)
        
        let message = """
        Ваш результат: \(correctAnswers)/\(questionsAmount)
        Количество сыгранных квизов: \(totalPlays)
        Рекорд: \(bestGame.correct)/\(bestGame.total) (\(bestGame.date.dateTimeString))
        Средняя точность: \(totalAccuracy)%
        """
        
        return message
    }
    
    // MARK: - QuestionFactoryDelegate
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            viewController?.showNetworkError(message: "Не удалось загрузить вопрос")
            return
        }
        
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.hideLoadingIndicator()
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        hideLoadingIndicator()
        questionFactory?.requestNextQuestion()
    }
    
    func didFailToLoadData(with error: Error) {
        hideLoadingIndicator()
        viewController?.showNetworkError(message: error.localizedDescription)
    }
}
