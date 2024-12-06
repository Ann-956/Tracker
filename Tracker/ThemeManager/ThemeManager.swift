import UIKit

final class ThemeManager {
    static let shared = ThemeManager()
    
    private init() {}
    
    var tabBarBorder: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .ypTotalBlack : .ypGray
        }
    }
    
    var separatorColor: UIColor {
        return UIColor { traitCollection in
            return traitCollection.userInterfaceStyle == .dark ? .ypLightGray : .ypGray
        }
    }
}
