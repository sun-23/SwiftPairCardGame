//
//  ViewController.swift
//  PairCard-RealityKit
//
//  Created by sun on 3/4/2563 BE.
//  Copyright © 2563 sun. All rights reserved.
//

import UIKit
import RealityKit

class ViewController: UIViewController {
    
    @IBOutlet var arView: ARView!
    
    // Session Card Pick
    var firstCardPick: Entity? = nil
    var secondCardPick: Entity? = nil
    
    // Create Cards
    var allCards: [Entity] = []
    var cardTemplates: [Entity] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: Add anchorentity to arView scene
        // Create an anchor for a horizontal plane with a minimum area of 20 cm^2
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.2 ,0.2])
        arView.scene.addAnchor(anchor)
        
        // MARK: Create Card
        for index in 1...8 {
            // Create card box
            let box = MeshResource.generateBox(width: 0.04, height: 0.002, depth: 0.04)
            
            // Create material
            let metalMaterial = SimpleMaterial(color: .gray, isMetallic: true)
            
            // Create ModelEntity using mesh and materials
            let model = ModelEntity(mesh: box, materials: [metalMaterial])
            
            // Generate collision shapes for the card so we can interact with it
            model.generateCollisionShapes(recursive: true)
            
            // Give the card a name so we'll know what we're interacting with
            model.name = "0\(index)"
            
            // Clone each card twice
            for _ in 1...2 {
                allCards.append(model.clone(recursive: true))
            }
        }
        
        // MARK: OcclusionBox
        // Create plane mesh, 0.5 meters wide & 0.5 meters deep
        let boxSize: Float = 0.5
        let occlusionBoxMesh = MeshResource.generateBox(size: boxSize)
        
        // Create occlusion material
        let material = OcclusionMaterial()
        
        // Create ModelEntity using mesh and materials
        let occlusionBox = ModelEntity(mesh: occlusionBoxMesh, materials: [material])
        
        // Position plane below game board
        occlusionBox.position.y = -boxSize / 2
        
        // Add to anchor
        anchor.addChild(occlusionBox)
        
        // MARK: Load model cardTemplates
        // Load the model asset for each card synchronous
        for index in 1...8 {
            let assetName = "0\(index)"
            let cardTemplate = try! Entity.loadModel(named: assetName)
            
            // Set size of cardTemplate
            cardTemplate.setScale(SIMD3<Float>(0.002, 0.002, 0.002), relativeTo: anchor)
            
            // Clone each card template twice
            for _ in 1...2 {
                cardTemplates.append(cardTemplate.clone(recursive: true))
            }
        }
        
        // MARK: Set cardTemplate to card
        for (index, cardTemplate) in cardTemplates.enumerated() {
            // Add cardTemplate model to card
            allCards[index].addChild(cardTemplate)
            // Set the card to rotate back to 180 degrees
            allCards[index].transform.rotation = simd_quatf(angle: .pi, axis: [1, 0, 0])
        }

        // MARK: Add card to AnchorEntity
        // Shuffle the cards so they are randomly ordered
        allCards.shuffle()

        // Position the shuffled cards in a 4-by-4 grid
        for (index, card) in allCards.enumerated() {
            let x = Float(index % 4) - 1.5
            let z = Float(index / 4) - 1.5

            // Set the position of the card
            card.position = [x * 0.1, 0, z * 0.1]

            // Add the card to the anchor
            print("show card")
            anchor.addChild(card)
        }
        
    }
    
    // Hit Testing
    @IBAction func onTap(_ sender: UITapGestureRecognizer) {
        let tapLocation = sender.location(in: arView)
        
        // Get the entity at the location we've tapped, if one exists
        if let card = arView.entity(at: tapLocation) {
//            if card.transform.rotation.angle == .pi {
//                flipCard(card: card, angle: 0)
//            } else {
//                flipCard(card: card, angle: .pi)
//            }
            flipCard(card: card, angle: 0)
            if firstCardPick !== nil {
                secondCardPick = card
                print("sccond card pick : \(String(describing: secondCardPick?.name ?? "no card"))")
            } else {
                firstCardPick = card
                print("first card pick : \(String(describing: firstCardPick?.name ?? "no card"))")
            }
            if (firstCardPick != nil && secondCardPick != nil) {
                chackPair()
            }
        }
    }
    
    func chackPair() {
        print("first card check: \(String(describing: firstCardPick?.name ?? "no card"))")
        print("sccond card check: \(String(describing: secondCardPick?.name ?? "no card"))")
        
        if (firstCardPick?.name == secondCardPick?.name) {
            print("Pair!!")
            // delay 1 second
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // remove card
                self.firstCardPick?.removeFromParent()
                self.secondCardPick?.removeFromParent()
                
                // clear card piker
                self.firstCardPick = nil
                self.secondCardPick = nil
            }
        } else {
//            // flip card down
//            var flipDownfirst = firstCardPick?.transform
//            var flipDownSecond = secondCardPick?.transform
//            // Set the card to rotate back to angle degrees in x axis
//            flipDownfirst?.rotation = simd_quatf(angle: .pi, axis: [1,0,0])
//            flipDownSecond?.rotation = simd_quatf(angle: .pi, axis: [1,0,0])
//            // action flip card down
//            firstCardPick?.move(to: flipDownfirst!, relativeTo: firstCardPick?.parent, duration: 0.25, timingFunction: .easeInOut)
//            secondCardPick?.move(to: flipDownSecond!, relativeTo: secondCardPick?.parent, duration: 0.25, timingFunction: .easeInOut)
//
            // clear card piker
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                // remove card
                self.flipCard(card: self.firstCardPick!, angle: .pi)
                self.flipCard(card: self.secondCardPick!, angle: .pi)
                // clear card piker
                self.firstCardPick = nil
                self.secondCardPick = nil
            }
        }
    }
    
    func flipCard(card: Entity, angle: Float) {
        var flipTransform = card.transform
        // Set the card to rotate back to angle degrees in x axis
        flipTransform.rotation = simd_quatf(angle: angle, axis: [1, 0, 0])
        
        card.move(to: flipTransform, relativeTo: card.parent, duration: 0.25, timingFunction: .easeInOut)
        
//        if (firstCardPick != nil && secondCardPick != nil) {
//            chackPair()
//        }
    }
    
}
