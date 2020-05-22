//
//  GameScene.swift
//  SpaceRace
//
//  Created by Levit Kanner on 22/05/2020.
//  Copyright © 2020 Levit Kanner. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene , SKPhysicsContactDelegate{
    var starField: SKEmitterNode!
    var scoreLabel: SKLabelNode!
    var player: SKSpriteNode!
    var gameOverlabel: SKSpriteNode?
    var restartNode: SKLabelNode?
    
    let possibleEnemies = ["ball", "hammer" , "tv"]
    var gameOver = false
    var gameTimer: Timer?
    
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var delay:Double = 1
    var enemyCount = 20
    
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor.black
        
        guard let starfield = SKEmitterNode(fileNamed: "starfield") else {
            fatalError("Star field could not be found")
        }
        starField = starfield
        starField.position = CGPoint(x: 1024, y: 384)
        starField.advanceSimulationTime(10)
        addChild(starField)
        starField.zPosition = -1
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: \(score)"
        scoreLabel.position = CGPoint(x: 1000, y: 700)
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.fontSize = CGFloat(40)
        addChild(scoreLabel)
        
        createPlayer(at:  CGPoint(x: 100, y: 384))
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        gameTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        let allNodes = nodes(at: location)
        
        if let restartnode = restartNode{
            if allNodes.contains(restartnode){
                restart()
                return
            }
        }
        
        
        //Clamping touch location
        if location.y < 100 {
            location.y = 100
        }else if location.y > 668 {
            location.y = 700
        }
        
        player.position = location
    }
    
    
    
    @objc func createEnemy() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let enemyNode = SKSpriteNode(imageNamed: enemy)
        enemyNode.position = CGPoint(x: 1200, y: Int.random(in: 50...736))
        addChild(enemyNode)
        
        enemyCount += 1
        
        if enemyCount > 0 && enemyCount % 20 == 0 {
            gameTimer?.invalidate()
            
            delay -= 0.1
            gameTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
        }
        
        enemyNode.physicsBody = SKPhysicsBody(texture: enemyNode.texture!, size: enemyNode.size)
        enemyNode.physicsBody?.categoryBitMask = 1
        enemyNode.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        enemyNode.physicsBody?.angularVelocity = 5
        enemyNode.physicsBody?.linearDamping = 0
        enemyNode.physicsBody?.angularDamping = 0
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !gameOver{
            score += 1
        }
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let explosion = SKEmitterNode(fileNamed: "explosion") else { return }
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        
        gameOver = true
        
        gameOverlabel = SKSpriteNode(imageNamed: "gameOver")
        gameOverlabel!.position = CGPoint(x: 512, y: 384)
        gameOverlabel!.name = "gameover"
        addChild(gameOverlabel!)
        
        gameTimer?.invalidate()
        
        restartNode = SKLabelNode(fontNamed: "Chalkduster")
        restartNode!.position = CGPoint(x: 100, y: 700)
        restartNode?.text = "Restart"
        restartNode?.fontSize = CGFloat(40)
        restartNode!.name = "restartBtn"
        addChild(restartNode!)
    }
    
    
    
    func restart() {
        gameOverlabel?.removeFromParent()
        score = 0
        gameOver = false
        enemyCount = 0
        delay = 1
        createPlayer(at:  CGPoint(x: 100, y: 384))
        restartNode?.removeFromParent()
        gameTimer = Timer.scheduledTimer(timeInterval: delay, target: self, selector: #selector(createEnemy), userInfo: nil, repeats: true)
    }
    
    
    
    func createPlayer(at position: CGPoint) {
        player = SKSpriteNode(imageNamed: "player")
        player.position = position
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
    }
    
    
}
