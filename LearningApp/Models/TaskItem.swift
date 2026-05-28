import Foundation

struct TaskItem: Identifiable, Codable {
    let id: String
    var title: String
    var isCompleted: Bool
    var createdAt: String
    var updatedAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case isCompleted = "is_completed"
        case createdAt   = "created_at"
        case updatedAt   = "updated_at"
    }
}
