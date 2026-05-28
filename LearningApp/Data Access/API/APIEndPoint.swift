import Foundation

enum APIEndPoint {
    
    static let baseURL = "https://todoist-api-repo.onrender.com"
    
    case todos(page: Int, limit: Int)
    case todo(id: Int)
    case add
    case update(id: String)
    case delete(id: String)
    case toggleTask(id: String)

    var path: String {
        switch self {
        case .todos(let page, let limit):
            return "/todos?page=\(page)&limit=\(limit)"
        case .todo(let id):
            return "/todos/\(id)"
        case .add:
            return "/todos"
        case .update(let id):
            return "/todos/\(id)"
        case .delete(let id):
            return "/todos/\(id)"
        case .toggleTask(let id):
            return "/todos/\(id)/completed"
        }
    }
    
    var url: String {
        return APIEndPoint.baseURL.appending(path)
    }
    
}
