import UIKit

class CellTableView: UITableViewCell {
    static let identifier = "CustomTableViewCell"
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17)
        return label
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .right
        return label
    }()
    
    private let accessoryImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "chevron.right"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .gray
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    private func setupLayout() {
        addSubview(titleLabel)
        addSubview(detailLabel)
        addSubview(accessoryImageView)
        
        NSLayoutConstraint.activate([
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            
            detailLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            detailLabel.trailingAnchor.constraint(equalTo: accessoryImageView.leadingAnchor, constant: -8),
            
            accessoryImageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            accessoryImageView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            accessoryImageView.widthAnchor.constraint(equalToConstant: 8)
        ])
    }
    
    func configure(title: String, detail: String) {
        titleLabel.text = title
        detailLabel.text = detail
    }
}
