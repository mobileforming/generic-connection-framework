//
//  GCF.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 8/29/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import Foundation

protocol GCF: class {
	var baseURL: String { get }
	var urlSession: URLSession { get }
	var decoder: JSONDecoder { get set }
	var plugin: GCFPlugin? { get set }
	
	init(baseURL: String, decoder: JSONDecoder, pinPublicKey: String?)
	func sendRequest<T: Codable>(for routable: Routable, completion: @escaping (T?, Error?) -> Void)
	func sendRequest(for routable: Routable, completion: @escaping (Bool, Error?) -> Void)
	func constructURL(from routable: Routable) -> URL
	func parseData<T: Codable>(from data: Data) throws -> T
	func configurePlugins(_ plugins: [GCFPlugin])
}

extension GCF {
	
	internal func constructURLRequest(from routable: Routable) -> URLRequest {
		let url = constructURL(from: routable)
		
		var urlRequest = URLRequest(url: url, cachePolicy: routable.cachePolicy, timeoutInterval: routable.defaultTimeout)
		urlRequest.httpMethod = routable.method.rawValue
		routable.headers?.forEach({ urlRequest.addValue($1, forHTTPHeaderField: $0) })
		
		if let body = routable.body, (routable.method == .post || routable.method == .put) {
			urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: body, options: [])
		}
		
		return urlRequest
	}
	
	internal func constructURL(from routable: Routable) -> URL {
		if var urlComponents = URLComponents(string: baseURL) {
			urlComponents.path = routable.path
			
			if let parameters = routable.parameters, parameters.keys.count > 0 {
				urlComponents.queryItems = parameters.map({ URLQueryItem(name: $0.0, value: $0.1) })
			}
			return urlComponents.url!
		}
		fatalError("cant construct url")
	}
	
	internal func parseData<T: Codable>(from data: Data) throws -> T {
		do {
			return try decoder.decode(T.self, from: data)
		} catch DecodingError.dataCorrupted(let error) {
			print(error)
			throw GCFError.parsingError
		} catch DecodingError.keyNotFound(let key, _) {
			print("key not found" + key.stringValue)
			throw GCFError.parsingError
		} catch DecodingError.typeMismatch(let type, _){
			print("typemismatch \(type)")
			throw GCFError.parsingError
		} catch {
			print(error.localizedDescription)
			throw GCFError.parsingError
		}
	}
}
