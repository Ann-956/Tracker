import UIKit

final class CellTableSchedule: UITableViewCell, ViewConfigurable {
    
    private var switchAction: ((Bool) -> Void)?
    
    // MARK: - UI Elements
    
    private lazy var dayLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var switchView: UISwitch = {
        let switchControl = UISwitch(frame: .zero)
        switchControl.onTintColor = .ypBlue
        switchControl.translatesAutoresizingMaskIntoConstraints = false
        return switchControl
    }()
    
    // MARK: - Initialization
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupView()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Views
    
    func setupView() {
        selectionStyle = .none
        [dayLabel, switchView].forEach {
            contentView.addSubview($0)
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            dayLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            dayLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            switchView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            switchView.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    // MARK: - Public Configuration
    
    func configure(with dayName: String, isOn: Bool, switchAction: @escaping (Bool) -> Void) {
        backgroundColor = .ypBackground
        dayLabel.text = dayName
        switchView.setOn(isOn, animated: true)
        self.switchAction = switchAction
        switchView.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
    }
    
    @objc private func switchChanged() {
        switchAction?(switchView.isOn)
    }
}

