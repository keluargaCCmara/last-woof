//
//  GameViewController.swift
//  test-game
//
//  Created by Winxen Ryandiharvin on 15/06/23.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {
    
    lazy var skView: SKView = {
      let view = SKView()
      view.isMultipleTouchEnabled = true
      return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }

    fileprivate func setupViews() {
      view.addSubview(skView)
      
      skView.frame = CGRect(x: 0.0, y: 0.0, width: ScreenSize.width, height: ScreenSize.height)
      
      let scene = MainMenuScene(size: CGSize(width: ScreenSize.width, height: ScreenSize.height))
      scene.scaleMode = .aspectFill
      skView.presentScene(scene)
    }
}
