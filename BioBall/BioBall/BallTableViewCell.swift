//
//  BallTableViewCell.swift
//  BioBall
//
//  Created by Jeremiah Benjamin on 12/30/22.
//  Copyright © 2022 Jeremiah Benjamin. All rights reserved.
//

import UIKit

class BallTableViewCell: UITableViewCell {

    @IBOutlet var ballLabel: UILabel!
    @IBOutlet var ballimgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ballLabel.textColor = .black
        ballimgView.layer.borderWidth = 2
        ballimgView.layer.masksToBounds = false
        ballimgView.layer.borderColor = UIColor.black.cgColor
        ballimgView.layer.cornerRadius = ballimgView.frame.height / 2
        ballimgView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

