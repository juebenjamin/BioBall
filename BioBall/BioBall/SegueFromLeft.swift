//
//  SegueFromLeft.swift
//  BioBall
//
//  Created by Jeremiah Benjamin on 12/15/22.
//  Copyright © 2022 Jeremiah Benjamin. All rights reserved.
//

import UIKit
class SegueFromLeft: UIStoryboardSegue {
    override func perform() {
        // Assign the source and destination views to local variables.
        let sourceViewController = self.source
        let destinationViewController = self.destination

        // Get the screen width and height.
        let screenWidth = UIScreen.main.bounds.size.width
        let screenHeight = UIScreen.main.bounds.size.height

        // Specify the initial position of the destination view.
        destinationViewController.view.frame = CGRect(x: -screenWidth, y: 0, width: screenWidth, height: screenHeight)

        // Get the window for the current scene and insert the destination view above the current (source) one.
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else { return }
        window.insertSubview(destinationViewController.view, aboveSubview: sourceViewController.view)

        // Animate the transition.
        UIView.animate(withDuration: 0.25, animations: {
            sourceViewController.view.frame = sourceViewController.view.frame.offsetBy(dx: screenWidth, dy: 0)
            destinationViewController.view.frame = destinationViewController.view.frame.offsetBy(dx: screenWidth, dy: 0)
        }) { finished in
            self.source.present(self.destination, animated: false, completion: nil)
        }
    }
}
