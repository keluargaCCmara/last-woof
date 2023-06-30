//
//  MissionSystem.swift
//  Last Woof
//
//  Created by Leonardo Wijaya on 22/06/23.
//

import GameplayKit

class MissionSystem {
    
    var inventory: InventoryManager = InventoryManager.shared
    
    var gameState: GameState
    var missions = Set<MissionComponent>()
    
    init(gameState: GameState) {
        self.gameState = gameState
    }
    
    func addComponent(mission: MissionComponent) {
        missions.insert(mission)
    }
    
    func checkMission(entity: CustomEntity, characterHolding: String?) -> SKSpriteNode {
        let objectName = entity.component(ofType: VisualComponent.self)?.visualNode.name
        var missionGathered: MissionComponent?
        for case let mission in missions {
            if checkPlayerInterractedWith(objectName: objectName!, interractedObject: mission.interractObject ?? []) {
                missionGathered = mission
                if checkSideMissionCompleted(mission) == true && checkNeededObject(characterHolding: characterHolding, neededObject: mission.neededObject) == true {
                    gameState.setSideMissionComplete(mission)
                    mission.success()
                    checkMainMission()
                    missions.remove(mission)
                    return generateFadingTextNode(text: missionGathered!.successPrompt, fontSize: 20)
                }
            }
        }
        return generateFadingTextNode(text: missionGathered?.failedPrompt ?? "", fontSize: 20)
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
    
    func generateFadingTextNode(text: String, fontSize: CGFloat) -> SKSpriteNode {
        let label = SKLabelNode(text: text)
        label.fontSize = fontSize
        label.fontColor = .black
        label.fontName = "Arial-BoldMT"
        
        // Create a white background node with rounded corners
        let backgroundNodeSize = CGSize(width: label.frame.width + 50, height: label.frame.height + 50)
        let backgroundTexture = makeRoundedCornerTexture(size: backgroundNodeSize, cornerRadius: 10, color: UIColor.white.withAlphaComponent(0.75))
        let backgroundNode = SKSpriteNode(texture: backgroundTexture)
        backgroundNode.alpha = 0.0 // Initially invisible
        backgroundNode.zPosition = 100
        backgroundNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Center the label within the background node
        label.position = CGPoint(x: 0, y: -label.frame.height / 2)
        backgroundNode.addChild(label)
        
        // Create fade in and fade out actions
        let fadeInAction = SKAction.fadeIn(withDuration: 1.0)
        let fadeOutAction = SKAction.fadeOut(withDuration: 1.0)
        
        // Create a sequence of actions: fade in, wait, fade out
        let sequenceAction = SKAction.sequence([fadeInAction, SKAction.wait(forDuration: 2.0), fadeOutAction])
        
        // Run the sequence action on the background node
        backgroundNode.run(sequenceAction)
        
        return backgroundNode
    }
    
    func makeRoundedCornerTexture(size: CGSize, cornerRadius: CGFloat, color: UIColor) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let roundedRect = CGRect(origin: .zero, size: size).insetBy(dx: cornerRadius, dy: cornerRadius)
            let path = UIBezierPath(roundedRect: roundedRect, cornerRadius: cornerRadius)
            color.setFill()
            path.fill()
        }
        return SKTexture(image: image)
    }
    
    
}
