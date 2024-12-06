import UIKit


final class OnboardingViewController: UIPageViewController, ViewConfigurable {
    
    //    MARK: - Private Variebles
    
    var didFinishOnboarding: (() -> Void)?
    private let skipButtonText = NSLocalizedString("skip_button", comment: "")
    
    // MARK: - Inizial
    
    init() {
        super.init(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //    MARK: - Private UI elements
    
    private lazy var pages: [UIViewController] = {
        let firstPage = OnboardingCustomController(pageModel: .firstPage)
        let secondPage = OnboardingCustomController(pageModel: .secondPage)
        
        return [firstPage, secondPage]
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.pageIndicatorTintColor = .ypTotalBlack.withAlphaComponent(0.3)
        pageControl.currentPageIndicatorTintColor = .ypTotalBlack
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var skipButton = {
        let button = UIButton()
        button.setTitle(skipButtonText, for: .normal)
        button.setTitleColor(.ypTotalWhite, for: .normal)
        button.backgroundColor = .ypTotalBlack
        button.layer.cornerRadius = 16
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        return button
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
        [pageControl, skipButton].forEach{
            view.addSubview($0)
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -134),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            skipButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            skipButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            skipButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            skipButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    //MARK: - Private Methode
    
    @objc private func skipButtonTapped() {
        UserDefaultsSettings.shared.onboardingWasShown = true
        didFinishOnboarding?()
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


