//
//  FavoriteTickerViewController.swift
//  Bithumb
//
//  Created by JINHONG AN on 2022/01/29.
//

import UIKit
import XLPagerTabStrip

final class FavoriteTickerViewController: UIViewController {
    //MARK: Properties
    @IBOutlet private weak var tickerTableView: UITableView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    private let repository: Repositoryable = Repository()
    private let tickerTableViewDataSource = TickerTableViewDataSource()
    private var apiType: ApiType = .upbit
    private var isViewDisplay = false
    
    //MARK: LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        repository.register(delegate: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isViewDisplay = true
        registerObserver()
        activityIndicator.startAnimating()
        reqeustRestTickerAPI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isViewDisplay = false
        removeObserver()
        repository.execute(request: .disconnect)
    }
}

//MARK: - SetUp UI
extension FavoriteTickerViewController {
    private func setUpTableView() {
        tickerTableView.dataSource = tickerTableViewDataSource
        tickerTableView.delegate = self
        tickerTableView.register(TickerTableViewCell.self, forCellReuseIdentifier: TickerTableViewCell.identifier)
    }
}

//MARK: - Conform to IndicatorInfoProvider
extension FavoriteTickerViewController: IndicatorInfoProvider {
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "관심")
    }
}

//MARK: - Conform to UITableViewDelegate
extension FavoriteTickerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let exchangeDetailViewController = storyboard?.instantiateViewController(withIdentifier: "ExchangeDetailViewController") as? ExchangeDetailViewController else {
            return
        }
        
        let symbol = tickerTableViewDataSource.findSymbol(by: indexPath.row)
        let koreanName = tickerTableViewDataSource.findKoreanName(by: indexPath.row)
        
        exchangeDetailViewController.register(apiType: apiType)
        exchangeDetailViewController.register(symbol: symbol)
        exchangeDetailViewController.register(koreanName: koreanName)
        
        navigationController?.pushViewController(exchangeDetailViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let cell = cell as? TickerTableViewCell else {
            return
        }
        
        let trend = tickerTableViewDataSource.bringTrend(by: indexPath.row)
        cell.sparkle(by: trend)
        tickerTableViewDataSource.resetTrend(by: indexPath.row)
    }
}

//MARK: - Network
extension FavoriteTickerViewController {
    private func reqeustUpbitRestTickerAPI() {
        let favoriteCoinSymbols = bringFavoriteCoinSymbols()
        if favoriteCoinSymbols.isEmpty {
            self.tickerTableViewDataSource.reset()
            self.tickerTableView.reloadData()
            activityIndicator.stopAnimating()
            return
        }
        var requestResults: [Result<[TickerDTO], RestError>] = []
        let dispatchGroup = DispatchGroup()
        
        
        let tickerRequests = favoriteCoinSymbols.compactMap { (symbol: String) ->UpbitTickerRequest? in
            return UpbitTickerRequest.lookUp(market: symbol)
        }
        
        tickerRequests.forEach {
            dispatchGroup.enter()
            repository.execute(request: $0) { result in
                requestResults.append(result)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .global()) { [weak self] in
            var favoriteCoinTickers: [TickerDTO] = []
            requestResults.forEach { result in
                switch result {
                case .success(let tickers):
                    favoriteCoinTickers.append(contentsOf: tickers)
                case .failure(let error):
                    UIAlertController.showAlert(about: error, on: self)
                }
            }
            self?.tickerTableViewDataSource.configure(tickers: favoriteCoinTickers)
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.tickerTableView.reloadData()
            }
            self?.requestUpbitWebSocketTickerAPI(marketList: favoriteCoinSymbols)
        }
    }
    
