import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectDays(_ days: [WeekDay])
}

final class ScheduleViewController: UIViewController, ViewConfigurable {
    
    // MARK: - Private variables
    
    var selectedDays: Set<WeekDay> = []
    weak var delegate: ScheduleViewControllerDelegate?
    private let weekDays: [WeekDay] = {
        let allDays = WeekDay.allCases
        let startIndex = allDays.firstIndex(of: .monday) ?? 0
        let reorderedDays = allDays[startIndex...] + allDays[..<startIndex]
        return Array(reorderedDays)
    }()
    
    // MARK: - Private UI elements
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var button: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .ypBlack
        button.setTitleColor(.ypWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        title = "Расписание"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
        ]
        
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        
        setupView()
        setupTableView()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.heightAnchor.constraint(equalToConstant: tableView.contentSize.height).isActive = true
    }
    
    // MARK: - Setup Views
    
    func setupView() {
        [tableView, button].forEach{
            view.addSubview($0)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CellTableSchedule.self, forCellReuseIdentifier: "DaySwitchCell")
        tableView.rowHeight = 75
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: button.topAnchor, constant: 39),
            
            
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    
    @objc private func switchChanged(_ sender: UISwitch) {
        let day = weekDays[sender.tag]
        
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
    
    @objc private func doneTapped() {
        let sortedDays = selectedDays.sorted { (day1, day2) -> Bool in
            guard let index1 = weekDays.firstIndex(of: day1),
                  let index2 = weekDays.firstIndex(of: day2) else {
                return false
            }
            return index1 < index2
        }
        delegate?.didSelectDays(sortedDays)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Extention TableView

extension ScheduleViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return WeekDay.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DaySwitchCell", for: indexPath) as? CellTableSchedule else {
            fatalError("Не удалось deque DaySwitchCell")
        }
        
        let day = weekDays[indexPath.row]
        let isOn = selectedDays.contains(day)
        
        cell.configure(with: day.displayName, isOn: isOn) { [weak self] isOn in
            guard let self = self else { return }
            if isOn {
                self.selectedDays.insert(day)
            } else {
                self.selectedDays.remove(day)
            }
        }
        if indexPath.row == weekDays.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.clipsToBounds = true
        } else {
            cell.layer.cornerRadius = 0
            cell.clipsToBounds = false
        }
        
        return cell
    }
}


