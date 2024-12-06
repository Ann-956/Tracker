import UIKit

//    MARK: - Protocol

protocol CategorySelectionDelegate: AnyObject {
    func didSelectCategory(_ category: TrackerCategory)
}

protocol CategoryViewModelProtocol: AnyObject {
    var categories: [TrackerCategory] { get }
    var onCategoriesUpdated: (([TrackerCategory]) -> Void)? { get set }
    func fetchCategories()
    func addCategory(name: String)
}

final class CategoryViewController: UIViewController, ViewConfigurable {
    
    // MARK: - Private variables
    
    private let viewModel: CategoryViewModelProtocol
    private var selectedCategory: TrackerCategory?
    weak var delegate: CategorySelectionDelegate?
    private let themeManager = ThemeManager.shared
    
    private let titlePage = NSLocalizedString("title_category_page", comment: "")
    private let textEmptyStar = NSLocalizedString("text_error_label", comment: "")
    private let textButtonAddCategory = NSLocalizedString("text_add_category_button", comment: "")
    
    // MARK: - Initializer
    
    init(viewModel: CategoryViewModelProtocol, selectedCategory: TrackerCategory? = nil) {
        self.viewModel = viewModel
        self.selectedCategory = selectedCategory
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    MARK: - Private UI elements
    
    private lazy var starImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Error")
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.text = textEmptyStar
        label.textColor = .ypBlack
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
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
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton()
        button.setTitle(textButtonAddCategory, for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createCategoryTapped), for: .touchUpInside)
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
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        title = titlePage
        navigationController?.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .medium),
        ]
        setupView()
        setupConstraints()
        setupTableView()
        fetchCategories()
        updateViewVisibility()
    }
    
    // MARK: - Setup Views
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(CellTableCategory.self, forCellReuseIdentifier: "CategoryTableViewCell")
    }
    
    func setupView() {
        [starImage, errorLabel].forEach{
            starStackView.addArrangedSubview($0)
        }
        [starStackView, tableView, addCategoryButton].forEach{
            view.addSubview($0)
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            starStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 28),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            tableView.bottomAnchor.constraint(equalTo: addCategoryButton.topAnchor, constant: -28),
            
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    // MARK: - Private Methods
    
    private func fetchCategories() {
        viewModel.onCategoriesUpdated = { [weak self] categories in
            DispatchQueue.main.async {
                self?.updateViewVisibility()
                self?.tableView.reloadData()
            }
        }
        viewModel.fetchCategories()
    }
    
    private func updateViewVisibility() {
        if viewModel.categories.isEmpty {
            starStackView.isHidden = false
            tableView.isHidden = true
        } else {
            starStackView.isHidden = true
            tableView.isHidden = false
        }
    }
    
    // MARK: - Action
    
    @objc private func createCategoryTapped() {
        let createCategoryVC = CreateCategoryViewController(viewModel: viewModel)
        navigationController?.pushViewController(createCategoryVC, animated: true)
    }
}

// MARK: - Extension TableView

extension CategoryViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.categories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryTableViewCell", for: indexPath) as? CellTableCategory else {
            fatalError("Не удалось dequeCategoryTableViewCell")
        }
        
        let category = viewModel.categories[indexPath.row]
        let isSelected = category.name == selectedCategory?.name
        
        cell.configure(with: category.name, isSelected: isSelected)
        
        if indexPath.row == viewModel.categories.count - 1 {
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
        let selected = viewModel.categories[indexPath.row]
        selectedCategory = selected
        
        tableView.reloadData()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            self.delegate?.didSelectCategory(selected)
            self.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = (indexPath.row == viewModel.categories.count - 1)
        ? UIEdgeInsets(top: 0, left: cell.bounds.width, bottom: 0, right: 0)
        : UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
    }
    
}
