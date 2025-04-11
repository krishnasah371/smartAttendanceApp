import Foundation

class ClassService {
    static let shared = ClassService()

    private init() {}

    func fetchEnrolledClasses() async throws -> [ClassModel]? {
        do {
            let response:ClassesResponse = try await APIClient.shared.request(.getClasses)
            return response.classes
            
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw NetworkError.serverError("An error occurred while fetching classes.")
        }
    }
    
    func fetchAllClasses() async throws -> [ClassModel]? {
        do {
            let response:ClassesResponse = try await APIClient.shared.request(.getAllClasses)
            return response.classes
            
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw NetworkError.serverError("An error occurred while fetching classes.")
        }
    }
    func enrollInAClass(classId: Int) async throws -> ClassEnrollResponse? {
        do {
            let response:ClassEnrollResponse = try await APIClient.shared.request(.enrollInAClass(classId:classId))
            return response
            
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw NetworkError.serverError("An error occurred while fetching classes.")
        }
    }
    func registerANewClass(classRegistrationPayload: ClassRegistrationPayload) async throws -> ClassRegistrationResponse? {
        do {
            let bodyData = try JSONEncoder().encode(classRegistrationPayload)
            
            print("BodyDATA is: ",bodyData)
            let response:ClassRegistrationResponse = try await APIClient.shared.request(.registerInAClass, body: bodyData)
            return response
            
        } catch let networkError as NetworkError {
            throw networkError
        } catch {
            throw NetworkError.serverError("An error occurred while fetching classes.")
        }
    }
}
