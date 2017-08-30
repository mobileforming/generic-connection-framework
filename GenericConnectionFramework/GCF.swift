//
//  GCF.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 8/29/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import Foundation
import RxSwift

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

extension GCF {
	
	internal func constructURL(from routable: Routable) -> URL {
		if var urlComponents = URLComponents(string: baseURL) {
			urlComponents.path = routable.path
			urlComponents.queryItems = routable.parameters?.map({ URLQueryItem(name: $0.0, value: $0.1) })
			return urlComponents.url!
		}
		fatalError("cant construct url")
	}
	
	internal func parseData<T: Decodable>(from data: Data) throws -> T {
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
