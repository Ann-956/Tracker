import UIKit

final class CreateTrackerViewController: UIViewController {
    
    weak var delegate: NewTrackerHabitViewControllerDelegate?

    
    //    MARK: - Private UI elements
    
    private let buttonHabit: UIButton = {
        let button = UIButton()
        button.setTitle("Привычка", for: .normal)
        button.backgroundColor = .ypBlack
        button.setTitleColor(.ypWhite, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16)
        return button
    }()
    
    private let buttonEvent: UIButton = {
        let button = UIButton()
        button.setTitle("Нерегулярное событие", for: .normal)
        button.backgroundColor = .ypBlack
        button.setTitleColor(.ypWhite, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16)
        return button
    }()
    
    //    MARK: - UI stack
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    //  MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ypWhite
        setupView()
        setupConstraints()
        
        title = "Создание трекера"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
        ]
        
        buttonEvent.addTarget(self, action: #selector(createNewEvent), for: .touchUpInside)
        buttonHabit.addTarget(self, action: #selector(createNewHabit), for: .touchUpInside)
    }
    
    //    MARK: - Private Methods setup
    
    private func setupView() {
        [buttonHabit, buttonEvent].forEach{
            buttonStackView.addArrangedSubview($0)
        }
        view.addSubview(buttonStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            buttonHabit.heightAnchor.constraint(equalToConstant: 60),
            buttonEvent.heightAnchor.constraint(equalToConstant: 60),
            
            buttonStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
    }
    
    //    MARK: - Objc Methods
    
    @objc func createNewHabit() {
        let createNewHabitViewController = NewTrackerHabitViewController()
        createNewHabitViewController.delegate = delegate
        navigationController?.pushViewController(createNewHabitViewController, animated: true)
    }

    @objc func createNewEvent() {
        let createNewEventViewController = NewTrackerEventViewController()
        navigationController?.pushViewController(createNewEventViewController, animated: true)
    }
}
