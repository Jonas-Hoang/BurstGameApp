//
//  ContentView.swift
//  BurstGame
//
//  Created by Jonas Hoang on 14/7/25.
//

import SwiftUI
import AVFoundation

struct ContentView: View {
    enum GameState: Equatable {
        case ready
        case waiting
        case go
        case result(Double)
    }

    @State private var gameState: GameState = .ready
    @State private var bestTime: Double = UserDefaults.standard.double(forKey: "BestTime")
    @State private var startTime: Date?
    @State private var delay: Double = 0
    @State private var showConfetti = false
    @State private var confettiOffsets: [CGFloat] = []
    @State private var reactionHistory: [Double] = UserDefaults.standard.array(forKey: "ReactionHistory") as? [Double] ?? []
    @State private var audioPlayer: AVAudioPlayer?

    var body: some View {
        VStack(spacing: 20) {
            Text("🎯 Dopamine Burst Game")
                .font(.largeTitle)
                .bold()

            if case .result(let time) = gameState {
                Text("⏱️ Phản xạ của bạn: \(String(format: "%.3f", time))s")
                    .font(.title2)
                    .foregroundColor(.blue)
            }

            Text("🏅 Best: \(bestTime > 0 ? String(format: "%.3f", bestTime) : "--")s")
                .font(.headline)
                .foregroundColor(.green)

            Button(action: handleButtonPress) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(buttonColor)
                        .frame(width: 200, height: 60)
                        .shadow(color: gameState == .go ? .green.opacity(0.7) : .clear, radius: 10, x: 0, y: 0)
                        .scaleEffect(gameState == .go ? 1.05 : 1.0)
                        .animation(.easeInOut(duration: 0.5), value: gameState)

                    Text(buttonTitle)
                        .foregroundColor(.white)
                        .font(.title2)
                        .bold()
                }
            }
            .buttonStyle(PlainButtonStyle())

            if showConfetti {
                ConfettiView()
                    .transition(.opacity)
            }

            Divider()

            Text("📜 Lịch sử phản xạ")
                .font(.headline)
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(Array(reactionHistory.reversed().prefix(10).enumerated()), id: \.offset) { index, value in
                        Text("#\(index + 1): \(String(format: "%.3f", value))s")
                    }
                }
                .padding(.horizontal)
            }
            .frame(height: 150)

            Spacer()
        }
        .padding()
        .frame(minWidth: 400, minHeight: 600)
        .animation(.easeInOut, value: showConfetti)
    }

    private var buttonTitle: String {
        switch gameState {
        case .ready: return "BẮT ĐẦU"
        case .waiting: return "Chờ tín hiệu..."
        case .go: return "BẤM NGAY!"
        case .result: return "CHƠI LẠI"
        }
    }

    private var buttonColor: Color {
        switch gameState {
        case .ready: return .blue
        case .waiting: return .gray
        case .go: return .green
        case .result: return .orange
        }
    }

    private func handleButtonPress() {
        switch gameState {
        case .ready:
            startWaiting()
        case .waiting:
            // Bấm sớm quá
            gameState = .ready
        case .go:
            if let startTime = startTime {
                let reactionTime = Date().timeIntervalSince(startTime)
                gameState = .result(reactionTime)
                updateHistory(reactionTime)
                checkBestScore(reactionTime)
                triggerReward()
            }
        case .result:
            gameState = .ready
            showConfetti = false
        }
    }

    private func startWaiting() {
        gameState = .waiting
        delay = Double.random(in: 2...5)
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            if gameState == .waiting {
                gameState = .go
                startTime = Date()
            }
        }
    }

    private func checkBestScore(_ time: Double) {
        if bestTime == 0 || time < bestTime {
            bestTime = time
            UserDefaults.standard.set(bestTime, forKey: "BestTime")
        }
    }

    private func updateHistory(_ time: Double) {
        reactionHistory.append(time)
        UserDefaults.standard.set(reactionHistory, forKey: "ReactionHistory")
    }

    private func triggerReward() {
        playSuccessSound()
        withAnimation {
            showConfetti = true
        }
    }

    private func playSuccessSound() {
        if let url = Bundle.main.url(forResource: "success", withExtension: "wav") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.play()
            } catch {
                print("Error playing custom sound: \(error)")
            }
        } else {
            // Fallback sound
            NSSound(named: NSSound.Name("Glass"))?.play()
        }
    }
}

#Preview {
    ContentView()
}
