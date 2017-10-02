//
//  DefaultGCF.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 8/29/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import Foundation
import RxSwift

public class DefaultGCF: GCF {
	var baseURL: String
	var urlSession: URLSession
	var decoder: JSONDecoder
	var plugin: GCFPlugin?
	
    public required init(baseURL: String) {
		guard !baseURL.isEmpty else { fatalError("invalid base url") }
		
		self.baseURL = baseURL
        self.urlSession = URLSession(configuration: .default)
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
				
				observer.onCompleted()
			})
			
			return Disposables.create()
		}
	}
	
	public func sendRequest<T: Decodable>(for routable: Routable, completion: @escaping (T?, Error?) -> Void) {
		var urlRequest = URLRequest(url: constructURL(from: routable))
		urlRequest.httpMethod = routable.method.rawValue
		
		if let body = routable.body, (routable.method == .post || routable.method == .put) {
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
