//
//  CricleBackGroundView.swift
//  BioBall
//
//  Created by Jeremiah Benjamin on 1/8/23.
//  Copyright © 2023 Jeremiah Benjamin. All rights reserved.
//

import UIKit

import UIKit

@IBDesignable
class CircleBackgroundView: UIView {

    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = bounds.size.width / 2
        layer.masksToBounds = true
    }

}
