//
//  InfoViewModel.swift
//  CryptoTracker
//
//  Created by Artyom Gurbovich on 3/16/20.
//  Copyright © 2020 Artyom Gurbovich. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Charts
import RealmSwift

class InfoViewModel {
    
    let isFavorite = BehaviorRelay<Bool>(value: false)
    let selectedCoin = BehaviorRelay<Coin>(value: CoinFormatter.missingCoin)
    let chart = PublishRelay<LineChartData>()
    var interval = "m1"
    private let coinsAPI = CoinsAPI.shared
    private let disposeBag = DisposeBag()
    
    init(id: String) {
        coinsAPI.coins.subscribe(onNext: { [weak self] coins in
            for coin in coins {
                if coin.id == id {
                    self?.selectedCoin.accept(CoinFormatter.formatCoin(coin))
                    self?.coinsAPI.getHistory(coin, self?.interval) { [weak self] history in
                        var chartDataEntries = [ChartDataEntry]()
                        for element in history {
                            chartDataEntries.append(ChartDataEntry(x: Double(element.time), y: Double(element.price)!))
                        }
                        let lineChartDataSet = LineChartDataSet(entries: chartDataEntries)
                        lineChartDataSet.mode = .cubicBezier
                        lineChartDataSet.drawCirclesEnabled = false
                        lineChartDataSet.drawValuesEnabled = false
                        lineChartDataSet.lineWidth = 1
                        lineChartDataSet.setColor(.darkGray)
                        let gradientColors = [UIColor.darkGray.cgColor, UIColor.white.cgColor] as CFArray
                        let gradient = CGGradient.init(colorsSpace: CGColorSpaceCreateDeviceRGB(), colors: gradientColors, locations: [1.0, 0.0])
                        lineChartDataSet.fill = Fill.fillWithLinearGradient(gradient!, angle: 90.0)
                        lineChartDataSet.drawFilledEnabled = true
                        self?.chart.accept(LineChartData(dataSet: lineChartDataSet))
                    }
                    break
                }
            }
        }).disposed(by: disposeBag)
    }
    
    public func checkFavorite() {
        let realm = try! Realm()
        if let _ = realm.objects(Favorite.self).filter("id == '\(selectedCoin.value.id)'").first {
            isFavorite.accept(true)
        } else {
            isFavorite.accept(false)
        }
    }
    
    public func toggleFavorite() {
        isFavorite.accept(!isFavorite.value)
        let realm = try! Realm()
        if isFavorite.value == true {
            let favorite = Favorite()
            favorite.id = selectedCoin.value.id
            try! realm.write {
                realm.add(favorite)
            }
        } else {
            let favorite = realm.objects(Favorite.self).filter("id == '\(selectedCoin.value.id)'").first!
            try! realm.write {
                realm.delete(favorite)
            }
        }
    }
}
