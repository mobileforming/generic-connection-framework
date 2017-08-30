import Foundation

public struct Posts: Decodable {
	var post: [Post]
}

public struct Post: Decodable {
	public var userId: Int
	public var title: String
	public var body: String
}
