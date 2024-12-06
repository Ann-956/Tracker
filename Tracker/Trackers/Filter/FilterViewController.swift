import UIKit

final class FilterViewController: UIViewController, ViewConfigurable {
    
    // MARK: - Private variables
    
    weak var delegate: FilterSelectionDelegate?
    var selectedFilter: FilterType = .all
    private let themeManager = ThemeManager.shared
    
    //    MARK: - Private UI elements
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.layer.masksToBounds = true
        tableView.separatorStyle = .singleLine
        tableView.separatorColor = themeManager.separatorColor
        tableView.rowHeight = 75
        tableView.isScrollEnabled = true
        return tableView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("title_filter_page", comment: "")
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
        ]
        
        view.backgroundColor = .ypWhite
        
        setupView()
        setupConstraints()
        setupTableView()
    }
    
    // MARK: - Setup Views
    
    func setupView() {
        view.addSubview(tableView)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CellFilterTable.self, forCellReuseIdentifier: "FilterTableViewCell")
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 1))
    }
}

// MARK: - Extension TableView

extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return FilterType.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FilterTableViewCell", for: indexPath) as? CellFilterTable else {
            fatalError("Не удалось dequeFilterTableViewCell")
        }
        
        let filter = FilterType.allCases[indexPath.row]
        let isSelected = filter.title == selectedFilter.title
        cell.configure(with: filter.title, isSelected: isSelected)
        
        if indexPath.row == FilterType.allCases.count - 1 {
            cell.layer.cornerRadius = 16
            cell.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            cell.clipsToBounds = true
        } else {
            cell.layer.cornerRadius = 0
            cell.clipsToBounds = false
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let filter = FilterType(rawValue: indexPath.row) else { return }
        selectedFilter = filter
        delegate?.didSelectFilter(filter)
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = (indexPath.row == FilterType.allCases.count - 1)
        ? UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
        : UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
}

