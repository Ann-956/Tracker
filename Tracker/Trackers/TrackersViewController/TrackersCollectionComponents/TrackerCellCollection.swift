import UIKit

final class TrackerCell: UICollectionViewCell, ViewConfigurable {
    
    var markButtonAction: (() -> Void)?
    
    // MARK: - UI Elements
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var emojiContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        view.layer.cornerRadius = 12
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var pinContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.masksToBounds = true
        
        return view
    }()
    
    private lazy var pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = .ypTotalWhite
        imageView.image = UIImage(named: "Pin")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.isHidden = true
        return imageView
    }()
    
    private lazy var trackerNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypTotalWhite
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var daysCountLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var markButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .ypWhite
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 17
        button.layer.masksToBounds = true
        return button
    }()
    
    // MARK: - UI stack
    
    lazy var titleStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.layer.cornerRadius = 16
        stackView.alignment = .leading
        return stackView
    }()
    
    lazy var imageStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var daysStackView: UIStackView = {
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
        setupView()
        setupConstraints()
        markButton.addTarget(self, action: #selector(markButtonTappedAction), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Views
    
    func setupView() {
        emojiContainerView.addSubview(emojiLabel)
        pinContainerView.addSubview(pinImageView)
        
        [emojiContainerView, pinContainerView].forEach {
            imageStackView.addArrangedSubview($0)
        }
        
        [imageStackView, trackerNameLabel].forEach {
            titleStackView.addArrangedSubview($0)
        }
        [daysCountLabel, markButton].forEach {
            daysStackView.addArrangedSubview($0)
        }
        [titleStackView, daysStackView].forEach {
            contentView.addSubview($0)
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            titleStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            titleStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
            titleStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
            titleStackView.heightAnchor.constraint(equalToConstant: 90),
            
            emojiLabel.centerXAnchor.constraint(equalTo: emojiContainerView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: emojiContainerView.centerYAnchor),
            
            pinImageView.centerXAnchor.constraint(equalTo: pinContainerView.centerXAnchor),
            pinImageView.centerYAnchor.constraint(equalTo: pinContainerView.centerYAnchor),
            
            imageStackView.topAnchor.constraint(equalTo: titleStackView.topAnchor, constant: 12),
            imageStackView.leadingAnchor.constraint(equalTo: titleStackView.leadingAnchor, constant: 12),
            imageStackView.trailingAnchor.constraint(equalTo: titleStackView.trailingAnchor, constant: -4),
            imageStackView.bottomAnchor.constraint(equalTo: trackerNameLabel.topAnchor, constant: -8),
            
           
            emojiLabel.widthAnchor.constraint(equalToConstant: 16),
            emojiLabel.heightAnchor.constraint(equalToConstant: 22),
            
            emojiContainerView.widthAnchor.constraint(equalToConstant: 24),
            emojiContainerView.heightAnchor.constraint(equalToConstant: 24),
            
            pinContainerView.widthAnchor.constraint(equalToConstant: 24),
            pinContainerView.heightAnchor.constraint(equalToConstant: 24),
            
            daysStackView.topAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 0),
            daysStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            daysStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
            
            markButton.widthAnchor.constraint(equalToConstant: 34),
            markButton.heightAnchor.constraint(equalToConstant: 34),
        ])
    }
    
    func configure(with tracker: Tracker, isCompleted: Bool, completedDays: Int, isFutureDate: Bool, isPinned: Bool) {
        emojiLabel.text = tracker.emoji
        trackerNameLabel.text = tracker.name
        titleStackView.backgroundColor = tracker.color
        
        daysCountLabel.text = daysCountString(count: completedDays)
        
        let configuration = UIImage.SymbolConfiguration(pointSize: 11, weight: .bold)
        let imageName = isCompleted ? "checkmark" : "plus"
        let image = UIImage(systemName: imageName, withConfiguration: configuration)
        markButton.setImage(image, for: .normal)
        markButton.backgroundColor = isCompleted ? tracker.color.withAlphaComponent(0.3) : tracker.color
        
        markButton.isEnabled = !isFutureDate
        markButton.alpha = isFutureDate ? 0.5 : 1.0
        pinImageView.isHidden = !isPinned
    }
    
    // MARK: - Action
    
    @objc private func markButtonTappedAction() {
        markButtonAction?()
    }
    
    private func daysCountString(count: Int) -> String {
        let formatString: String = NSLocalizedString("days_сount", comment: "")
        let resultString: String = String.localizedStringWithFormat(formatString, count)
        return resultString
    }
}
