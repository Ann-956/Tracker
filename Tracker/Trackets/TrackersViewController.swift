import UIKit

final class TrackersViewController: UIViewController {
    
//    MARK: 
    
    private let addTrackerButton: UIBarButtonItem = {
        let button = UIButton()
        button.setImage(UIImage(named: "Pluse"), for: .normal)
        button.tintColor = .ypBlack
        button.translatesAutoresizingMaskIntoConstraints = false
        button.contentMode = .scaleAspectFit
        let navBarButton = UIBarButtonItem(customView: button)
        return navBarButton
    }()
    
    private lazy var choiceDate: UIBarButtonItem = {
        let picker = UIDatePicker()
        picker.preferredDatePickerStyle = .compact
        picker.datePickerMode = .date
        picker.locale = Locale.current
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.addTarget(
            self,
            action: #selector(datePickerValueChanged(_:)),
            for: .valueChanged
        )
        let navBarButton = UIBarButtonItem(customView: picker)
        return navBarButton
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
    
    private let infoStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 7
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
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
    
    private let starStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        setupNavBar()
        setupView()
        setupConstraints()
    }
    
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
        [infoStackView,starStackView].forEach{
            view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            // Констрейнты для infoStackView
            infoStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            infoStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            infoStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            
            // Констрейнты для searchBar
            searchBar.searchBar.heightAnchor.constraint(equalToConstant: 36),
            searchBar.searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 8),
            searchBar.searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -8),
            
            // Констрейнты для starStackView
            starStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 48),
        ])
    }
    
    @objc func datePickerValueChanged(_ sender: UIDatePicker) {
        let selectedDate = sender.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yy"
        let formattedDate = dateFormatter.string(from: selectedDate)
        print("Выбранная дата: \(formattedDate)") // здесь отображается формат верно, но сам datepicker не меняется (не понимаю почему )
    }
}
