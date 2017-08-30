import Foundation

public enum JSONPlaceholderAPI: Routable {
	case posts
	
	public var path: String {
		switch self {
		case .posts:
			return "/posts"
		}
	}
	
	public var method: String {
		switch self {
		case .posts:
			return "GET"
		}
	}
	
	public var header: [String : String]? {
		return nil
	}
	
	public var parameters: [String : String]? {
		return nil
	}
	
	public var body: [String : Any]? {
		return nil
	}
}
