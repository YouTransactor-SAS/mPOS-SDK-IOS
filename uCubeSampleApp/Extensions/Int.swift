//
//  Int.swift
//  uCube
//
//  Created by Rémi Hillairet on 6/25/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

extension Int {
    
    var hexString: String {
        return String(format:"%02X", self)
    }
    
    func bcd(length: Int) -> Data {
        var data = Data(count: length)
        var value = self
        for i in (0..<length).reversed() {
            data[i] = UInt8(value % 10)
            value /= 10
            data[i] |= UInt8((value % 10) << 4)
            value /= 10
        }
        return data
    }
    
    func data(size: Int) -> Data {
        var data = Data(capacity: size)
        var value = self
        
        for i in (0..<size).reversed() {
            data[i] = UInt8(value)
            value = value >> 8
        }

        return data
    }
}
