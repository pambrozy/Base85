//
//  Encoding.swift
//  
//  Copyright (c) 2020 Przemysław Ambroży
//

public extension Base85 {

    /// Base-85 encoding mode
    struct Encoding: Hashable, Equatable {
        public let encode: [UInt8]
        public let decode: [UInt8]
        public let startDelimeter: [UInt8]?
        public let endDelimeter: [UInt8]?
        public let compressFourZeros: UInt8?
        public let compressFourSpaces: UInt8?
    }

}

public extension Base85.Encoding {

    /// ASCII version
    /// - Note: This format uses ASCII characters "!" through "u".
    /// It does not compress zeros, spaces or use any start/end delimeters
    static let ascii = Self(encode: [33, 34, 35, 36, 37, 38, 39, 40, 41, 42,
                                     43, 44, 45, 46, 47, 48, 49, 50, 51, 52,
                                     53, 54, 55, 56, 57, 58, 59, 60, 61, 62,
                                     63, 64, 65, 66, 67, 68, 69, 70, 71, 72,
                                     73, 74, 75, 76, 77, 78, 79, 80, 81, 82,
                                     83, 84, 85, 86, 87, 88, 89, 90, 91, 92,
                                     93, 94, 95, 96, 97, 98, 99, 100, 101, 102,
                                     103, 104, 105, 106, 107, 108, 109, 110, 111, 112,
                                     113, 114, 115, 116, 117],
                            decode: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9,
                                     10, 11, 12, 13, 14, 15, 16, 17, 18, 19,
                                     20, 21, 22, 23, 24, 25, 26, 27, 28, 29,
                                     30, 31, 32, 33, 34, 35, 36, 37, 38, 39,
                                     40, 41, 42, 43, 44, 45, 46, 47, 48, 49,
                                     50, 51, 52, 53, 54, 55, 56, 57, 58, 59,
                                     60, 61, 62, 63, 64, 65, 66, 67, 68, 69,
                                     70, 71, 72, 73, 74, 75, 76, 77, 78, 79,
                                     80, 81, 82, 83, 84],
                            startDelimeter: nil,
                            endDelimeter: nil,
                            compressFourZeros: nil,
                            compressFourSpaces: nil)

    /// RFC 1924 version
    static let rfc1924 = Self(encode: [48, 49, 50, 51, 52, 53, 54, 55, 56, 57,
                                       65, 66, 67, 68, 69, 70, 71, 72, 73, 74,
                                       75, 76, 77, 78, 79, 80, 81, 82, 83, 84,
                                       85, 86, 87, 88, 89, 90, 97, 98, 99, 100,
                                       101, 102, 103, 104, 105, 106, 107, 108, 109, 110,
                                       111, 112, 113, 114, 115, 116, 117, 118, 119, 120,
                                       121, 122, 33, 35, 36, 37, 38, 40, 41, 42,
                                       43, 45, 59, 60, 61, 62, 63, 64, 94, 95,
                                       96, 123, 124, 125, 126],
                              decode: [62, 0, 63, 64, 65, 66, 0, 67, 68, 69,
                                       70, 0, 71, 0, 0, 0, 1, 2, 3, 4,
                                       5, 6, 7, 8, 9, 0, 72, 73, 74, 75,
                                       76, 77, 10, 11, 12, 13, 14, 15, 16, 17,
                                       18, 19, 20, 21, 22, 23, 24, 25, 26, 27,
                                       28, 29, 30, 31, 32, 33, 34, 35, 0, 0,
                                       0, 78, 79, 80, 36, 37, 38, 39, 40, 41,
                                       42, 43, 44, 45, 46, 47, 48, 49, 50, 51,
                                       52, 53, 54, 55, 56, 57, 58, 59, 60, 61,
                                       81, 82, 83, 84],
                              startDelimeter: nil,
                              endDelimeter: nil,
                              compressFourZeros: nil,
                              compressFourSpaces: nil)

    /// `btoa` program version
    /// - Note:
    ///     This format:
    ///     - Uses "x" delimeter at the end of data
    ///     - Uses "y" to represent four spaces
    ///     - Uses "z" to represent four zeros
    static let btoa = Self(encode: ascii.encode,
                           decode: ascii.decode,
                           startDelimeter: nil,
                           endDelimeter: [120],
                           compressFourZeros: 122,
                           compressFourSpaces: 121)

    /// Adobe Ascii85 version
    /// - Note:
    ///     This format:
    ///     - Encloses data wist delimeters "<~" and "~>"
    ///     - Uses "z" to represent four zeros
    static let adobeAscii85 = Self(encode: ascii.encode,
                                   decode: ascii.decode,
                                   startDelimeter: [60, 126],
                                   endDelimeter: [126, 62],
                                   compressFourZeros: 122,
                                   compressFourSpaces: nil)

    /// ZeroMQ format
    /// - Warning: The specification for this format requires that the decoded
    /// data be divisible by 4 and the encoded data be divisible by 5. This library
    /// currently does not enforce this requirement.
    static let z85 = Self.init(encode: [48, 49, 50, 51, 52, 53, 54, 55, 56, 57,
                                        97, 98, 99, 100, 101, 102, 103, 104, 105, 106,
                                        107, 108, 109, 110, 111, 112, 113, 114, 115, 116,
                                        117, 118, 119, 120, 121, 122, 65, 66, 67, 68,
                                        69, 70, 71, 72, 73, 74, 75, 76, 77, 78,
                                        79, 80, 81, 82, 83, 84, 85, 86, 87, 88,
                                        89, 90, 46, 45, 58, 43, 61, 94, 33, 47,
                                        42, 63, 38, 60, 62, 40, 41, 91, 93, 123,
                                        125, 64, 37, 36, 35],
                               decode: [68, 0, 84, 83, 82, 72, 0, 75, 76, 70,
                                        65, 0, 63, 62, 69, 0, 1, 2, 3, 4,
                                        5, 6, 7, 8, 9, 64, 0, 73, 66, 74,
                                        71, 81, 36, 37, 38, 39, 40, 41, 42, 43,
                                        44, 45, 46, 47, 48, 49, 50, 51, 52, 53,
                                        54, 55, 56, 57, 58, 59, 60, 61, 77, 0,
                                        78, 67, 0, 0, 10, 11, 12, 13, 14, 15,
                                        16, 17, 18, 19, 20, 21, 22, 23, 24, 25,
                                        26, 27, 28, 29, 30, 31, 32, 33, 34, 35,
                                        79, 0, 80],
                               startDelimeter: nil,
                               endDelimeter: nil,
                               compressFourZeros: nil,
                               compressFourSpaces: nil)

    /// Customized Base-85 encoding based on an existing encoding
    /// - Parameters:
    ///   - encoding: Base encoding
    ///   - startDelimeter: Delimeter to be added before the data
    ///   - endDelimeter: Delimeter to be added after the data
    ///   - zeros: Character to represent four zeros
    ///   - spaces: Character to represent four spaces
    /// - Returns: Customized Base-85 encoding
    static func customized(baseEncoding encoding: Self,
                           startDelimeter: String?,
                           endDelimeter: String?,
                           representFourZerosAs zeros: Character?,
                           representFourSpacesAs spaces: Character?) -> Self {

        // Start delimeter
        var startDel: [UInt8]?
        if let startDelimeter = startDelimeter, startDelimeter.count > 0 {
            startDel = Array(startDelimeter.utf8)
        }

        // End delimeter
        var endDel: [UInt8]?
        if let endDelimeter = endDelimeter, endDelimeter.count > 0 {
            endDel = Array(endDelimeter.utf8)
        }

        // Four zeros delimeter
        var compressFourZeros: UInt8?
        if let zeros = zeros, let char = zeros.asciiValue {
            compressFourZeros = char
        }

        // Four spaces delimeter
        var compressFourSpaces: UInt8?
        if let spaces = spaces, let char = spaces.asciiValue {
            compressFourSpaces = char
        }

        return Self(encode: encoding.encode,
                    decode: encoding.decode,
                    startDelimeter: startDel,
                    endDelimeter: endDel,
                    compressFourZeros: compressFourZeros,
                    compressFourSpaces: compressFourSpaces)

    }

    /// Custom Base-85 encoding based on an array of characters
    /// - Parameters:
    ///   - characters: An array with ASCII representation of values.
    ///     - The smallest character value cannot be smaller than 33 (ASCII "!").
    ///     - The number of characters should be 85.
    ///   - startDelimeter: Delimeter to be added before the data
    ///   - endDelimeter: Delimeter to be added after the data
    ///   - zeros: Character to represent four zeros
    ///   - spaces: Character to represent four spaces
    /// - Returns: Custom Base-85 encoding or nil
    static func custom(characters: [Character],
                       startDelimeter: String?,
                       endDelimeter: String?,
                       representFourZerosAs zeros: Character?,
                       representFourSpacesAs spaces: Character?) -> Self? {

        // Encoding characters
        let encode = characters.compactMap { $0.asciiValue }

        guard
            let min = encode.min(),
            let max = encode.max(),
            min >= 33,
            encode.count >= 85
        else { return nil }

        // Decoding characters
        var decode = [UInt8](repeating: 0, count: Int(max - min) + 1)

        for (index, char) in encode.enumerated() {
            decode[ Int(char - 33) ] = UInt8(index)
        }

        // Start delimeter
        var startDel: [UInt8]?
        if let startDelimeter = startDelimeter, startDelimeter.count > 0 {
            startDel = Array(startDelimeter.utf8)
        }

        // End delimeter
        var endDel: [UInt8]?
        if let endDelimeter = endDelimeter, endDelimeter.count > 0 {
            endDel = Array(endDelimeter.utf8)
        }

        // Four zeros delimeter
        var compressFourZeros: UInt8?
        if let zeros = zeros, let char = zeros.asciiValue {
            compressFourZeros = char
        }

        // Four spaces delimeter
        var compressFourSpaces: UInt8?
        if let spaces = spaces, let char = spaces.asciiValue {
            compressFourSpaces = char
        }

        return Self(encode: encode,
                    decode: decode,
                    startDelimeter: startDel,
                    endDelimeter: endDel,
                    compressFourZeros: compressFourZeros,
                    compressFourSpaces: compressFourSpaces)

    }
}
