import Foundation

final class TaskService {
    
    static let shared = TaskService()
    
    private init() {}
    
    func fetchTasks(page: Int, limit: Int) async throws -> TaskResponse {
        let response: TaskResponse = try await APIClient.shared.fetch(
            from: .todos(page: page, limit: limit)
        )
        return response
    }
    
    func fetchTask(id: Int) async throws -> TaskItem {
        let task: TaskItem = try await APIClient.shared.fetch(from: .todo(id: id))
        return task
    }
    
    func addTask(title: String) async throws -> TaskItem {
        let body = AddTaskRequest(title: title, isCompleted: false)
        return try await APIClient.shared.post(
            to: .add,
            body: body
        )
    }
    
    func updateTask(_ task: TaskItem) async throws -> TaskItem {
        let body = EditTaskRequest(title: task.title, isCompleted: task.isCompleted)
        return try await APIClient.shared.put(
            to: .update(id: task.id), body: body
        )
    }
    
}
