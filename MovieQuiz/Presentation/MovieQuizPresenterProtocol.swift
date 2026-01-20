import UIKit

protocol MovieQuizPresenterProtocol: AnyObject {
    var viewController: MovieQuizViewControllerProtocol? { get set }
    var currentQuestion: QuizQuestion? { get set }
    var isLastQuestion: Bool { get }
    
    func yesButtonClicked()
    func noButtonClicked()
    func convert(model: QuizQuestion) -> QuizStepViewModel
    func restartGame()
    
    func startLoadingQuestions()
    func requestNextQuestion()
    func makeResultsMessage() -> String
}
