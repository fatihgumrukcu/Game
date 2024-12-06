import SpriteKit
import AVFoundation

class GameScene: SKScene, SKPhysicsContactDelegate {
    var duck: SKSpriteNode!
    var gameOverLabel: SKSpriteNode!
    var tryAgainButton: SKSpriteNode!
    var scoreLabel: SKSpriteNode!
    var scoreValueLabel: SKLabelNode!
    var gameStarted = false
    var touchOffset: CGPoint? = nil
    var spawnInterval: Double = 1.0
    var score: Int = 0
    var poisonedEggImage: SKTexture!
    var multiplierFourEggImage: SKTexture! // Yeni yumurtanın görseli
    var powerEggImage: SKTexture!
    var backgroundImage: SKSpriteNode!
    var duckImage: SKTexture!
    var obstacleImage: SKTexture!
    var isPoweredUp = false  // PowerEgg etkisini takip eder
    var thornsImage: SKTexture!
    var multiplierActive = false // Çarpanın aktif olup olmadığını takip eder
    var multiplierTwoNode: SKSpriteNode! // x2 çarpanı görseli
    var multiplierDuration: Double = 10.0 // Çarpanın aktif kalma süresi




    
    override func didMove(to view: SKView) {
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        loadAssets()
        setupBackground()
        setupDuck()
        setupGameOverUI()
        setupScoreUI()
        setupBackground()
    }
    
    func loadAssets() {
        duckImage = SKTexture(imageNamed: "duckgame.png")
        obstacleImage = SKTexture(imageNamed: "thorn.png")
        thornsImage = SKTexture(imageNamed: "thorns.png") // Yeni görseli yükle
        backgroundImage = SKSpriteNode(texture: SKTexture(imageNamed: "bg.png"))
        poisonedEggImage = SKTexture(imageNamed: "poisonedegg.png")
        multiplierFourEggImage = SKTexture(imageNamed: "multiplerfouregg.png")
        powerEggImage = SKTexture(imageNamed: "poweregg.png")
    }

    
    func setupBackground() {
        // Arkaplan görselini ekle
        let background = SKSpriteNode(imageNamed: "mainscreen")
        background.position = CGPoint(x: size.width / 2, y: size.height / 2) // Orta noktaya yerleştir
        background.size = size // Ekran boyutuna ayarla
        background.zPosition = -1 // Diğer öğelerin arkasında olması için zPosition negatif bir değer
        addChild(background) // Sahneye ekle
    }


    
    func setupDuck() {
        duck = SKSpriteNode(texture: duckImage)
        duck.position = CGPoint(x: size.width / 2, y: size.height / 4)
        duck.physicsBody = SKPhysicsBody(texture: duck.texture!, size: duck.size)
        duck.physicsBody?.isDynamic = false
        duck.physicsBody?.affectedByGravity = false
        duck.physicsBody?.allowsRotation = false
        duck.physicsBody?.linearDamping = 1.0
        duck.physicsBody?.angularDamping = 1.0
        duck.physicsBody?.categoryBitMask = PhysicsCategory.duck
        duck.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.poisonedEgg | PhysicsCategory.powerEgg
        duck.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(duck)
    }
    
    func setupGameOverUI() {
        gameOverLabel = SKSpriteNode(imageNamed: "gameover.png")
        gameOverLabel.position = CGPoint(x: size.width / 2, y: size.height / 2 + 50)
        gameOverLabel.setScale(0.5)
        gameOverLabel.zPosition = 100
        gameOverLabel.isHidden = true
        addChild(gameOverLabel)
        
        tryAgainButton = SKSpriteNode(imageNamed: "tryagain.png")
        tryAgainButton.name = "tryagain"
        tryAgainButton.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
        tryAgainButton.setScale(0.5)
        tryAgainButton.zPosition = 100
        tryAgainButton.isHidden = true
        addChild(tryAgainButton)
    }
    func setupScoreUI() {
        // Score görselini ayarlayın
        scoreLabel = SKSpriteNode(imageNamed: "score.png")
        scoreLabel.setScale(0.5) // Görsel boyutunu ayarlar
        scoreLabel.position = CGPoint(x: size.width / 1 - scoreLabel.size.width / 1, y: size.height - 100)
        addChild(scoreLabel)
        
        // Skor değerini ayarlayın
        scoreValueLabel = SKLabelNode(fontNamed: "PixelifySans-Bold")
        scoreValueLabel.text = "0"
        scoreValueLabel.fontSize = 40 // Skor yazısının boyutunu ayarlar
        scoreValueLabel.fontColor = .white // Başlangıçta beyaz renk
        scoreValueLabel.horizontalAlignmentMode = .left // Soldan hizalama
        scoreValueLabel.position = CGPoint(
            x: scoreLabel.position.x + scoreLabel.size.width / 2 - 50,
            y: scoreLabel.position.y - 13.5
        )
        addChild(scoreValueLabel)
        
        // Çarpan görseli
        multiplierTwoNode = SKSpriteNode(imageNamed: "multiplertwo.png")
        multiplierTwoNode.name = "multiplierTwoNode"
        multiplierTwoNode.setScale(0.1) // Görsel boyutunu ayarla
        multiplierTwoNode.position = CGPoint(
            x: scoreValueLabel.position.x + 100, // Skorun sağında görünmesi için pozisyon
            y: scoreValueLabel.position.y
        )
        multiplierTwoNode.zPosition = 10
        multiplierTwoNode.isHidden = true // Başlangıçta gizli
        addChild(multiplierTwoNode)
    }

