//
//  MemoriesScene.swift
//  Last Woof
//
//  Created by Angelica Patricia on 26/06/23.
//

import SpriteKit
import GameplayKit

class MemoriesScene: SKScene {
    private var background: SKSpriteNode?

    override func didMove(to view: SKView) {
        self.backgroundColor = SKColor.white
        guard let backgroundNode = childNode(withName: "background") as? SKSpriteNode else {
            fatalError("Background node not found in .sks file")
        }
        self.background = backgroundNode
        self.background?.zPosition = -1
        self.background?.alpha = 0
        self.background?.position = CGPoint(x: 0, y: 0)
        self.background?.size = CGSize(width: (scene?.size.width)!, height: (scene?.size.height)!)
    }
}
