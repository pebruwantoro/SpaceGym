//
//  NextLevelScene.swift
//  SpaceGym
//
//  Created by Doni Pebruwantoro on 20/05/24.
//

import SpriteKit
import GameplayKit

class NextLevelScene: SKScene {
    private var count = 5
    private var countLabel: SKLabelNode!
    private var timer: Timer?

    override func sceneDidLoad() {
        super.sceneDidLoad()
        setupLabel()
        countDown()
    }

    private func setupLabel() {
        countLabel = SKLabelNode(fontNamed: "Marker Felt")
        countLabel.text = "\(self.count)"
        countLabel.fontSize = 120
        countLabel.position = CGPoint(x: 0, y: 0)
        countLabel.horizontalAlignmentMode = .right
        countLabel.zPosition = 1
        countLabel.numberOfLines = 1
        addChild(countLabel)
    }

    private func countDown() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if GameManager.shared.currentLevel < 7 {
                if self.count > 0 {
                    self.countLabel.text = "\(self.count)"
                    self.count -= 1
                } else {
                    transitionToNextScene()
                    self.timer?.invalidate()
                    self.timer = nil
                }
            }

            if GameManager.shared.currentLevel == 7 {
                finishGame()
            }
            
            
        }
    }
    
    private func finishGame() {
        if let scene = FinishGameScene(fileNamed: "FinishGameScene") {
            scene.scaleMode = .aspectFill
            scene.view?.showsFPS = false
            scene.view?.showsNodeCount = false
            self.view?.presentScene(scene)
        }
    }

    private func transitionToNextScene() {
        GameManager.shared.currentLevel += 1
        if let scene = GKScene(fileNamed: "GameScene"),
           let sceneNode = scene.rootNode as? GameScene {
            sceneNode.scaleMode = .aspectFill
            let transition = SKTransition.fade(withDuration: 0.1)
            self.view?.presentScene(sceneNode, transition: transition)
            self.view?.showsFPS = false
            self.view?.showsNodeCount = false
        }
    }
}
