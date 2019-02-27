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
        
        if let label = configuration.dispatchQueueLabel {
            dispatchQueue = DispatchQueue(label: label)
        } else {
            dispatchQueue = DispatchQueue.global(qos: .default)
        }
	}
	
	public required init(baseURL: String, decoder: JSONDecoder = JSONDecoder(), pinPublicKey: String? = nil) {
		guard !baseURL.isEmpty else { fatalError("invalid base url") }
		
		if let pinPublicKey = pinPublicKey {
			pinningDelegate = GCFPinningDelegate(publicKey: pinPublicKey)
		}
		
		self.baseURL = baseURL
		self.urlSession = URLSession(configuration: .default, delegate: pinningDelegate, delegateQueue: nil)
		self.decoder = JSONDecoder()
        dispatchQueue = DispatchQueue.global(qos: .default)
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
	
    
    // MARK - Codable
    
    public func sendRequest<T: Codable>(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping (T?, Error?) -> Void) {
        sendRequest(for: routable, numAuthRetries: numAuthRetries, isRetrying: false, completion: completion)
    }
    
    func sendRequest<T: Codable>(for routable: Routable, numAuthRetries: Int, isRetrying: Bool, completion: @escaping (T?, Error?) -> Void) {
		dispatchQueue.async {
            
            var urlRequest = self.constructURLRequest(from: routable)
			
			//check and queue same requests
            let requestKey = self.inFlightRequests.key(for: urlRequest, numAuthRetries: numAuthRetries, completionType: .codable)
            let shouldSendRequest = isRetrying || self.inFlightRequests.shouldRequestContinue(forKey: requestKey, completion: completion)
			guard shouldSendRequest else { return }
            
            if let willSendError = self.plugin?.willSendRequest(&urlRequest, needsAuthorization: routable.needsAuthorization) {
                switch willSendError {
                case GCFError.authError(let error):
					self.inFlightRequests.processCompletions(forKey: requestKey, result: nil as T?, error: error)
					return
                case GCFError.PluginError.failureAbortRequest:
					self.inFlightRequests.processCompletions(forKey: requestKey, result: nil as T?, error: GCFError.pluginError)
					return
                default:
                    break
                }
            }
            
			self.urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
				guard let strongself = self else { return }
				
                if let didReceiveError = strongself.plugin?.didReceive(data: data, response: response, error: error, forRequest: &urlRequest) {
                    
                    switch didReceiveError {
                    case GCFError.PluginError.failureAbortRequest:
						return strongself.inFlightRequests.processCompletions(forKey: requestKey, result: nil as T?, error: GCFError.pluginError)
                    case GCFError.PluginError.failureRetryRequest:
                        guard numAuthRetries > 0 else {
							return strongself.inFlightRequests.processCompletions(forKey: requestKey, result: nil as T?, error: GCFError.pluginError)
                        }
                        strongself.sendRequest(for: routable, numAuthRetries: numAuthRetries - 1, isRetrying: true, completion: completion)
                        return
                        
                    case GCFError.authError(let error):
						return strongself.inFlightRequests.processCompletions(forKey: requestKey, result: nil as T?, error: error)
                    default:
                        break
                    }
                }
				
				if let data = data, error == nil {
					do {
                        // special case where T is Data (no need to parseData)
                        if let genericData = data as? T {
                            strongself.inFlightRequests.processCompletions(forKey: requestKey, result: genericData, error: nil)
                        } else {
                            strongself.inFlightRequests.processCompletions(forKey: requestKey, result: try strongself.parseData(from: data) as T, error: nil)
                        }
                    } catch let error as GCFError {
                        strongself.inFlightRequests.processCompletions(forKey: requestKey, result: nil as T?, error: error)
					} catch {
                        strongself.inFlightRequests.processCompletions(forKey: requestKey, result: nil as T?, error: GCFError.parsingError)
					}
					
				} else {
                    strongself.inFlightRequests.processCompletions(forKey: requestKey, result: nil as T?, error: GCFError.requestError)
				}
			}.resume()
		}
	}
	
    
    // MARK - Bool
    
    public func sendRequest(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping (Bool, Error?) -> Void) {
        sendRequest(for: routable, numAuthRetries: numAuthRetries, isRetrying: false, completion: completion)
    }
    
	func sendRequest(for routable: Routable, numAuthRetries: Int = 3, isRetrying: Bool, completion: @escaping (Bool, Error?) -> Void) {
		dispatchQueue.async {
            
			var urlRequest = self.constructURLRequest(from: routable)
			
            //check and queue same requests
            let requestKey = self.inFlightRequests.key(for: urlRequest, numAuthRetries: numAuthRetries, completionType: .bool)
            let shouldSendRequest = isRetrying || self.inFlightRequests.shouldRequestContinue(forKey: requestKey, completion: completion)
            guard shouldSendRequest else { return }
            
            if let willSendError = self.plugin?.willSendRequest(&urlRequest, needsAuthorization: routable.needsAuthorization) {
                switch willSendError {
                case GCFError.authError(let error):
                    self.inFlightRequests.processCompletions(forKey: requestKey, result: false, error: error)
                case GCFError.PluginError.failureAbortRequest:
                    self.inFlightRequests.processCompletions(forKey: requestKey, result: false, error: GCFError.pluginError)
                default:
                    break
                }
            }
			
			self.urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
				guard let strongself = self else { return }
				
                if let didReceiveError = strongself.plugin?.didReceive(data: data, response: response, error: error, forRequest: &urlRequest) {
                    
                    switch didReceiveError {
                    case GCFError.PluginError.failureAbortRequest:
                        return strongself.inFlightRequests.processCompletions(forKey: requestKey, result: false, error: GCFError.pluginError)
                    case GCFError.PluginError.failureRetryRequest:
                        guard numAuthRetries > 0 else {
                            return strongself.inFlightRequests.processCompletions(forKey: requestKey, result: false, error: GCFError.pluginError)
                        }
                        strongself.sendRequest(for: routable, numAuthRetries: numAuthRetries - 1, completion: completion)
                        return
                    case GCFError.authError(let error):
                        return strongself.inFlightRequests.processCompletions(forKey: requestKey, result: false, error: error)
                    default:
                        break
                    }
                }
				
				if data != nil, error == nil {
                    strongself.inFlightRequests.processCompletions(forKey: requestKey, result: true, error: nil)
				} else {
                    strongself.inFlightRequests.processCompletions(forKey: requestKey, result: false, error: error)
				}
				}.resume()
		}
	}
    
    
    // MARK - Dictionary
    
    public func sendRequest(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping ([String: Any]?, Error?) -> Void) {
        sendRequest(for: routable, numAuthRetries: numAuthRetries, isRetrying: false, completion: completion)
    }
    
    func sendRequest(for routable: Routable, numAuthRetries: Int = 3, isRetrying: Bool, completion: @escaping ([String: Any]?, Error?) -> Void) {
        dispatchQueue.async {
            
            var urlRequest = self.constructURLRequest(from: routable)
            
            //check and queue same requests
            let requestKey = self.inFlightRequests.key(for: urlRequest, numAuthRetries: numAuthRetries, completionType: .dictionary)
            let shouldSendRequest = isRetrying || self.inFlightRequests.shouldRequestContinue(forKey: requestKey, completion: completion)
            guard shouldSendRequest else { return }
            
            if let willSendError = self.plugin?.willSendRequest(&urlRequest, needsAuthorization: routable.needsAuthorization) {
                switch willSendError {
                case GCFError.authError(let error):
                    self.inFlightRequests.processCompletions(forKey: requestKey, result: nil as [String: Any]?, error: error)
                case GCFError.PluginError.failureAbortRequest:
                    self.inFlightRequests.processCompletions(forKey: requestKey, result: nil as [String: Any]?, error: GCFError.pluginError)
                default:
                    break
                }
            }
            
            self.urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
                guard let strongself = self else { return }
                
                if let didReceiveError = strongself.plugin?.didReceive(data: data, response: response, error: error, forRequest: &urlRequest) {
                    
                    switch didReceiveError {
                    case GCFError.PluginError.failureAbortRequest:
                        return strongself.inFlightRequests.processCompletions(forKey: requestKey, result: nil as [String: Any]?, error: GCFError.pluginError)
                    case GCFError.PluginError.failureRetryRequest:
                        guard numAuthRetries > 0 else {
                            return strongself.inFlightRequests.processCompletions(forKey: requestKey, result: nil as [String: Any]?, error: GCFError.pluginError)
                        }
                        strongself.sendRequest(for: routable, numAuthRetries: numAuthRetries - 1, completion: completion)
                        return
                    case GCFError.authError(let error):
                        return strongself.inFlightRequests.processCompletions(forKey: requestKey, result: nil as [String: Any]?, error: error)
                    default:
                        break
                    }
                }
                
                if let data = data, error == nil {
                    do {
                        strongself.inFlightRequests.processCompletions(forKey: requestKey, result: try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], error: nil)
                    } catch {
                        strongself.inFlightRequests.processCompletions(forKey: requestKey, result: nil as [String: Any]?, error: GCFError.parsingError)
                    }
                    
                } else {
                    strongself.inFlightRequests.processCompletions(forKey: requestKey, result: nil as [String: Any]?, error: GCFError.requestError)
                }

                }.resume()
        }
    }
    
}
