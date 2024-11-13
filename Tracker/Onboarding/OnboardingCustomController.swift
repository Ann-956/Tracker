import UIKit

final class OnboardingCustomController: UIViewController, ViewConfigurable {
    
    //    MARK: - Variebles
    
    var backgroundImageName: String?
    var labelText: String?
    var buttonAction: (() -> Void)?
    
    // MARK: - Inizial
    
    init(backgroundImageName: String?, labelText: String?, buttonAction: (() -> Void)?) {
        super.init(nibName: nil, bundle: nil)
        self.backgroundImageName = backgroundImageName
        self.labelText = labelText
        self.buttonAction = buttonAction
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //    MARK: - Private UI Elements
    
    private lazy var backgroundImage = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        if let imageName = backgroundImageName, let image = UIImage(named: imageName) {
            imageView.image = image
        } else {
            imageView.backgroundColor = .white
        }
        return imageView
    }()
    
    private lazy var label = {
        let label = UILabel()
        label.text = labelText
        label.font = .boldSystemFont(ofSize: 32)
        label.textColor = .ypBlack
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var button = {
        let button = UIButton()
        button.setTitle("Вот это технологии!", for: .normal)
        button.setTitleColor(.ypWhite, for: .normal)
        button.backgroundColor = .ypBlack
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //  MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        setupConstraints()
    }
    
    // MARK: - Setup Views
    
    func setupView() {
        [backgroundImage, label, button].forEach{
            view.addSubview($0)
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            
            backgroundImage.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImage.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImage.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            backgroundImage.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            button.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            button.heightAnchor.constraint(equalToConstant: 60),
            
            label.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -160),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
        ])
    }
    
    // MARK: - Actions
    
    @objc private func actionButtonTapped() {
        buttonAction?()
    }
}
