import UIKit

final class TrackerCell: UICollectionViewCell {
    
    var markButtonAction: (() -> Void)?
    
    // MARK: - UI Elements
    
    let emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    let emojiContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    let trackerNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .ypWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let markButton: UIButton = {
        let button = UIButton(type: .system)
        let configuration = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        let image = UIImage(systemName: "plus", withConfiguration: configuration)
        button.setImage(image, for: .normal)
        button.tintColor = .ypWhite
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        return button
    }()
    
    // MARK: - UI stack
    
    let titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 16
        stackView.alignment = .leading
        return stackView
    }()
    
    let daysStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        markButton.addTarget(self, action: #selector(markButtonTappedAction), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Views
    
    private func setupViews() {
        
        emojiContainerView.addSubview(emojiLabel)
        
        [emojiContainerView, trackerNameLabel].forEach {
            titleStackView.addArrangedSubview($0)
        }
        [daysCountLabel, markButton].forEach {
            daysStackView.addArrangedSubview($0)
        }
        [titleStackView, daysStackView].forEach {
            contentView.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            titleStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            titleStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            titleStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            titleStackView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.topAnchor.constraint(equalTo: emojiContainerView.topAnchor, constant: 1),
            emojiLabel.leadingAnchor.constraint(equalTo: emojiContainerView.leadingAnchor, constant: 4),
            emojiLabel.trailingAnchor.constraint(equalTo: emojiContainerView.trailingAnchor, constant: -4),
            emojiLabel.bottomAnchor.constraint(equalTo: emojiContainerView.bottomAnchor, constant: -1),
            
            emojiContainerView.topAnchor.constraint(equalTo: titleStackView.topAnchor, constant: 12),
            emojiContainerView.leadingAnchor.constraint(equalTo: titleStackView.leadingAnchor, constant: 12),
            emojiLabel.widthAnchor.constraint(equalToConstant: 16),
            emojiLabel.heightAnchor.constraint(equalToConstant: 22),
            
            emojiContainerView.widthAnchor.constraint(equalToConstant: 24),
            emojiContainerView.heightAnchor.constraint(equalToConstant: 24),
            
            trackerNameLabel.leadingAnchor.constraint(equalTo: titleStackView.leadingAnchor, constant: 12),
            trackerNameLabel.trailingAnchor.constraint(equalTo: titleStackView.trailingAnchor, constant: -12),
            trackerNameLabel.bottomAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 12),
            
            daysStackView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 0),
            daysStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            daysStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            markButton.widthAnchor.constraint(equalToConstant: 34),
            markButton.heightAnchor.constraint(equalToConstant: 34),
        ])
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool, completedDays: Int, isFutureDate: Bool) {
        emojiLabel.text = tracker.emoji
        trackerNameLabel.text = tracker.name
        titleStackView.backgroundColor = tracker.color
        
        daysCountLabel.text = "\(completedDays) дней"
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        let imageName = isCompleted ? "checkmark" : "plus"
        let image = UIImage(systemName: imageName, withConfiguration: configuration)
        markButton.setImage(image, for: .normal)
        markButton.tintColor = .ypWhite
        markButton.backgroundColor = isCompleted ? tracker.color.withAlphaComponent(0.3) : tracker.color
        
        markButton.isEnabled = !isFutureDate
        markButton.alpha = isFutureDate ? 0.5 : 1.0
    }
    
    @objc func markButtonTappedAction() {
        markButtonAction?()
    }
}
