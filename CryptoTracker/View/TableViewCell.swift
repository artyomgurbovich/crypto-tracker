//
//  TableViewCell.swift
//  CryptoTracker
//
//  Created by Artyom Gurbovich on 3/11/20.
//  Copyright © 2020 Artyom Gurbovich. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var symbolLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var changePercentLabel: UILabel!
    @IBOutlet weak var cellView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        UIConfigurator.configCellView(cellView)
    }
}
