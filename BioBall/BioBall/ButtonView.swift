//
//  ButtonView.swift
//  BioBall
//
//  Created by Jeremiah Benjamin on 6/5/20.
//  Copyright © 2020 Jeremiah Benjamin. All rights reserved.
//

import UIKit

class ButtonView: UIButton {
    func setup() {
        bounds.size.width = 50
        bounds.size.height = 50
        layer.borderWidth = 2
        layer.cornerRadius = bounds.size.width/2
        clipsToBounds = true
        setTitle("", for:.normal)
        backgroundColor = UIColor.lightGray
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setup()
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setup()
    }
}

