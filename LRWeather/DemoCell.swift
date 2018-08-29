//
//  DemoCell.swift
//  FoldingCell
//
//  Created by Alex K. on 25/12/15.
//  Copyright © 2015 Alex K. All rights reserved.
//

import FoldingCell
import UIKit
import Hero

class DemoCell: FoldingCell {

    @IBOutlet var closeNumberLabel: UILabel!
    @IBOutlet var openNumberLabel: UILabel!
    @IBOutlet weak var LocationImage1: UIImageView!
    @IBOutlet weak var LocationImage2: UIImageView!
    @IBOutlet weak var Detail: UIButton!
    
    var CellCityInfo: String = "--" {
        didSet {
            closeNumberLabel.text = String(CellCityInfo)
            openNumberLabel.text = String(CellCityInfo)
        }
    }

    override func awakeFromNib() {
        foregroundView.layer.cornerRadius = 10
        foregroundView.layer.masksToBounds = true
        super.awakeFromNib()
    }

    override func animationDuration(_ itemIndex: NSInteger, type _: FoldingCell.AnimationType) -> TimeInterval {
        let durations = [0.26, 0.2, 0.2]
        return durations[itemIndex]
    }
    
}

// MARK: - Actions ⚡️

extension DemoCell {
    
}
