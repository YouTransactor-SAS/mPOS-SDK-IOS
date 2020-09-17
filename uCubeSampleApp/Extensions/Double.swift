//
//  Double.swift
//  uCube
//
//  Created by Rémi Hillairet on 6/25/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

extension Double {
    
    func bcd(length: Int) -> Data {
        let formatter = NumberFormatter()
        formatter.minimumIntegerDigits = 2 * length
        formatter.maximumIntegerDigits = 2 * length
        formatter.maximumFractionDigits = 0 // seems useless
        return formatter.string(from: NSNumber(value: self))?.hexadecimal ?? Data(repeating: 0x00, count: length)
    }
}
