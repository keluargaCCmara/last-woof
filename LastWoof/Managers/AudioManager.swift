//
//  AudioManager.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 28/06/23.
//

import AVFoundation

class AudioManager {
    static let shared = AudioManager()
    
    private var bgmPlayer: AVAudioPlayer?
    private var soundEffectPlayer: AVAudioPlayer?
    
    func playAudio(fileName: String, isBGM: Bool) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("URL is wrong")
            return
        }
        
        do {
            let player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            
            if isBGM {
                bgmPlayer?.stop()
                bgmPlayer = player
                bgmPlayer?.numberOfLoops = -1 // Infinite looping
                bgmPlayer?.setVolume(0.8, fadeDuration: 1.5)
                bgmPlayer?.play()
            } else {
                soundEffectPlayer = player
                soundEffectPlayer?.numberOfLoops = 0 // Non-looping
                soundEffectPlayer?.volume = 1.0
                soundEffectPlayer?.play()
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func stopBGM() {
        bgmPlayer?.setVolume(0.0, fadeDuration: 1.5)
        bgmPlayer?.stop()
        bgmPlayer = nil
    }
    
    func stopAllAudio() {
        stopBGM()
        soundEffectPlayer?.stop()
        soundEffectPlayer = nil
    }
}
