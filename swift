import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var snake: Snake?
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.black
        
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
        
        snake = Snake(scene: self)
        snake?.start()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        snake?.didBegin(contact)
    }
    
    override func update(_ currentTime: TimeInterval) {
        snake?.update()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        snake?.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        snake?.touchesEnded(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        snake?.touchesMoved(touches, with: event)
    }
}

class Snake {
    
    let scene: SKScene
    var snakeBody: [SKSpriteNode] = []
    var currentDirection: Direction = .right
    var nextDirection: Direction?
    var lastUpdateTime: TimeInterval = 0
    var timeSinceMove: TimeInterval = 0
    var food: SKSpriteNode?
    
    init(scene: SKScene) {
        self.scene = scene
        let head = SKSpriteNode(color: SKColor.green, size: CGSize(width: 20, height: 20))
        head.position = CGPoint(x: 100, y: 100)
        head.zPosition = 1
        snakeBody.append(head)
        scene.addChild(head)
    }
    
    func start() {
        addFood()
    }
    
    func update() {
        let currentTime = NSDate.timeIntervalSinceReferenceDate
        if lastUpdateTime == 0 {
            lastUpdateTime = currentTime
        }
        let timeDelta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        timeSinceMove += timeDelta
        if timeSinceMove >= 0.1 {
            timeSinceMove = 0
            move()
        }
    }
    
    func move() {
        if let nextDirection = nextDirection {
            currentDirection = nextDirection
            self.nextDirection = nil
        }
        
        let head = snakeBody.first!
        var newHead: SKSpriteNode?
        switch currentDirection {
        case .up:
            newHead = SKSpriteNode(color: SKColor.green, size: CGSize(width: 20, height: 20))
            newHead!.position = CGPoint(x: head.position.x, y: head.position.y + 20)
        case .down:
            newHead = SKSpriteNode(color: SKColor.green, size: CGSize(width: 20, height: 20))
            newHead!.position = CGPoint(x: head.position.x, y: head.position.y - 20)
        case .left:
            newHead = SKSpriteNode(color: SKColor.green, size: CGSize(width: 20, height: 20))
            newHead!.position = CGPoint(x: head.position.x - 20, y: head.position.y)
        case .right:
            newHead = SKSpriteNode(color: SKColor.green, size: CGSize(width: 20, height: 20))
            newHead!.position = CGPoint(x: head.position.x + 20, y: head.position.y)
        }
        newHead!.zPosition = 1
        snakeBody.insert(newHead!, at: 0)
        scene.addChild(newHead!)
        
        if let food = food, head.intersects(food) {
            self.food?.removeFromParent()
            self.food = nil
            addFood()
        } else {
            let tail = snakeBody.removeLast()
            tail.removeFromParent()
        }
    }
    
    func addFood() {
        let food = SKSpriteNode(color: SKColor.red, size: CGSize(width: 20, height: 20))
        food.position = CGPoint(x: CGFloat(arc4random_uniform(UInt32(scene.size.width - 40))) +
