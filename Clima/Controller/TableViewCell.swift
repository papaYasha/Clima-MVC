//
//  TableViewCell.swift
//  Clima
//
//  Created by Macbook on 8.01.22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var minTempLabel: UILabel!
    @IBOutlet weak var maxTempLabel: UILabel!
    static let identifier = "TableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    func config(with model: WeatherModelDaily) {
        dayLabel.text = model.time
        iconImage.image = UIImage(systemName: model.conditionName)
        minTempLabel.text = model.minTemperatureString
        maxTempLabel.text = model.maxTemperatureString
    }
}
