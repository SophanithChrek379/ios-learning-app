import Foundation

struct EditTaskRequest: Encodable {
    let title: String
    let isCompleted: Bool
}
