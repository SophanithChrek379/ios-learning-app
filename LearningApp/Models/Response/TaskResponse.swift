import Foundation

struct TaskResponse: Codable {
    let todos: [TaskItem]
    let meta: Meta
}

struct Meta: Codable {
    let page: Int
    let limit: Int
    let total: Int
    let total_pages: Int
    let sort_by: String
    let order: String
}