    func activateMultiplier() {
        guard let multiplierNode = multiplierTwoNode else { return }
        
        multiplierNode.isHidden = false
        multiplierActive = true
        
        // Skor rengini değiştir
        scoreValueLabel.fontColor = UIColor(red: 240/255, green: 44/255, blue: 59/255, alpha: 1.0) // #f02c3b
        
        multiplierNode.position = CGPoint(x: scoreValueLabel.position.x + 110, // Skorun sağında
                                           y: scoreValueLabel.position.y)
        multiplierNode.setScale(0.2) // Küçük bir başlangıç boyutu (örnek: %20 küçülme)
        // Pop-up animasyonu
        let startScale: CGFloat = 0.1
        let endScale: CGFloat = 0.3
        multiplierNode.setScale(startScale)
        
        let scaleUp = SKAction.scale(to: endScale * 1.2, duration: 0.2)
        let scaleDown = SKAction.scale(to: endScale, duration: 0.1)
        let popUpEffect = SKAction.sequence([scaleUp, scaleDown])
        
        multiplierNode.run(popUpEffect)
        
        // 10 saniye sonra çarpanı devre dışı bırak
        let wait = SKAction.wait(forDuration: multiplierDuration)
        let deactivate = SKAction.run { [weak self] in
            self?.deactivateMultiplier()
        }
        let sequence = SKAction.sequence([wait, deactivate])
        run(sequence, withKey: "multiplierTimer")
    }

