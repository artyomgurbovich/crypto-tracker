//
//  ViewController.swift
//  CryptoTracker
//
//  Created by Artyom Gurbovich on 3/8/20.
//  Copyright © 2020 Artyom Gurbovich. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class CoinsViewController: UIViewController {
    
    @IBOutlet weak var shadowView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    let searchBar = UISearchBar()
    let disposeBag = DisposeBag()
    let coinsViewModel = CoinsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIConfigurator.configNavigationBar(navigationController?.navigationBar)
        UIConfigurator.configSearchBar(searchBar, navigationItem)
        UIConfigurator.configShadowView(shadowView)
        UIConfigurator.configTableView(tableView)
        coinsViewModel.targets.drive(tableView.rx.items(cellIdentifier: "cell", cellType: TableViewCell.self)) { (_, element, cell) in
            cell.iconImageView.image = element.icon
            cell.nameLabel.text = element.name
            cell.symbolLabel.text = element.symbol
            cell.priceLabel.text = element.price
            cell.changePercentLabel.text = element.change
            cell.changePercentLabel.textColor = UIConfigurator.getChangeColorBased(on: element)
            }.disposed(by: disposeBag)
        tableView.rx
            .modelSelected(Coin.self)
            .subscribe(onNext: { coin in
                self.performSegue(withIdentifier: "coinInfo", sender: coin)
            }).disposed(by: disposeBag)
        searchBar.rx.text
            .orEmpty
            .throttle(DispatchTimeInterval.milliseconds(500), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind(to: coinsViewModel.search)
            .disposed(by: disposeBag)
        searchBar.rx.searchButtonClicked.subscribe(onNext: {
                self.searchBar.resignFirstResponder()
            }).disposed(by: disposeBag)
    }
    
    @IBAction func favoritesButtonTapped(_ sender: UIBarButtonItem) {
        coinsViewModel.toggleFavortes()
        if sender.image == UIImage(systemName: "star.fill") {
           sender.image = UIImage(systemName: "star")
        } else {
            sender.image = UIImage(systemName: "star.fill")
        }
    }
    
    @IBAction func sortButtonTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Sort by", message: nil, preferredStyle: .actionSheet)
        alert.view.tintColor = UIColor.darkGray
        alert.addAction(UIAlertAction(title: "Market Cap", style: .default) { _ in self.coinsViewModel.sort.accept(.marketCap) })
        alert.addAction(UIAlertAction(title: "Change", style: .default)     { _ in self.coinsViewModel.sort.accept(.change)    })
        alert.addAction(UIAlertAction(title: "Volume", style: .default)     { _ in self.coinsViewModel.sort.accept(.volume)    })
        alert.addAction(UIAlertAction(title: "Price", style: .default)      { _ in self.coinsViewModel.sort.accept(.price)     })
        alert.addAction(UIAlertAction(title: "Name", style: .default)       { _ in self.coinsViewModel.sort.accept(.name)      })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let infoViewController = segue.destination as! InfoViewController
        infoViewController.setSelectedCoin(sender as! Coin)
    }
}
