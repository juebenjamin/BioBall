//
//  ViewController.swift
//  BioBall
//
//  Created by Jeremiah Benjamin on 6/5/20.
//  Copyright © 2020 Jeremiah Benjamin. All rights reserved.
//

import UIKit
class ViewController: UIViewController, UICollisionBehaviorDelegate {
//  Reference for balls/label/start buttons from storyboard to code
    @IBOutlet var ball1: ButtonView!
    @IBOutlet var ball2: ButtonView!
    @IBOutlet var ball3: ButtonView!
    @IBOutlet var ball4: ButtonView!
    @IBOutlet var ball5: ButtonView!
    @IBOutlet var ball6: ButtonView!
    @IBOutlet var ball7: ButtonView!
    @IBOutlet var ball8: ButtonView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var startButton: UIButton!
    //  Declaration of animator
    var animator: UIDynamicAnimator!
//  Collison detection added to balls to fix sliding issue
    func collisionBehavior(_ behavior: UICollisionBehavior, beganContactFor item: UIDynamicItem, withBoundaryIdentifier identifier: NSCopying?, at p: CGPoint) {
        let threshold: CGFloat = 1
        var pushDirection: CGFloat = 0
        // Collision detected on left side, set angle to be somewhere opposite
        if p.x <= threshold {
            pushDirection = CGFloat.random(in: degreesToRadians(degrees: 300)...degreesToRadians(degrees: 420))
        // Collision detected on right side, set angle to be somewhere opposite
        } else if p.x >= view.bounds.width - threshold {
            pushDirection = CGFloat.random(in: degreesToRadians(degrees: 120)...degreesToRadians(degrees: 240))
        // Collision detected on top, set angle to be somewhere opposite
        } else if p.y <= threshold {
            pushDirection = CGFloat.random(in: degreesToRadians(degrees: 210)...degreesToRadians(degrees: 330))
        // Collision detected on bottom, set angle to be somewhere opposite
        } else if p.y >= view.bounds.height - threshold {
            pushDirection = CGFloat.random(in: degreesToRadians(degrees: 30)...degreesToRadians(degrees: 150))
        }
        if pushDirection != 0 {
            let movement = UIPushBehavior(items: [item], mode: .instantaneous)
            movement.magnitude = 0.4
            movement.angle = pushDirection
            animator?.addBehavior(movement)
        }
    }
    func degreesToRadians(degrees: Double) -> Double {
      return degrees * .pi / 180
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//      Added colors to start button
        startButton.tintColor = UIColor.white
        startButton.backgroundColor = UIColor(red: 197/255, green: 0/255, blue: 197/255, alpha: 1)
//      Make button round
        startButton.layer.cornerRadius = startButton.frame.height / 2
        startButton.clipsToBounds = true
//      Lock button in place on screen
        view.addSubview(startButton)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
              startButton.widthAnchor.constraint(equalToConstant: 200),
              startButton.heightAnchor.constraint(equalToConstant: 50),
              startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
              startButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -75)
            ])
        
//      Set title label to always be on top
        self.view.bringSubviewToFront(titleLabel)
//      Initilizing the animator
        animator = UIDynamicAnimator(referenceView: self.view)
        let balls: [UIDynamicItem] = [ball1, ball2, ball3, ball4, ball5, ball6, ball7, ball8]
        // Sets phyiscs properties for each ball
        let ballsProperties = UIDynamicItemBehavior(items: balls)
        ballsProperties.elasticity = 0.9
        ballsProperties.friction = 0
        ballsProperties.resistance = 0
        ballsProperties.allowsRotation = false
        animator?.addBehavior(ballsProperties)
        // Gives initial movement for balls, all going in different directions
        for ball in balls {
            let movement = UIPushBehavior(items: [ball], mode: .instantaneous)
            movement.magnitude = 0.4
            movement.angle = CGFloat.random(in: 0...2*CGFloat.pi)
            animator?.addBehavior(movement)
        }
        // Allow balls to collide with each other and with outer view
        let boundaries = UICollisionBehavior(items: balls)
        boundaries.translatesReferenceBoundsIntoBoundary = true
        boundaries.collisionDelegate = self
        animator?.addBehavior(boundaries)
        }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop the animator
        animator.removeAllBehaviors()
      }
    }
    
// Play with mode?
// Neg magnitude?
// pushDirection?