    func deactivateMultiplier() {
        guard let multiplierNode = multiplierTwoNode else { return }
        
        let scaleDown = SKAction.scale(to: 0.1, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let disappear = SKAction.group([scaleDown, fadeOut])
        
        multiplierNode.run(disappear) {
            multiplierNode.isHidden = true
            multiplierNode.alpha = 1.0
            multiplierNode.setScale(0.3) // Orijinal boyuta döndür
        }
        
        // Skor rengini eski haline döndür
        scoreValueLabel.fontColor = .white // Orijinal renk
        
        multiplierActive = false
    }

    func startGame() {
        gameStarted = true
        duck.physicsBody?.isDynamic = true
        spawnObstacles()
        spawnEggs()
        
        let increaseScore = SKAction.run { self.incrementScore() }
        let delay = SKAction.wait(forDuration: 1.0)
        let scoreSequence = SKAction.sequence([increaseScore, delay])
        let scoreForever = SKAction.repeatForever(scoreSequence)
        run(scoreForever, withKey: "scoring")
    }
    
    func incrementScore() {
        if multiplierActive {
            score += 2 // multiplierTwoNode aktifse skoru 2 ile çarp
        } else {
            score += 1 // multiplier aktif değilse normal artış
        }
        
        scoreValueLabel.text = "\(score)"
        
        // Skor belirli değerlere ulaştığında özel durumları kontrol et
        if score >= 10 && !multiplierActive {
            activateMultiplier() // Çarpanı etkinleştir
        }
        
        // PowerEgg'in daha sık görünmesini sağla
        if score >= 30 {
            spawnEggs()
        }
    }


    
    func spawnObstacles() {
        let spawn = SKAction.run {
            let obstacleType = Int.random(in: 0...1) // 0 veya 1
            if obstacleType == 0 {
                self.createObstacle() // Statik engel
            } else {
                self.spawnMovingThorns() // Hareket eden engel
            }
        }
        let delay = SKAction.wait(forDuration: spawnInterval)
        let spawnSequence = SKAction.sequence([spawn, delay])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        run(spawnForever, withKey: "spawnObstacles")
    }

    
    func createObstacle() {
        let obstacle = SKSpriteNode(texture: obstacleImage)
        obstacle.size = CGSize(width: obstacleImage.size().width, height: obstacleImage.size().height)
        
        var randomX: CGFloat
        var position: CGPoint
        
        repeat {
            randomX = CGFloat.random(in: obstacle.size.width / 2...size.width - obstacle.size.width / 2)
            position = CGPoint(x: randomX, y: size.height)
        } while isOverlappingWithExistingObjects(position: position, size: obstacle.size)
        
        obstacle.position = position
        obstacle.name = "obstacle"
        obstacle.physicsBody = SKPhysicsBody(texture: obstacle.texture!, size: obstacle.size)
        obstacle.physicsBody?.isDynamic = true
        obstacle.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        obstacle.physicsBody?.contactTestBitMask = PhysicsCategory.duck
        obstacle.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(obstacle)
        
        let moveDown = SKAction.moveTo(y: -obstacle.size.height, duration: 3.0)
        let remove = SKAction.removeFromParent()
        obstacle.run(SKAction.sequence([moveDown, remove]))
    }


    func isOverlappingWithExistingObjects(position: CGPoint, size: CGSize, padding: CGFloat = 10.0) -> Bool {
        // Yeni nesnenin genişletilmiş çerçevesini oluştur
        let newFrame = CGRect(
            x: position.x - size.width / 2 - padding,
            y: position.y - size.height / 2 - padding,
            width: size.width + 2 * padding,
            height: size.height + 2 * padding
        )
        
        // Mevcut nesnelerin çerçeveleriyle çakışmayı kontrol et
        for node in children {
            if node.name == "obstacle" ||
                node.name == "poisonedEgg" ||
                node.name == "powerEgg" ||
                node.name == "thorns" {
   
                let existingFrame = node.calculateAccumulatedFrame()
                if newFrame.intersects(existingFrame) {
                    return true
                }
            }
        }
        return false
    }

    func spawnThorns() {
        let thorns = SKSpriteNode(texture: thornsImage)
        thorns.size = CGSize(width: obstacleImage.size().width, height: obstacleImage.size().height)

        var randomX: CGFloat
        var position: CGPoint
        
        repeat {
            randomX = CGFloat.random(in: thorns.size.width / 2...size.width - thorns.size.width / 2)
            position = CGPoint(x: randomX, y: size.height)
        } while isOverlappingWithExistingObjects(position: position, size: thorns.size)
        
        thorns.position = position
        thorns.name = "thorns"
        thorns.physicsBody = SKPhysicsBody(texture: thorns.texture!, size: thorns.size)
        thorns.physicsBody?.isDynamic = true
        thorns.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        thorns.physicsBody?.contactTestBitMask = PhysicsCategory.duck
        thorns.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(thorns)

        let moveDown = SKAction.moveTo(y: -thorns.size.height, duration: 3.5)
        let remove = SKAction.removeFromParent()
        thorns.run(SKAction.sequence([moveDown, remove]))
    }

    func spawnEggs() {
        guard gameStarted, score >= 10 else { return }
        
        if children.contains(where: { $0.name == "poisonedEgg" || $0.name == "powerEgg" || $0.name == "multiplierFourEgg" }) {
            return
        }
        
        let spawnPoisonedEgg = SKAction.run {
            if Int.random(in: 0...99) < 25 { // %25 olasılık
                self.spawnPoisonedEgg(at: self.randomEggPosition())
            }
        }
        let spawnPowerEgg = SKAction.run {
            if Int.random(in: 0...99) < 25 { // %25 olasılık
                self.spawnPowerEgg(at: self.randomEggPosition())
            }
        }
        let spawnMultiplierFourEgg = SKAction.run {
            if Int.random(in: 0...99) < 25 { // %10 olasılık
                self.spawnMultiplierFourEgg(at: self.randomEggPosition())
            }
        }
        
        let delay = SKAction.wait(forDuration: 2.5)
        run(SKAction.repeatForever(SKAction.sequence([spawnPoisonedEgg, delay, spawnPowerEgg, delay, spawnMultiplierFourEgg])), withKey: "spawnEggs")
    }

    func spawnMultiplierFourEgg(at position: CGPoint) {
        let multiplierFourEgg = SKSpriteNode(texture: multiplierFourEggImage)
        multiplierFourEgg.size = CGSize(width: 150, height: 150) // Boyutu diğer yumurtalarla eşitle
        multiplierFourEgg.position = position
        multiplierFourEgg.physicsBody = SKPhysicsBody(texture: multiplierFourEgg.texture!, size: multiplierFourEgg.size)
        multiplierFourEgg.physicsBody?.isDynamic = true
        multiplierFourEgg.physicsBody?.categoryBitMask = PhysicsCategory.powerEgg // Çarpan yumurtası kategorisi
        multiplierFourEgg.physicsBody?.contactTestBitMask = PhysicsCategory.duck
        multiplierFourEgg.physicsBody?.collisionBitMask = PhysicsCategory.none
        multiplierFourEgg.name = "multiplierFourEgg"
        addChild(multiplierFourEgg)
        
        // Yanıp sönme animasyonu
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let blink = SKAction.sequence([fadeOut, fadeIn])
        let repeatBlink = SKAction.repeatForever(blink)
        multiplierFourEgg.run(repeatBlink)
        
        // Aşağı hareket ve kaldırma
        let moveDown = SKAction.moveTo(y: -multiplierFourEgg.size.height, duration: 3.0)
        let remove = SKAction.removeFromParent()
        multiplierFourEgg.run(SKAction.sequence([moveDown, remove]))
    }




    func randomEggPosition() -> CGPoint {
        let safeMargin: CGFloat = 50.0 // Engellerden ve diğer yumurtalardan uzaklık
        var xPosition: CGFloat = CGFloat.random(in: safeMargin...(size.width - safeMargin))
        let yPosition: CGFloat = size.height

        // Yumurtanın engellerle veya diğer nesnelerle çakışmasını engellemek için kontrol
        while children.contains(where: { node in
            let nodeRect = node.calculateAccumulatedFrame()
            let eggRect = CGRect(x: xPosition - safeMargin / 2, y: yPosition - safeMargin / 2, width: safeMargin, height: safeMargin)
            return nodeRect.intersects(eggRect) && (node.name == "obstacle" || node.name?.contains("Egg") == true)
        }) {
            xPosition = CGFloat.random(in: safeMargin...(size.width - safeMargin))
        }

        return CGPoint(x: xPosition, y: yPosition)
    }

    
    func spawnPoisonedEgg(at position: CGPoint) {
        let poisonedEgg = SKSpriteNode(texture: poisonedEggImage)
        poisonedEgg.size = CGSize(width: 150, height: 150)

        if isOverlappingWithExistingObjects(position: position, size: poisonedEgg.size) {
            return
        }
        
        poisonedEgg.position = position
        poisonedEgg.physicsBody = SKPhysicsBody(texture: poisonedEgg.texture!, size: poisonedEgg.size)
        poisonedEgg.physicsBody?.isDynamic = true
        poisonedEgg.physicsBody?.categoryBitMask = PhysicsCategory.poisonedEgg
        poisonedEgg.physicsBody?.contactTestBitMask = PhysicsCategory.duck
        poisonedEgg.physicsBody?.collisionBitMask = PhysicsCategory.none
        poisonedEgg.name = "poisonedEgg"
        addChild(poisonedEgg)
        
        let moveDown = SKAction.moveTo(y: -poisonedEgg.size.height, duration: 3.0)
        let remove = SKAction.removeFromParent()
        poisonedEgg.run(SKAction.sequence([moveDown, remove]))
    }


    
    func spawnPowerEgg(at position: CGPoint) {
        let powerEgg = SKSpriteNode(texture: powerEggImage)
        powerEgg.size = CGSize(width: 150, height: 150)
        
        if isOverlappingWithExistingObjects(position: position, size: powerEgg.size) {
            return
        }
        
        powerEgg.position = position
        powerEgg.physicsBody = SKPhysicsBody(texture: powerEgg.texture!, size: powerEgg.size)
        powerEgg.physicsBody?.isDynamic = true
        powerEgg.physicsBody?.categoryBitMask = PhysicsCategory.powerEgg
        powerEgg.physicsBody?.contactTestBitMask = PhysicsCategory.duck
        powerEgg.physicsBody?.collisionBitMask = PhysicsCategory.none
        powerEgg.name = "powerEgg"
        addChild(powerEgg)
        
        let moveDown = SKAction.moveTo(y: -powerEgg.size.height, duration: 3.0)
        let remove = SKAction.removeFromParent()
        powerEgg.run(SKAction.sequence([moveDown, remove]))
    }


    func spawnMovingThorns() {
        let thorns = SKSpriteNode(texture: thornsImage)
        thorns.size = CGSize(width: obstacleImage.size().width, height: obstacleImage.size().height)
        
        // Pozisyon belirleme
        let halfWidth = thorns.size.width / 2
        let screenMargin: CGFloat = 50
        let lowerBound = halfWidth + screenMargin
        let upperBound = size.width - halfWidth - screenMargin
        let randomX = CGFloat.random(in: lowerBound...upperBound)
        
        thorns.position = CGPoint(x: randomX, y: size.height)
        thorns.name = "movingThorn"
        thorns.physicsBody = SKPhysicsBody(texture: thorns.texture!, size: thorns.size)
        thorns.physicsBody?.isDynamic = true
        thorns.physicsBody?.categoryBitMask = PhysicsCategory.obstacle
        thorns.physicsBody?.contactTestBitMask = PhysicsCategory.duck
        thorns.physicsBody?.collisionBitMask = PhysicsCategory.none
        addChild(thorns)
        
        // Yüksekten aşağı hareket
        let moveDown = SKAction.moveTo(y: -thorns.size.height, duration: 3.0)
        
        // Sağ ve sola hareket animasyonu
        let moveLeft = SKAction.moveBy(x: -50, y: 0, duration: 0.5)
        let moveRight = SKAction.moveBy(x: 50, y: 0, duration: 0.5)
        let horizontalMovement = SKAction.sequence([moveLeft, moveRight])
        let horizontalForever = SKAction.repeatForever(horizontalMovement)
        
        // Hareketleri eşzamanlı çalıştırma
        let group = SKAction.group([moveDown, horizontalForever])
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([group, remove])
        
        thorns.run(sequence)
    }

    func applyPowerUp() {
        guard !isPoweredUp else { return }
        isPoweredUp = true

        let originalSize = duck.size
        duck.run(SKAction.scale(by: 1.75, duration: 0.3))

        // Power-Up etkisi süresi
        let wait = SKAction.wait(forDuration: 5.0)
        let reset = SKAction.run {
            self.duck.run(SKAction.scale(to: originalSize, duration: 0.3))
            self.isPoweredUp = false
        }
        run(SKAction.sequence([wait, reset]))
    }



    func explodeNode(_ node: SKNode) {
        if let explosion = SKEmitterNode(fileNamed: "Explosion") {
            explosion.position = node.position
            addChild(explosion)

            let wait = SKAction.wait(forDuration: 0.5)
            let remove = SKAction.removeFromParent()
            explosion.run(SKAction.sequence([wait, remove]))
        }
    }


    func applyPoisonEffect() {
        let poisonOverlay = SKSpriteNode(color: UIColor.green.withAlphaComponent(0.4), size: self.size)
        poisonOverlay.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        poisonOverlay.zPosition = 150 // Diğer öğelerin üzerinde görünmesi için
        poisonOverlay.alpha = 0.0
        addChild(poisonOverlay)

        let fadeIn = SKAction.fadeAlpha(to: 0.4, duration: 0.2) // Yeşil efektin görünmesi
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: 0.4) // Eski haline dönmesi
        let remove = SKAction.removeFromParent() // Efekt tamamlanınca kaldır
        poisonOverlay.run(SKAction.sequence([fadeIn, fadeOut, remove]))
    }

