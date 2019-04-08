//
//  ExchangeRate.swift
//  Forex
//
//  Created by Andrew R Madsen on 10/21/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import Foundation

public struct ExchangeRate {
    public var symbol: String
    public var date: Date
    public var rate: Double
    public var base: String
}
