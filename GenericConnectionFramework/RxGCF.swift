//
//  RxGCF.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 8/30/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import Foundation
import RxSwift

public class RxGCF: GCF {
	var baseURL: String
	var urlSession: URLSession
	var plugin: GCFPlugin?
	var decoder: JSONDecoder
	internal var disposeBag = DisposeBag()
	
    public required init(baseURL: String) {
		guard !baseURL.isEmpty else { fatalError("invalid base url") }
		
		self.baseURL = baseURL
        self.urlSession = URLSession(configuration: .default)
		decoder = JSONDecoder()
    }
	
	public func sendRequest<T: Decodable>(for routable: Routable) -> Observable<T> {
		var urlRequest = constructURLRequest(from: routable)
		
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
				
				observer.onCompleted()
				
			}.resume()
			
			return Disposables.create()
		}
	}
	
	public func sendRequest<T: Decodable>(for routable: Routable, completion: @escaping (T?, Error?) -> Void) {
		let observable: Observable<T> = sendRequest(for: routable)
		observable.subscribe { (event) in
			switch event {
			case .next(let object):
				completion(object, nil)
			case .error(let error):
				completion(nil, error)
			case .completed:
				break
			}
		}.disposed(by: disposeBag)
	}
}

