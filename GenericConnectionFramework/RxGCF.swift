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
	var liveObservables: [URLRequest:Any] = [:]
	let dispatchQueue = DispatchQueue.global(qos: .default)
	
	public required init(baseURL: String, decoder: JSONDecoder = JSONDecoder()) {
		guard !baseURL.isEmpty else { fatalError("invalid base url") }
	
		self.baseURL = baseURL
        self.urlSession = URLSession(configuration: .default)
		self.decoder = decoder
    }
	
	public func configurePlugin(_ plugin: GCFPlugin) {
		self.plugin = plugin
	}
	
	public func configurePlugins(_ plugins: [GCFPlugin]) {
		self.plugin = AggregatePlugin(plugins: plugins)
	}
	
	public func sendRequest<T: Codable>(for routable: Routable) -> Observable<T> {
        var urlRequest = constructURLRequest(from: routable)
        
        // Check to see if we already have an existing observable for this request
        if let storedObservable = liveObservables[urlRequest] as? Observable<T> {
            return storedObservable
        }
		
		let observable = Observable<T>.create { [weak self] observer in
			guard let strongself = self else {
				observer.onError(GCFError.requestError)
				return Disposables.create()
			}
			
			strongself.dispatchQueue.async {
				strongself.plugin?.willSendRequest(&urlRequest)

				strongself.urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
					guard let strongself = self else { return }
					guard let data = data, error == nil else { return observer.onError(GCFError.requestError) }
					
					//plugins
					do {
						try strongself.plugin?.didReceive(data: data, response: response, error: error, forRequest: &urlRequest)
					} catch GCFError.PluginError.failureAbortRequest {
						observer.onError(GCFError.PluginError.failureAbortRequest)
					} catch {
						//continue
					}
					
					//serialize data
					do {
						observer.onNext(try strongself.parseData(from: data))
					} catch {
						observer.onError(GCFError.parsingError)
					}
					
					// The request is no longer in flight, so we can remove our saved observable
					strongself.liveObservables.removeValue(forKey: urlRequest)
					
					observer.onCompleted()
					
				}.resume()
			}
			
			return Disposables.create()
		}.share()
        
        // Keep this observable around until the request is done
        liveObservables[urlRequest] = observable
        
        return observable
	}
	
	public func sendRequest<T: Codable>(for routable: Routable, completion: @escaping (T?, Error?) -> Void) {
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
	
	public func sendRequest(for routable: Routable, completion: @escaping (Bool, Error?) -> Void) {
		dispatchQueue.async {
			var urlRequest = self.constructURLRequest(from: routable)
			self.plugin?.willSendRequest(&urlRequest)
			
			self.urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
				guard let strongself = self else { return }
				
				do {
					try strongself.plugin?.didReceive(data: data, response: response, error: error, forRequest: &urlRequest)
				} catch GCFError.PluginError.failureAbortRequest {
					completion(false, GCFError.pluginError)
				} catch {
					//continue
				}
				
				if data != nil, error == nil {
					completion(true, nil)
				} else {
					completion(false, error)
				}
			}.resume()
		}
	}
}

