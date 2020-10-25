//
//  Foundation+Base85.swift
//
//  Copyright (c) 2020 Przemysław Ambroży
//

#if canImport(Foundation)
import Foundation

// MARK: - Data encoding / decoding options

public extension Data {

    /// Options for methods used to encode data using Base85
    struct Base85EncodingOptions: OptionSet {

        public let rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        /// Set the maxiumum line length to 64 characters, after which line ending is inserted
        /// - Note: The default line ending is CR LF
        public static var lineLength64Characters = Self(rawValue: 1 << 0)

        /// Set the maxiumum line length to 76 characters, after which line ending is inserted
        /// - Note: The default line ending is CR LF
        public static var lineLength76Characters = Self(rawValue: 1 << 1)

        /// When a maximum line length is set, line ending will include carriage return
        public static var endLineWithCarriageReturn = Self(rawValue: 1 << 4)

        /// When a maximum line length is set, line ending will include line feed
        public static var endLineWithLineFeed = Self(rawValue: 1 << 5)

    }

    /// Options to modify the decoding algorithm used to decode Base85 encoded data
    struct Base85DecodingOptions: OptionSet {
        public let rawValue: UInt

        public init(rawValue: UInt) {
            self.rawValue = rawValue
        }

        /// When decoding, unknown characters are ignored (including line feed and carriage return)
        public static var ignoreUnknownCharacters = Self(rawValue: 1 << 0)
    }

}

// MARK: - Data decoding

public extension Data {

    /// Initialize a `Data` from a Base-85 encoded String
    ///
    /// Returns nil when the input is not recognized as valid Base-85
    ///
    /// - Parameters:
    ///   - base85String: The string to parse
    ///   - options: Encoding options (default is `[]`)
    ///   - encoding: Base-85 encoding (default is RFC1924)
    init?(base85Encoded base85String: String,
          options: Data.Base85DecodingOptions = [],
          encoding: Base85.Encoding = .rfc1924) {

        if
            let data = base85String.data(using: .utf8),
            let decoded = Data(base85Encoded: data, options: options, encoding: encoding)
        {
            self = decoded
        } else {
            return nil
        }

    }

    /// Initialize a `Data` from a Base-85 encoded `Data`
    ///
    /// Returns nil when the input is not recognized as valid Base-85
    ///
    /// - Parameters:
    ///   - base85Data: Base-85 encoded input
    ///   - options: Decoding options (default is `[]`)
    ///   - encoding: Base-85 encoding (default is RFC1924)
    init?(base85Encoded base85Data: Data,
          options: Data.Base85DecodingOptions = [],
          encoding: Base85.Encoding = .rfc1924) {

        var data = Array(base85Data)
        if options.contains(.ignoreUnknownCharacters) {
            data = data.filter { encoding.encode.contains($0) }
        }

        if let decoded = Base85.decode(data, encoding: encoding) {
            self = Data(decoded)
        } else {
            return nil
        }
    }
}

// MARK: - Data encoding

public extension Data {

    /// Returns a Base-85 encoded string.
    /// - Parameters:
    ///   - options: The options to use for the encoding (default is `[]`)
    ///   - encoding: Base-85 encoding (default is RFC1924)
    /// - Returns: The Base-85 encoded data
    func base85EncodedString(options: Data.Base85EncodingOptions = [],
                             encoding: Base85.Encoding = .rfc1924) -> String {

        let data = base85EncodedData(options: options, encoding: encoding)
        return String(data: data, encoding: .utf8)!
    }

    /// Returns a Base-85 encoded `Data`
    /// - Parameters:
    ///   - options: The options to use for the encoding (default is `[]`)
    ///   - encoding: Base-85 encoding (default is RFC1924)
    /// - Returns: The Base-85 encoded data
    func base85EncodedData(options: Data.Base85EncodingOptions = [],
                           encoding: Base85.Encoding = .rfc1924) -> Data {

        let data = Base85.encode(Array(self), encoding: encoding)!

        // Line length
        var lineLength: Int?

        if options.contains(.lineLength64Characters) {
            lineLength = 64
        } else if options.contains(.lineLength76Characters) {
            lineLength = 76
        }

        // Return data with new lines
        if let lineLength = lineLength {
            let lineBreak: [UInt8]
            switch (
                options.contains(.endLineWithCarriageReturn),
                options.contains(.endLineWithLineFeed)) {
            case (true, false):
                lineBreak = [13]
            case (false, true):
                lineBreak = [10]
            case (false, false), (true, true):
                lineBreak = [13, 10]
            }

            return Data(
                data
                    .chunked(into: lineLength)
                    .flatMap { $0 + lineBreak }
                    .dropLast(lineBreak.count)
            )
        }

        // Return data without newlines
        else {
            return Data(data)
        }

    }

}

// MARK: - JSON Encoding / Decoding

public extension JSONEncoder.DataEncodingStrategy {

    /// Encoded the `Data` as a Base85-encoded string using RFC1924 encoding
    static var base85: Self {
        Self.base85(encoding: .rfc1924)
    }

    /// Encoded the `Data` as a Base85-encoded string
    /// - Parameter encoding: Base-85 encoding
    static func base85(encoding: Base85.Encoding) -> Self {
        Self.custom { (data, encoder) in
            let base85 = data.base85EncodedString(encoding: encoding)
            var container = encoder.singleValueContainer()
            try container.encode(base85)
        }
    }
}

public extension JSONDecoder.DataDecodingStrategy {

    /// Decode the `Data` from a Base64-encoded string using RFC1924 encoding
    static var base85: Self {
        Self.base85(encoding: .rfc1924)
    }

    /// Decode the `Data` from a Base64-encoded string
    /// - Parameter encoding: Base-85 encoding
    static func base85(encoding: Base85.Encoding) -> Self {
        Self.custom({ (decoder) -> Data in
            let container = try decoder.singleValueContainer()
            let text = try container.decode(String.self)
            if let data = Data(base85Encoded: text, encoding: encoding) {
                return data
            } else {
                throw DecodingError.dataCorruptedError(in: container,
                                                       debugDescription: "Wrong Base-85 format")
            }
        })
    }

}

#endif
