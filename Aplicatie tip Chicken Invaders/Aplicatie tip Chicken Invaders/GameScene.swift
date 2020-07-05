//
//  GameScene.swift
//  Aplicatie tip Chicken Invaders
//
//  Created by user169232 on 5/5/20.
//  Copyright © 2020 user169232. All rights reserved.
//

import SpriteKit
import GameplayKit


var gameScore = 0//ca sa poata fi accesata si in alte scene


class GameScene: SKScene,SKPhysicsContactDelegate {
    
    let player = SKSpriteNode(imageNamed: "playerShip")
    
    let bulletSound = SKAction.playSoundFileNamed("bulletSoundEffect.wav", waitForCompletion: false)
    
    let scoreLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    let livesLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    let tapToStartLabel = SKLabelNode(fontNamed: "The Bold Font")
    
    var levelNumber = 0
    
    var livesNumber = 3
    
    
    enum gameState{
        case preGame //cand stadiul jocului este inainte de startul jocului
        case inGame // cand stadiul jocului este in timpul jocului
        case afterGame //cand stadiul jocului este dupa startul jocului
    }
    
    
    var currentGameState = gameState.preGame
    
    
    struct PhysicsCategories{
        static let None: UInt32 = 0
        static let Player: UInt32 = 0b1 //1 in binar
        static let Bullet: UInt32 = 0b10 //2 in binar
        static let Enemy: UInt32 = 0b100 //4 in binar
        }
    
    
    //func random() -> CGFloat{
    //    return CGFloat(Float(arc4random() / 0xFFFFFFFF))
   // }
    
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        //return random() * (max - min) + min
        
