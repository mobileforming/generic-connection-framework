//
//  DefaultGCF.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 8/29/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import Foundation
import RxSwift

open class DefaultGCF: GCF {
	public var baseURL: String
	public var urlSession: URLSession
	public var decoder: JSONDecoder
	public var plugin: GCFPlugin?
	
	public required init(baseURL: String) {
		guard !baseURL.isEmpty else { fatalError("invalid base url") }
		
		self.baseURL = baseURL
		urlSession = URLSession(configuration: .default)
		decoder = JSONDecoder()
	}
	
	public func sendRequest<T: Decodable>(for routable: Routable) -> Observable<T> {
		return Observable.create { [weak self] observer in
			guard let strongself = self else {
				observer.onError(GCFError.requestError)
				return Disposables.create()
			}
			
			strongself.sendRequest(for: routable, completion: { (result: T?, error) in
				if let result = result, error == nil {
					observer.onNext(result)
					observer.onCompleted()
				} else if let error = error {
					observer.onError(error)
				} else {
					observer.onError(GCFError.requestError)
				}
			})
			
			return Disposables.create()
		}
	}
	
	public func sendRequest<T: Decodable>(for routable: Routable, completion: @escaping (T?, Error?) -> Void) {
		var urlRequest = URLRequest(url: constructURL(from: routable))
		urlRequest.httpMethod = routable.method
		
		if let body = routable.body, (routable.method == "POST" || routable.method == "PUT") {
			urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: body, options: [])
		}
		
		plugin?.willSendRequest(&urlRequest)
		
		urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
			guard let strongself = self else { return }
			
			do {
				try strongself.plugin?.didRecieve(data: data, response: response, error: error, forRequest: &urlRequest)
			} catch GCFPluginError.failureAbortRequest {
				completion(nil, GCFError.pluginError)
			} catch {
				//continue
			}
			
			if let data = data, error == nil {
				do {
					completion(try strongself.parseData(from: data), nil)
				} catch {
					completion(nil, GCFError.parsingError)
				}
				
			} else {
				completion(nil,GCFError.requestError)
			}
			}.resume()
	}
}
