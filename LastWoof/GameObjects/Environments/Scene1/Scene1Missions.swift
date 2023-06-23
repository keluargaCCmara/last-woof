//
//  Scene1Missions.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 22/06/23.
//

import Foundation

class Scene1Missions {
    
    var gameState: GameState?
    var missionSystem: MissionSystem?
    var checkPlant1: MissionComponent?
    var checkPlant2: MissionComponent?
    var mainMission: MissionComponent?
    
    init() {
        gameState = GameState()
        
        missionSystem = MissionSystem(gameState: gameState!)
        
//        checkPlant1 = MissionComponent(missionID: "Plant1", dependencies: [], prompt: "Visit Plant 1")
//        
//        checkPlant2 = MissionComponent(missionID: "Plant2", dependencies: [], prompt: "Visit Plant 2")
//        
//        mainMission = MissionComponent(missionID: "Pond", dependencies: ["Plant1", "Plant2"], prompt: nil)
        
        missionSystem!.addComponent(checkPlant1!)
        missionSystem!.addComponent(checkPlant2!)
        missionSystem!.addComponent(mainMission!)
        
        missionSystem!.updateMissions()
    }
    
}
