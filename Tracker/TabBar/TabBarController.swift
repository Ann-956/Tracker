import UIKit

final class TabBarController: UITabBarController {
    
    private let titleTrackers = NSLocalizedString("trackers", comment: "")
    private let titleStatistics = NSLocalizedString("statistics", comment: "")
    private let themeManager: ThemeManager = .shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        setupTopBar()
    }
    
    private func setupViewControllers() {
        let trackersViewController = UINavigationController(rootViewController: TrackersViewController())
        trackersViewController.tabBarItem = UITabBarItem(
            title: titleTrackers,
            image: UIImage(named: "TrackerActive"),
            selectedImage: nil
        )
        
        let statisticsViewController = UINavigationController(rootViewController: StatisticsViewController())
        statisticsViewController.tabBarItem = UITabBarItem(
            title: titleStatistics,
            image: UIImage(named: "StatisticActive"),
            selectedImage: nil
        )
        
        self.viewControllers = [trackersViewController, statisticsViewController]
    }
    
    private func setupTopBar() {
        tabBar.backgroundColor = .ypWhite
        let topBorder = UIView()
        topBorder.backgroundColor = themeManager.tabBarBorder
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(topBorder)
        
        NSLayoutConstraint.activate([
            topBorder.heightAnchor.constraint(equalToConstant: 1),
            topBorder.leadingAnchor.constraint(equalTo: tabBar.leadingAnchor),
            topBorder.trailingAnchor.constraint(equalTo: tabBar.trailingAnchor),
            topBorder.bottomAnchor.constraint(equalTo: tabBar.topAnchor)
        ])
    }
}
