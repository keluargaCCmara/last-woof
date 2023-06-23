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
    
    func update(entity: GKEntity) {
        if (entity.component(ofType: MissionComponent.self) != nil) {
            addComponent(foundIn: entity)
        }
    }
    
    func updateMissions() {
        for component in components {
            component.updateMissionState(gameState: gameState)
        }
    }
    
    func checkMission(name: String) {
        for case let component in components {
            if component.missionID == name {
                if component.dependencies.count > 0 {
                    printPrompt(detectedComponent: component)
                    break
                }
                else {
                    if component.type == "Main Mission" {
                        gameState.completeMainMission()
                        print("Main Mission Completed")
                        break
                    }
                    else {
                        gameState.setSideMissionCompleted(component.missionID, completed: true)
                        deleteDependency(detectedComponent: component)
                        print(component.missionID, " is Completed")
                        break
                    }
                }
            }
        }
    }
    
    private func printPrompt(detectedComponent: MissionComponent) {
        for case let component in components {
            if component.missionID == detectedComponent.dependencies.first {
                print(component.prompt)
                break
            }
        }
    }
    
    private func deleteDependency(detectedComponent: MissionComponent) {
        for case let component in components {
            for dependency in component.dependencies {
                var i = 0
                if dependency == detectedComponent.missionID {
                    component.dependencies.remove(at: i)
                    break
                }
                i += 1
            }
        }
    }
}