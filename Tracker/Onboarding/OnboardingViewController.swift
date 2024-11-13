import UIKit


final class OnboardingViewController: UIPageViewController, ViewConfigurable {
    
    // MARK: - Inizial
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //    MARK: - Private UI elements
    
    private lazy var pages: [UIViewController] = {
        let firstPage = OnboardingCustomController(
            backgroundImageName: "blue",
            labelText: "Отслеживайте только то, что хотите",
            buttonAction: { [weak self] in
                self?.navigateToMainController()
            }
        )
        
        let secondPage = OnboardingCustomController(
            backgroundImageName: "red",
            labelText: "Даже если это не литры воды и йога",
            buttonAction: { [weak self] in
                self?.navigateToMainController()
            }
        )
        
        return [firstPage, secondPage]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .ypBlack.withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = .ypBlack
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    //  MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let first = pages.first {
            setViewControllers([first], direction: .forward, animated: true, completion: nil)
        }
        setupView()
        setupConstraints()
        delegate = self
        dataSource = self
    }
    
    // MARK: - Setup Views
    
    func setupView() {
        view.addSubview(pageControl)
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    //MARK: - Private Methode
    
    private func navigateToMainController() {
        
        let userDefaults = UserDefaults.standard
        userDefaults.set(true, forKey: "onboardingWasShown")
        
        let tabBarController = TabBarController()
        tabBarController.modalTransitionStyle = .crossDissolve
        tabBarController.modalPresentationStyle = .fullScreen
        
        if let sceneDelegate = view.window?.windowScene?.delegate as? SceneDelegate,
           let window = sceneDelegate.window {
            window.rootViewController = tabBarController
            
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {}, completion: nil)
        }
    }
}

// MARK: - Extention UIPageViewController

extension OnboardingViewController: UIPageViewControllerDataSource,  UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard var viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        viewControllerIndex -= 1
        
        if viewControllerIndex < 0 {
            viewControllerIndex = pages.count - 1
        }
        
        return pages[viewControllerIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard var viewControllerIndex = pages.firstIndex(of: viewController) else {
            return nil
        }
        
        viewControllerIndex += 1
        
        if viewControllerIndex >= pages.count {
            viewControllerIndex = 0
        }
        
        return pages[viewControllerIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if let currentViewController = pageViewController.viewControllers?.first,
           let currentIndex = pages.firstIndex(of: currentViewController) {
            pageControl.currentPage = currentIndex
        }
    }
}


