//
//  MissionComponent.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 22/06/23.
//

import GameplayKit

class MissionComponent: GKComponent {
    let missionID: String
    let type: String
    var dependencies: [String]
    let prompt: String?
    
    init(missionID: String, type: String, dependencies: [String], prompt: String?) {
        self.missionID = missionID
        self.type = type
        self.dependencies = dependencies
        self.prompt = prompt
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
