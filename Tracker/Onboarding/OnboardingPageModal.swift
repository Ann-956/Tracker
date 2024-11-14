import UIKit

enum PageModel {
    case firstPage
    case secondPage
    
    var imageName: UIImage? {
        switch self {
        case .firstPage:
            return UIImage(named: "blue")
        case .secondPage:
            return UIImage(named: "red")
        }
    }
    
    var text: String {
        switch self {
        case .firstPage:
            return "Отслеживайте только то, что хотите"
        case .secondPage:
            return "Даже если это не литры воды и йога"
        }
    }
}
