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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create an anchor for a horizontal plane with a minimum area of 20 cm^2
        let anchor = AnchorEntity(plane: .horizontal, minimumBounds: [0.2 ,0.2])
        arView.scene.addAnchor(anchor)
        
        // Create Cards
        var allCards: [Entity] = []
        var cardTemplates: [Entity] = []
        
        // Load the model asset for each card
        for index in 1...8 {
            let assetName = "modelusdzfile/0\(index)"
            let cardTemplate = try! Entity.loadModel(named: assetName)
            cardTemplates.append(cardTemplate)
        }
        
        for cardTemplate in cardTemplates {
            // Clone each card template twice
            for _ in 1...2 {
                allCards.append(cardTemplate.clone(recursive: true))
            }
        }
        
        // Shuffle the cards so they are randomly ordered
        allCards.shuffle()
        
        // Position the shuffled cards in a 4-by-4 grid
        for (index, card) in allCards.enumerated() {
            let x = Float(index % 4) - 1.5
            let z = Float(index / 4) - 1.5
            
            // Set the position of the card
            card.position = [x * 0.1, 0, z * 0.1]
            
            // Add the card to the anchor
            anchor.addChild(card)
        }
    }
}
