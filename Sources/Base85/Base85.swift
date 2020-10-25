//
//  Base85.swift
//
//  Copyright (c) 2020 Przemysław Ambroży
//

/// A struct used to encode and decode Base-85 data
/// - Author: Przemysław Ambroży
public struct Base85 {

    private init() { }

    /// Encode using Base-85 encoding
    /// - Parameters:
    ///   - data: Data to be encoded
    ///   - encoding: Base-85 encoding (default is RFC1924)
    /// - Returns: A Base-85 encoded data or nil if data cannot be encoded
    public static func encode(_ data: [UInt8], encoding: Encoding = .rfc1924) -> [UInt8]? {

        let padding = (data.count % 4) > 0 ? 4 - (data.count % 4) : 0

        let padded = Array(data) + Array(repeating: 0, count: padding)

        var result = padded
            .chunked(into: 4)
            .flatMap { bytes -> [UInt8] in

                var number = UInt32(bigEndian: bytes.withUnsafeBytes { $0.load(as: UInt32.self) })
                var byte = [UInt8]()
                for _ in 0..<5 {
                    byte.append(UInt8(number % 85))
                    number /= 85
                }

                return byte.reversed()
            }
            .dropLast(padding)
            .array()
            .chunked(into: 5)
            .flatMap { chunk -> [UInt8] in
                if let zeros = encoding.compressFourZeros, chunk == [0, 0, 0, 0, 0] {
                    return [zeros]
                // or [10, 27, 53, 67, 43]
                } else if let spaces = encoding.compressFourSpaces, chunk == [16, 11, 25, 52, 30] {
                    return [spaces]
                } else {
                    return chunk.map { encoding.encode[ Int($0) ] }
                }
            }

        // Array cannot end with zeros
        if let zeros = encoding.compressFourZeros, result.last == zeros {
            result.removeLast()
            result += Array(repeating: encoding.encode[0], count: 5)
        }

        // Start delimeter
        if let startDelimeter = encoding.startDelimeter {
            result = startDelimeter + result
        }

        // End delimeter
        if let endDelimeter = encoding.endDelimeter {
            result += endDelimeter
        }

        return result
    }

    /// Prepare data for decoding
    private static func prepareForDecoding(data: [UInt8], encoding: Encoding) -> [UInt8]? {

        var data = data

        // Remove start delimeter
        if let startDelimeter = encoding.startDelimeter {
            if data.starts(with: startDelimeter) {
                data.removeFirst(startDelimeter.count)
            }
        }

        // Remove end delimeter
        if let endDelimeter = encoding.endDelimeter {
            if data.ends(with: endDelimeter) {
                data.removeLast(endDelimeter.count)
            }
        }

        // Replace zeros delimeter with zeros
        if let encZeros = encoding.compressFourZeros {

            guard encoding.encode.count > 0 else { return nil }

            data = data.flatMap { char -> [UInt8] in
                if char == encZeros {
                    return Array(repeating: encoding.encode[0], count: 5)
                } else {
                    return [char]
                }
            }
        }

        // Replace spaces delimeter with spaces
        if let encSpaces = encoding.compressFourSpaces {

            guard encoding.encode.count > 67 else { return nil }

            data = data.flatMap { char -> [UInt8] in
                if char == encSpaces {
                    return [
                        encoding.encode[16],
                        encoding.encode[11],
                        encoding.encode[25],
                        encoding.encode[52],
                        encoding.encode[30]
                    ]
                } else {
                    return [char]
                }
            }
        }

        return data
    }

    /// Decode using Base85 encoding
    /// - Parameters:
    ///   - data: Data to be decoded
    ///   - encoding: Base-85 encoding (default is RFC1924)
    /// - Returns: Decoded data or nil if data cannot be decoded
    public static func decode(_ data: [UInt8], encoding: Encoding = .rfc1924) -> [UInt8]? {

        // Prepare data
        guard var data = prepareForDecoding(data: data, encoding: encoding) else { return nil }

        // Calculate padding
        let padding = (data.count % 5) > 0 ? 5 - (data.count % 5) : 0

        // Add padding
        data += Array(repeating: encoding.encode[84], count: padding)

        if let max = data.max() {
            guard encoding.decode.count >= max - 33 else { return nil }
        }

        let result = data
            .map { encoding.decode[ Int($0) - 33 ] }
            .chunked(into: 5)
            .map { array -> UInt32 in
                var number: UInt32 = 0
                for num in array {
                    number *= 85
                    number += UInt32(num)
                }
                return number
            }
            .flatMap { number -> [UInt8] in
                var number = number
                var array = [UInt8]()
                for _ in 0...3 {
                    array.append(UInt8(number & 0xff))
                    number = number >> 8
                }
                return array.reversed()
            }
            .dropLast(padding)

        return Array(result)
    }

}

internal extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

fileprivate extension Array where Element: Equatable {
    func ends(with possibleSuffix: [Element]) -> Bool {
        if count >= possibleSuffix.count {
            return Array(self[(endIndex - possibleSuffix.count)..<endIndex]) == possibleSuffix
        }
        return false
    }
}

fileprivate extension ArraySlice {
    func array() -> [Element] {
        Array(self)
    }
}
