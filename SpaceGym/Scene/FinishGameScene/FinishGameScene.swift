//
//  FinishGameScene.swift
//  SpaceGym
//
//  Created by Doni Pebruwantoro on 21/05/24.
//

import SpriteKit
import GameplayKit

class FinishGameScene: SKScene {
    private var label: SKLabelNode!

    override func sceneDidLoad() {
        super.sceneDidLoad()
        setupLabel()
    }

    private func setupLabel() {
        label = SKLabelNode(fontNamed: "Marker Felt")
        label.text = "FINISH"
        label.fontSize = 200
        label.position = CGPoint(x: 0, y: 0)
        label.horizontalAlignmentMode = .right
        label.zPosition = 1
        label.numberOfLines = 1
        addChild(label)
    }
}
