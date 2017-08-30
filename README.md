# General Connection Framework

The General Connection Framework (GCF) is part of mobileforming's modularization effort.  The end result will be less time spent writing duplicated code across projects through the use of this library.  Every project utilizing the GCF will have an increased level of confidence in the network code, in addition to other shared benefits.

## Why Use GCF?

- Never have to write URLSession code in your app again (cuts down on network code)
- No more JSON parsing
- Will be fully tested (no buggy network code)
- Easier/quicker API integration
- Less fragile (no string literal parameters for creating a request)
- Supports standard completion block pattern or Rx/observable pattern
- Encourages modular design
- Bain says so...

## Features

- Modular
- Highly configurable
- Flexible plugin architecture
- Swift Decodable support
- Robust test coverage (ongoing)
- Authentication support (planned)
- Credential management (planned)
- Request queueing (planned)
- Retry logic (planned)

## Dependencies

- [RxSwift]

## Requirements

- iOS 9.0+
- Xcode 9
- Swift 4
- [CocoaPods]

## Installation

 - TBD

## Usage

See playground for more detailed explanation and examples

### Routable

```swift
public protocol Routable {
    var path: String { get }
    var method: String { get }
    var header: [String : String]? { get }
    var parameters: [String : String]? { get }
    var body: [String : Any]? { get }
}
```

### GCF

```swift
protocol GCF: class {
	var baseURL: String { get }
	var urlSession: URLSession { get }
	var decoder: JSONDecoder { get }
	var plugin: GCFPlugin? { get }

	init(baseURL: String)
	func sendRequest<T: Decodable>(for routable: Routable) -> Observable<T>
	func sendRequest<T: Decodable>(for routable: Routable, completion: @escaping (T?, Error?) -> Void)
	func constructURL(from routable: Routable) -> URL
	func parseData<T: Decodable>(from data: Data) throws -> T
}
```

### GCF Plugin
```swift
//Plugin interface
protocol GCFPlugin {
	func willSendRequest(_ request: inout URLRequest)
	func didRecieve(data: Data?, response: URLResponse?, error: Error?, forRequest request: inout URLRequest) throws
}
```

### Using the GCF in Your App

```swift
//create an instance of the GCF
let gcf = GCF(baseURL: "https://somebaseurl.com")
```
```swift
//using completion, LoginObject: Decodable
gcf.sendRequest(for: ExampleAPI.login) { (response: LoginObject?, error) in
}
```
```swift
//using observable, LoginObject: Decodable
let loginObservable: Observable<LoginObject> = gcf.sendRequest(for: ExampleAPI.login)
```


[RxSwift]: https://github.com/ReactiveX/RxSwift/
[CocoaPods]: https://github.com/CocoaPods/CocoaPods
