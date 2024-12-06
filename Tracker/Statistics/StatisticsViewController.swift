import UIKit

final class StatisticsViewController: UIViewController, ViewConfigurable {
    
    // MARK: - Private Variables
    
    private let trackerRecordStore = TrackerRecordStore.shared
    private let trackerStore = TrackerStore.shared
    private var statistics: [Statistic] = []
    
    private let titlePageStatistic = NSLocalizedString("title_page_statistics", comment: "")
    private let textLableEmpty = NSLocalizedString("statistics_emty_text", comment: "")
    private let bestPeriodTitle = NSLocalizedString("best_period" , comment: "")
    private let perfectDaysTitle = NSLocalizedString("perfect_days", comment: "")
    private let totalCompletedTitle = NSLocalizedString("total_completed", comment: "")
    private let averageCompletionTitle = NSLocalizedString("average_completion", comment: "")
    
    
    // MARK: - UI Elements
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(CellStatisticsTableView.self, forCellReuseIdentifier: CellStatisticsTableView.identifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = .ypWhite
        return tableView
    }()
    
    private lazy var imegeError: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "StatHolder")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var titleLabelError: UILabel = {
        let label = UILabel()
        label.text = textLableEmpty
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private lazy var emptyStateView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 8
        return stackView
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.title = titlePageStatistic
        
        setupView()
        setupConstraints()
        updateViewVisibility()
        loadStatistics()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTrackerRecordDidChange), name: NSNotification.Name("TrackerRecordDidChange"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("TrackerRecordDidChange"), object: nil)
    }
    
    
    // MARK: - Setup
    
    func setupView() {
        
        [imegeError, titleLabelError].forEach{
            emptyStateView.addArrangedSubview($0)
        }
        [tableView, emptyStateView].forEach{
            view.addSubview($0)
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 77),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyStateView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    // MARK: - Data Fetching
    
    private func loadStatistics() {
        trackerRecordStore.fetchRecords { [weak self] records in
            guard let self = self else { return }
            self.trackerStore.fetchTrackers { trackers in
                self.calculateStatistics(records: records, trackers: trackers)
            }
        }
    }
    
    @objc private func handleTrackerRecordDidChange() {
        loadStatistics()
    }
    
    // MARK: - Calculations
    
    private func calculateStatistics(records: [TrackerRecord], trackers: [Tracker]) {
        guard !records.isEmpty else {
            statistics = []
            updateViewVisibility()
            return
        }
        
        let totalCompleted = records.count
        let bestPeriod = calculateBestPeriod(records: records)
        let perfectDays = calculatePerfectDays(records: records, allTrackers: trackers)
        let averageCompletion = calculateAverage(records: records)
        
        statistics = [
            Statistic(value: "\(bestPeriod)", title: bestPeriodTitle),
            Statistic(value: "\(perfectDays)", title: perfectDaysTitle),
            Statistic(value: "\(totalCompleted)", title: totalCompletedTitle),
            Statistic(value: "\(averageCompletion)", title: averageCompletionTitle),
        ]
        
        DispatchQueue.main.async {
            self.updateViewVisibility()
            self.tableView.reloadData()
        }
    }
    
    private func updateViewVisibility() {
        let hasData = !statistics.isEmpty
        tableView.isHidden = !hasData
        emptyStateView.isHidden = hasData
    }
    
    private func calculateBestPeriod(records: [TrackerRecord]) -> Int {
        guard !records.isEmpty else { return 0 }
        
        let sortedDates = records.map { $0.date }.sorted()
        var longestStreak = 0
        var currentStreak = 1
        
        for i in 1..<sortedDates.count {
            let prevDate = sortedDates[i - 1]
            let currentDate = sortedDates[i]
            
            if Calendar.current.isDate(currentDate, inSameDayAs: prevDate.addingTimeInterval(86400)) {
                currentStreak += 1
            } else {
                longestStreak = max(longestStreak, currentStreak)
                currentStreak = 1
            }
        }
        return max(longestStreak, currentStreak)
    }
    
    private func calculatePerfectDays(records: [TrackerRecord], allTrackers: [Tracker]) -> Int {
        guard !records.isEmpty, !allTrackers.isEmpty else { return 0 }
        
        let groupedByDay = Dictionary(grouping: records, by: { Calendar.current.startOfDay(for: $0.date) })
        var perfectDays = 0
        
        for (_, dailyRecords) in groupedByDay {
            let uniqueTrackers = Set(dailyRecords.map { $0.trackerId })
            if uniqueTrackers.count == allTrackers.count {
                perfectDays += 1
            }
        }
        return perfectDays
    }
    
    private func calculateAverage(records: [TrackerRecord]) -> Int {
        guard !records.isEmpty else { return 0 }
        
        let groupedByDay = Dictionary(grouping: records, by: { Calendar.current.startOfDay(for: $0.date) })
        let daysCount = groupedByDay.count
        
        return records.count / daysCount
    }
}

// MARK: - TableView DataSource

extension StatisticsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return statistics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CellStatisticsTableView.identifier, for: indexPath) as? CellStatisticsTableView else {
            return UITableViewCell()
        }
        
        let statistic = statistics[indexPath.row]
        cell.configure(with: statistic)
        return cell
    }
    
}
