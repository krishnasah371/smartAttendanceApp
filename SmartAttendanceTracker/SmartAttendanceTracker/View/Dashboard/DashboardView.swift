import SwiftUI

struct DashboardView: View {
    @State private var showCheckInPopup = false

    var body: some View {
        NavigationStack {
            VStack {
                Text("Dashboard")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top, 120)
                    .foregroundColor(.primaryColorDark)

                Text("You have too much low energy to study.")
                    .font(.subheadline)
                    .foregroundColor(.primaryColorDarker)

                Text("Go and sleep. Goodnight!")
                    .font(.subheadline)
                    .foregroundColor(.primaryColorDarker)

                Spacer()

                // "Connect to your class" button
                NavigationLink(destination: BLEScanView()) {
                    Text("Connect to your class")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryColorDark)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }

                // "Check in" button
                Button(action: {
                    showCheckInPopup = true
                }) {
                    Text("Check in")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.primaryColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal)
                }
                .alert("✅ Attendance Recorded", isPresented: $showCheckInPopup)
                {
                    Button("OK", role: .cancel) {}
                }

                Spacer()

                NavigationLink(destination: SignupView()) {
                    Text("Settings")
                        .foregroundColor(.blue)
                        .padding()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.white)  // ✅ Set white background
            .edgesIgnoringSafeArea(.all)  // ✅ Ensure full screen background
            .preferredColorScheme(.light)  // ✅ Force light mode
        }
    }
}

// Preview
struct DashboardView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardView()
    }
}
