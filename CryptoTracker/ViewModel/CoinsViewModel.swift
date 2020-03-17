//
//  ViewModel.swift
//  CryptoTracker
//
//  Created by Artyom Gurbovich on 3/13/20.
//  Copyright © 2020 Artyom Gurbovich. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxRelay
import RealmSwift

class CoinsViewModel {
    
    var onlyFavorites = BehaviorRelay<Bool>(value: false)
    let search = PublishRelay<String>()
    let sort = BehaviorRelay<CoinSortType>(value: .marketCap)
    let targets: Driver<[Coin]>
    private let coinsAPI = CoinsAPI.shared
    private let disposeBag = DisposeBag()
    
    init() {
        print("INITT")
        targets = Observable.combineLatest(coinsAPI.coins.asObservable(), search.asObservable(), sort.asObservable(), onlyFavorites.asObservable()) { (coins, search, sort, onlyFavorites) -> [Coin] in
            var coins = coins
            if onlyFavorites {
                let realm = try! Realm()
                let favoriteIds = realm.objects(Favorite.self).map{$0.id}
                coins = coins.filter{ favoriteIds.contains($0.id) }
            }
            if search != "" {
                coins = coins.filter { $0.name.lowercased().contains(search.lowercased()) }
            }
            switch sort {
            case .marketCap:
                coins.sort{ return Double($0.marketCap)! > Double($1.marketCap)! }
            case .change:
                coins.sort{ return Double($0.change)! > Double($1.change)! }
            case .volume:
                coins.sort{ return Double($0.volume)! > Double($1.volume)! }
            case .price:
                coins.sort{ return Double($0.price)! > Double($1.price)! }
            case .name:
                coins.sort{ return $0.name.lowercased() < $1.name.lowercased() }
            }
            return coins.map{ CoinFormatter.formatCoin($0) }
        }.asDriver(onErrorJustReturn: [])
    }
    
    public func toggleFavortes() {
        onlyFavorites.accept(!onlyFavorites.value)
    }
}
