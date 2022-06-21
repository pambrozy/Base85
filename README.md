# Base85

## ⛔️ Deprecated

Please use the [Bases](https://github.com/pambrozy/Bases) Package.

![build](https://github.com/pambrozy/Base85/workflows/build/badge.svg)

Base85 is a Swift library to convert data from Base-85 and vice versa. The API was designed to easily replace the Foundation's built-in Base-64 encoding API.

## Installation
You can install this package through Swift Package Manager. Either add this to your `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/pambrozy/Base85", .upToNextMajor(from: "1.0.0")),
    ...
],
```
Or, by using Xcode:
1. Select File &rarr; Swift Packages &rarr; Add Package Dependency...
2. Enter package URL: `https://github.com/pambrozy/Base85`

## Usage
### Foundation
To **encode** data use the following functions:
```swift
let encodedData = data.base85EncodedData()

let encodedString = data.base85EncodedString()
```
You can also specify encoding options and character set (the default is RFC 1924, [see all](#character-sets)):
```swift
data.base85EncodedData(options: .lineLength64Characters,
                       encoding: .z85)

data.base85EncodedString(options: [.endLineWithCarriageReturn,
                                   .lineLength76Characters],
                         encoding: .adobeAscii85)
```
\
In order to **decode** data:
```swift
let fromString = Data(base85Encoded: "JQEepgAAAABM9s8PUbctjl7/Wxk=")

let fromData = Data(base85Encoded: encodedData,
                    options: .ignoreUnknownCharacters,
                    encoding: .rfc1924)
```

\
You can also use this library to encode and decode raw data from and into JSON:
```swift
let encoder = JSONEncoder()
encoder.dataEncodingStrategy = .base85

let decoder = JSONDecoder()
decoder.dataDecodingStrategy = .base85(encoding: .btoa)
```

### Standalone
To **encode** data:
```swift
// The type of `data` is [UInt8]
let encoded = Base85.encode(data, encoding: .rfc1924)
```

To **decode** data:
```swift
// The type of `data` is [UInt8]
let decoded = Base85.decode(data, encoding: .rfc1924)
```

## Character sets
This package comes with some character sets build in. They are referred in code as `Base85.Encoding`. The default encoding is RFC 1924.

Built in character sets:
| Encoding            | ascii     | btoa      | Ascii85<br>(Adobe) | RFC 1924  | Z85      |
| -                   | :-:       | :-:       | :-:                | :-:       | :-:       |
| Characters          | `!` - `u` | `!` - `u` | `!` - `u`          | `0` - `~` | `0` - `#` |
| Beginning of string | -         | -         | `<~`               | -         | -         |
| End of string       | -         | `x`       | `~>`               | -         | -         |
| Four zeros          | -         | `z`       | `z`                | -         | -         |
| Four spaces         | -         | `y`       | -                  | -         |           |

### Custom character set
You can customize each character set by using this static method:
```swift
let customizedBtoa = Base85.Encoding.customized(baseEncoding: .btoa,
                                                startDelimeter: nil,
                                                endDelimeter: "x",
                                                representFourZerosAs: "z",
                                                representFourSpacesAs: nil)
```

You can also create a fully custom character set, by using the following method:
```swift
Base85.Encoding.custom(characters: [Character],
                       startDelimeter: String?,
                       endDelimeter: String?,
                       representFourZerosAs zeros: Character?,
                       representFourSpacesAs spaces: Character?)
```
- The smallest character value cannot be smaller than 33 (ASCII "!").
- The number of characters should be 85.

## Todo
- [ ] Test Foundation extensions
- [ ] Test customized and custom encoding
- [ ] Make `Base85.encode` and `Base85.decode` throw an error instead of returning nil in case of failure

## License
This package is released under The MIT License. [See LICENSE](LICENSE) for details.
