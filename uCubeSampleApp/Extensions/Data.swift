//
//  Data.swift
//  uCube
//
//  Created by Rémi Hillairet on 6/19/20.
//  Copyright © 2020 YouTransactor. All rights reserved.
//

public extension Data {
    
    var svppSerialNumberLen: Int {
        return 5
    }
    
    var svppPartNumberLen: Int {
        return 15
    }
    
    var svppVersionLen: Int {
        return 4
    }
    
    enum Endianness {
        case bigEndian
        case littleEndian
    }
    
    var intValue: Int {
        var result = 0
        for b in self {
            var bb = Int(b)
            if bb < 0 {
                bb = 256 + bb
            }
            result = result << 8
            result |= bb
        }
        switch count {
        case 1:
            result &= 0x000000FF
        case 2:
            result &= 0x0000FFFF
        case 3:
            result &= 0x00FFFFFF
        default:
            break
        }
        return result
//        guard count == 2 else {
//            return 0
//        }
//        var msbInt = Int(self[0])
//        var lsbInt = Int(self[1])
//
//        if msbInt < 0 {
//            msbInt += 0x100
//        }
//        if lsbInt < 0 {
//            lsbInt += 0x100
//        }
//        return msbInt * 0x100 + lsbInt
//        switch count {
//        case 1:
//            return Int(integerValue() as UInt8)
//        case 2:
//            return Int(integerValue() as UInt16)
//        case 4:
//            return Int(integerValue() as UInt32)
//        default:
//            return integerValue()
//        }
    }
    
    var hexString: String {
        return map { String(format: "%02X", $0) }.joined()
    }
    
    mutating func writeTagID(_ tagID: Int) {
        if tagID >= 0x100 {
            append(UInt8((tagID & 0xFF00) >> 8))
        }
        append(UInt8(tagID & 0xFF))
    }
    
    mutating func writeTagLength(_ length: Int) {
        if length > 0xFFFF {
            return
        }

        if length < 0x7F {
            append(UInt8(length))
            return
        }

        if length <= 0xFF {
            append(0x81)
            append(UInt8(length))
            return
        }

        append(0x82)
        append(UInt8(length >> 8))
        append(UInt8(length))
        return
    }
    
    func parseTLV() -> [Int: Data] {
        return parseTLV(offset: 0, length: count)
    }
    
    func parseTLV(offset firstOffset: Int, length: Int) -> [Int: Data] {
        var result: [Int: Data] = [:]
        var offset = firstOffset
        let lastOffset = Swift.min(count, offset + length)
        while offset < lastOffset {
            guard let tag = readTag(offset: offset) else {
                break
            }
            offset += tag.count
            guard let tagLength = readTagLength(offset: offset) else {
                break
            }
            offset += tagLength.count
            guard let tagValue = readTagValue(offset: offset, length: tagLength.intValue) else {
                break
            }
            offset += tagValue.count
            result[tag.intValue] = tagValue
        }
        return result
    }
    
    func parseYtBerMixedLen() -> [Int: Data] {
        return parseYtBerMixedLen(offset: 0, length: count)
    }
    
    func parseYtBerMixedLen(offset firstOffset: Int, length: Int) -> [Int: Data] {
        var result: [Int: Data] = [:]
        var offset = firstOffset
        let lastOffset = Swift.min(count, offset + length)
        while offset < lastOffset {
            guard let tag = readTag(offset: offset) else {
                break
            }
            offset += tag.count
            guard let tagLength = readTagLengthYTBERMixedStyle(offset: offset, tag: tag) else {
                break
            }
            offset += tagLength.count
            guard let tagValue = readTagValue(offset: offset, length: tagLength.intValue) else {
                break
            }
            offset += tagValue.count
            result[tag.intValue] = tagValue
        }
        return result
    }
    
    func parseWithRedundancy(offset firstOffset: Int, length: Int) -> [Int: Data] {
        var result: [Int: Data] = [:]
        var offset = firstOffset
        let lastOffset = Swift.min(count, offset + length)
        while offset < lastOffset {
            guard let tag = readTag(offset: offset) else {
                break
            }
            offset += tag.count
            guard let tagLength = readTagLengthYTBERMixedStyle(offset: offset, tag: tag) else {
                break
            }
            offset += tagLength.count
            guard let tagValue = readTagValue(offset: offset, length: tagLength.intValue) else {
                break
            }
            offset += tagValue.count
            if !result.keys.contains(tag.intValue) {
                result[tag.intValue] = tagValue
            }
        }
        return result
    }
    
