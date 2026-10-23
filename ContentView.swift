// language: Swift, file: ContentView.swift
import SwiftUI
import AVFoundation

class SoundManager: ObservableObject {
    var audioPlayer: AVAudioPlayer?
    
    init() {
        do {
            // Настраиваем аудиосессию ОДИН РАЗ при запуске.
            // .playback позволяет играть звук даже в беззвучном режиме.
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Ошибка настройки аудиосессии: \(error.localizedDescription)")
        }
    }
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "scream", withExtension: "mp3") else {
            print("ОШИБКА: Файл scream.mp3 не найден в бандле! Добавь его в проект и поставь Target Membership.")
            return
        }
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.play()
            
            // Сильная вибрация (работает только на реальном iPhone, не в симуляторе)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.error)
            
        } catch {
            print("Ошибка воспроизведения звука: \(error.localizedDescription)")
        }
    }
}

struct ContentView: View {
    @StateObject private var soundManager = SoundManager()
    @State private var isFlashing = false
    
    var body: some View {
        ZStack {
            // Фон меняется при нажатии
            Color(isFlashing ? .red : .black)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Text("ДЮВАН")
                    .font(.system(size: 60, weight: .black, design: .default))
                    .foregroundColor(.white)
                    .shadow(color: .red, radius: 10, x: 0, y: 0)
                
                // Картинка дивана из Assets.xcassets
                if let uiImage = UIImage(named: "duvan") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 300, height: 300)
                        .cornerRadius(20)
                        .shadow(radius: 20)
                } else {
                    Rectangle()
                        .fill(Color.gray)
                        .frame(width: 300, height: 300)
                        .cornerRadius(20)
                        .overlay(Text("Добавь duvan в Assets").foregroundColor(.white))
                }
                
                Button(action: {
                    soundManager.playSound()
                    
                    // Анимация вспышки через Task (защита от быстрых кликов)
                    Task {
                        withAnimation(.easeIn(duration: 0.1)) {
                            isFlashing = true
                        }
                        try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 сек
                        withAnimation(.easeOut(duration: 0.2)) {
                            isFlashing = false
                        }
                    }
                }) {
                    Text("НАЖМИ")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 250)
                        .background(Color.red)
                        .cornerRadius(50)
                        .shadow(color: .red, radius: 20)
                }
            }
        }
    }
}
