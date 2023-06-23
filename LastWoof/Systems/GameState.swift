//
//  GameState.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 22/06/23.
//

import GameplayKit

class GameState {
    
    var mainMissionCompleted: Bool = false
    var sideMissionsCompleted: [String: Bool] = [:]
    
    func isSideMissionCompleted(_ missionID: String) -> Bool {
        return sideMissionsCompleted[missionID] ?? false
    }
    
    func setSideMissionCompleted(_ missionID: String, completed: Bool) {
        sideMissionsCompleted[missionID] = completed
        print(missionID, " is completed")
    }
    
    func completeMainMission() {
        mainMissionCompleted = true
    }
    
}
