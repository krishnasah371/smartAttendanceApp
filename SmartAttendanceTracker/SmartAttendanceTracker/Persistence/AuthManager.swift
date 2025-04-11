import Foundation

class AuthManager {
    static let shared = AuthManager()
    private let tokenKey = "authToken"
    private let userKey = "currentUser"

    private init() {}

    // MARK: - Token
    func saveToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: tokenKey)
    }

    func getToken() -> String? {
        return UserDefaults.standard.string(forKey: tokenKey)
    }

    func removeToken() {
        UserDefaults.standard.removeObject(forKey: tokenKey)
    }

    var isLoggedIn: Bool {
        return getToken() != nil
    }

    // MARK: - User
    func saveUser(_ user: UserModel) {
        if let data = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(data, forKey: userKey)
        }
    }

    func getUser() -> UserModel? {
        guard let data = UserDefaults.standard.data(forKey: userKey) else { return nil }
        return try? JSONDecoder().decode(UserModel.self, from: data)
    }

    func removeUser() {
        UserDefaults.standard.removeObject(forKey: userKey)
    }
}

