import UIKit

private let titleFirstPage = NSLocalizedString("title_first_screen", comment: "")
private let titleSecondPage = NSLocalizedString("title_second_screen", comment: "")

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
            return titleFirstPage
        case .secondPage:
            return titleSecondPage
        }
    }
}