    func endGame() {
        // Tüm engel ve yumurta üretimini durdur
        removeAction(forKey: "spawnObstacles") // Engel üretimini durdur
        removeAction(forKey: "spawnEggs") // Yumurta üretimini durdur
        
        // Skor artırma işlemini durdur
        removeAction(forKey: "scoring")
        
        // Game Over ekranını göster
        gameOverLabel.isHidden = false
        tryAgainButton.isHidden = false
        duck.isHidden = true
        
        // Sahnedeki mevcut engel ve yumurtaları kaldır
        for node in children where node.name == "obstacle" || node.name == "poisonedEgg" || node.name == "powerEgg" || node.name == "multiplierFourEgg" || node.name == "movingThorn" {
            node.removeFromParent()
        }
        
        // Oyun durumu
        gameStarted = false
    }


    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !gameStarted {
            startGame()
        } else {
            if let touch = touches.first {
                let location = touch.location(in: self)
                let touchedNode = atPoint(location)
                if touchedNode.name == "tryagain" {
                    restartGame()
                } else if touchedNode == duck {
                    touchOffset = CGPoint(x: location.x - duck.position.x, y: location.y - duck.position.y)
                }
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let offset = touchOffset else { return }
        
        // Dokunulan konuma göre yeni pozisyon hesapla
        let location = touch.location(in: self)
        var newPosition = CGPoint(x: location.x - offset.x, y: location.y - offset.y)
        
        // Ekran sınırlarını belirle
        let leftLimit: CGFloat = duck.size.width / 5
        let rightLimit: CGFloat = size.width - duck.size.width / 5
        let bottomLimit: CGFloat = duck.size.height / 4
        let topLimit: CGFloat = size.height - duck.size.height / 4

        // Yeni pozisyonu sınırlar içinde tut
        newPosition.x = max(leftLimit, min(newPosition.x, rightLimit))
        newPosition.y = max(bottomLimit, min(newPosition.y, topLimit))
        
        // Yeni pozisyonu ata
        duck.position = newPosition
    }


    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchOffset = nil
    }
    
