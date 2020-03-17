//
//  UIConfigurator.swift
//  CryptoTracker
//
//  Created by Artyom Gurbovich on 3/15/20.
//  Copyright © 2020 Artyom Gurbovich. All rights reserved.
//

import UIKit
import Charts

class UIConfigurator {
    
    public static func configNavigationBar(_ navigationBar: UINavigationBar?) {
        navigationBar?.shadowImage = UIImage()
        navigationBar?.backgroundColor = .white
        navigationBar?.barTintColor = .white
    }
    
    public static func configSearchBar(_ searchBar: UISearchBar, _ navigationItem: UINavigationItem) {
        searchBar.sizeToFit()
        searchBar.barTintColor = UIColor.white
        searchBar.placeholder = "Search Coins"
        searchBar.enablesReturnKeyAutomatically = false
        searchBar.returnKeyType = .default
        navigationItem.titleView = searchBar
    }
    
    public static func configShadowView(_ shadowView: UIView) {
        shadowView.layer.shadowPath = UIBezierPath(rect: CGRect(x: 0, y: shadowView.bounds.height, width: UIScreen.main.bounds.width, height: 7)).cgPath
        shadowView.layer.shadowColor = UIColor.black.cgColor
        shadowView.layer.shadowRadius = 2
        shadowView.layer.shadowOpacity = 0.15
        shadowView.layer.masksToBounds = false
        shadowView.clipsToBounds = false
    }
    
    public static func configTableView(_ tableView: UITableView) {
        tableView.contentInset = UIEdgeInsets(top: 12.5, left: 0, bottom: 0, right: 0)
    }
    
    public static func configCellView(_ cellView: UIView) {
        cellView.layer.cornerRadius = 15
        cellView.layer.shadowOffset = CGSize(width: 0, height: 2.5)
        cellView.layer.shadowColor = UIColor.black.cgColor
        cellView.layer.shadowRadius = 5
        cellView.layer.shadowOpacity = 0.2
        cellView.layer.masksToBounds = false
        cellView.clipsToBounds = false
    }
    
    public static func configInfoTitleView(_ navigationItem: UINavigationItem, _ nameLabel: UILabel, _ symbolLabel: UILabel, _ iconImageView: UIImageView) {
        nameLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.1
        nameLabel.textColor = UIColor.darkGray
        symbolLabel.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        symbolLabel.textColor = .gray
        iconImageView.clipsToBounds = true
        iconImageView.contentMode = .scaleAspectFit
        let imageViewWidthConstraint = NSLayoutConstraint(item: iconImageView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25)
        let imageViewHeightConstraint = NSLayoutConstraint(item: iconImageView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 25)
        iconImageView.addConstraints([imageViewWidthConstraint, imageViewHeightConstraint])
        let stackView = UIStackView(arrangedSubviews: [iconImageView, nameLabel, symbolLabel])
        stackView.spacing = 10
        navigationItem.titleView = stackView
    }
    
    public static func getChangeColorBased(on coin: Coin) -> UIColor {
        return coin.change.starts(with: "▼") ?  UIColor.systemRed : UIColor.systemGreen
    }
    
    public static func configureLineChartView(_ lineChartView: LineChartView) {
        lineChartView.noDataText = "Loading…"
        lineChartView.noDataTextColor = .darkGray
        lineChartView.noDataFont = .systemFont(ofSize: 17, weight: .medium)
        lineChartView.leftAxis.enabled = false
        lineChartView.legend.enabled = false
        let yAxis = lineChartView.rightAxis
        yAxis.labelFont = .systemFont(ofSize: 13)
        yAxis.labelTextColor = .darkGray
        yAxis.axisLineColor = .darkGray
        yAxis.gridColor = .white
        lineChartView.xAxis.enabled = false
    }
}
