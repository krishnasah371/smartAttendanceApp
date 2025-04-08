import SwiftUI

struct WelcomeView: View {
    @State private var selectedRole: UserRole?

    var body: some View {
        NavigationStack {
            VStack {
                AuthHeaderView()

                // Role selection card
                VStack(spacing: 30) {
                    Text("Welcome to ABSENTEES")
                        .foregroundColor(.primaryColorDarker)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.vertical, 15)

                    Text("Smart attendance simplified for both students and teachers.")
                        .font(.system(size: 16, weight: .medium))
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: 350)
                        .foregroundColor(.primaryColor)
                        .padding(.top, -30)

                    VStack(spacing: 16) {
                        Button {
                            selectedRole = .student
                        } label: {
                            HStack {
                                Image(systemName: "graduationcap.fill")
                                Text("I’m a Student")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.primaryColorDark)
                            .cornerRadius(14)
                        }

                        Button {
                            selectedRole = .teacher
                        } label: {
                            HStack {
                                Image(systemName: "person.crop.rectangle.stack.fill")
                                Text("I’m a Teacher")
                            }
                            .font(.headline)
                            .foregroundColor(.primaryColorDark)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(14)
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.primaryColorDark, lineWidth: 1)
                            )
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 25))
                .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                .padding(.horizontal, 12)
                .offset(y: -200)

                Spacer()

                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                        .font(.headline)

                    NavigationLink(destination: LoginView()) {
                        Text("Login")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primaryColor)
                    }
                }
            }
            .navigationDestination(item: $selectedRole) { role in
                SignupView(role: role)
            }
        }
    }
}


#Preview {
    WelcomeView()
}
