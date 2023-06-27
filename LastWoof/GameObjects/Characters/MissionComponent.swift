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
    let successState: [String : String]
    let successPrompt: String
    var sideMissionNeedToBeDone: [MissionComponent]?
    
    init(missionID: String, type: MissionType, interractObject: [String]?, neededObject: String?, failedPrompt: String?, successState: [String : String], successPrompt: String, sideMissionNeedToBeDone: [MissionComponent]?) {
        self.missionID = missionID
        self.type = type
        self.interractObject = interractObject
        self.neededObject = neededObject
        self.failedPrompt = failedPrompt
        self.successState = successState
        self.successPrompt = successPrompt
        self.sideMissionNeedToBeDone = sideMissionNeedToBeDone
    }

    func succes() {
        for (object, action) in successState {
            if action == "Remove" {
                guard let entity = entitySearcher(name: object) else { return }
                entityManager.removeEntity(entity: entity)
            } else if action == "Store" {
                guard let entity = entitySearcher(name: object) else { return }
                entityManager.storeInventory(entity: entity)
                entityManager.removeEntity(entity: entity)
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

