import XCTest
@testable import Base85

final class Base85Tests: XCTestCase {

    struct Base64Data {
        let decoded: String
        let encoded: [Base85.Encoding: String]

        static let all = [
            Self(decoded: "/1JHWN+il+Y9jzEL",
                 encoded: [
                     .ascii: "cyYpP2hoa0hKIjRjXzwq",
                     .adobeAscii85: "PH5zJik/aGhrSEoiNGNfPCp+Pg==",
                     .btoa: "cyYpP2hoa0hKIjRjXzwqeA==",
                     .rfc1924: "fDU4VS0tPWRmMUomIVI5",
                     .z85: "JTU4dT8/PkRGMWo9LnI5"
                 ]
            ),
            Self(decoded: "wlREUxYko/GFzDWfqA==",
                 encoded: [
                     .ascii: "X0dpcCUoKm9bRkwhMkVIVnU=",
                     .adobeAscii85: "PH5fR2lwJSgqb1tGTCEyRUhWdX4+",
                     .btoa: "X0dpcCUoKm9bRkwhMkVIVnV4",
                     .rfc1924: "IWM7XzQ3OV53YmgwSGFkcn4=",
                     .z85: "LkMmezQ3OV1XQkgwaEFEUiM="
                 ]
            ),
            Self(decoded: "a7B7oIWvT8Nx+SmefUI=",
                 encoded: [
                     .ascii: "Q1RyL1lLcys6aUVWViZUSTZt",
                     .adobeAscii85: "PH5DVHIvWUtzKzppRVZWJlRJNm1+Pg==",
                     .btoa: "Q1RyL1lLcys6aUVWViZUSTZteA==",
                     .rfc1924: "WXB7RXVnfEFQO2FycjVwZUw/",
                     .z85: "eVBAZVVHJWFwJkFSUjVQRWwp"
                 ]
            ),
            Self(decoded: "ehd5rWk+UmHjDDa6lbEw",
                 encoded: [
                     .ascii: "SDVDay9CZyxGJ2lzW2lXUSpFIg==",
                     .adobeAscii85: "PH5INUNrL0JnLEYnaXNbaVdRKkUifj4=",
                     .btoa: "SDVDay9CZyxGJ2lzW2lXUSpFIng=",
                     .rfc1924: "ZEtZPUVYK0JiNjt8dztzbTlhMQ==",
                     .z85: "RGt5PmV4KmJCNiYlVyZTTTlBMQ=="
                 ]
            ),
            Self(decoded: "ulAPufGehnlM9eh66E21yA==",
                 encoded: [
                     .ascii: "XGtpcEpuWGJKXDlfSVVxa1k4Sis=",
                     .adobeAscii85: "PH5ca2lwSm5YYkpcOV9JVXFrWThKK34+",
                     .btoa: "XGtpcEpuWGJKXDlfSVVxa1k4Sit4",
                     .rfc1924: "eD07X2ZAdCVmeE8hZXFgPXVOZkE=",
                     .z85: "WD4me0ZbVCtGWG8uRVF9PlVuRmE="
                 ]
            )
        ]
    }

    private let encodings: [Base85.Encoding] = [.ascii, .adobeAscii85, .btoa, .rfc1924, .z85]

    func testEmpty() {
        let data = [UInt8]()

        for enc in encodings {
            let encoded = Base85.encode(data, encoding: enc)
            XCTAssertNotNil(encoded, "Error encoding empty data")
            let decoded = Base85.decode(encoded!, encoding: enc)
            XCTAssertNotNil(decoded, "Error decoding empty data")
            XCTAssertEqual(data, decoded, "Empty encoding does not match.")
        }
    }

    func testEncoding() {
        for data in Base64Data.all {
            let decoded = Array(Data(base64Encoded: data.decoded)!)

            for enc in [Base85.Encoding.ascii, .adobeAscii85, .btoa, .rfc1924, .z85] {
                let encoded = Base85.encode(decoded, encoding: enc)
                XCTAssertNotNil(encoded, "Error encoding data \(data.decoded)")
                let base64encoded = Data(encoded!).base64EncodedString()
                XCTAssertEqual(data.encoded[enc], base64encoded, "Encoding does not match")
            }
        }
    }

