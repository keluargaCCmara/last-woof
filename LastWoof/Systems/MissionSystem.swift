//
//  MissionSystem.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 22/06/23.
//

import GameplayKit

class MissionSystem: GKComponentSystem<MissionComponent> {
    
    var inventory: InventoryManager = InventoryManager.shared
    
    private var gameState: GameState
    var missions = Set<MissionComponent>()
    
    init(gameState: GameState) {
        self.gameState = gameState
        super.init(componentClass: MissionComponent.self)
    }
    
    func addComponent(mission: MissionComponent) {
        missions.insert(mission)
    }
    
     func checkMission(entity: CustomEntity) -> Bool {
         let name = entity.component(ofType: VisualComponent.self)?.visualNode.name
         for case let mission in missions {
             if mission.interractObject == name {
                 if mission.neededObject?.count ?? 0 > 0 {
                     if checkPlayerHasObject(mission: mission) == true {
                         if mission.stateRequirement == entity.interracted {
                             gameState.setSideMissionCompleted(mission.missionID, completed: true)
                             mission.succes()
                             print(mission.successPrompt)
                             checkMainMission()
                             missions.remove(mission)
                             return true
                         }
                     }
                     print(mission.failedPrompt)
                     return false
                 }
                 else {
                     if mission.stateRequirement == entity.interracted {
                         gameState.setSideMissionCompleted(mission.missionID, completed: true)
                         mission.succes()
                         print(mission.successPrompt)
                         checkMainMission()
                         missions.remove(mission)
                         return true
                     }
                 }
             }
         }
         return false
     }
    
    private func checkPlayerHasObject(mission: MissionComponent) -> Bool {
        var flag = 0
        for object in mission.neededObject! {
            for inventory in inventory.inventory {
                if object == inventory {
                    flag += 1
                }
            }
        }
        if flag == mission.neededObject?.count {
            return true
        }
        return false
    }
    
    private func checkMainMission() {
        for mission in missions {
            if mission.type == "Main Mission" {
                if checkPlayerHasObject(mission: mission) == true {
                    gameState.completeMainMission()
                    break
                }
            }
        }
    }
    
}
