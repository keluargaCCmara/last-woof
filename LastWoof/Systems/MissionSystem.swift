//
//  MissionSystem.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 22/06/23.
//

import GameplayKit

class MissionSystem {
    
    var inventory: InventoryManager = InventoryManager.shared
    
    private var gameState: GameState
    var missions = Set<MissionComponent>()
    
    init(gameState: GameState) {
        self.gameState = gameState
    }
    
    func addComponent(mission: MissionComponent) {
        missions.insert(mission)
    }
    
    func checkMission(entity: CustomEntity, characterHolding: String?) -> Bool {
         let objectName = entity.component(ofType: VisualComponent.self)?.visualNode.name
        var missionGathered: MissionComponent?
        print(characterHolding)
         for case let mission in missions {
             if checkPlayerInterractedWith(objectName: objectName!, interractedObject: mission.interractObject ?? []) {
                 missionGathered = mission
                 if checkSideMissionCompleted(mission) == true && checkNeededObject(characterHolding: characterHolding, neededObject: mission.neededObject) == true {
                     gameState.setSideMissionComplete(mission)
                     mission.succes()
                     checkMainMission()
                     print(mission.successPrompt)
                     missions.remove(mission)
                     return true
                 }
             }
         }
        print(missionGathered?.failedPrompt)
         return false
     }
    
    private func checkMainMission() {
        for mission in missions {
            if mission.type == .main && checkSideMissionCompleted(mission) == true {
                gameState.completeMainMission()
            }
        }
    }
    
    private func checkPlayerInterractedWith(objectName: String, interractedObject: [String]) -> Bool {
        for object in interractedObject {
            if objectName == object {
                return true
            }
        }
        return false
    }
    
    private func checkNeededObject(characterHolding: String?, neededObject: String?) -> Bool {
        guard let neededObject = neededObject else { return true }
        return characterHolding == neededObject
    }
    
    private func checkSideMissionCompleted(_ mission: MissionComponent) -> Bool {
        guard let sideMissionNeedToBeDone = mission.sideMissionNeedToBeDone else { return true }
        var flag = 0
        for requiredSideMission in sideMissionNeedToBeDone {
            for completedMission in gameState.sideMissionsCompleted {
                if requiredSideMission == completedMission {
                    flag += 1
                }
            }
        }
        return flag == sideMissionNeedToBeDone.count
    }
    
}
