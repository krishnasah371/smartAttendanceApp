import Foundation

class ClassService {
    static let shared = ClassService()

    private init() {}

    func fetchEnrolledClasses() async throws -> [ClassModel] {
        do {
            return try await APIClient.shared.request(.getClasses)
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw NetworkError.serverError("An error occurred while fetching classes.")
        }
    }
}
