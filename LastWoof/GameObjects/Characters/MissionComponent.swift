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
    let interractObject: String?
    let neededObject: String?
    let failedPrompt: String?
    let successPrompt: String?
    
    init(missionID: String, type: String, interractObject: String?, neededObject: String?, failedPrompt: String?, successPrompt: String?) {
        self.missionID = missionID
        self.type = type
        self.interractObject = interractObject
        self.neededObject = neededObject
        self.failedPrompt = failedPrompt
        self.successPrompt = successPrompt
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
