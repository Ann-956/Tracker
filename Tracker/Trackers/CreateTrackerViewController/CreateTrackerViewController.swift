import UIKit

final class CreateTrackerViewController: UIViewController, ViewConfigurable {
    
    weak var delegateHabit: NewTrackerHabitViewControllerDelegate?
    weak var delegateEvent: NewTrackerEventViewControllerDelegate?
    
    private let titlePage = NSLocalizedString("title_create_tracker", comment: "")
    private let textButtonHabit = NSLocalizedString("text_button_habit", comment: "")
    private let textButtonEvent = NSLocalizedString("text_button_event", comment: "")
    
    
    //    MARK: - Private UI elements
    
    private lazy var buttonHabit: UIButton = {
        let button = UIButton()
        button.setTitle(textButtonHabit, for: .normal)
        button.backgroundColor = .ypBlack
        button.setTitleColor(.ypWhite, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    private lazy var buttonEvent: UIButton = {
        let button = UIButton()
        button.setTitle(textButtonEvent, for: .normal)
        button.backgroundColor = .ypBlack
        button.setTitleColor(.ypWhite, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    //    MARK: - UI stack
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .fill
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    //  MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupView()
        setupConstraints()
        
        title = titlePage
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
        ]
        
        buttonEvent.addTarget(self, action: #selector(createNewEvent), for: .touchUpInside)
        buttonHabit.addTarget(self, action: #selector(createNewHabit), for: .touchUpInside)
    }
    
    //    MARK: - Setup Views
    
    func setupView() {
        [buttonHabit, buttonEvent].forEach{
            buttonStackView.addArrangedSubview($0)
        }
        view.addSubview(buttonStackView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            buttonHabit.heightAnchor.constraint(equalToConstant: 60),
            buttonEvent.heightAnchor.constraint(equalToConstant: 60),
            
            buttonStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    //    MARK: - Objc Methods
    
    @objc private func createNewHabit() {
        let createNewHabitViewController = NewTrackerHabitViewController()
        createNewHabitViewController.delegate = delegateHabit
        navigationController?.pushViewController(createNewHabitViewController, animated: true)
    }
    
    @objc private func createNewEvent() {
        let createNewEventViewController = NewTrackerEventViewController()
        createNewEventViewController.delegate = delegateEvent
        navigationController?.pushViewController(createNewEventViewController, animated: true)
    }
}
