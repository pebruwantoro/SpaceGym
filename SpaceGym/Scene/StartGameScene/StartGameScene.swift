//
//  StartGameScene.swift
//  SpaceGym
//
//  Created by Doni Pebruwantoro on 20/05/24.
//

import SpriteKit
import GameplayKit

class StartGameScene: SKScene, SKPhysicsContactDelegate {
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
   
    private var lastUpdateTime : TimeInterval = 0

    private var isGameStart = false
    
    override func sceneDidLoad() {
//        obstacles()
//        self.lastUpdateTime = 0
//        self.player = self.childNode(withName: "Player")
//        self.background = self.childNode(withName: "Background")
//        scoreLabel()
//        levelLabel()
//        self.player?.physicsBody?.allowsRotation = false
//        self.bullet = self.childNode(withName: "Bullet")
//        self.bullet?.physicsBody?.allowsRotation = false
//        bulletMove()
        
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 59:
            isGameStart = true
        default:
            break
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 49:
            isGameStart = false
        default:
            break
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
//         Called before each frame is rendered
//
//         Initialize _lastUpdateTime if it has not already been
        if (self.lastUpdateTime == 0) {
            self.lastUpdateTime = currentTime
        }
        
        
        // Calculate time since last update
        let dt = currentTime - self.lastUpdateTime
        
        // Update entities
        for entity in self.entities {
            entity.update(deltaTime: dt)
        }
        
        self.lastUpdateTime = currentTime
        
        if isGameStart {
            
        }
    }
}
