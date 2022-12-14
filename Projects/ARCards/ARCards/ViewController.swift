import UIKit
import RealityKit
import Combine
import ARKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    var cardTemplates: [ModelEntity] = []
    var cancellables = [AnyCancellable]()
    var publishers: [LoadRequest<ModelEntity>] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create an anchor for horizontal plane
        let anchor = AnchorEntity(.plane(.horizontal, classification: .table, minimumBounds: [0.1, 0.1]))
        arView.scene.addAnchor(anchor)
        
        if let assetURLs = Bundle.main.urls(forResourcesWithExtension: "usdz", subdirectory: "") {
                        
            // Simple load
            /*
            for url in assetURLs {
                var assetName = url.relativeString
                assetName = (assetName as NSString).deletingPathExtension
                let cardTemplate = try! Entity.loadModel(named: assetName)
                cardTemplate.generateCollisionShapes(recursive: true)
                cardTemplate.name = assetName
                cardTemplates.append(cardTemplate)
            }
        
            // Create card deck
            var cards = createCards(with: cardTemplates)
            
            // Create an anchor for horizontal plane
            let anchor = AnchorEntity(.plane(.horizontal, classification: .table, minimumBounds: [0.1, 0.1]))
            arView.scene.addAnchor(anchor)
            
            // Position cards
             positionCards(cards)
            */
            
            // Load the assets asynchronously
            // /*
            
            for asset in assetURLs {
                print(asset)
                let assetName = (asset.relativeString as NSString).deletingPathExtension
                let entity = ModelEntity.loadModelAsync(named: assetName)
                publishers.append(entity)
            }
            
            Publishers.MergeMany(publishers)
            .collect()
            .sink(receiveCompletion: {
                print("complete", $0)
            },
                  receiveValue: { [weak self] entity in
                let cards = self?.createCards(with: entity)
                self?.positionCards(cards!, anchor: anchor)
            }).store(in: &cancellables)

            //*/
        }
        
        // Tapping - is ok if is loaded before the cards
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        arView.addGestureRecognizer(tapGestureRecognizer)
        
        // Add occlusion material
        let occlusionMesh = MeshResource.generateBox(size: 0.5)
        let occlusionMaterial = OcclusionMaterial()
        let occlusionEntity = ModelEntity(mesh: occlusionMesh, materials: [occlusionMaterial])
        occlusionEntity.position.y = -0.5/2-0.01
        anchor.addChild(occlusionEntity)
        
        
        // Set debug options
        #if DEBUG
//        arView.debugOptions = .showPhysics
        #endif
    }
    
    func positionCards(_ cards: [ModelEntity], anchor: AnchorEntity ) {
        // Create an anchor for horizontal plane
//        let anchor = AnchorEntity(.plane(.horizontal, classification: .table, minimumBounds: [0.1, 0.1]))
//        arView.scene.addAnchor(anchor)
    
        // Position cards
        for (index, card) in cards.enumerated() {
            let x = Float(index % 4) - 1.5
            let z = Float(index / 4) - 1.5
            card.position = [x * 0.07, 0, z * 0.07]
            anchor.addChild(card)
            // Initialize faceDown
            flipUpCard(card)
        }
    }
    
    func createCards(with models: [ModelEntity]) -> [ModelEntity] {
        var cards: [ModelEntity] = []
        for cardTemplate in models {
            cardTemplate.generateCollisionShapes(recursive: true)
            for _ in 1...2 {
                cards.append(cardTemplate.clone(recursive: true))
            }
        }
        cards.shuffle()
        return cards
    }
    
    func flipUpCard(_ card: Entity) {
        var flipUpTransform = card.transform
        flipUpTransform.rotation = simd_quatf(angle: .pi, axis: [1,0,0])
        let _ = card.move(to: flipUpTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeInOut)
    }
    
    func flipDownCard(_ card: Entity) {
        var flipUpTransform = card.transform
        flipUpTransform.rotation = simd_quatf(angle: 0, axis: [1,0,0])
        let _ = card.move(to: flipUpTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeInOut)
    }
    
    @objc func handleTap(_ sender: UIGestureRecognizer) {
        // 2D Screen tap
        let tapLocation = sender.location(in: arView)
        // Raycast query
        if let card = arView.entity(at: tapLocation) {
            print(card.name)
            flipDownCard(card)        }
    }

 
}
