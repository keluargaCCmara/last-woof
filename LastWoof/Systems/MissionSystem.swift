//
//  MissionSystem.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 22/06/23.
//

import GameplayKit

class MissionSystem: GKComponentSystem<MissionComponent> {
    
    private var gameState: GameState
    
    init(gameState: GameState) {
        self.gameState = gameState
        super.init(componentClass: MissionComponent.self)
    }
    
    func addComponent(entity: GKEntity) {
        if (entity.component(ofType: MissionComponent.self) != nil) {
            addComponent(foundIn: entity)
        }
    }
    
    func checkMission(name: String) -> Bool {
        for case let component in components {
            if component.missionID == name {
                if component.dependencies.count > 0 {
                    print(component.failedPrompt)
                    return false
                }
                else {
                    if component.type == "Main Mission" {
                        gameState.completeMainMission()
                        print("Main Mission Completed")
                        return true
                    }
                    else {
                        gameState.setSideMissionCompleted(component.missionID, completed: true)
                        deleteDependency(detectedComponent: component)
                        print(component.successPrompt)
                        removeComponent(component)
                        return true
                    }
                }
            }
        }
        return false
    }
    
    private func deleteDependency(detectedComponent: MissionComponent) {
        for case let component in components {
            for dependency in component.dependencies {
                var i = 0
                if dependency == detectedComponent.missionID {
                    component.dependencies.remove(at: i)
                }
                i += 1
            }
        }
    }
}
