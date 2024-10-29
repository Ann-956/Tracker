import UIKit

protocol NewTrackerHabitViewControllerDelegate: AnyObject {
    func didCreateNewTracker(_ tracker: Tracker, categoryName: String)
}

final class NewTrackerHabitViewController: UIViewController, ScheduleViewControllerDelegate {
    
    // MARK: - Private variables
    
    let dataTableView: [String] = ["Категория", "Расписание"]
    var selectedDays: [WeekDay] = []
    weak var delegate: NewTrackerHabitViewControllerDelegate?
    
    // MARK: - Private UI elements
    
    private let trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.layer.cornerRadius = 16
        textField.font = .systemFont(ofSize: 17)
        textField.backgroundColor = .ypBackground
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = leftPaddingView
        textField.leftViewMode = .always
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.rightView = rightPaddingView
        textField.rightViewMode = .always
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = 75
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.separatorStyle = .singleLine
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private let cancelButton: UIButton = {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("Отменить", for: .normal)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 16
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        return cancelButton
    }()
    
    private let createButton: UIButton = {
        let createButton = UIButton(type: .system)
        createButton.setTitle("Создать", for: .normal)
        createButton.setTitleColor(.ypWhite, for: .normal)
        createButton.backgroundColor = .ypGray
        createButton.layer.cornerRadius = 16
        createButton.translatesAutoresizingMaskIntoConstraints = false
        return createButton
    }()
    
    //    MARK: - UI stack
    
    private let buttonBottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        navigationItem.hidesBackButton = true
        setupUI()
        setupConstraints()
        setupTableView()
        
        title = "Новая привычка"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
        ]
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.heightAnchor.constraint(equalToConstant: tableView.contentSize.height).isActive = true
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        [trackerNameTextField, tableView].forEach{
            view.addSubview($0)
        }
        [cancelButton, createButton].forEach{
            buttonBottomStackView.addArrangedSubview($0)
        }
        view.addSubview(buttonBottomStackView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            trackerNameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            trackerNameTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            trackerNameTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            
            tableView.topAnchor.constraint(equalTo: trackerNameTextField.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            buttonBottomStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0),
            buttonBottomStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            buttonBottomStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            createButton.widthAnchor.constraint(equalToConstant: 164),
            
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.widthAnchor.constraint(equalToConstant: 164),
        ])
    }
    
    private func setupTableView() {
        tableView.register(CellTableHabitController.self, forCellReuseIdentifier: "CellTableHabitController")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func createTapped() {
        guard let trackerName = trackerNameTextField.text, !trackerName.isEmpty else {
            trackerNameTextField.text? = "Введите название трекера"
            return
        }
        let newTracker = Tracker(
            id: UUID(),
            name: trackerName,
            emoji: "🔔",
            color: .red,
            schedule: selectedDays
        )
        delegate?.didCreateNewTracker(newTracker, categoryName: "основная")
        dismiss(animated: true, completion: nil)
        print(newTracker)
    }
}

// MARK: - Extention TableView

extension NewTrackerHabitViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellTableHabitController", for: indexPath) as? CellTableHabitController else {
            return UITableViewCell()
        }
        cell.titleLabel.text = dataTableView[indexPath.row]
        cell.backgroundColor = .ypBackground
        
        if indexPath.row == 1 {
            let allDays = Set(WeekDay.allCases)
            if Set(selectedDays) == allDays {
                cell.detailLabel.text = "Каждый день"
            } else {
                cell.detailLabel.text = selectedDays.sorted(by: { $0.rawValue < $1.rawValue }).map { $0.shortDisplayName }.joined(separator: ", ")
            }
        }
        
        if indexPath.row == dataTableView.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = dataTableView[indexPath.row]
        
        switch selectedItem {
        case "Категория":
            print("категория")
        case "Расписание":
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            scheduleViewController.selectedDays = Set(selectedDays)
            let navController = UINavigationController(rootViewController: scheduleViewController)
            present(navController, animated: true, completion: nil)
        default:
            break
        }
    }
    
    func didSelectDays(_ days: [WeekDay]) {
        self.selectedDays = days
        tableView.reloadData()
    }
}
