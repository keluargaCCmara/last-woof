//
//  GameState.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 22/06/23.
//

import GameplayKit

class GameState {
    var chapter: Int
    var mainMissionCompleted: Bool = false
    var sideMissionsCompleted: [MissionComponent] = []
    
    init(chapter: Int) {
        self.chapter = chapter
    }
    
    func setSideMissionComplete(_ missionID: MissionComponent) {
        sideMissionsCompleted.append(missionID)
    }
    
    func completeMainMission() {
        AudioManager.shared.stopBGM()
        mainMissionCompleted = true
    }
    
}