    func parseSerial() -> String {
        guard count == svppSerialNumberLen else {
            return ""
        }
        var v: Int64 = 0
        for b in self {
            v = (v << 8) + Int64(b & 0xFF)
        }
        v /= 4
        return String(format: "%012ld", v)
    }
    
    func parseParNumber() -> String {
        guard count == svppPartNumberLen else {
            return ""
        }
        let realPartNumber = self.subdata(in: 0..<svppPartNumberLen)
        return String(data: realPartNumber, encoding: .utf8)?.replacingOccurrences(of: " ", with: "") ?? ""
    }
    
    func parseVersion() -> String {
        var version = ""
        for i in 0..<self.count {
            if i > 0 {
                version.append(".")
            }
            version.append("\(self[i])")
        }
        return version
    }
    
    func readTag(offset: Int) -> Data? {
        guard offset >= 0, offset < count else {
            return nil
        }
        if (self[offset] & 0x1F) == 0x1F {
            guard offset + 1 < count else {
                return nil
            }
            return Data([self[offset], self[offset + 1]])
        }
        return Data([self[offset]])
    }
    
    func readTagLength(offset: Int) -> Data? {
        guard offset >= 0, offset < count else {
            return nil
        }
        var byte = self[offset]
        if (byte & 0x80) == 0 {
            return Data([byte])
        }
        byte = byte & 0x7F
        if byte == 0 {
            return Data([0x80])
        }
        return self.subdata(in: offset..<(offset + Int(byte)))
    }
    
    func readTagLengthYTBERMixedStyle(offset firstOffset: Int, tag: Data) -> Data? {
        var offset = firstOffset
        guard offset >= 0, offset < count else {
            return nil
        }
        var length = Data()
        var byte = self[offset]
        offset += 1
        if (byte & 0x80) == 0 {
            return Data([byte])
        }
        switch tag[0] {
        case 0xE8: // when tag E8 is detected, check if len is BER or YT style
            LogManager.debug(message: "ReadTag: Mixed BER-TLV and YT-TLV tag length detected!")
            switch byte {
            case 0x81, 0x82:
                // BER_TLV length style
                break
            default:
                // YT length style
                return Data([byte])
            }
        default:
            break
        }
        byte = byte & 0x7F
        if byte == 0 {
            return Data([0x80])
        }
        // DIRTY Solution, the length of the length will be used as offset at upper layer :'(
        // TODO: Needs to fix this properly
        // As if we take in accouht 81 or 82, but replaced by 0
        length[0] = 0
        for i in 0..<Int(byte) {
            length[i + 1] = self[offset + i]
        }
        return length
    }
    
    func readTagValue(offset: Int, length: Int) -> Data? {
        guard offset >= 0, offset + length <= count else {
            return nil
        }
        return self.subdata(in: offset..<(offset + length))
    }
    
    func fromBCD() -> Double {
        return Double(hexString) ?? 0
    }
    
    func fromBCD() -> Int {
        var result = 0
        for i in 0..<count {
            result *= 10
            result += Int((self[i] << 4) & 0xF)
            result *= 10
            result += Int(self[i] & 0xF)
        }
        return result
    }
    
    func checksumCRC16() -> Int {
        var crc = 0x0000
        var temp = 0
        var crcByte: UInt8 = 0
        
        for byte in self {
            crcByte = byte
            for _ in 0..<8 {
                temp = (crc >> 15) ^ (Int(crcByte) >> 7)
                crc <<= 1
                crc &= 0xFFFF
                if temp > 0 {
                    crc ^= 0x1021
                    crc &= 0xFFFF
                }
                crcByte <<= 1
                crcByte &= 0xFF
            }
        }
        return crc
    }
    
    private func integerValue<T: FixedWidthInteger>() -> T {
        guard count <= MemoryLayout<T>.size else {
            LogManager.error(message: "Cannot convert \([UInt8](self)) to \(T.self)")
            return 0
        }
        return reversed().reduce(0) { (soFar, byte) -> T in
            return soFar << 8 | T(byte)
        }
    }
    
    private func value<T: FixedWidthInteger>(at index: Data.Index, endianness: Endianness) -> T {
        let number: T = subdata(in: index..<(index + MemoryLayout<T>.size)).withUnsafeBytes({ $0.load(as: T.self) })
        switch endianness {
        case .bigEndian:
            return number.bigEndian
        case .littleEndian:
            return number.littleEndian
        }
    }
}
