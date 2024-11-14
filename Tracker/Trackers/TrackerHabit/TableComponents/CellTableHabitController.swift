import UIKit

final class CellTableHabitController: UITableViewCell, ViewConfigurable {
    
    // MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var detailLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .ypGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.tintColor = .ypGray
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    //    MARK: - UI Stack
    
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 2
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
     // MARK: - Initializer
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    MARK: - Setup Views
    
    func setupView() {
        [titleLabel, detailLabel].forEach{
            stackView.addArrangedSubview($0)
        }
        [stackView, arrowImageView].forEach{
            addSubview($0)
        }
    }
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: arrowImageView.leadingAnchor, constant: -10),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            arrowImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            arrowImageView.widthAnchor.constraint(equalToConstant: 20),
            arrowImageView.heightAnchor.constraint(equalToConstant: 20)
        ])
    }
    
    // MARK: - Public Configuration
    
    func configure(title: String, selectedDays: [WeekDay]?, categoryName: String?, isScheduleRow: Bool) {
        titleLabel.text = title
        backgroundColor = .ypBackground

        if isScheduleRow, let selectedDays = selectedDays {
            let allDays = Set(WeekDay.allCases)
            if Set(selectedDays) == allDays {
                detailLabel.text = "Каждый день"
            } else {
                detailLabel.text = selectedDays
                    .sorted(by: { $0.rawValue < $1.rawValue })
                    .map { $0.shortDisplayName }
                    .joined(separator: ", ")
            }
        } else if !isScheduleRow, let categoryName = categoryName {
            detailLabel.text = categoryName
        } else {
            detailLabel.text = nil
        }
    }
}
