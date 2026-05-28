import Foundation

@MainActor
final class TaskViewModel {
    
    private(set) var tasks: [TaskItem] = []
    private(set) var isLoading: Bool = false
    private(set) var isLoadingMore: Bool = false
    private(set) var errorMessage: String?

    var onUpdate: (() -> Void)?

    private let pageSize = 20
    private var currentPage = 1
    private var totalPages = 1

    var hasMoreTasks: Bool {
        return currentPage < totalPages
    }

    private let service: TaskService

    init(service: TaskService = .shared) {
        self.service = service
    }

    func loadTasks() async {
        isLoading = true
        onUpdate?()

        defer {
            isLoading = false
            onUpdate?()
        }

        do {
            let response = try await service.fetchTasks(page: 1, limit: pageSize)
            tasks = response.todos
            currentPage = response.meta.page
            totalPages = response.meta.total_pages
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func loadMoreTasks() async {
        /// Don't start another load if one is already running, or if there's nothing left
        guard !isLoading, !isLoadingMore, hasMoreTasks else { return }

        isLoadingMore = true
        onUpdate?()

        defer {
            isLoadingMore = false
            onUpdate?()
        }

        do {
            let nextPage = currentPage + 1
            let response = try await service.fetchTasks(page: nextPage, limit: pageSize)
            tasks.append(contentsOf: response.todos)
            currentPage = response.meta.page
            totalPages = response.meta.total_pages
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func loadTask(id: Int) async {
        isLoading = true
        onUpdate?()
        
        defer {
            isLoading = false
            onUpdate?()
        }
        
        do {
            let result = try await TaskService.shared.fetchTask(id: id)
            tasks = [result]
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func updateTask(_ task: TaskItem) async {
        isLoading = true
        onUpdate?()

        defer {
            isLoading = false
            onUpdate?()
        }

        do {
            let updated = try await service.updateTask(task)

            if let index = tasks.firstIndex(where: { $0.id == updated.id }) {
                tasks[index] = updated
            }

            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func addTask(title: String) async {
        isLoading = true
        onUpdate?()
        
        defer {
            isLoading = false
            onUpdate?()
        }
        
        do {
            let newTask = try await service.addTask(title: title)
            tasks.insert(newTask, at: 0)
            errorMessage = nil
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func numberOfTasks() -> Int {
        tasks.count
    }
    
    func task(at index: Int) -> TaskItem {
        tasks[index]
    }
    
}
