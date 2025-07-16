import SwiftUI

struct ConfettiView: View {
    @State private var offsets: [CGSize] = Array(repeating: .zero, count: 20)
    @State private var rotations: [Double] = Array(repeating: 0, count: 20)

    var body: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { i in
                Text("🎊")
                    .font(.title)
                    .offset(offsets[i])
                    .rotationEffect(.degrees(rotations[i]))
                    .onAppear {
                        withAnimation(Animation.easeIn(duration: Double.random(in: 2.5...3.5))) {
                            offsets[i] = CGSize(width: Double.random(in: -150...150),
                                                height: 400)
                            rotations[i] = Double.random(in: 360...1080)
                        }
                    }
            }
        }
    }
}
