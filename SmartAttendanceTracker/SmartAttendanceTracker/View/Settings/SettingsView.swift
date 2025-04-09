import SwiftUI
import PhotosUI

struct SettingsView: View {
    @EnvironmentObject var sessionManager: SessionManager
    @AppStorage("userName") var userName: String = "Student Name"
    @AppStorage("userEmail") var userEmail: String = "student@email.com"

    @State private var selectedImage: UIImage? = ImageStorageManager.load()
    @State private var showImageSourceSheet = false
    @State private var showSystemImagePicker = false
    @State private var imagePickerSource: UIImagePickerController.SourceType = .photoLibrary

    @State private var showEditProfile = false
    @State private var showNotifications = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SettingsHeaderView()

                VStack(spacing: 16) {
                    // Avatar
                    VStack(spacing: 12) {
                        ZStack(alignment: .bottomTrailing) {
                            if let img = selectedImage {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.gray.opacity(0.6))
                            }

                            Button {
                                showImageSourceSheet = true
                            } label: {
                                Image(systemName: "camera.fill")
                                    .padding(6)
                                    .background(Color.white)
                                    .clipShape(Circle())
                            }
                            .offset(x: -4, y: -4)
                        }

                        Text(userName)
                            .font(.title2.bold())
                        Text(userEmail)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }

                    // Menu
                    VStack(spacing: 16) {
                        SettingsRow(icon: "bell.fill", title: "View Notifications") {
                            showNotifications = true
                        }
                        SettingsRow(icon: "pencil.line", title: "Edit Profile") {
                            showEditProfile = true
                        }
                        SettingsRow(icon: "rectangle.portrait.and.arrow.right", title: "Sign Out", color: .red) {
                            AuthManager.shared.removeToken()
                            sessionManager.isLoggedIn = false
                        }
                    }
                    .padding(.top, 20)
                }
                .padding(.horizontal, 20)
                .padding(.top, -20)

                Spacer()
            }
            .sheet(isPresented: $showSystemImagePicker) {
                ImagePicker(sourceType: imagePickerSource, selectedImage: $selectedImage)
            }
            .confirmationDialog("Choose Source", isPresented: $showImageSourceSheet, titleVisibility: .visible) {
                Button("Camera") {
                    imagePickerSource = .camera
                    showSystemImagePicker = true
                }
                Button("Photo Library") {
                    imagePickerSource = .photoLibrary
                    showSystemImagePicker = true
                }
                Button("Cancel", role: .cancel) {}
            }
            .onChange(of: selectedImage) { img in
                if let img = img {
                    ImageStorageManager.save(image: img)
                }
            }
            .navigationDestination(isPresented: $showEditProfile) {
                EditProfileView()
            }
            .navigationDestination(isPresented: $showNotifications) {
                NotificationsView()
            }
        }
    }
}

#Preview {
    SettingsView().environmentObject(SessionManager())
}
