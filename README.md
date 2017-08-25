# General Connection Framework

Description...

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

### Routables

```swift
//Routable interface
public protocol Routable {
    var path: String { get }
    var method: String { get }
    var header: [String : String]? { get }
    var parameters: [String : String]? { get }
    var body: [String : Any]? { get }
}
```
```swift
//Routable implementation
public enum ExampleAPI: Routable {
    case login
    case userList
    case user(String)
    
    var path: String {
        switch self {
        case login:
            return "/login"
        case userList:
            return "/users"
        case user(let userID):
            return "/users/\(userID)"
        }
    }
    
    var method: String {
        return "GET"
    }
    
    var header: [String : String]? {
        return nil
    }
    
    var parameters: [String : String]? {
        return nil
    }
    
    var body: [String : Any]? {
        return nil
    }
}
```

### GCF Instance

```swift
//GCF Error
public enum GCFError: Error {
	case parsingError
	case requestError
}
```
```swift
//GCF Interface
public protocol GCF: class {
	var baseURL: String { get }
	var urlSession: URLSession { get }
	var decoder: JSONDecoder { get }
	var plugin: GCFPlugin? { get }
	
	func sendRequest<T: Decodable>(for routable: Routable) -> Observable<T>
	func sendRequest<T: Decodable>(for routable: Routable, completion: @escaping (T?, Error?) -> Void)
}
```
```swift
//GCF Implementation
class ExampleGCF: GCF {
    var baseURL: String
    var urlSession: URLSession
    var decoder: JSONDecoder
    var plugin: GCFPlugin?
    
    init(baseURL: String) {
        guard !baseURL.isEmpty else { fatalError("need baseurl") }
        self.baseURL = baseURL
		urlSession = URLSession(configuration: .default)
		decoder = JSONDecoder()
    }
    
    func sendRequest<T: Decodable>(for routable: Routable) -> Observable<T> {
        //...
    }
	func sendRequest<T: Decodable>(for routable: Routable, completion: @escaping (T?, Error?) -> Void) {
	    //...
    }
}
```

### GCF Plugin

```swift
//Plugin Error/State
enum GCFPluginError: Error {
	case failureAbortRequest		//fail entire request
	case failureCompleteRequest		//don't process remaining plugins, finish the request
	case failureContinue			//continue with remaining plugins
}
```
```swift
//Plugin interface
protocol GCFPlugin {
	func willSendRequest(_ request: inout URLRequest)
	func didRecieve(data: Data?, response: URLResponse?, error: Error?, forRequest request: inout URLRequest) throws
}
```
```swift
//Plugin implementation
class ExamplePlugin: GCFPlugin {
    
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
