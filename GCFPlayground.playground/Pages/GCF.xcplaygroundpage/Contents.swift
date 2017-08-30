
//: [Back to Plugins](@previous)
//: ## GCF
/*:
A GCF implementation just needs some configuration to get started

```swift
public enum GCFError: Error {
	case parsingError
	case requestError
	case pluginError
}

public protocol GCF: class {
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

The following is an example of GCF
```swift
class ExampleGCF: GCF {
	var baseURL: String
	var urlSession: URLSession
	var decoder: JSONDecoder
	var plugin: GCFPlugin?
	
	required init(baseURL: String) {
		guard !baseURL.isEmpty else { fatalError("invalid base url") }

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
> Finish instantiating GCF with a base url below:
*/
let gcf = ExampleGCF(baseURL: <#T##String#>)
//: Using the two examples below, you can play around with GCF:
import UIKit
import RxSwift
import PlaygroundSupport
let currentPage = PlaygroundPage.current
currentPage.needsIndefiniteExecution = true

//: > Observable pattern
let observable: Observable<Posts> = gcf.sendRequest(for: JSONPlaceholderAPI.posts)
//observable.subscribe(<#T##observer: ObserverType##ObserverType#>)
//: > Closure pattern
gcf.sendRequest(for: JSONPlaceholderAPI.posts) { (postsObject: Posts?, error) in
//	print(postsObject)
	currentPage.finishExecution()
}
