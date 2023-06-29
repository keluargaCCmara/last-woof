//
//  AudioManager.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 28/06/23.
//

import AVFoundation

class AudioManager {
    
    static let shared = AudioManager()
    
    var player: AVAudioPlayer?
    
    func playAudio(fileName: String) {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "mp3") else {
            print("URL is wrong"); return
        }
        do {
            player = try AVAudioPlayer(contentsOf: url)
            guard let player = player else { return }
            
            player.prepareToPlay()
            player.play()
            
        } catch {
            print(error.localizedDescription)
        }
    }
    
}
