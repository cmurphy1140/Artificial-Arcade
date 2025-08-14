//
//  GameViewController.swift
//  Artificial Arcade
//
//  Created by Connor A Murphy on 8/9/25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize user system
        UserManager.shared.initializeUserSystem()
        
        // Determine which scene to show
        let scene: SKScene
        if UserManager.shared.currentUser == nil || !UserDefaults.standard.bool(forKey: "HasSeenLogin") {
            // First time or no user - show login
            scene = LoginScene(size: CGSize(width: 375, height: 667))
            UserDefaults.standard.set(true, forKey: "HasSeenLogin")
        } else {
            // Existing user - go to main menu
            scene = ArcadeMenuScene(size: CGSize(width: 375, height: 667))
        }
        
        scene.scaleMode = .aspectFill
        
        // Present the scene
        guard let view = self.view as? SKView else {
            print("Error: Could not cast view to SKView")
            return
        }
        
        view.presentScene(scene)
        view.ignoresSiblingOrder = true
        view.showsFPS = false
        view.showsNodeCount = false
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
