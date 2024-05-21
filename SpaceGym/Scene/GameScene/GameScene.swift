//
//  GameScene.swift
//  SpaceGym
//
//  Created by Doni Pebruwantoro on 20/05/24.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var entities = [GKEntity]()
    var graphs = [String : GKGraph]()
    var level: Int {
        return GameManager.shared.currentLevel
    }
    
    enum Direction {
        case left
        case right
    }
    
    enum hitPoint {
        case object1
        case object2
        case object3
        case object4
        case object5
        case object6
        case object7
        case object8
    }

    private var lastUpdateTime : TimeInterval = 0
    private var player: SKNode?
    private var background: SKNode?
    private var startGame: SKNode?
    private var playerMoveRigth = false
    private var playerMoveLeft = false
    private var isContinueNextLevel = false
    private var isLastGame = false
    private var object1: SKNode?
    private var object2: SKNode?
    private var object3: SKNode?
    private var object4: SKNode?
    private var object5: SKNode?
    private var object6: SKNode?
    private var object7: SKNode?
    private var object8: SKNode?
    private var bullet: SKNode?
    
    private var scoreText: SKLabelNode!
    private var levelText: SKLabelNode!
    private var score = 0
    private var maxScore = 0
    private let rows = 20
    private let columns = 20
    let b = BluetoothManager()
   

    
    override func sceneDidLoad() {
        b.startScanning()
        GameManager.shared.checkFirstLaunch()
        obstacles()
        self.lastUpdateTime = 0
        self.player = self.childNode(withName: "Player")
        self.background = self.childNode(withName: "Background")
        scoreLabel()
        levelLabel()
        self.player?.physicsBody?.allowsRotation = false
        self.bullet = self.childNode(withName: "Bullet")
        self.bullet?.physicsBody?.allowsRotation = false
        bulletMove()
        
    }
    
    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123:
            playerMoveLeft = true
        case 124:
            playerMoveRigth = true
        default:
            break
        }
    }
    
    override func keyUp(with event: NSEvent) {
        switch event.keyCode {
        case 123:
            playerMoveLeft = false
        case 124:
            playerMoveRigth = false
        default:
            break
        }
    }
    
    private func scoreLabel() {
        self.scoreText = SKLabelNode(fontNamed: "Marker Felt")
        self.scoreText?.fontSize = 40
        self.scoreText?.position = CGPoint(x: 1350, y: 600)
        self.scoreText?.horizontalAlignmentMode = .right
        self.scoreText?.zPosition = 2
        self.scoreText?.numberOfLines = 2
        addChild(scoreText)
    }
    
    private func levelLabel() {
        self.levelText = SKLabelNode(fontNamed: "Marker Felt")
        self.levelText?.fontSize = 40        
        self.levelText?.position = CGPoint(x: 1350, y: 750)
        self.levelText?.horizontalAlignmentMode = .right
        self.levelText?.zPosition = 2
        self.levelText?.numberOfLines = 2
        self.levelText?.text = "Level:\n \(self.level)"
        addChild(levelText)
    }
    
    private class HitObject: SKSpriteNode {
        var hitCount: Int = 0
        var objectName: String = ""
    }
    
    private func getHitCountObject(object: HitObject)-> Int {
        switch object.objectName {
            case "Object1": 1
            case "Object2": 2
            case "Object3": 3
            case "Object4": 4
            case "Object5": 5
            case "Object6": 6
            case "Object7": 7
            case "Object8": 8
        default:
            0
        }
    }
    
    private func obstacles() {
        let xPositionMin = -1100.00
        let xPositionMax = 1200.00
        let yPositionMax = 760.00
        let yPositionMin = 100.00
        let spacing: CGFloat = 150
        let objectSize = CGSize(width: 10, height: 10)

        for row in 0..<rows {
            for col in 0..<columns {
                if xPositionMax >= xPositionMin + CGFloat(col) * (objectSize.width + spacing) && yPositionMax >= yPositionMin + CGFloat(row) * (objectSize.height + spacing) {
                    if row >= 1 && row < 4 && col >= 5 && col < 10 {
                        if row == 2 && col == 7 {
                            let object = createObject(image: "Object\(self.level+2)", xPosition: xPositionMin + CGFloat(col) * (objectSize.width + spacing), yPosition: yPositionMin + CGFloat(row) * (objectSize.height + spacing))
                            object.objectName = object.name ?? ""
                            object.hitCount = getHitCountObject(object: object)
                            self.maxScore += object.hitCount
                            addChild(object)

                        } else {
                            let object = createObject(image: "Object\(self.level+1)", xPosition: xPositionMin + CGFloat(col) * (objectSize.width + spacing), yPosition: yPositionMin + CGFloat(row) * (objectSize.height + spacing))
                            object.objectName = object.name ?? ""
                            object.hitCount = getHitCountObject(object: object)
                            self.maxScore += object.hitCount
                            addChild(object)
                        }
                    } else {
                        let object = createObject(image: "Object\(self.level)", xPosition: xPositionMin + CGFloat(col) * (objectSize.width + spacing), yPosition: yPositionMin + CGFloat(row) * (objectSize.height + spacing))
                        object.objectName = object.name ?? ""
                        object.hitCount = getHitCountObject(object: object)
                        self.maxScore += object.hitCount
                        addChild(object)
                    }
                }
            }
        }
    }
    
    private func createObject(image: String, xPosition : Double, yPosition: Double) -> HitObject {
        let objectNode = HitObject(imageNamed: image)
        objectNode.position = CGPoint(x: xPosition, y: yPosition)
        objectNode.zPosition = 1
        objectNode.name = image
        
        objectNode.physicsBody = SKPhysicsBody(rectangleOf: objectNode.size)
        objectNode.physicsBody?.categoryBitMask = PhysicsCategory.Object
        objectNode.physicsBody?.contactTestBitMask = PhysicsCategory.Bullet
        objectNode.physicsBody?.collisionBitMask = PhysicsCategory.None
        objectNode.physicsBody?.affectedByGravity = false

        
        return objectNode
    }
    
    private func bulletMove() {
        bulletPhysicsBody()
        
        let maxHeight = CGFloat((self.background?.frame.size.height ?? 0) / 2 - 200)
        let startYposition = self.bullet?.position.y ?? 0
        
        let wait = SKAction.wait(forDuration: 0.001)
        let updatePosition = SKAction.run {[weak self] in
            if self?.bullet?.position.y ?? 0 <= maxHeight {
                self?.bullet?.position.y += 30
            } else {
                self?.bullet?.position.y = startYposition
            }
            
            self?.bullet?.position.x = self?.player?.position.x ?? 0
        }
        let sequence = SKAction.sequence([wait, updatePosition])
        let repeatForever = SKAction.repeatForever(sequence)
        run(repeatForever)
    }
    
    private func bulletPhysicsBody() {
        physicsWorld.contactDelegate = self

        if let bulletSize = self.bullet?.frame.size {
            self.bullet?.physicsBody = SKPhysicsBody(rectangleOf: bulletSize)
            self.bullet?.physicsBody?.categoryBitMask = PhysicsCategory.Bullet
            self.bullet?.physicsBody?.contactTestBitMask = PhysicsCategory.Object
            self.bullet?.physicsBody?.collisionBitMask = PhysicsCategory.None
            self.bullet?.physicsBody?.affectedByGravity = false
        }
    }
    
    private func movePlayer(direction: Direction) {
        let moveAction: SKAction
        let moveDistance: CGFloat = 10.0
        let maxWidth = CGFloat(((self.background?.frame.size.width ?? 0) / 2) - 200)
       
        switch direction {
        case .left:
            let newPosition = CGFloat(self.player?.position.x ?? 0) - moveDistance
            
            if newPosition >= -maxWidth {
                moveAction = SKAction.moveBy(x: -moveDistance, y: 0, duration: 0.1)
                self.player?.run(moveAction)
            }
            
        case .right:
            let newPosition = CGFloat(self.player?.position.x ?? 0) + moveDistance
            if newPosition <= maxWidth {
                moveAction = SKAction.moveBy(x: moveDistance, y: 0, duration: 0.1)
                self.player?.run(moveAction)
            }
        }
    }
    
    struct PhysicsCategory {
        static let None: UInt32 = 0
        static let Bullet: UInt32 = 0b1
        static let Object: UInt32 = 0b10
    }

    private func bulletDidCollideWithObject(object: HitObject) {
        object.hitCount -= 1
        if object.hitCount == 0 {
            switch object.name {
            case "Object1": score += 1
            case "Object2": score += 2
            case "Object3": score += 3
            case "Object4": score += 4
            case "Object5": score += 5
            case "Object6": score += 6
            case "Object7": score += 7
            case "Object8": score += 8
        default:
            score += 0
            }
            object.run(removalAnimation())
            self.scoreText?.text = "Score:\n \(score)"
            if score == maxScore {
                self.isContinueNextLevel = true
            }
        }
    }

    func removalAnimation() -> SKAction {
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let scaleDown = SKAction.scale(to: 0.0, duration: 0.2)
        let group = SKAction.group([fadeOut, scaleDown])
        let remove = SKAction.removeFromParent()
        return SKAction.sequence([group, remove])
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody: SKPhysicsBody
        let secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & PhysicsCategory.Bullet != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.Object != 0) {
            if let object = secondBody.node as? HitObject {
                bulletDidCollideWithObject(object: object)
            }
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
        
        if playerMoveLeft {
            movePlayer(direction: .left)
        }
        
        if playerMoveRigth {
            movePlayer(direction: .right)
        }
        
        if isContinueNextLevel && level <= 6 {
            if let scene = NextLevelScene(fileNamed: "NextLevelScene") {
                scene.scaleMode = .aspectFill
                scene.view?.showsFPS = false
                scene.view?.showsNodeCount = false
                self.view?.presentScene(scene)
                if level == 6 {
                    self.isLastGame = true
                }
            }
        }
        
        if isLastGame {
            if let scene = FinishGameScene(fileNamed: "FinishGameScene") {
                scene.scaleMode = .aspectFill
                scene.view?.showsFPS = false
                scene.view?.showsNodeCount = false
                self.view?.presentScene(scene)
            }
        }
    }
}
