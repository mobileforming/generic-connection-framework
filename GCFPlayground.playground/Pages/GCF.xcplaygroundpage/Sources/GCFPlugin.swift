import Foundation

public enum GCFPluginError: Error {
	case failureAbortRequest		//fail entire request
	case failureCompleteRequest		//don't process remaining plugins, finish the request
	case failureContinue			//continue with remaining plugins
}

public protocol GCFPlugin {
	func willSendRequest(_ request: inout URLRequest)
	func didRecieve(data: Data?, response: URLResponse?, error: Error?, forRequest request: inout URLRequest) throws
}
