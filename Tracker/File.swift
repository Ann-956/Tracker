import UIKit

class CreateTrackerViewController: UIViewController {
    
    private let nameTextField = UITextField()
    private let createButton = UIButton(type: .system)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "Создать трекер"
        
        // Поле для ввода названия трекера
        nameTextField.placeholder = "Введите название"
        view.addSubview(nameTextField)
        nameTextField.frame = CGRect(x: 20, y: 100, width: view.frame.width - 40, height: 40)
        
        // Кнопка создания трекера
        createButton.setTitle("Создать", for: .normal)
        createButton.addTarget(self, action: #selector(createTracker), for: .touchUpInside)
        view.addSubview(createButton)
        createButton.frame = CGRect(x: 20, y: 160, width: view.frame.width - 40, height: 40)
    }
    
    @objc private func createTracker() {
        // Логика создания нового трекера (можно передать его обратно на основной экран)
        navigationController?.popViewController(animated: true)
    }
}
