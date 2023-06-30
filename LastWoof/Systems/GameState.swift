//
//  GameState.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 22/06/23.
//

import GameplayKit

class GameState {
    
    var mainMissionCompleted: Bool = false
    var sideMissionsCompleted: [MissionComponent] = []
    
    func setSideMissionComplete(_ missionID: MissionComponent) {
        sideMissionsCompleted.append(missionID)
    }
    
    func completeMainMission() {
        print("MAIN MISSION COMPLETE WOYYYYY")
        AudioManager.shared.stopBGM()
        mainMissionCompleted = true
    }
    
}
