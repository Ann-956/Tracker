import Foundation

class CategoryViewModel {
    private let store: TrackerCategoryStore
    var categories: [TrackerCategory] = [] {
        didSet {
            onCategoriesUpdated?(categories)
        }
    }
    var onCategoriesUpdated: (([TrackerCategory]) -> Void)?

    init(store: TrackerCategoryStore = .shared) {
        self.store = store
    }

    func fetchCategories() {
        store.fetchCategories { [weak self] categories in
            self?.categories = categories
        }
    }

    func addCategory(name: String) {
        store.createCategory(name: name) { [weak self] category in
            guard let newCategory = category else { return }
            self?.categories.append(newCategory)
        }
    }
}
