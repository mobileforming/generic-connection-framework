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
	
	public func sendRequest(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping ResponseCompletion<[String: Any]?>) {
		sendRequestInternal(for: routable, numAuthRetries: numAuthRetries, completion: completion)
	}
	
	public func sendRequest(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping ResponseCompletion<Bool>) {
		sendRequestInternal(for: routable, numAuthRetries: numAuthRetries) { (header, response: Bool?, error) in completion(header, response ?? false, error) }
	}
	
	public func sendRequest<T: Codable>(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping ResponseCompletion<T?>) {
		sendRequestInternal(for: routable, numAuthRetries: numAuthRetries, completion: completion)
	}
	
	// MARK: - Convenience methods to discard ResponseHeader capture
	public func sendRequest<T: Codable>(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping (T?, Error?) -> Void) {
		sendRequest(for: routable, numAuthRetries: numAuthRetries) { (_, response: T?, error) in
			completion(response, error)
		}
	}
	
	public func sendRequest(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping (Bool, Error?) -> Void) {
		sendRequest(for: routable, numAuthRetries: numAuthRetries) { (_, response: Bool, error) in
			completion(response, error)
		}
	}
	
	public func sendRequest(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping ([String: Any]?, Error?) -> Void) {
		sendRequest(for: routable, numAuthRetries: numAuthRetries) { (_, response: [String: Any]?, error) in
			completion(response, error)
		}
	}
	
}

// MARK: - Internal/private methods
extension APIClient {
    
    internal func sendRequestInternal<T>(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping (T?, Error?) -> Void) {
        sendRequestInternal(for: routable, numAuthRetries: numAuthRetries) { (_, response: T?, error) in
            completion(response, error)
        }
    }

    internal func sendRequestInternal<T>(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping ResponseCompletion<T?>) {
        sendRequest(for: routable, numAuthRetries: numAuthRetries, retriesRemaining: numAuthRetries, completion: completion)
    }
    
    private func sendRequest<T>(for routable: Routable, numAuthRetries: Int, retriesRemaining: Int, completion: @escaping ResponseCompletion<T?>) { // swiftlint:disable:this cyclomatic_complexity
		dispatchQueue.async {
            
            let isRetrying = numAuthRetries != retriesRemaining
            
            var urlRequest = self.constructURLRequest(from: routable)
			
			//check and queue same requests
            let requestKey = self.inFlightRequests.key(for: routable, numAuthRetries: numAuthRetries, completionType: T.self)
            let shouldSendRequest = isRetrying || self.inFlightRequests.shouldRequestContinue(forKey: requestKey, completion: completion)
			guard shouldSendRequest else { return }
            
            switch self.plugin?.willSendRequest(&urlRequest, needsAuthorization: routable.needsAuthorization) {
            case GCFError.authError(let error)?:
                return self.processCompletions(forKey: requestKey, result: nil as T?, error: error)
            case GCFError.PluginError.failureAbortRequest?:
                return self.processCompletions(forKey: requestKey, result: nil as T?, error: GCFError.pluginError(nil))
            default:
                break
            }
            
			self.urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
				guard let strongself = self else { return }
				
                let retError = strongself.plugin?.didReceive(data: data, response: response, error: error, forRequest: &urlRequest)
                
                switch retError {
                    
                case GCFError.PluginError.failureAbortRequest?:
                    return strongself.processCompletions(forKey: requestKey, response: response, result: nil as T?, error: GCFError.pluginError(nil))
                    
                case GCFError.PluginError.failureRetryRequest? where retriesRemaining > 0:
                    
                    return strongself.sendRequest(for: routable, numAuthRetries: numAuthRetries, retriesRemaining: retriesRemaining - 1, completion: completion)
                    
                case GCFError.PluginError.failureRetryRequest?:
                    return strongself.processCompletions(forKey: requestKey, response: response, result: nil as T?, error: GCFError.pluginError(nil))
                    
                case GCFError.authError(let aerror)?:
                    return strongself.processCompletions(forKey: requestKey, response: response, result: nil as T?, error: aerror)
                    
                case GCFError.requestError(let reqError)?:
                    strongself.processCompletions(forKey: requestKey, response: response, result: nil as T?, error: GCFError.requestError(reqError))
                    
                // LocalizedError here
                default:
                    if error == nil && retError == nil {
                        do {
                            let result: T = try strongself.parseData(from: data)
                            
                            strongself.processCompletions(forKey: requestKey, response: response, result: result, error: retError)
                        } catch let error {
                            strongself.processCompletions(forKey: requestKey, response: response, result: nil as T?, error: (error as? GCFError) ?? .parsingError)
                        }
                    } else {
                    
                        strongself.processCompletions(forKey: requestKey, response: response, result: nil as T?, error: GCFError.requestError(error as NSError?))
                    }
                    
                }
                
			}.resume()
		}
	}
	
    private func processCompletions<T>(forKey key: CompletionQueue.RequestKey, response: URLResponse? = nil, result: T?, error: Error?) {
        inFlightRequests.processCompletions(forKey: key, response: response, result: result, error: error)
    }
}
