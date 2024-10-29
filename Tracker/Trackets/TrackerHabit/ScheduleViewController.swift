import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectDays(_ days: [WeekDay])
}

final class ScheduleViewController: UIViewController {
    
    // MARK: - Private variables
    
    var selectedDays: Set<WeekDay> = []
    weak var delegate: ScheduleViewControllerDelegate?
    private let weekDays: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    
    // MARK: - Private UI elements
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.separatorStyle = .singleLine
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private let button: UIButton = {
        let button = UIButton()
        button.setTitle("Готово", for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .ypBlack
        button.setTitleColor(.ypWhite, for: .normal)
        return button
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        title = "Расписание"
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
        ]
        
        button.addTarget(self, action: #selector(doneTapped), for: .touchUpInside)
        
        setupUI()
        setupTableView()
        setupConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.heightAnchor.constraint(equalToConstant: tableView.contentSize.height).isActive = true
    }
    
    // MARK: - Setup UI
    
    private func setupUI() {
        [tableView, button].forEach{
            view.addSubview($0)
        }
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.rowHeight = 75
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            button.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 39),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            button.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Actions
    
    @objc func switchChanged(_ sender: UISwitch) {
        let day = weekDays[sender.tag]
        
        if sender.isOn {
            selectedDays.insert(day)
        } else {
            selectedDays.remove(day)
        }
    }
    
    @objc func doneTapped() {
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
        
        let day = weekDays[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = day.displayName
        cell.backgroundColor = .ypBackground
        
        let switchView = UISwitch(frame: .zero)
        switchView.setOn(selectedDays.contains(day), animated: true)
        switchView.tag = indexPath.row
        switchView.addTarget(
            self,
            action: #selector(switchChanged(_:)),
            for: .valueChanged
        )
        switchView.onTintColor = .ypBlue
        
        if indexPath.row == weekDays.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        }
        
        cell.accessoryView = switchView
        cell.selectionStyle = .none
        
        return cell
    }
}


