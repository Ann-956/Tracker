import UIKit

final class CellTableCategory: UITableViewCell, ViewConfigurable {
    
    // MARK: - UI Elements
    
    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let selectionIndicator: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = .ypBlue
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
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
        [categoryLabel, selectionIndicator].forEach{
            addSubview($0)
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            categoryLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            categoryLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            selectionIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            selectionIndicator.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    // MARK: - Public Configuration
    
    func configure(with categoryName: String, isSelected: Bool) {
        backgroundColor = .ypBackground
        categoryLabel.text = categoryName
        selectionIndicator.isHidden = !isSelected
    }
    
}
