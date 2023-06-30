//
//  MissionComponent.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 22/06/23.
//

import GameplayKit

enum MissionType: String {
    case main = "Main Mission"
    case side = "Side Mission"
}

class MissionComponent: Hashable {
    
    static func == (lhs: MissionComponent, rhs: MissionComponent) -> Bool {
        return lhs.missionID == rhs.missionID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(missionID)
    }
    
    var entityManager: EntityManager = EntityManager.shared
    
    let missionID: String
    let type: MissionType
    let interractObject: [String]?
    let neededObject: String?
    let failedPrompt: String?
    let successState: [String]
    let successPrompt: String
    var sideMissionNeedToBeDone: [MissionComponent]?
    let sound: String?
    
    init(missionID: String, type: MissionType, interractObject: [String]?, neededObject: String?, failedPrompt: String?, successState: [String], successPrompt: String, sideMissionNeedToBeDone: [MissionComponent]?, sound: String?) {
        self.missionID = missionID
        self.type = type
        self.interractObject = interractObject
        self.neededObject = neededObject
        self.failedPrompt = failedPrompt
        self.successState = successState
        self.successPrompt = successPrompt
        self.sideMissionNeedToBeDone = sideMissionNeedToBeDone
        self.sound = sound
    }

    func success() {
        if sound != nil {
            AudioManager.shared.playAudio(fileName: sound!, isBGM: false)
        }
        for str in successState {
            let object = str.split(separator: "_").first.map({ String($0) })!
            let action = str.split(separator: "_").last.map({ String($0) })!
            
            guard let entity = entitySearcher(name: object) as? CustomEntity else { return }
            if action == "Remove" {
                entityManager.removePhysics(entity: entity)
                entityManager.removeEntity(entity: entity)
            } else if action == "Store" {
                entityManager.storeInventory(entity: entity)
            } else if action == "Change" {
                entity.changeState()
            }
        }
    }
    
    private func entitySearcher(name: String) -> GKEntity? {
        for entity in entityManager.entities {
            if entity.component(ofType: VisualComponent.self)?.visualNode.name == name {
                return entity
            }
        }
        return nil
    }
    
}
