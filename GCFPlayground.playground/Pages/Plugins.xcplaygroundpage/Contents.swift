//: [Back to Routables](@previous)
//: ## GCF Plugins
/*:
A plugin is a way for the GCF to interact with both requests and responses.  They can be used as logging requests/responses, handling authentication, and much more.  A plugin can be composed of several other plugins, and their state can be managed by [Swift's error handling pattern](https://developer.apple.com/library/content/documentation/Swift/Conceptual/Swift_Programming_Language/ErrorHandling.html).

```swift
public enum GCFPluginError: Error {
	case failureAbortRequest		//fail entire request
	case failureCompleteRequest		//don't process remaining plugins, finish the request
	case failureContinue			//continue with remaining plugins
}

public protocol GCFPlugin {
	func willSendRequest(_ request: inout URLRequest)
	func didRecieve(data: Data?, response: URLResponse?, error: Error?, forRequest request: inout URLRequest) throws
}
```

Take a look at a simple plugin that logs the request.  Can you implement logging any response errors?
*/
import UIKit
class LoggerPlugin: GCFPlugin {
	func willSendRequest(_ request: inout URLRequest) {
		print(request.url?.absoluteString)
	}
	
	func didRecieve(data: Data?, response: URLResponse?, error: Error?, forRequest request: inout URLRequest) throws {
		
	}
}

//: > Plugins can also be composed of other plugins.  Using the logging plugin above, can you finish implementing the plugin below that logs 3 times?

class SuperLoggerPlugin: GCFPlugin {
	
	var plugins: [GCFPlugin]?
	
	func willSendRequest(_ request: inout URLRequest) {
		
	}
	
	func didRecieve(data: Data?, response: URLResponse?, error: Error?, forRequest request: inout URLRequest) throws {
		
	}
}

//: [Next: GCF](@next)
