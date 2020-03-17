//
//  InfoViewController.swift
//  CryptoTracker
//
//  Created by Artyom Gurbovich on 3/15/20.
//  Copyright © 2020 Artyom Gurbovich. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Charts

class InfoViewController: UIViewController {

    @IBOutlet weak var backBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var favoriteBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var chartView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var changeLabel: UILabel!
    @IBOutlet weak var volumeLabel: UILabel!
    @IBOutlet weak var marketCapLabel: UILabel!
    @IBOutlet weak var supplyLabel: UILabel!
    @IBOutlet weak var maxSupplyLabel: UILabel!
    
    let nameLabel = UILabel()
    let symbolLabel = UILabel()
    let iconImageView = UIImageView()
    
    var infoViewModel: InfoViewModel!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIConfigurator.configNavigationBar(navigationController?.navigationBar)
        UIConfigurator.configShadowView(shadowView)
        UIConfigurator.configCellView(chartView)
        UIConfigurator.configCellView(infoView)
        UIConfigurator.configureLineChartView(lineChartView)
        UIConfigurator.configInfoTitleView(navigationItem, nameLabel, symbolLabel, iconImageView)
        backBarButtonItem.rx.tap.subscribe(onNext: { [unowned self] in
                self.navigationController?.popViewController(animated: true)
            }).disposed(by: disposeBag)
        favoriteBarButtonItem.rx.tap.subscribe(onNext: { [unowned self] in
                self.infoViewModel.toggleFavorite()
            }).disposed(by: disposeBag)
        self.infoViewModel.isFavorite.subscribe(onNext: {  [unowned self] state in
                self.favoriteBarButtonItem.image = state ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
            }).disposed(by: disposeBag)
        segmentedControl.rx.selectedSegmentIndex.subscribe(onNext: { [unowned self] index in
                self.lineChartView.clear()
                switch index {
                case 1:
                    self.infoViewModel.interval = "m15"
                case 2:
                    self.infoViewModel.interval = "h1"
                case 3:
                    self.infoViewModel.interval = "h6"
                case 4:
                    self.infoViewModel.interval = "d1"
                default:
                    self.infoViewModel.interval = "m1"
                }
            }).disposed(by: disposeBag)
        infoViewModel.chart
            .asDriver(onErrorJustReturn: LineChartData())
            .drive(onNext: { [unowned self] data in
                self.lineChartView.data = data
            }).disposed(by: disposeBag)
        infoViewModel.selectedCoin
            .asDriver(onErrorJustReturn: CoinFormatter.missingCoin)
            .drive(onNext: { [unowned self] coin in
                self.iconImageView.image = coin.icon
                self.priceLabel.text = coin.price
                self.changeLabel.text = coin.change
                self.changeLabel.textColor = UIConfigurator.getChangeColorBased(on: coin)
                self.volumeLabel.text = coin.volume
                self.marketCapLabel.text = coin.marketCap
                self.supplyLabel.text = coin.supply
                self.maxSupplyLabel.text = coin.maxSupply
            }).disposed(by: disposeBag)
    }
    
    public func setSelectedCoin(_ coin: Coin) {
        nameLabel.text = " " + coin.name
        symbolLabel.text = coin.symbol
        iconImageView.image = coin.icon
        infoViewModel = InfoViewModel(id: coin.id)
        infoViewModel.selectedCoin.accept(coin)
        infoViewModel.checkFavorite()
    }
}
