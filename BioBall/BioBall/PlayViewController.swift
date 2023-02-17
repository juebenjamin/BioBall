//
//  PlayViewController.swift
//  BioBall
//
//  Created by Jeremiah Benjamin on 12/15/22.
//  Copyright © 2022 Jeremiah Benjamin. All rights reserved.
//

import UIKit
import CoreData
import SCLAlertView

class PlayViewController: UIViewController, UICollisionBehaviorDelegate {
    var pageControl: UIPageControl!
    var animator: UIDynamicAnimator!
    var dataArray = [NSManagedObject]()
    var buttons = [ButtonView]()
    
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
        // Do any additional setup after loading the view.
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(pageControl)
        // Add constraints to center the page control horizontally and position it at the bottom of the screen
            NSLayoutConstraint.activate([
                pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
            ])
        pageControl.addTarget(self, action: #selector(pageControlTapped(_:)), for: .valueChanged)
        let managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Balls")
            do {
                    dataArray = try managedObjectContext.fetch(fetchRequest)
                } catch {
                    print("Error fetching data from Core Data: \(error)")
                }
        let label = UILabel()
        label.text = "You don't currently have any balls to display!"
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = label.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let verticalConstraint = label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint])
        label.isHidden = true
        for (index, object) in dataArray.enumerated() {
            let btn = ButtonView()
            let screenWidth = UIScreen.main.bounds.width
            let screenHeight = UIScreen.main.bounds.height
            let buttonWidth: CGFloat = 50
            let buttonHeight: CGFloat = 50
            let x = CGFloat(Int.random(in: 0...Int(screenWidth - buttonWidth)))
            let y = CGFloat(Int.random(in: 0...Int(screenHeight - buttonHeight)))
            let buttonFrame = CGRect(x: x, y: y, width: buttonWidth, height: buttonHeight)
            btn.frame = buttonFrame
            let uploadedImage = object.value(forKey: "images") as? Data
            let image = UIImage(data: uploadedImage!)
            btn.setImage(image, for: .normal)
            btn.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            btn.tag = index
            view.addSubview(btn)
            buttons.append(btn)
        }
        if buttons.isEmpty {
            label.isHidden = false
        }
//      Initilizing the animator
        animator = UIDynamicAnimator(referenceView: self.view)
        // Sets phyiscs properties for each ball
        let balls: [UIDynamicItem] = buttons
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
        // Perform transition to balls list screen when swiped left
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(swipeFunc(gesture:)))
        swipeLeft.direction = .left
        self.view.addGestureRecognizer(swipeLeft)
    }
    // Create action method for button tap
    @objc func buttonTapped(_ sender: UIButton) {
        let managedObject = dataArray[sender.tag]
        let appearance = SCLAlertView.SCLAppearance( kCircleIconHeight: 59.0)
        let alert = SCLAlertView(appearance: appearance)
        let uploadedImg = managedObject.value(forKey: "images") as? Data
        let img = UIImage(data: uploadedImg!)
        alert.showCustom((managedObject.value(forKey: "titles") as? String)!, subTitle: (managedObject.value(forKey: "balldescriptions") as? String)!, color: UIColor(red: 197/255, green: 0/255, blue: 197/255, alpha: 1), icon: img!)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Stop the animator when view disappears
        animator.removeAllBehaviors()
      }
    // Function for swipe left to balls list screen
    @objc func swipeFunc(gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .left {
            performSegue(withIdentifier: "toRight", sender: self)
            
        }
    }
    @objc func pageControlTapped(_ sender: UIPageControl) {
        // Update the current page of the page control to the tapped page
        pageControl.currentPage = sender.currentPage
        performSegue(withIdentifier: "toRight", sender: self)
    }
}
