import UIKit

protocol NewTrackerEventViewControllerDelegate: AnyObject {
    func didCreateNewTracker(_ tracker: Tracker, categoryName: String)
    func didUpdateTracker(_ tracker: Tracker, categoryName: String)
}

final class NewTrackerEventViewController: UIViewController, ViewConfigurable, CategorySelectionDelegate {
    
    // MARK: - Private Variables
    
    private let dataTableView: [TrackerDataType] = [.category]
    private let colorData: [UIColor] = [.sel1, .sel2, .sel3, .sel4, .sel5, .sel6, .sel7, .sel8, .sel9, .sel10, .sel11, .sel12, .sel13, .sel14, .sel15, .sel16, .sel17, .sel18]
    private let emojiData: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    weak var delegate: NewTrackerEventViewControllerDelegate?
    let irregularEventSchedule: [WeekDay] = [.specificDate(Date())]
    
    private var selectedEmoji: String? {
        didSet { updateCreateButtonState() }
    }
    private var selectedColor: UIColor? {
        didSet { updateCreateButtonState() }
    }
    private var selectedCategory: TrackerCategory? {
        didSet { updateCreateButtonState() }
    }
    
    var isEditingTracker: Bool = false
    var trackerToEdit: Tracker?
    var trackerCreationDate: Date = Calendar.current.startOfDay(for: Date())
    
    private let trackerStore = TrackerStore.shared
    private let themeManager = ThemeManager.shared
    
