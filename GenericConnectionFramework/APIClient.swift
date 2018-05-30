//
//  APIClient.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 5/22/18.
//  Copyright © 2018 mobileforming LLC. All rights reserved.
//

import Foundation

public class APIClient: GCF {
	
	var baseURL: String
	var urlSession: URLSession
	var plugin: GCFPlugin?
	var decoder: JSONDecoder
	let dispatchQueue = DispatchQueue.global(qos: .default)
	var pinningDelegate: URLSessionDelegate?
	
	public required init(baseURL: String, decoder: JSONDecoder = JSONDecoder(), pinPublicKey: String? = nil) {
		guard !baseURL.isEmpty else { fatalError("invalid base url") }
		
		if let pinPublicKey = pinPublicKey {
			pinningDelegate = GCFPinningDelegate(publicKey: pinPublicKey)
		}
		
		self.baseURL = baseURL
		self.urlSession = URLSession(configuration: .default, delegate: pinningDelegate, delegateQueue: nil)
		self.decoder = JSONDecoder()
	}
	
	public func configurePlugins(_ plugins: [GCFPlugin]) {
		self.plugin = AggregatePlugin(plugins: plugins)
	}
	
	public func sendRequest<T: Codable>(for routable: Routable, completion: @escaping (T?, Error?) -> Void) {
		var urlRequest = constructURLRequest(from: routable)
		
		dispatchQueue.async {
			self.plugin?.willSendRequest(&urlRequest)
			self.urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
				guard let strongself = self else { return }
				
				do {
					try strongself.plugin?.didReceive(data: data, response: response, error: error, forRequest: &urlRequest)
				} catch GCFError.PluginError.failureAbortRequest {
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
