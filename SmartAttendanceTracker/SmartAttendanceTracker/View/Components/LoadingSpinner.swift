import SwiftUI

struct LoadingSpinner: View {
    @State private var isSpinning: Bool = false
    var size: CGFloat = 50
    var lineWidth: CGFloat = 6
    
    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.80)  // Leaves a gap
                .stroke(
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .frame(width: size, height: size)
                .foregroundColor(.primaryColorDarker)
                .rotationEffect(.degrees(isSpinning ? 360 : 0))
        }
        .frame(width: 50, height: 50)
        .onAppear {
            withAnimation(
                .linear(duration: 0.8).repeatForever(autoreverses: false)
            ) {
                isSpinning = true
            }
        }

    }
}

struct LoadingSpinner_Previews: PreviewProvider {
    static var previews: some View {
        LoadingSpinner()
    }
}
