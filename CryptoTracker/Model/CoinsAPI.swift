//
//  Model.swift
//  CryptoTracker
//
//  Created by Artyom Gurbovich on 3/5/20.
//  Copyright © 2020 Artyom Gurbovich. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import RxRelay

class CoinsAPI {
    
    static let shared = CoinsAPI()
    let coins = PublishRelay<[Coin]>()
    private var symbolToIcon = [String: UIImage]()
    private let backgroundQueue = DispatchQueue.global(qos: .background)
    private let semaphore = DispatchSemaphore(value: 1)
    
    private init() {
        downloadIcons()
        fetchCoins(withDelay: 0.5)
    }
    
    public func getHistory(_ coin: Coin, _ interval: String?, handler: @escaping ([(price: String, time: Int)]) -> Void) {
        let interval = interval ?? "m1"
        AF.request("https://api.coincap.io/v2/assets/\(coin.id)/history", parameters: ["interval": interval]).responseJSON(queue: backgroundQueue) { response in
            guard let value = response.value,
                  let assets = JSON(value)["data"].array else { return }
            var history = [(price: String, time: Int)]()
            let start = assets.count - 100 > 0 ? assets.count - 100 : 0
            for i in start..<assets.count {
                guard let price = assets[i]["priceUsd"].string,
                      let time = assets[i]["time"].int else { continue }
                history.append((price, time))
            }
            handler(history)
        }
    }
    
    private func downloadIcons() {
        AF.request("https://api.coincap.io/v2/assets", parameters: ["limit": "2000"]).responseJSON(queue: backgroundQueue) { [unowned self] response in
            guard let value = response.value,
                  let assets = JSON(value)["data"].array else { return }
            for asset in assets {
            guard let symbol = asset["symbol"].string else { continue }
                if let data = try? Data(contentsOf: URL(string: "https://static.coincap.io/assets/icons/\(symbol.lowercased())@2x.png")!) {
                    self.semaphore.wait()
                    self.symbolToIcon[symbol] = UIImage(data: data)
                    self.semaphore.signal()
                }
            }
        }
    }
    
    private func fetchCoins(withDelay time: Double) {
        AF.request("https://api.coincap.io/v2/assets", parameters: ["limit": "2000"]).responseJSON(queue: backgroundQueue) { [unowned self] response in
            guard let value = response.value,
                  let assets = JSON(value)["data"].array else { return }
            var coinsBuffer = [Coin]()
            for asset in assets {
                guard let id = asset["id"].string,
                      let name = asset["name"].string,
                      let symbol = asset["symbol"].string,
                      let price = asset["priceUsd"].string,
                      let change = asset["changePercent24Hr"].string,
                      let marketCap = asset["marketCapUsd"].string,
                      let volume = asset["volumeUsd24Hr"].string else { continue }
                let supply = asset["supply"].string ?? String()
                let maxSupply = asset["maxSupply"].string ?? String()
                self.semaphore.wait()
                let icon = self.symbolToIcon[symbol] ?? UIImage(named: "missing")!
                self.semaphore.signal()
                coinsBuffer.append(Coin(id: id,
                                        name: name,
                                        symbol: symbol,
                                        price: price,
                                        change: change,
                                        volume: volume,
                                        marketCap: marketCap,
                                        supply: supply,
                                        maxSupply: maxSupply,
                                        icon: icon))
            }
            self.coins.accept(coinsBuffer)
            self.backgroundQueue.asyncAfter(deadline: .now() + time) { [unowned self] in
                self.fetchCoins(withDelay: time)
            }
        }
    }
}