    private let textFieldPlaceholder = NSLocalizedString("tracker_name_text_field", comment: "")
    private let textErrorLabelField = NSLocalizedString("error_label_text_field", comment: "")
    private let textCancelButton = NSLocalizedString("cancel_button", comment: "")
    private let textCreateButton = NSLocalizedString("create_button", comment: "")
    private let titleEmoji = NSLocalizedString("emoji_title", comment: "")
    private let titleColor = NSLocalizedString("color_title", comment: "")
    
    
    // MARK: - Private UI
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var trackerNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = textFieldPlaceholder
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
        textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        return textField
    }()
    
    private lazy var errorLabelTextField: UILabel = {
        let label = UILabel()
        label.textColor = .ypRed
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.isHidden = true
        label.text = textErrorLabelField
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.layer.cornerRadius = 16
        tableView.rowHeight = 75
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private lazy var collectionColorView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .ypWhite
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var collectionEmojiView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .ypWhite
        collectionView.isScrollEnabled = false
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle(textCancelButton, for: .normal)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.cornerRadius = 16
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        return cancelButton
    }()
    
    private lazy var createButton: UIButton = {
        let createButton = UIButton(type: .system)
        createButton.setTitle(textCreateButton, for: .normal)
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.layer.cornerRadius = 16
        createButton.setTitleColor(.ypTotalWhite, for: .normal)
        createButton.backgroundColor = .ypGray
        createButton.translatesAutoresizingMaskIntoConstraints = false
        createButton.isEnabled = false
        return createButton
    }()
    
    // MARK: - UI Stack
    
    private lazy var textFieldStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var buttonBottomStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var daysStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 40
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        navigationItem.hidesBackButton = true
        setupView()
        setupConstraints()
        setupCollectionView()
        setupTableView()
        
        collectionColorView.reloadData()
        collectionEmojiView.reloadData()
        
        
        if isEditingTracker {
            populateDataForEditing()
            title = NSLocalizedString("title_edit_event_page", comment: "")
        } else {
            title =  NSLocalizedString("title_event_page", comment: "")
        }
        
        navigationItem.largeTitleDisplayMode = .never
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
        ]
        createButton.addTarget(self, action: #selector(createTapped), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        
        trackerNameTextField.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.heightAnchor.constraint(equalToConstant: tableView.contentSize.height).isActive = true
        updateCollectionViewHeights()
    }
    
    
    // MARK: - Setup Views
    
    func setupView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        [trackerNameTextField, errorLabelTextField].forEach {
            textFieldStackView.addArrangedSubview($0)
        }
        
        [textFieldStackView, tableView, collectionEmojiView, collectionColorView, buttonBottomStackView].forEach {
            contentView.addSubview($0)
        }
        
        [cancelButton, createButton].forEach {
            buttonBottomStackView.addArrangedSubview($0)
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            
            trackerNameTextField.heightAnchor.constraint(equalToConstant: 75),
            textFieldStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            textFieldStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textFieldStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            tableView.topAnchor.constraint(equalTo: textFieldStackView.bottomAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            collectionEmojiView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            collectionEmojiView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            collectionEmojiView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            
            collectionColorView.topAnchor.constraint(equalTo: collectionEmojiView.bottomAnchor, constant: 16),
            collectionColorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 18),
            collectionColorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -18),
            
            buttonBottomStackView.topAnchor.constraint(equalTo: collectionColorView.bottomAnchor, constant: 16),
            buttonBottomStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            buttonBottomStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            buttonBottomStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            createButton.heightAnchor.constraint(equalToConstant: 60),
            cancelButton.heightAnchor.constraint(equalToConstant: 60),
            
            cancelButton.widthAnchor.constraint(equalToConstant: (view.frame.width / 2) - 30),
            createButton.widthAnchor.constraint(equalToConstant: (view.frame.width / 2) - 30),
            
            
        ])
    }
    
    private func setupTableView() {
        tableView.register(CellTableHabitController.self, forCellReuseIdentifier: "CellTableHabitController")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupCollectionView() {
        collectionColorView.delegate = self
        collectionColorView.dataSource = self
        collectionColorView.register(HeaderColor.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderColor.reuseIdentifier)
        collectionColorView.register(CellColorCollection.self, forCellWithReuseIdentifier: "CellColor")
        
        collectionEmojiView.delegate = self
        collectionEmojiView.dataSource = self
        collectionEmojiView.register(HeaderEmoji.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HeaderEmoji.reuseIdentifier)
        collectionEmojiView.register(CellEmojiCollection.self, forCellWithReuseIdentifier: "CellEmoji")
    }
    
    // MARK: - Actions
    
    @objc private func cancelTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func createTapped() {
        guard let trackerName = trackerNameTextField.text, !trackerName.isEmpty,
              let emoji = selectedEmoji,
              let color = selectedColor,
              let categoryName = selectedCategory?.name else {
            return
        }
        
        if isEditingTracker, let trackerToEdit = trackerToEdit {
            trackerStore.updateTracker(
                trackerToEdit,
                name: trackerName,
                emoji: emoji,
                color: color,
                schedule: trackerToEdit.schedule,
                categoryName: categoryName
            ) { [weak self] success in
                DispatchQueue.main.async {
                    if success {
                        self?.delegate?.didUpdateTracker(trackerToEdit, categoryName: categoryName)
                        self?.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            let newTracker = Tracker(
                id: UUID(),
                name: trackerName,
                emoji: emoji,
                color: color,
                schedule: [.specificDate(trackerCreationDate)]
            )
            
            trackerStore.createTracker(
                id: newTracker.id,
                name: newTracker.name,
                emoji: newTracker.emoji,
                color: newTracker.color,
                schedule: newTracker.schedule,
                categoryName: categoryName
            ) { [weak self] tracker in
                DispatchQueue.main.async {
                    guard let tracker = tracker else { return }
                    self?.delegate?.didCreateNewTracker(tracker, categoryName: categoryName)
                    self?.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
    @objc private func textFieldDidChange() {
        updateCreateButtonState()
    }
    
    // MARK: - Private Methods
    
    private func updateCreateButtonState() {
        let isFormComplete = trackerNameTextField.text?.isEmpty == false &&
        selectedEmoji != nil &&
        selectedColor != nil &&
        selectedCategory != nil
        
        createButton.isEnabled = isFormComplete
        createButton.backgroundColor = isFormComplete ? .ypBlack : .ypGray
        createButton.setTitleColor(isFormComplete ? .ypWhite : .ypTotalWhite, for: .normal)
    }
    
    private func updateCollectionViewHeights() {
        contentView.layoutIfNeeded()
        let itemsPerRow: CGFloat = 6
        let interItemSpacing: CGFloat = 5
        let lineSpacing: CGFloat = 0
        let padding = 18
        let totalInterItemSpacing = (itemsPerRow - 1) * interItemSpacing
        let availableWidth = contentView.frame.width - CGFloat(padding * 2) - totalInterItemSpacing
        let itemWidth = floor(availableWidth / itemsPerRow)
        let headerHeight: CGFloat = 18
        
        let emojiRows = ceil(CGFloat(emojiData.count) / itemsPerRow)
        let emojiHeight = (emojiRows * itemWidth) + ((emojiRows - 1) * lineSpacing) + headerHeight + 24 + 24
        collectionEmojiView.heightAnchor.constraint(equalToConstant: emojiHeight).isActive = true
        
        let colorRows = ceil(CGFloat(colorData.count) / itemsPerRow)
        let colorHeight = (colorRows * itemWidth) + ((colorRows - 1) * lineSpacing) + headerHeight + 24 + 24
        collectionColorView.heightAnchor.constraint(equalToConstant: colorHeight).isActive = true
    }
    
    func didSelectCategory(_ category: TrackerCategory) {
        selectedCategory = category
        tableView.reloadData()
    }
    
    private func populateDataForEditing() {
        guard isEditingTracker, let trackerToEdit = trackerToEdit else {
            return
        }

        trackerNameTextField.text = trackerToEdit.name
        selectedEmoji = trackerToEdit.emoji
        selectedColor = trackerToEdit.color

        if let specificDate = trackerToEdit.schedule.compactMap({ day -> Date? in
            if case .specificDate(let date) = day { return date }
            return nil
        }).first {
            trackerCreationDate = specificDate
        }

        if let category = trackerStore.fetchCategory(for: trackerToEdit.id) {
            selectedCategory = category
        }

        tableView.reloadData()
        collectionColorView.reloadData()
        collectionEmojiView.reloadData()
        updateCreateButtonState()
    }

}

// MARK: - Extention TableView

extension NewTrackerEventViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataTableView.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CellTableHabitController", for: indexPath) as? CellTableHabitController else {
            return UITableViewCell()
        }
        
        let itemType = dataTableView[indexPath.row]
        
        cell.configure(
            title: itemType.displayName,
            selectedDays: nil,
            categoryName: selectedCategory?.name,
            isScheduleRow: itemType == .schedule
        )
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = dataTableView[indexPath.row]
        
        switch selectedItem {
        case .category:
            let categoryViewModel = CategoryViewModel()
            let categoryViewController = CategoryViewController(viewModel: categoryViewModel)
            categoryViewController.delegate = self
            let navController = UINavigationController(rootViewController: categoryViewController)
            present(navController, animated: true, completion: nil)
            
        case .schedule:
            break
        }
    }
    
}

// MARK: - Extention UITextFieldDelegate

extension NewTrackerEventViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        guard let textRange = Range(range, in: currentText) else { return true }
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        
        if updatedText.count > 38 {
            self.errorLabelTextField.isHidden = false
            self.createButton.isEnabled = false
            return false
        } else {
            self.errorLabelTextField.isHidden = true
            self.updateCreateButtonState()
            return true
        }
    }
}

// MARK: - Extention UICollectionView

extension NewTrackerEventViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionView == collectionEmojiView ? emojiData.count : colorData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == collectionEmojiView {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellEmoji", for: indexPath) as? CellEmojiCollection else {
                return UICollectionViewCell()
            }
            let emoji = emojiData[indexPath.item]
            let isSelected = emoji == selectedEmoji
            cell.configure(with: emoji, isSelected: isSelected)
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CellColor", for: indexPath) as? CellColorCollection else {
                return UICollectionViewCell()
            }
            let color = colorData[indexPath.item]
            let isSelected = color == selectedColor
            cell.configure(with: color, isSelected: isSelected)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == collectionEmojiView {
            selectedEmoji = emojiData[indexPath.item]
        } else {
            selectedColor = colorData[indexPath.item]
        }
        collectionView.reloadData()
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let numberOfItemsPerRow: CGFloat = 6
        let interItemSpacing: CGFloat = 5
        let totalInterItemSpacing = (numberOfItemsPerRow - 1) * interItemSpacing
        let availableWidth = collectionView.bounds.width - totalInterItemSpacing
        let itemWidth = floor(availableWidth / numberOfItemsPerRow)
        return CGSize(width: itemWidth, height: itemWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        if collectionView == collectionEmojiView {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderEmoji.reuseIdentifier, for: indexPath) as? HeaderEmoji else {
                return UICollectionReusableView()
            }
            header.configure(with: titleEmoji)
            return header
        } else {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderColor.reuseIdentifier, for: indexPath) as? HeaderColor else {
                return UICollectionReusableView()
            }
            header.configure(with: titleColor)
            return header
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 24, left: 0, bottom: 24, right: 0)
    }
    
}