    private func requestBithumbRestTickerAPI() {
        let favoriteCoinSymbols = bringFavoriteCoinSymbols()
        var requestResults: [Result<[TickerDTO], RestError>] = []
        let dispatchGroup = DispatchGroup()
        
        
        let tickerRequests = favoriteCoinSymbols.compactMap { (symbol: String) -> TickerRequest? in
            let currencies = symbol.split(separator: "_").map { String($0) }
            guard let orderCurrency = currencies.first, let paymentCurrency = currencies.last else {
                return nil
            }
            
            return TickerRequest.lookUp(orderCurrency: orderCurrency, paymentCurrency: paymentCurrency)
        }
        
        tickerRequests.forEach {
            dispatchGroup.enter()
            repository.execute(request: $0) { result in
                requestResults.append(result)
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .global()) { [weak self] in
            var favoriteCoinTickers: [TickerDTO] = []
            requestResults.forEach { result in
                switch result {
                case .success(let tickers):
                    favoriteCoinTickers.append(contentsOf: tickers)
                case .failure(let error):
                    UIAlertController.showAlert(about: error, on: self)
                }
            }
            self?.tickerTableViewDataSource.configure(tickers: favoriteCoinTickers)
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                self?.tickerTableView.reloadData()
            }
            self?.requestWebSocketTickerAPI(symbols: favoriteCoinSymbols)
        }
    }
    
    private func requestUpbitWebSocketTickerAPI(marketList: [String]) {
        repository.execute(request: .connect(target: .upbitPublic))
        repository.execute(request: .send(message: .upibtTicker(markets: marketList)))
    }
    
    private func requestWebSocketTickerAPI(symbols: [String]) {
        repository.execute(request: .connect(target: .bitumbPublic))
        repository.execute(request: .send(message: .ticker(symbols: symbols)))
    }
    
    private func reqeustRestTickerAPI() {
        if apiType == .bithumb {
            requestBithumbRestTickerAPI()
        } else if apiType == .upbit {
            reqeustUpbitRestTickerAPI()
        } else {
            return
        }
    }
    
    private func bringFavoriteCoinSymbols() -> [String] {
        var favoriteCoinKey = ""
        if apiType == .upbit {
            favoriteCoinKey = "upbitFavoriteCoinSymbols"
        } else {
            favoriteCoinKey = "bithumbFavoriteCoinSymbols"
        }
        guard let favoriteCoinSymbols = UserDefaults.standard.array(forKey: favoriteCoinKey) as? [String] else {
            return []
        }
        return favoriteCoinSymbols
    }
}

extension FavoriteTickerViewController: WebSocketDelegate {
    func didReceive(_ upbitMessageEvent: WebSocketUpbitResponseMessage) {
        switch upbitMessageEvent {
        case .ticker(let tickerDTO):
            guard let index = tickerTableViewDataSource.update(by: tickerDTO) else {
                return
            }
            DispatchQueue.main.async {
                self.tickerTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        default:
            break
        }
    }
    
    func didReceive(_ connectionEvent: WebSocketConnectionEvent) {
        UIAlertController.showAlert(about: connectionEvent, on: self)
    }
    
    func didReceive(_ messageEvent: WebSocketResponseMessage) {
        switch messageEvent {
        case .ticker(let tickerDTO):
            guard let index = tickerTableViewDataSource.update(by: tickerDTO) else {
                return
            }
            DispatchQueue.main.async {
                self.tickerTableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .none)
            }
        default:
            break
        }
    }
    
    func didReceive(_ subscriptionEvent: WebSocketSubscriptionEvent) {
        UIAlertController.showAlert(about: subscriptionEvent, on: self)
    }
    
    func didReceive(_ error: WebSocketCommonError) {
        UIAlertController.showAlert(about: error, on: self)
    }
}

//MARK: - Conform to AppLifeCycleOserverable
extension FavoriteTickerViewController: AppLifeCycleOserverable {
    func receiveForegoundNotification() {
        requestBithumbRestTickerAPI()
    }
    
    func receiveBackgroundNotification() {
        repository.execute(request: .disconnect)
    }
}

//MARK: - Conform to ChagneAPIObservable
extension FavoriteTickerViewController: changeAPIObserverable {
    func didRecive(apiType: ApiType) {
        self.apiType = apiType
        
        if isViewDisplay {
            repository.execute(request: .disconnect)
            switch apiType {
            case .bithumb:
                requestBithumbRestTickerAPI()
            case .upbit:
                reqeustUpbitRestTickerAPI()
            }
        } else {
            return
        }
    }
}
