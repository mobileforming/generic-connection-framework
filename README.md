# mobileforming iOS Generic Connection Framework

The General Connection Framework (GCF) is part of mobileforming's modularization effort. GCF will allow you to spend less time writing boilerplate networking code, less time dealing with the nitty gritty, sometimes complex code surrounding authentication and retry logic, and more time making your apps awesome. With every new app, you'll be able to reuse existing GCF code as well as create custom plugins specific to your API needs. Every project utilizing the GCF will have an increased level of confidence in the network code, in addition to other shared benefits.

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
- Request queueing

## Planned Features

- Authentication support
- Credential management
- Retry logic

## Dependencies



## Requirements

- iOS 9.0+
- Xcode 9
- Swift 4
- [CocoaPods]

## Installation

 1. Add the correct podspec source url to the project's podfile
   - This will either be the internal mobileforming spec repo or a client specific spec repo
 2. Also add the master spec repo source url since this will no longer be implicitly added
   - source 'https://github.com/CocoaPods/Specs.git'
 3. Specify the correct GCF version for the target(s) in the podfile.
   - pod 'GenericConnectionFramework', '~> 1.0'
 4. Add the correct nexus credentials to the computer if you're using the static framework
   - Must get these from Techops
   - in terminal:  echo "machine nexus.mobileforming.com login {username} password {password}" >> ~/.netrc
 5. Run pod install (may need to run pod update first)
 6. Open the workspace, clean, and build

## Usage

See playground for more detailed explanation and examples

### Routable

```swift
public protocol Routable {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String : String]? { get }
    var parameters: [String : String]? { get }
    var body: [String : AnyHashable]? { get }
    var defaultTimeout: TimeInterval { get }
    var cachePolicy: URLRequest.CachePolicy { get }
}
```

### GCF

```swift
protocol GCF: class {
	var baseURL: String { get }
	var urlSession: URLSession { get }
	var decoder: JSONDecoder { get }
	var plugin: GCFPlugin? { get }

	init(baseURL: String, decoder: JSONDecoder)
	func sendRequest<T: Codable>(for routable: Routable) -> Observable<T>
	func sendRequest<T: Codable>(for routable: Routable, completion: @escaping (T?, Error?) -> Void)
	func sendRequest(for routable: Routable, completion: @escaping (Bool, Error?) -> Void)
	func constructURL(from routable: Routable) -> URL
	func parseData<T: Codable>(from data: Data) throws -> T
	func configurePlugin(_ plugin: GCFPlugin)
	func configurePlugins(_ plugins: [GCFPlugin])
}
```

### GCF Plugin
```swift
//Plugin interface
protocol GCFPlugin {
	func willSendRequest(_ request: inout URLRequest)
	func didReceive(data: Data?, response: URLResponse?, error: Error?, forRequest request: inout URLRequest) throws
}
```

### Using the GCF in Your App

```swift
//1. create an instance of the GCF
let gcf = RxGCF(baseURL: "https://somebaseurl.com")

//or you can optionally provide an instance of JSONDecoder for GCF to use (allows you to configure the data or date format)
let decoder = JSONDecoder()
decoder.dateDecodingStrategy = .millisecondsSince1970
let gcf = RxGCF(baseURL: "https://somebaseurl.com", decoder: decoder)
```
```swift
//2. Configure plugin
gcf.configurePlugin(plugin)

//or you can optionally apply any plugins (1 or more) to this gcf instance.  
//GCF will process the plugins in order for willSend, and reverse order for didReceive
gcf.configurePlugins([plugin1, plugin2, plugin3])
```
```swift
//3. use with completion, LoginObject: Codable
gcf.sendRequest(for: ExampleAPI.login) { (response: LoginObject?, error) in
}
```
```swift
//or use as observable, LoginObject: Decodable
let loginObservable: Observable<LoginObject> = gcf.sendRequest(for: ExampleAPI.login)
```


[RxSwift]: https://github.com/ReactiveX/RxSwift/
[CocoaPods]: https://github.com/CocoaPods/CocoaPods

