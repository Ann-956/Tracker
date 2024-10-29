import UIKit

final class TrackersViewController: UIViewController, NewTrackerHabitViewControllerDelegate {
    
    //      MARK: - Private variables
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var visibleCategories: [TrackerCategory] = []
    private var currentDate: Date = Date()
    
    //    MARK: - Private UI elements
    
    private lazy var addTrackerButton: UIBarButtonItem = {
        let button = UIBarButtonItem(
            image: UIImage(named: "Pluse"),
            style: .plain,
            target: self,
            action: #selector(addTrackerTapped)
        )
        button.tintColor = .ypBlack
        return button
    }()
    
    private lazy var choiceDate: UIBarButtonItem = {
        let navBarButton = UIBarButtonItem(customView: datePicker)
        return navBarButton
    }()
    
    private let datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.locale = Locale.current
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.date = Date()
        return picker
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Трекеры"
        label.textColor = .ypBlack
        label.font = .boldSystemFont(ofSize: 34)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let searchBar: UISearchController = {
        let searchController = UISearchController()
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.placeholder = "Поиск"
        return searchController
    }()
    
    private let starImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Error")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private let errorLable: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .ypWhite
        
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
    }()
    
    //    MARK: - UI stack
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private let starStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    //    MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        setupNavBar()
        setupView()
        setupConstraints()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseIdentifier)
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)

        updateViewVisibility()
    }
    
    //    MARK: - Private Methods setup
    
    private func setupNavBar() {
        navigationItem.leftBarButtonItem = addTrackerButton
        navigationItem.rightBarButtonItem = choiceDate
    }
    
    private func setupView() {
        [titleLabel, searchBar.searchBar].forEach{
            infoStackView.addArrangedSubview($0)
        }
        [starImage,errorLable].forEach{
            starStackView.addArrangedSubview($0)
        }
        [infoStackView, collectionView, starStackView].forEach{
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            infoStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            infoStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            infoStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            searchBar.searchBar.heightAnchor.constraint(equalToConstant: 36),
            searchBar.searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            searchBar.searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            
            collectionView.topAnchor.constraint(equalTo: infoStackView.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            starStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 66),
        ])
    }
    
    func updateViewVisibility() {
        if visibleCategories.isEmpty {
            starStackView.isHidden = false
            collectionView.isHidden = true
        } else {
            starStackView.isHidden = true
            collectionView.isHidden = false
            collectionView.reloadData()
        }
    }
    
    //    MARK: - Action
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        currentDate = sender.date
        filterTrackersForSelectedDate()
    }
    
    @objc func addTrackerTapped() {
        let createTrackerViewController = CreateTrackerViewController()
        createTrackerViewController.delegate = self
        let navController = UINavigationController(rootViewController: createTrackerViewController)
        present(navController, animated: true, completion: nil)
    }
    
    func didCreateNewTracker(_ tracker: Tracker, categoryName: String) {
        var newCategories = categories

        if let index = newCategories.firstIndex(where: { $0.name == categoryName }) {
            let existingCategory = newCategories[index]
            var updatedTrackers = existingCategory.trackers
            updatedTrackers.append(tracker)
            let updatedCategory = TrackerCategory(name: existingCategory.name, trackers: updatedTrackers)
            newCategories[index] = updatedCategory
        } else {
            let newCategory = TrackerCategory(name: categoryName, trackers: [tracker])
            newCategories.append(newCategory)
        }

        categories = newCategories
        filterTrackersForSelectedDate()
        updateViewVisibility()
    }
    
    func markButtonTapped(at indexPath: IndexPath) {
        let selectedDate = currentDate
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]

        guard Calendar.current.compare(selectedDate, to: Date(), toGranularity: .day) != .orderedDescending else {
            return
        }

        let record = TrackerRecord(trackerId: tracker.id, date: selectedDate)

        if completedTrackers.contains(record) {
            completedTrackers.remove(record)
        } else {
            completedTrackers.insert(record)
        }

        collectionView.reloadItems(at: [indexPath])
    }
    
    private func filterTrackersForSelectedDate() {
        let selectedDate = currentDate
        let calendar = Calendar.current
        let selectedWeekdayNumber = calendar.component(.weekday, from: selectedDate)
        
        guard let selectedWeekday = WeekDay(rawValue: selectedWeekdayNumber) else {
            visibleCategories = []
            collectionView.reloadData()
            updateViewVisibility()
            return
        }
        
        visibleCategories = categories.compactMap { category in
            let trackersForDate = category.trackers.filter { tracker in
                return tracker.schedule.contains(selectedWeekday)
            }
            if trackersForDate.isEmpty {
                return nil
            } else {
                return TrackerCategory(name: category.name, trackers: trackersForDate)
            }
        }
        
        collectionView.reloadData()
        updateViewVisibility()
    }
    
}
//    MARK: - Extention UICollection

extension TrackersViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count

    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? TrackerCell else {
            return UICollectionViewCell()
        }

        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        let selectedDate = currentDate
        let isFutureDate = Calendar.current.compare(selectedDate, to: Date(), toGranularity: .day) == .orderedDescending

        let isCompleted = completedTrackers.contains { record in
            record.trackerId == tracker.id && Calendar.current.isDate(record.date, inSameDayAs: selectedDate)
        }
        let completedDays = completedTrackers.filter { $0.trackerId == tracker.id }.count

        cell.configure(with: tracker, isCompleted: isCompleted, completedDays: completedDays, isFutureDate: isFutureDate)
        cell.markButtonAction = { [weak self] in
            self?.markButtonTapped(at: indexPath)
        }

        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader,
              let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseIdentifier, for: indexPath) as? SectionHeader else {
            return UICollectionReusableView()
        }
        header.titleLabel.text = visibleCategories[indexPath.section].name
        return header
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let interItemSpacing: CGFloat = 7
        let availableWidth = collectionView.bounds.width - interItemSpacing
        let width = availableWidth / 2
        return CGSize(width: width, height: 141)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 0, bottom: 16, right: 0)
    }
}


