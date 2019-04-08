//
//  TodayViewController.swift
//  ForexWidget
//
//  Created by Nelson Gonzalez on 4/8/19.
//  Copyright © 2019 Lambda School. All rights reserved.
//

import UIKit
import NotificationCenter
import Forex_Core

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet weak var exchangeRateLabel: UILabel!
    
    @IBOutlet weak var rateHistoryView: RateHistoryView!
    
    private let fetcher = ExchangeRateFetcher()
    
    private var currencyFormatter: NumberFormatter = {
        let result = NumberFormatter()
        result.numberStyle = .decimal
        result.maximumFractionDigits = 2
        result.minimumIntegerDigits = 1
        return result
    }()
    
    private var rates = [ExchangeRate]() {
        didSet {
            DispatchQueue.main.async {
                self.rateHistoryView?.exchangeRates = self.rates
            }
        }
    }
    
    private var symbol: String {
        return groupedUserDefaults.string(forKey: "lastViewedSymbol") ?? "EUR"
    }
    
    let groupedUserDefaults = UserDefaults(suiteName: "group.com.nelsongonzalez.Forex")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
       //NSExtensionContext. The thing that drives the app extension and starts it. The closest thing to the  UIApplication of the widget.
        //Adds the show more/less  button
        self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded //Lets you show more.
    }
    //I want to update the info in my widget
    //Gets called automaticallt in the foreground and backround but also it gets called when the user opens the notification center.
    //Any updates need to happen here.
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        
        fetcher.fetchCurrentExchangeRate(for: symbol) { (rate, error) in
            if let error = error {
                NSLog("Error fetching current exchange rate for \(self.symbol): \(error)")
                completionHandler(NCUpdateResult.failed)
                return
            }
            guard let rate = rate else {
                completionHandler(NCUpdateResult.failed)
                return
            }
            
            self.updateLabel(with: rate)
        }
        
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        var components = DateComponents()
        components.calendar = calendar
        components.year = -1
        let aYearAgo = calendar.date(byAdding: components, to: now)!
        
        fetcher.fetchExchangeRates(startDate: aYearAgo, symbols: [symbol]) { (rates, error) in
            if let error = error {
                NSLog("Error fetching exchange rates: \(error)")
                return
            }
            self.rates = rates ?? []
            
        }
        
        completionHandler(NCUpdateResult.newData)
    }
    
    //Gets called when the show more/less button is tapped.
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        switch activeDisplayMode {
        case .compact:
            preferredContentSize = maxSize
            self.rateHistoryView.isHidden = true
        case .expanded:
            //CGSize is just width and height
            //Make the widget  200 points high
            preferredContentSize = CGSize(width: maxSize.width, height: 200)
            self.rateHistoryView.isHidden = false
        default:
            break
        }
    }
    
    
    
    private func updateLabel(with rate: ExchangeRate) {
        DispatchQueue.main.async {
            self.exchangeRateLabel.text = (self.currencyFormatter.string(from: rate.rate as NSNumber) ?? "") + " \(rate.symbol) = 1 \(rate.base)"
        }
    }
    
    
   
}
