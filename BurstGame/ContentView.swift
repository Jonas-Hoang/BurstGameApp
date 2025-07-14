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

    var body: some View {
        VStack(spacing: 30) {
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
                    Text(buttonTitle)
                        .foregroundColor(.white)
                        .font(.title2)
                        .bold()
                }
            }
            .buttonStyle(PlainButtonStyle())

            if showConfetti {
                Text("🎊🎊🎊")
                    .font(.system(size: 50))
                    .transition(.scale)
            }
        }
        .frame(minWidth: 400, minHeight: 400)
        .padding()
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
            gameState = .ready
        case .go:
            if let startTime = startTime {
                let reactionTime = Date().timeIntervalSince(startTime)
                gameState = .result(reactionTime)
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

    private func triggerReward() {
        playSuccessSound()
        withAnimation {
            showConfetti = true
        }
    }

    private func playSuccessSound() {
        NSSound(named: NSSound.Name("Glass"))?.play()
    }
}

#Preview {
    ContentView()
}
