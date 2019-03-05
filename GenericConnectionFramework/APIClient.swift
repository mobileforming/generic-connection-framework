//
//  APIClient.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 5/22/18.
//  Copyright © 2018 mobileforming LLC. All rights reserved.
//

import Foundation

public class APIClient: GCF {
	var remoteConfiguration: RemoteConfiguration?
	var baseURL: String
	var urlSession: URLSession
    var plugin: AggregatePlugin?
	var decoder: JSONDecoder
    let dispatchQueue: DispatchQueue
	var pinningDelegate: URLSessionDelegate?
	
	let inFlightRequests = CompletionQueue()
	
	public required init(configuration: RemoteConfiguration) {
		remoteConfiguration = configuration
		
		baseURL = configuration.baseURL
		
		let urlConfig = URLSessionConfiguration.default
		urlConfig.httpAdditionalHeaders = configuration.defaultHeaders
		
		urlSession = URLSession(configuration: urlConfig)
		decoder = JSONDecoder()
        let label = configuration.dispatchQueueLabel ?? "com.hilton.gcf.\(configuration.baseURL)"
        dispatchQueue = DispatchQueue(label: label, attributes: .concurrent)
        
	}
	
	public required init(baseURL: String, decoder: JSONDecoder = JSONDecoder(), pinPublicKey: String? = nil) {
		guard !baseURL.isEmpty else { fatalError("invalid base url") }
		
		if let pinPublicKey = pinPublicKey {
			pinningDelegate = GCFPinningDelegate(publicKey: pinPublicKey)
		}
		
		self.baseURL = baseURL
		self.urlSession = URLSession(configuration: .default, delegate: pinningDelegate, delegateQueue: nil)
		self.decoder = JSONDecoder()
        dispatchQueue = DispatchQueue(label: "com.hilton.gcf.\(baseURL)", attributes: .concurrent)
	}
	
	public func configurePlugins(_ plugins: [GCFPlugin]) {
		self.plugin = AggregatePlugin(plugins: plugins)
	}

    public func appendPlugin(_ plugin: GCFPlugin) {
        guard let aggregate = self.plugin else {
            return configurePlugins([plugin])
        }

       aggregate.plugins.append(plugin)
    }
    
    internal func sendRequestInternal<T>(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping (T?, Error?) -> Void) {
        sendRequest(for: routable, numAuthRetries: numAuthRetries, retriesRemaining: numAuthRetries, completion: completion)
    }
    
    private func sendRequest<T>(for routable: Routable, numAuthRetries: Int, retriesRemaining: Int, completion: @escaping (T?, Error?) -> Void) {
		dispatchQueue.async {
            
            let isRetrying = numAuthRetries != retriesRemaining
            
            var urlRequest = self.constructURLRequest(from: routable)
			
			//check and queue same requests
            let requestKey = self.inFlightRequests.key(for: urlRequest, numAuthRetries: numAuthRetries, completionType: T.self)
            let shouldSendRequest = isRetrying || self.inFlightRequests.shouldRequestContinue(forKey: requestKey, completion: completion)
			guard shouldSendRequest else { return }
            
            switch self.plugin?.willSendRequest(&urlRequest, needsAuthorization: routable.needsAuthorization) {
            case GCFError.authError(let error)?:
                return self.processCompletions(forKey: requestKey, result: nil as T?, error: error)
            case GCFError.PluginError.failureAbortRequest?:
                return self.processCompletions(forKey: requestKey, result: nil as T?, error: GCFError.pluginError)
            default:
                break
            }
            
			self.urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
				guard let strongself = self else { return }
				
                switch strongself.plugin?.didReceive(data: data, response: response, error: error, forRequest: &urlRequest) {
                    
                case GCFError.PluginError.failureAbortRequest?:
                    return strongself.processCompletions(forKey: requestKey, result: nil as T?, error: GCFError.pluginError)
                    
                case GCFError.PluginError.failureRetryRequest? where retriesRemaining > 0:
                    
                    return strongself.sendRequest(for: routable, numAuthRetries: numAuthRetries, retriesRemaining: retriesRemaining - 1, completion: completion)
                    
                case GCFError.PluginError.failureRetryRequest?:
                    return strongself.processCompletions(forKey: requestKey, result: nil as T?, error: GCFError.pluginError)
                    
                case GCFError.authError(let error)?:
                    return strongself.processCompletions(forKey: requestKey, result: nil as T?, error: error)
                    
                case _ where error == nil:
                    do {
                        let result: T = try strongself.parseData(from: data)
                        
                        strongself.processCompletions(forKey: requestKey, result: result, error: nil)
                    } catch let error {
                        strongself.processCompletions(forKey: requestKey, result: nil as T?, error: (error as? GCFError) ?? .parsingError)
                    }
                    
                default:
                    strongself.processCompletions(forKey: requestKey, result: nil as T?, error: GCFError.requestError)
                    
                }
                
			}.resume()
		}
	}
	
    private func processCompletions<T>(forKey key: CompletionQueue.RequestKey, result: T?, error: Error?) {
        inFlightRequests.processCompletions(forKey: key, result: result, error: error)
    }
    
}

extension APIClient {
    
    func sendRequest(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping ([String: Any]?, Error?) -> Void) {
        sendRequestInternal(for: routable, numAuthRetries: numAuthRetries, completion: completion)
    }
    
    func sendRequest(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping (Bool, Error?) -> Void) {
        sendRequestInternal(for: routable, numAuthRetries: numAuthRetries) { (response: Bool?, error) in completion(response ?? false, error) }
    }
    
    func sendRequest<T: Codable>(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping (T?, Error?) -> Void) {
        sendRequestInternal(for: routable, numAuthRetries: numAuthRetries, completion: completion)
    }
    
}
