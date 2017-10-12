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
	var liveObservables: [HashableRoutable: Any] = [:]
    
    public required init(baseURL: String) {
		guard !baseURL.isEmpty else { fatalError("invalid base url") }
		
		self.baseURL = baseURL
        self.urlSession = URLSession(configuration: .default)
		decoder = JSONDecoder()
    }
	
	public func sendRequest<T: Routable, U: Decodable>(for routable: T) -> Observable<U> {
        
        // Check to see if we already have an existing observable for this route
        let hashableRoutable = HashableRoutable(routable: routable)
        if let storedObservable = liveObservables[hashableRoutable] as? Observable<U> {
            return storedObservable
        }
        
		var urlRequest = constructURLRequest(from: routable)
		
		plugin?.willSendRequest(&urlRequest)
		
		let observable = Observable<U>.create { [weak self] observer in
			guard let strongself = self else {
				observer.onError(GCFError.requestError)
				return Disposables.create()
			}
			
			strongself.urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
				guard let strongself = self else { return }
				
                // The request is no longer in flight, so we can remove our saved observable
                strongself.liveObservables.removeValue(forKey: hashableRoutable)
                
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
		}.share()
        
        // Keep this observable around until the request is done
        liveObservables[hashableRoutable] = observable
        
        return observable
	}
	
	func sendRequest<T: Routable, U: Decodable>(for routable: T, completion: @escaping (U?, Error?) -> Void) {
		let observable: Observable<U> = sendRequest(for: routable)
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