        return CGFloat(arc4random_uniform(UInt32(max - min)) + UInt32(min))
    }
    
    
    let gameArea: CGRect
    
    override init(size: CGSize){
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        
        super.init(size: size)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func didMove(to view: SKView) {
        
        gameScore = 0
        
        self.physicsWorld.contactDelegate = self
        
        //for dynamic background
        for i in 0...1{
            
        let background = SKSpriteNode(imageNamed: "background")
        background.size = self.size
        background.anchorPoint = CGPoint(x: 0.5, y: 0)//punctul care se bazeaza pe pozitia background-ului
        background.position = CGPoint(x: self.size.width/2, y: self.size.height*CGFloat(i))
        background.zPosition = 0
        background.name = "Background"
        self.addChild(background)
        }
        
       
        player.setScale(1)
        player.position = CGPoint(x: self.size.width/2, y: 0 - player.size.height)//jucatorul va veni de sub ecran
        player.zPosition = 2
        //physicsBody
        player.physicsBody = SKPhysicsBody(rectangleOf: player.size)
        player.physicsBody!.affectedByGravity = false
        player.physicsBody!.categoryBitMask = PhysicsCategories.Player//categorie player
        player.physicsBody!.collisionBitMask = PhysicsCategories.None//ciocnire
        player.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy//contact
        self.addChild(player)
        
        
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 70
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width*0.15, y: self.size.height + scoreLabel.frame.size.height)
        scoreLabel.zPosition = 100
        self.addChild(scoreLabel)
        
        
        livesLabel.text = "Lives: 3"
        livesLabel.fontSize = 70
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width*0.85, y: self.size.height + livesLabel.frame.size.height)
        livesLabel.zPosition = 100
        self.addChild(livesLabel)
        
        
        //mutam scorul si vietile pe ecran
        let moveOnToScreenAction = SKAction.moveTo(y: self.size.height*0.9, duration: 0.3)
        scoreLabel.run(moveOnToScreenAction)
        livesLabel.run(moveOnToScreenAction)
        
        
        tapToStartLabel.text = "Tap To Begin"
        tapToStartLabel.fontSize = 100
        tapToStartLabel.fontColor = SKColor.white
        tapToStartLabel.zPosition = 1
        tapToStartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        tapToStartLabel.alpha = 0//transparenta(invizibil)
        self.addChild(tapToStartLabel)
        
        
        let fadeInAction = SKAction.fadeIn(withDuration: 0.3)
        tapToStartLabel.run(fadeInAction)
        }
    
    
    var lastUpdateTime: TimeInterval = 0//secunde
    var deltaFrameTime: TimeInterval = 0//secunde, timpul trecut
    var amountToMovePerSecond: CGFloat = 600.0//puncte mutate pe secunda
    
    
    //functia ruleaza o data per game frame(game loop)
    //ruleaza de cate frame-uri are jocul
    override func update(_ currentTime: TimeInterval) {
        
        if lastUpdateTime == 0{
                lastUpdateTime = currentTime
            }
            
        else{
            deltaFrameTime = currentTime - lastUpdateTime
            lastUpdateTime = currentTime
        }
        
        
        let amountToMoveBackground = amountToMovePerSecond * CGFloat(deltaFrameTime)
        
        
        self.enumerateChildNodes(withName: "Background"){//lista
            background, stop in
            
            if self.currentGameState == gameState.inGame{
            background.position.y -= amountToMoveBackground
            }
            
            //cand ecranul paraseste josul ecranului, il aducem inapoi
            if background.position.y < -self.size.height{
                background.position.y += self.size.height*2
            }
        }
    }

    
    func startGame(){
        
        currentGameState = gameState.inGame
        
        let fadeOutAction = SKAction.fadeOut(withDuration: 0.5)
        let deleteAction = SKAction.removeFromParent()
        let deleteSequence = SKAction.sequence([fadeOutAction, deleteAction])
        tapToStartLabel.run(deleteSequence)
        
        let moveShipOntoScreenAction = SKAction.moveTo(y: self.size.height*0.2, duration: 0.5)
        let startLevelAction = SKAction.run(startNewLevel)
        let startGameSequence = SKAction.sequence([moveShipOntoScreenAction, startLevelAction])
        player.run(startGameSequence)
        }
    
    
    func loseALife(){
        
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"//afisam vietile ramase
        
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1, duration: 0.2)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        livesLabel.run(scaleSequence)
        
        if livesNumber == 0{
            runGameOver()
        }
    }
    
    
    func addScore(){
        
        gameScore += 1
        scoreLabel.text = "Score: \(gameScore)"//afisam scorul actual
        
        if gameScore == 10 || gameScore == 20 || gameScore == 30{
            startNewLevel()
        }
    }
    
    
    func runGameOver(){
        
        currentGameState = gameState.afterGame
        
        self.removeAllActions()
        
        //stergem toate gloantele din lista
        self.enumerateChildNodes(withName: "Bullet"){
            bullet, stop in
            bullet.removeAllActions()
            
        }
        
        //stergem toti inamicii din lista
        self.enumerateChildNodes(withName: "Enemy"){
            enemy, stop in
            enemy.removeAllActions()
        }
        
        let changeSceneAction = SKAction.run(changeScene)
        let waitToChangeScene = SKAction.wait(forDuration: 1)
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, changeSceneAction])
        self.run(changeSceneSequence)
        }
    

    func changeScene(){
        
        let sceneToMoveTo = GameOverScene(size: self.size)
        sceneToMoveTo.scaleMode = self.scaleMode
        let myTransition = SKTransition.fade(withDuration: 0.5)
        self.view!.presentScene(sceneToMoveTo, transition: myTransition)
        }
    
    
    //ruleaza atunci cand are loc un contact, functia pentru contact
    func didBegin( _ contact: SKPhysicsContact) {
        
        var body1 = SKPhysicsBody()
        var body2 = SKPhysicsBody()
        
        //pentru ordine crescatoare
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask{
            body1 = contact.bodyA
            body2 = contact.bodyB
        }
            
        else{
            body1 = contact.bodyB
            body2 = contact.bodyA
        }
        
        //daca jucatorul loveste inamicul
        if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy{
            
            //pentru eventuale crash-uri
            if body1.node != nil{
            spawnExplosion(spawnPosition: body1.node!.position)
            }
            
            if body2.node != nil{
            spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            //distrugere corpuri
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            
            runGameOver()
            }
        
        //daca glontul loveste inamicul cand este pe ecran
        if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy && (body2.node?.position.y)! < self.size.height{
            
            addScore()
            
            //pentru eventuale crash-uri
            if body2.node != nil{
            spawnExplosion(spawnPosition: body2.node!.position)
            }
            
            //distrugere corpuri
            body1.node?.removeFromParent()
            body2.node?.removeFromParent()
            }
        }
    
    
    func spawnExplosion(spawnPosition: CGPoint){
        
        let explosion = SKSpriteNode(imageNamed: "explosion")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.setScale(0)
        self.addChild(explosion)
        
        let scaleIn = SKAction.scale(to: 1, duration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let delete = SKAction.removeFromParent()
        
        let explosionSequence = SKAction.sequence([scaleIn, fadeOut, delete])
        
        explosion.run(explosionSequence)
        
    }
    
    
    func startNewLevel(){
        
        levelNumber += 1
        
        //oprim spawnarea inamicilor
        if self.action(forKey: "spawningEnemies") != nil{
            self.removeAction(forKey: "spawningEnemies")
        }
        
        var levelDuration = TimeInterval()
        
        //setarea diferentei de timp intre spawnari in functie de level
        switch levelNumber{
        case 1: levelDuration = 1.2
        case 2: levelDuration = 1
        case 3: levelDuration = 0.8
        case 4: levelDuration = 0.5
        default:
            levelDuration = 0.5
            print("Nu am gasit informatii despre level")
        }
        
        let spawn = SKAction.run(spawnEnemy)
        let waitToSpawn = SKAction.wait(forDuration: levelDuration)
        let spawnSequence = SKAction.sequence([waitToSpawn, spawn])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        self.run(spawnForever, withKey: "spawningEnemies")
        }
    
    
    func fireBullet() {
        
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        
        bullet.setScale(1)
        bullet.position = player.position
        bullet.zPosition = 1
        //physicsBody
        bullet.physicsBody = SKPhysicsBody(rectangleOf: bullet.size)
        bullet.physicsBody!.affectedByGravity = false
        bullet.physicsBody!.categoryBitMask = PhysicsCategories.Bullet//categorie glont
        bullet.physicsBody!.collisionBitMask = PhysicsCategories.None//ciocnire
        bullet.physicsBody!.contactTestBitMask = PhysicsCategories.Enemy//contact
        
        self.addChild(bullet)
        
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1)
        let deleteBullet = SKAction.removeFromParent()
        
        let bulletSequence = SKAction.sequence([bulletSound, moveBullet, deleteBullet])
        bullet.run(bulletSequence)
        }
    
    
    func spawnEnemy(){
        
        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        
        let enemy = SKSpriteNode(imageNamed: "enemyShip")
        enemy.name = "Enemy"
        enemy.setScale(1)
        enemy.position = startPoint
        enemy.zPosition = 2
        //physicsBody
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody!.affectedByGravity = false
        enemy.physicsBody!.categoryBitMask = PhysicsCategories.Enemy//categorie nava inamica
        enemy.physicsBody!.collisionBitMask = PhysicsCategories.None//ciocnire
        enemy.physicsBody!.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet//contact
        
        self.addChild(enemy)
        
        let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
        let deleteEnemy = SKAction.removeFromParent()
        let loseALifeAction = SKAction.run(loseALife)//daca ajunge la destinatie pierdem o viata
        let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy,loseALifeAction])
        
        //daca timpul de spawnare e fix atunci cand vom schimba scena(rar)
        if currentGameState == gameState.inGame{
        enemy.run(enemySequence)
        }
        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let amountToRotate = atan2(dy, dx)
        enemy.zRotation = amountToRotate
        }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == gameState.preGame{
            startGame()
        }
        
            //pentru partea cand se putea trage in freeze(game over)
        else if currentGameState == gameState.inGame{
            fireBullet()
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches{
            
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
            let amountDragged = pointOfTouch.x - previousPointOfTouch.x
            
            //pentru partea cand se putea misca in freeze(game over)
            if currentGameState == gameState.inGame{
            player.position.x += amountDragged
            }
            
            if player.position.x >= gameArea.maxX - player.size.width/2{
                player.position.x = gameArea.maxX - player.size.width/2
                }
            
            if player.position.x <= gameArea.minX + player.size.width/2{
                player.position.x = gameArea.minX + player.size.width/2
            }
        }
        
    }
    
}

