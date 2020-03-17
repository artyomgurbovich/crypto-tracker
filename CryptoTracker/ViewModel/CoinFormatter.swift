//
//  CoinFormatter.swift
//  CryptoTracker
//
//  Created by Artyom Gurbovich on 3/15/20.
//  Copyright © 2020 Artyom Gurbovich. All rights reserved.
//

import UIKit

struct CoinFormatter {
    
    public static let missingCoin = Coin(id: "…",
                                         name: "…",
                                         symbol: "…",
                                         price: "…",
                                         change: "…",
                                         volume: "…",
                                         marketCap: "…",
                                         supply: "…",
                                         maxSupply: "…",
                                         icon: UIImage(named: "missing")!)
    
    public static func formatCoin(_ coin: Coin) -> Coin {
        return Coin(id: coin.id,
                    name: coin.name,
                    symbol: coin.symbol,
                    price: formatPrice(coin.price),
                    change: formatChange(coin.change),
                    volume: formatAmount(coin.volume, ending: "$"),
                    marketCap: formatAmount(coin.marketCap, ending: "$"),
                    supply: formatAmount(coin.supply, ending: coin.symbol),
                    maxSupply: formatAmount(coin.maxSupply, ending: coin.symbol),
                    icon: coin.icon)
    }
    
    private static func formatAmount(_ amount: String, ending: String) -> String {
        if amount.isEmpty {
            return "No Data"
        }
        var value = Array(amount.split(separator: ".")[0])
        var length = value.count
        var postfix = String()
        if length > 11 {
            value = Array(value[0..<length-9])
            postfix = "T"
        } else if length > 8 {
            value = Array(value[0..<length-6])
            postfix = "B"
        } else if length > 5 {
            value = Array(value[0..<length-3])
            postfix = "M"
        } else if length > 2 {
            value = Array(value[0..<length])
            postfix = "K"
        }
        length = value.count
        value = Array(length > 3 ? value[0..<length-3] + "." + value[length-3..<length] : "0." + value)
        return value + postfix + " " + ending
    }
    
    private static func formatChange(_ change: String) -> String {
        var parts = change.split(separator: ".").map{Array($0)}
        parts[0] = parts[0][0] == "-" ? "▼ " + Array(parts[0][1..<parts[0].count]) : "▲ " + parts[0]
        parts[1] = parts[1].count > 1 ? Array(parts[1][0..<2]) : parts[1] + "0"
        return parts[0] + "." + parts[1] + " %"
    }

    private static func formatPrice(_ price: String) -> String {
        var parts = price.split(separator: ".").map{Array($0)}
        while parts[1].count < 8 {
            parts[1] += "0"
        }
        var borderIndex = 1
        if parts[0].count < 2 {
            if parts[0][0] != "0" {
                borderIndex = 2
            } else {
                borderIndex = 0
                while borderIndex < 7 {
                    if parts[1][borderIndex] != "0" {
                        break
                    } else {
                        borderIndex += 1
                    }
                }
                borderIndex = min(borderIndex + 3, 7)
            }
        }
        return parts[0] + "." + parts[1][0...borderIndex] + " $"
    }
}
