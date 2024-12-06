import UIKit
import AppMetricaCore

final class TrackersViewController: UIViewController, NewTrackerHabitViewControllerDelegate, NewTrackerEventViewControllerDelegate, ViewConfigurable  {
    
    // MARK: - Private Variables
    
    private var categories: [TrackerCategory] = []
    private var completedTrackers: Set<TrackerRecord> = []
    private var visibleCategories: [TrackerCategory] = []
    private let trackerStore = TrackerStore.shared
    private let categoryStore = TrackerCategoryStore.shared
    private let recordStore = TrackerRecordStore.shared
    private var currentDate: Date = Date()
    private let userDefaultsSettings = UserDefaultsSettings.shared
    
    private let titlePage = NSLocalizedString("title_main_screen", comment: "")
    private let textSearchPlaceholder = NSLocalizedString("search_placeholder", comment: "")
    private let textEmptyStar = NSLocalizedString("empty_star", comment: "")
    private let textNothingFound = NSLocalizedString("nothing_found", comment: "")
    private let filterButtonText = NSLocalizedString("filter_button", comment: "")
    private let pinnedCategoryName = NSLocalizedString("pinned", comment: "")
    
    // MARK: - Private UI Elements
    
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
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.locale = Locale.current
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.date = Date()
        return picker
    }()
    
    private lazy var searchBar: UISearchController = {
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.backgroundImage = UIImage()
        searchController.searchBar.placeholder = textSearchPlaceholder
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        return searchController
    }()
    
    private lazy var starImage: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .ypWhite
        
        collectionView.showsVerticalScrollIndicator = false
        collectionView.register(TrackerCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseIdentifier)
        return collectionView
    }()
    
    private lazy var filterButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .ypBlue
        button.setTitle(filterButtonText, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17)
        button.setTitleColor(.ypTotalWhite, for: .normal)
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
        return button
    }()
    
    // MARK: - UI Stack
    
    private lazy var starStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        setupNavBar()
        setupView()
        setupConstraints()
        setupInsetCollection()
        additionalSafeAreaInsets.top = 14
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        datePicker.addTarget(self, action: #selector(datePickerValueChanged), for: .valueChanged)
        
        fetchCategories()
        fetchCompletedTrackers()
        userDefaultsSettings.loadPinnedTrackers()
        
        applyFilter()
        updateViewVisibility()
    }
    
    // MARK: - Setup Views
    
    private func setupNavBar() {
        navigationItem.title = titlePage
        navigationItem.leftBarButtonItem = addTrackerButton
        navigationItem.rightBarButtonItem = choiceDate
        navigationItem.searchController = searchBar
        navigationItem.hidesSearchBarWhenScrolling = false
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    func setupView() {
        [starImage, errorLabel].forEach {
            starStackView.addArrangedSubview($0)
        }
        [collectionView, filterButton, starStackView].forEach {
            view.addSubview($0)
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            starStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 66),
            
            filterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filterButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filterButton.heightAnchor.constraint(equalToConstant: 50),
            filterButton.widthAnchor.constraint(equalToConstant: 114),
        ])
    }
    
    private func setupInsetCollection() {
        let filterButtonHeight: CGFloat = 50
        let filterButtonBottomPadding: CGFloat = 16
        let totalBottomInset = filterButtonHeight + filterButtonBottomPadding + 16
        
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: totalBottomInset, right: 0)
        collectionView.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: totalBottomInset, right: 0)
        collectionView.alwaysBounceVertical = true
        collectionView.contentInsetAdjustmentBehavior = .never
    }
    
    // MARK: - Update View Visibility
    
    private func updateViewVisibility() {
        let trackersOnSelectedDate = allTrackersOnSelectedDate()
        
        if trackersOnSelectedDate.isEmpty {
            
            starStackView.isHidden = false
            collectionView.isHidden = true
            filterButton.isHidden = true
            
            errorLabel.text = textEmptyStar
            starImage.image = UIImage(named: "Error")
        } else {
            if visibleCategories.isEmpty {
                
                starStackView.isHidden = false
                collectionView.isHidden = true
                filterButton.isHidden = false
                
                errorLabel.text = textNothingFound
                starImage.image = UIImage(named: "NothingFound")
            } else {
                starStackView.isHidden = true
                collectionView.isHidden = false
                filterButton.isHidden = false
            }
        }
    }
    
    
    // MARK: - Get Core Data
    
    private func fetchCategories() {
        categoryStore.fetchCategories { [weak self] categories in
            DispatchQueue.main.async {
                guard let self = self else { return }
                var filteredCategories = categories.filter { !$0.trackers.isEmpty }
                let allTrackers = filteredCategories.flatMap { $0.trackers }
                let pinnedTrackerList = allTrackers.filter { self.userDefaultsSettings.isPinned(trackerId: $0.id) }
                filteredCategories.removeAll { $0.name == NSLocalizedString("pinned", comment: "") }
                
                for (index, category) in filteredCategories.enumerated() {
                    let trackersWithoutPinned = category.trackers.filter { !self.userDefaultsSettings.isPinned(trackerId: $0.id) }
                    filteredCategories[index] = TrackerCategory(name: category.name, trackers: trackersWithoutPinned)
                }
                filteredCategories = filteredCategories.filter { !$0.trackers.isEmpty }
                
                if !pinnedTrackerList.isEmpty {
                    let pinnedCategory = TrackerCategory(name: NSLocalizedString("pinned", comment: ""), trackers: pinnedTrackerList)
                    filteredCategories.insert(pinnedCategory, at: 0)
                }
                
                self.categories = filteredCategories
                self.applyFilter()
                self.updateViewVisibility()
            }
        }
    }
    
    private func fetchCompletedTrackers() {
        recordStore.fetchRecords { [weak self] records in
            DispatchQueue.main.async {
                self?.completedTrackers = Set(records)
                self?.applyFilter()
                self?.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func datePickerValueChanged(_ sender: UIDatePicker) {
        AppMetrica.reportEvent(name: "DatePickerChanged", parameters: ["selectedDate": sender.date.description])
        currentDate = sender.date
        applyFilter()
    }
    
    @objc private func addTrackerTapped() {
        AppMetrica.reportEvent(name: "AddTrackerTapped", parameters: ["screen": "Trackers"])
        let createTrackerViewController = CreateTrackerViewController()
        createTrackerViewController.delegateHabit = self
        createTrackerViewController.delegateEvent = self
        let navController = UINavigationController(rootViewController: createTrackerViewController)
        present(navController, animated: true, completion: nil)
    }
    
    @objc private func filterButtonTapped() {
        AppMetrica.reportEvent(name: "FilterButtonTapped", parameters: ["screen": "Trackers"])
        
        let filterVC = FilterViewController()
        filterVC.selectedFilter = currentFilter
        filterVC.delegate = self
        let navController = UINavigationController(rootViewController: filterVC)
        navController.modalPresentationStyle = .formSheet
        present(navController, animated: true, completion: nil)
    }
    
    func didCreateNewTracker(_ tracker: Tracker, categoryName: String) {
        fetchCategories()
    }
    
    private func markButtonTapped(at indexPath: IndexPath) {
        let selectedDate = Calendar.current.startOfDay(for: currentDate)
        let today = Calendar.current.startOfDay(for: Date())
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.item]
        
        guard selectedDate <= today else {
            AppMetrica.reportEvent(name: "MarkTrackerFailed", parameters: ["reason": "Future date"])
            return
        }
        
        let record = TrackerRecord(trackerId: tracker.id, date: selectedDate)
        
        if completedTrackers.contains(record) {
            recordStore.deleteRecord(trackerId: tracker.id, date: selectedDate) { [weak self] success in
                if success {
                    self?.completedTrackers.remove(record)
                    AppMetrica.reportEvent(name: "TrackerUnmarked", parameters: ["trackerId": tracker.id.uuidString])
                    DispatchQueue.main.async {
                        self?.collectionView.reloadItems(at: [indexPath])
                    }
                }
            }
        } else {
            recordStore.addRecord(trackerId: tracker.id, date: selectedDate) { [weak self] success in
                if success {
                    self?.completedTrackers.insert(record)
                    AppMetrica.reportEvent(name: "TrackerMarked", parameters: ["trackerId": tracker.id.uuidString])
                    DispatchQueue.main.async {
                        self?.collectionView.reloadItems(at: [indexPath])
                    }
                }
            }
        }
    }
    private func allTrackersOnSelectedDate() -> [Tracker] {
        let selectedDate = currentDate
        let selectedWeekday = WeekDay.from(date: selectedDate)
        
        return categories.flatMap { category in
            if category.name == self.pinnedCategoryName {
                return category.trackers
            } else {
                return category.trackers.filter { tracker in
                    tracker.schedule.contains(selectedWeekday) ||
                    tracker.schedule.contains { day in
                        if case .specificDate(let date) = day {
                            return Calendar.current.isDate(date, inSameDayAs: selectedDate)
                        }
                        return false
                    }
                }
            }
        }
    }


    
    // MARK: - Filtering
    
    private var currentFilter: FilterType {
        get {
            let rawValue = userDefaultsSettings.currentFilterRawValue
            return FilterType(rawValue: rawValue) ?? .all
        }
        set {
            userDefaultsSettings.currentFilterRawValue = newValue.rawValue
        }
    }
    
    private func applyFilter() {
        switch currentFilter {
        case .all:
            filterTrackersForSelectedDate()
        case .today:
            currentDate = Date()
            filterTrackersForSelectedDate()
        case .completed:
            visibleCategories = categories.compactMap { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    completedTrackers.contains { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(name: category.name, trackers: filteredTrackers)
            }
        case .incomplete:
            visibleCategories = categories.compactMap { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    !completedTrackers.contains { $0.trackerId == tracker.id && Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
                }
                return filteredTrackers.isEmpty ? nil : TrackerCategory(name: category.name, trackers: filteredTrackers)
            }
        }
        collectionView.reloadData()
        updateViewVisibility()
    }
    
    private func filterTrackersForSelectedDate() {
        let selectedDate = currentDate
        
        visibleCategories = categories.compactMap { category in
            let trackersForDate = category.trackers.filter { tracker in
                category.name == pinnedCategoryName ||
                tracker.schedule.contains { day in
                    switch day {
                    case .specificDate(let date):
                        return Calendar.current.isDate(date, inSameDayAs: selectedDate)
                    default:
                        return day == WeekDay.from(date: selectedDate)
                    }
                }
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
    
    
    
    
    private func togglePinTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        if userDefaultsSettings.isPinned(trackerId: tracker.id) {
            userDefaultsSettings.removePinnedTracker(id: tracker.id)
            AppMetrica.reportEvent(name: "TrackerUnpinned", parameters: ["trackerId": tracker.id.uuidString])
        } else {
            userDefaultsSettings.addPinnedTracker(id: tracker.id)
            AppMetrica.reportEvent(name: "TrackerPinned", parameters: ["trackerId": tracker.id.uuidString])
        }
        fetchCategories()
        collectionView.reloadData()
    }
    
    
    private func deleteTracker(_ tracker: Tracker, at indexPath: IndexPath) {
        AppMetrica.reportEvent(name: "DeleteTrackerAttempt", parameters: ["trackerId": tracker.id.uuidString])
        trackerStore.deleteTracker(tracker) { [weak self] success in
            guard let self = self else { return }
            if success {
                AppMetrica.reportEvent(name: "DeleteTrackerSuccess", parameters: ["trackerId": tracker.id.uuidString])
                DispatchQueue.main.async {
                    let category = self.visibleCategories[indexPath.section]
                    let updatedTrackers = category.trackers.filter { $0.id != tracker.id }
                    if updatedTrackers.isEmpty {
                        self.visibleCategories.remove(at: indexPath.section)
                    } else {
                        let updatedCategory = TrackerCategory(name: category.name, trackers: updatedTrackers)
                        self.visibleCategories[indexPath.section] = updatedCategory
                    }
                    
                    if self.userDefaultsSettings.isPinned(trackerId: tracker.id) {
                        self.userDefaultsSettings.removePinnedTracker(id: tracker.id)
                    }
                    
                    self.fetchCategories()
                    self.collectionView.reloadData()
                }
            } else {
                AppMetrica.reportEvent(name: "DeleteTrackerFailed", parameters: ["trackerId": tracker.id.uuidString])
                print("Не удалось удалить трекер")
            }
        }
    }
    
    private func editTracker(_ tracker: Tracker) {
        AppMetrica.reportEvent(name: "EditTrackerTapped", parameters: ["trackerId": tracker.id.uuidString])
        let editViewController = NewTrackerHabitViewController()
        editViewController.trackerToEdit = tracker
        editViewController.isEditingTracker = true
        editViewController.delegate = self
        editViewController.title = NSLocalizedString("edit_tracker_title", comment: "")
        navigationController?.pushViewController(editViewController, animated: true)
    }
    
    private func presentEditController(for tracker: Tracker) {
        if tracker.schedule.contains(where: { day in
            if case .specificDate = day { return true }
            return false
        }) {
            guard let specificDate = tracker.schedule.compactMap({ day -> Date? in
                if case .specificDate(let date) = day {
                    return date
                }
                return nil
            }).first else {
                return
            }
            
            let editViewController = NewTrackerEventViewController()
            editViewController.trackerToEdit = tracker
            editViewController.isEditingTracker = true
            editViewController.trackerCreationDate = specificDate
            editViewController.delegate = self
            editViewController.title = NSLocalizedString("edit_tracker_title", comment: "")
            navigationController?.pushViewController(editViewController, animated: true)
        } else {
            editTracker(tracker)
        }
    }

    
    
    func didUpdateTracker(_ tracker: Tracker, categoryName: String) {
        fetchCategories()
    }
    
    private func presentDeleteConfirmation(for tracker: Tracker, at indexPath: IndexPath) {
        let alertController = UIAlertController(title: nil, message: NSLocalizedString("delete_confirmation_message", comment: ""), preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("delete_alert", comment: ""), style: .destructive) { _ in
            self.deleteTracker(tracker, at: indexPath)
        }
        let cancelAction = UIAlertAction(title: NSLocalizedString("cancel_alert", comment: ""), style: .cancel, handler: nil)
        AppMetrica.reportEvent(name: "DeleteTrackerCancelled", parameters: ["trackerId": tracker.id.uuidString])
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        AppMetrica.reportEvent(name: "DeleteTrackerConfirmationPresented", parameters: ["trackerId": tracker.id.uuidString])
        present(alertController, animated: true, completion: nil)
    }
    
}

// MARK: - Extension UICollectionView

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
        
        let isPinned = userDefaultsSettings.isPinned(trackerId: tracker.id)
        
        cell.configure(with: tracker, isCompleted: isCompleted, completedDays: completedDays, isFutureDate: isFutureDate, isPinned: isPinned)
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
        return CGSize(width: collectionView.bounds.width, height: 20)
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
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { _ in
            let tracker = self.visibleCategories[indexPath.section].trackers[indexPath.item]
            
            let isSpecificDate = tracker.schedule.contains { day in
                if case .specificDate = day { return true }
                return false
            }
            
            let editAction = UIAction(title: NSLocalizedString("edit", comment: "")) { _ in
                self.presentEditController(for: tracker)
            }
            
            let deleteAction = UIAction(title: NSLocalizedString("delete", comment: ""), attributes: .destructive) { _ in
                self.presentDeleteConfirmation(for: tracker, at: indexPath)
            }
            
            let pinTitle = self.userDefaultsSettings.isPinned(trackerId: tracker.id) ? NSLocalizedString("unpin", comment: "") : NSLocalizedString("pin", comment: "")
            let pinAction = UIAction(title: pinTitle) { _ in
                self.togglePinTracker(tracker, at: indexPath)
            }
            
            if isSpecificDate {
                return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
            } else {
                return UIMenu(title: "", children: [pinAction, editAction, deleteAction])
            }
            
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        return UITargetedPreview(view: cell.titleStackView, parameters: parameters)
    }
    
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell else {
            return nil
        }
        
        let parameters = UIPreviewParameters()
        parameters.backgroundColor = .clear
        
        return UITargetedPreview(view: cell.titleStackView, parameters: parameters)
    }
}

// MARK: - Extension for UISearchResultsUpdating

extension TrackersViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            visibleCategories = categories.compactMap { category in
                let filteredTrackers = category.trackers.filter { tracker in
                    tracker.name.lowercased().contains(searchText.lowercased())
                }
                if filteredTrackers.isEmpty {
                    return nil
                } else {
                    return TrackerCategory(name: category.name, trackers: filteredTrackers)
                }
            }
            collectionView.reloadData()
            updateViewVisibility()
        } else {
            applyFilter()
        }
    }
}

// MARK: - Extension for FilterSelectionDelegate

extension TrackersViewController: FilterSelectionDelegate {
    func didSelectFilter(_ filter: FilterType) {
        currentFilter = filter
        let filterActive = filter != .all
        filterButton.setTitleColor(filterActive ? .ypRed : .ypTotalWhite, for: .normal)
        applyFilter()
    }
}
