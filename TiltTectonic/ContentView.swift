//
//  ContentView.swift
//  TiltTectonic
//
//  Created by Mirabella on 22/05/25.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    @State private var tilt: Double = 0.0
    @State private var gameWon = false
    @State private var gameOver = false
    @State private var scene = GameScene(size: CGSize(width: 400, height: 600))
    
    var body: some View {
        VStack(spacing: 20) {
            SpriteView(scene: scene)
                .frame(width: 400, height: 600)
                .cornerRadius(16)
                .onAppear {
                    configureScene()
                }

            Text("Tilt: \(String(format: "%.1f", tilt))°")
            Slider(value: $tilt, in: -30...30)
                .padding(.horizontal)
                .disabled(gameWon || gameOver)
            
            if gameWon {
                Text("🎉 You Win!").font(.title).foregroundColor(.green)
            }

            if gameOver {
                Text("💥 Game Over").font(.title).foregroundColor(.red)
            }
            
            if gameWon || gameOver {
                Button("Start Over") {
                    resetGame()
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }
    
    func configureScene() {
        scene.externalTiltBinding = $tilt
        scene.onWin = {
            gameWon = true
        }
        scene.onLose = {
            gameOver = true
        }
    }
    
    func resetGame() {
        gameWon = false
        gameOver = false
        scene = GameScene(size: CGSize(width: 400, height: 600))
        configureScene()
    }
}

#Preview {
    ContentView()
}
