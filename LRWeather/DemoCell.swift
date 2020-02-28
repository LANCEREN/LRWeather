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
    @IBOutlet weak var UpdateTimeLabel: UILabel!
    @IBOutlet weak var Date: UILabel!
    @IBOutlet weak var tips: UILabel!
    @IBOutlet weak var FeelLabel: UILabel!
    @IBOutlet weak var MaxTemp: UILabel!
    @IBOutlet weak var MinTemp: UILabel!
    @IBOutlet weak var FeelLabel2: UILabel!
    @IBOutlet weak var AQI: UILabel!
    @IBOutlet weak var HUmidity: UILabel!
    @IBOutlet weak var RainPop: UILabel!
    @IBOutlet weak var DayWeather: UILabel!
    @IBOutlet weak var NightWeather: UILabel!
    @IBOutlet weak var DayWindli: UILabel!
    @IBOutlet weak var NightWindLi: UILabel!
    @IBOutlet weak var DayWindXiang: UILabel!
    @IBOutlet weak var NightWindXiang: UILabel!
    
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