    func testDecoding() {
        for data in Base64Data.all {
            for enc in [Base85.Encoding.ascii, .adobeAscii85, .btoa, .rfc1924, .z85] {
                let encoded = Array(Data(base64Encoded: data.encoded[enc]!)!)
                let decoded = Base85.decode(encoded, encoding: enc)
                XCTAssertNotNil(decoded, "Error decoding data \(data.decoded)")
                let base64decoded = Data(decoded!).base64EncodedString()
                XCTAssertEqual(data.decoded, base64decoded, "Encoding does not match")
            }
        }
    }

    func testRandom() {
        for len in 32...64 {
            var data = [UInt8](repeating: 0, count: len)
            for elem in 0..<len {
                data[elem] = UInt8.random(in: UInt8.min...UInt8.max)
            }
            for enc in encodings {
                let encoded = Base85.encode(data, encoding: enc)
                XCTAssertNotNil(encoded, "Error encoding random data")
                let decoded = Base85.decode(encoded!, encoding: enc)
                XCTAssertNotNil(decoded, "Error decoding random data")
                XCTAssertEqual(decoded, data,
                               "Data encoded and then decoded does not match")
            }
        }
    }

    func testZeros() {
        let containsZeros = [
            "AQEBAQAAAAAB",
            "JQEepgAAAABM9s8PUbctjl7/Wxk=",
            "cRILd/wPKtgAAAAAhuXBqEXUJgk="
        ]
        .map { Array(Data(base64Encoded: $0)!) }

        let doesntContainZeros = [
            "AQEBAQAAAAA=",
            "O5WvBov/DJ/Hrb1stTAuRgAAAAA=",
            "0BKEO3VAkX+qA9ZLGaoraQAAAAA="
        ]
        .map { Array(Data(base64Encoded: $0)!) }

        for enc in encodings {
            if let zeroDelimeter = enc.compressFourZeros {

                for data in containsZeros {
                    let encoded = Base85.encode(data, encoding: enc)
                    XCTAssertNotNil(encoded, "Error encoding data \(data)")
                    XCTAssertTrue(encoded!.contains(zeroDelimeter),
                                  "Error: encoding does not contain zero delimeter.")

                    let decoded = Base85.decode(encoded!, encoding: enc)
                    XCTAssertNotNil(decoded, "Error decoding data \(data)")
                    XCTAssertEqual(decoded, data,
                                   "Data encoded and then decoded does not match")
                }

                for data in doesntContainZeros {
                    let encoded = Base85.encode(data, encoding: enc)
                    XCTAssertNotNil(encoded, "Error encoding data \(data)")
                    XCTAssertFalse(encoded!.contains(zeroDelimeter),
                                   "Error: encoding does contain zero delimeter, but shouldn't.")

                    let decoded = Base85.decode(encoded!, encoding: enc)
                    XCTAssertNotNil(decoded, "Error decoding data \(data)")
                    XCTAssertEqual(decoded, data,
                                   "Data encoded and then decoded does not match")
                }

            }
        }

    }

    func testSpaces() {
        let containsSpaces = [
            "MjIyMg==",
            "MjIyMpnVn0/KsCIjaNHmjwjBmi4=",
            "4bCJjzIyMjJEMZLfHFjzD0Bd4DE=",
            "oT7RSvJhLLjDQWxkS+t+IDIyMjI="
        ]
        .map { Array(Data(base64Encoded: $0)!) }

        for enc in encodings {
            if let spaceDelimeter = enc.compressFourSpaces {

                for data in containsSpaces {
                    let encoded = Base85.encode(data, encoding: enc)
                    XCTAssertNotNil(encoded, "Error encoding data \(data)")
                    XCTAssertTrue(encoded!.contains(spaceDelimeter),
                                  "Error: encoding does not contain space delimeter (\(spaceDelimeter)). \(data)")

                    let decoded = Base85.decode(encoded!, encoding: enc)
                    XCTAssertNotNil(decoded, "Error decoding data \(data)")
                    XCTAssertEqual(decoded, data,
                                   "Data encoded and then decoded does not match")
                }

            }
        }

    }

    static var allTests = [
        ("testEmpty", testEmpty),
        ("testEncoding", testEncoding),
        ("testDecoding", testDecoding),
        ("testRandom", testRandom),
        ("testZeros", testZeros),
        ("testSpaces", testSpaces)
    ]
}
