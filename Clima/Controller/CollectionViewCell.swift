//
//  CollectionViewCell.swift
//  Clima
//
//  Created by Macbook on 8.01.22.
//  Copyright © 2022 App Brewery. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {

    static let identifier = String(describing: CollectionViewCell.self)
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var iconImage: UIImageView!
    @IBOutlet weak var degreeLabel: UILabel!
        
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func config(with model: WeatherModelHourly) {
        timeLabel.text = model.time
        degreeLabel.text = model.temperatureString
        iconImage.image = UIImage(systemName: model.conditionName)
    }
}
