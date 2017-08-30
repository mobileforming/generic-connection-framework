//
//  RxGCF.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 8/30/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import Foundation
import RxSwift

open class RxGCF: GCF {
	public var baseURL: String
	public var urlSession: URLSession
	public var decoder: JSONDecoder
	public var plugin: GCFPlugin?
	internal var disposeBag = DisposeBag()
	
	public required init(baseURL: String) {
		guard !baseURL.isEmpty else { fatalError("invalid base url") }
		
		self.baseURL = baseURL
		urlSession = URLSession(configuration: .default)
		decoder = JSONDecoder()
	}
	
	public func sendRequest<T: Decodable>(for routable: Routable) -> Observable<T> {
		var urlRequest = URLRequest(url: constructURL(from: routable))
		urlRequest.httpMethod = routable.method
		
		if let body = routable.body, (routable.method == "POST" || routable.method == "PUT") {
			urlRequest.httpBody = try! JSONSerialization.data(withJSONObject: body, options: [])
		}
		
		plugin?.willSendRequest(&urlRequest)
		
		return Observable.create { [weak self] observer in
			guard let strongself = self else {
				observer.onError(GCFError.requestError)
				return Disposables.create()
			}
			
			strongself.urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
				guard let strongself = self else { return }
				
				do {
					try strongself.plugin?.didRecieve(data: data, response: response, error: error, forRequest: &urlRequest)
				} catch GCFPluginError.failureAbortRequest {
					observer.onError(GCFPluginError.failureAbortRequest)
				} catch {
					//continue
				}
				
				if let data = data, error == nil {
					do {
						observer.onNext(try strongself.parseData(from: data))
					} catch {
						observer.onError(GCFError.parsingError)
					}
				} else {
					observer.onError(GCFError.requestError)
				}
				}.resume()
			
			return Disposables.create()
		}
	}
	
	public func sendRequest<T: Decodable>(for routable: Routable, completion: @escaping (T?, Error?) -> Void) {
		let observable: Observable<T> = sendRequest(for: routable)
		observable.subscribe { (event) in
			if let object = event.element {
				completion(object, event.error)
			} else {
				completion(nil, event.error)
			}
		}.addDisposableTo(disposeBag)
	}
}

