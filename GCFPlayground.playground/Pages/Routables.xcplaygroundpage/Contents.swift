//: [Back to Intro](@previous)
//: ## Routables
/*:
A routable is a representation of everything needed to construct a request.  Take a look at the protocol to see what it contains:

```swift
public protocol Routable {
	var path: String { get }
	var method: String { get }
	var header: [String : String]? { get }
	var parameters: [String : String]? { get }
	var body: [String : Any]? { get }
}
```

By implementing the routable protocol with an enum, different paths can be grouped together.  Let's try completing the implementation below:

http://jsonplaceholder.typicode.com
* posts GET
* posts/{id} PUT
* comments GET
*/

enum JSONPlaceholderAPI: Routable {
	case posts
	case posts(String)
	
	var path: String {
		switch self {
		case .posts:
			return "/posts"
		case .posts(let postID):
			return "/posts/\(postID)"
		}
	}
	
	var method: String {
		switch self {
		case .posts:
			return "GET"
		case .posts(_):
			return "PUT"
		}
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

//: [Next: Plugins](@next)
