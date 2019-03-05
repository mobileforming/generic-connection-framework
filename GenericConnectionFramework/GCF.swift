//
//  GCF.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 8/29/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import Foundation

public protocol RemoteConfiguration {
	var baseURL: String { get }
	var defaultHeaders: [String:String]? { get }
    var dispatchQueueLabel: String? { get }
}

public extension RemoteConfiguration {
    var dispatchQueueLabel: String? { return nil }
}

public protocol GraphRemoteConfiguration: RemoteConfiguration {
	var graphURL: String { get }
}
public extension GraphRemoteConfiguration {
	var baseURL: String {
		return graphURL
	}
}

protocol GCF: class {
	var remoteConfiguration: RemoteConfiguration? { get }
	var baseURL: String { get }
	var urlSession: URLSession { get }
	var decoder: JSONDecoder { get set }
	var plugin: AggregatePlugin? { get set }
	
	init(configuration: RemoteConfiguration)
	init(baseURL: String, decoder: JSONDecoder, pinPublicKey: String?)
    func sendRequest<T: Codable>(for routable: Routable, numAuthRetries: Int, completion: @escaping (ResponseHeader?, T?, Error?) -> Void)
    func sendRequest(for routable: Routable, numAuthRetries: Int, completion: @escaping (ResponseHeader?, Bool, Error?) -> Void)
    func sendRequest(for routable: Routable, numAuthRetries: Int, completion: @escaping (ResponseHeader?, [String: Any]?, Error?) -> Void)
    func constructURL(from routable: Routable) -> URL
    func parseData<T>(from data: Data?) throws -> T
	func configurePlugins(_ plugins: [GCFPlugin])
}

extension GCF {
	
	func constructURLRequest(from routable: Routable) -> URLRequest {
		let url = constructURL(from: routable)
		
		var urlRequest = URLRequest(url: url, cachePolicy: routable.cachePolicy, timeoutInterval: routable.defaultTimeout)
		urlRequest.httpMethod = routable.method.rawValue
		urlRequest.timeoutInterval = routable.defaultTimeout
		routable.headers?.forEach({ urlRequest.addValue($1, forHTTPHeaderField: $0) })
		
		if let body = routable.body, (routable.method == .post || routable.method == .put) {
			urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
		}
		
		return urlRequest
	}
	
	func constructURL(from routable: Routable) -> URL {
		if var urlComponents = URLComponents(string: baseURL) {
			
			if !(routable is GraphRoutable) {
				urlComponents.path = routable.path
			}
			
			if let parameters = routable.parameters, parameters.keys.count > 0 {
                urlComponents.queryItems = parameters.map({ URLQueryItem(name: $0.0, value: $0.1) }).sorted { $0.name < $1.name }
			}
			return urlComponents.url!
		}
		fatalError("cant construct url")
	}
    
    func debugPrintError(_ error: Error) {
        
        guard let decodingError = error as? DecodingError else {
            print(error.localizedDescription)
            return
        }
        
        switch decodingError {
        case .dataCorrupted(let context):
            print(context)
        case .keyNotFound(let key, _):
            print("key not found: \(key.stringValue)")
        case .typeMismatch(let type, _):
            print("typemismatch: \(type)")
        case .valueNotFound:
            print(error.localizedDescription)
        }
        
    }
    
}

// Convenience methods to discard ResponseHeader capture

extension GCF {

    public func sendRequest<T: Codable>(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping (T?, Error?) -> Void) {
        sendRequest(for: routable, numAuthRetries: numAuthRetries) { (_, response: T?, error) in
            completion(response, error)
        }
    }
    
    public func sendRequest(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping (Bool, Error?) -> Void) {
        sendRequest(for: routable, numAuthRetries: numAuthRetries) { (_, response: Bool, error) in
            completion(response, error)
        }

    }
    
    public func sendRequest(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping ([String: Any]?, Error?) -> Void) {
        sendRequest(for: routable, numAuthRetries: numAuthRetries) { (_, response: [String: Any]?, error) in
            completion(response, error)
        }

    }

}
