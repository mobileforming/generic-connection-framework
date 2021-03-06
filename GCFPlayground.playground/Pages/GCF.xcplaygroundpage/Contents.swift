
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
*/
import Foundation
import RxSwift
import PlaygroundSupport
let currentPage = PlaygroundPage.current
currentPage.needsIndefiniteExecution = true

//: Finish instantiating GCF using our example api (https://jsonplaceholder.typicode.com) as the base url below:
let gcf = ExampleGCF(baseURL: <#T##String#>)

//: Using the two examples below, you can play around with GCF:
//: > Observable pattern
let observable: Observable<[Post]> = gcf.sendRequest(for: JSONPlaceholderAPI.posts)
observable.subscribe { (event) in
//	if !event.isCompleted {
//		print(event.element?.first?.title)
//	}
}
//: > Closure pattern
gcf.sendRequest(for: JSONPlaceholderAPI.posts) { (postsObject: [Post]?, error) in
//	print(postsObject!.first!.body)
	currentPage.finishExecution()
}
