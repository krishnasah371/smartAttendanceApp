import UIKit

enum ImageStorageManager {
    private static let key = "userProfileImage"

    static func save(image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func load() -> UIImage? {
        if let data = UserDefaults.standard.data(forKey: key) {
            return UIImage(data: data)
        }
        return nil
    }
}