    func restartGame() {
        spawnInterval = 1.0
        score = 0
        scoreValueLabel.text = "0"
        duck.position = CGPoint(x: size.width / 2, y: size.height / 4)
        duck.isHidden = false
        gameOverLabel.isHidden = true
        tryAgainButton.isHidden = true
        startGame()

        // Mevcut tüm engelleri kaldır
        for node in children where node.name == "obstacle" || node.name == "movingThorn" || node.name == "poisonedEgg" || node.name == "powerEgg" {
            node.removeFromParent()
        }
        
        // Gecikmeli olarak engel üretimini başlat
        let delay = SKAction.wait(forDuration: 3.0) // 3 saniye gecikme
        let startObstacles = SKAction.run { [weak self] in
            self?.spawnObstacles()
        }
        run(SKAction.sequence([delay, startObstacles]), withKey: "startObstacles")

        gameStarted = true
        duck.physicsBody?.isDynamic = true

        // Skor arttırıcıyı başlat
        let increaseScore = SKAction.run { self.incrementScore() }
        let scoreDelay = SKAction.wait(forDuration: 1.0)
        let scoreSequence = SKAction.sequence([increaseScore, scoreDelay])
        let scoreForever = SKAction.repeatForever(scoreSequence)
        run(scoreForever, withKey: "scoring")
    }

    
    func didBegin(_ contact: SKPhysicsContact) {
        let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask

        if collision == PhysicsCategory.duck | PhysicsCategory.poisonedEgg {
            if !isPoweredUp {
                applyPoisonEffect()
                endGame()
            }
        } else if collision == PhysicsCategory.duck | PhysicsCategory.obstacle {
            if isPoweredUp {
                let obstacle = contact.bodyA.node?.name == "obstacle" || contact.bodyA.node?.name == "thorns" ? contact.bodyA.node : contact.bodyB.node
                if let obstacle = obstacle {
                    explodeNode(obstacle)
                    obstacle.removeFromParent()
                }
            } else {
                endGame()
            }
        } else if collision == PhysicsCategory.duck | PhysicsCategory.powerEgg {
            if let powerEgg = contact.bodyA.node?.name == "powerEgg" ? contact.bodyA.node : contact.bodyB.node {
                powerEgg.removeFromParent()
                applyPowerUp()
            }
        } else if collision == PhysicsCategory.duck | PhysicsCategory.powerEgg {
            if let multiplierFourEgg = contact.bodyA.node?.name == "multiplierFourEgg" ? contact.bodyA.node : contact.bodyB.node {
                multiplierFourEgg.removeFromParent()
                activateMultiplierFour() // Yeni çarpanı aktif et
            }
        }
    }
    func activateMultiplierFour() {
        multiplierActive = true
        
        scoreValueLabel.fontColor = UIColor(red: 240/255, green: 44/255, blue: 59/255, alpha: 1.0) // Çarpan aktif rengi
        
        multiplierTwoNode.isHidden = false
        multiplierTwoNode.texture = SKTexture(imageNamed: "multiplierfour.png") // x4 çarpan görseli
        
        let wait = SKAction.wait(forDuration: 10.0)
        let deactivate = SKAction.run { [weak self] in
            self?.deactivateMultiplier()
        }
        let sequence = SKAction.sequence([wait, deactivate])
        run(sequence, withKey: "multiplierFourTimer")
    }


    struct PhysicsCategory {
        static let none: UInt32 = 0
        static let duck: UInt32 = 0b1
        static let obstacle: UInt32 = 0b10
        static let poisonedEgg: UInt32 = 0b100
        static let powerEgg: UInt32 = 0b1000
    }
}
