import Foundation

struct AddTaskRequest: Encodable {
    let title: String
    let isCompleted: Bool
}
