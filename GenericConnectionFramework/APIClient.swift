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
	let dispatchQueue = DispatchQueue.global(qos: .default)
	var pinningDelegate: URLSessionDelegate?
	
	public required init(configuration: RemoteConfiguration) {
		remoteConfiguration = configuration
		
		baseURL = configuration.baseURL
		
		let urlConfig = URLSessionConfiguration.default
		urlConfig.httpAdditionalHeaders = configuration.defaultHeaders
		
		urlSession = URLSession(configuration: urlConfig)
		decoder = JSONDecoder()
	}
	
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

    public func appendPlugin(_ plugin: GCFPlugin) {
        guard let aggregate = self.plugin else {
            return configurePlugins([plugin])
        }

       aggregate.plugins.append(plugin)
    }
	
    
    public func sendRequest<T: Codable>(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping (T?, Error?) -> Void) {
        sendRequest(for: routable, numAuthRetries: numAuthRetries, isRetrying: false, completion: completion)
    }
    
    
    func key(for request: URLRequest, numAuthRetries: Int) -> String {
        return "\(request.hashValue + numAuthRetries)"
    }
    

// This doesn't work
    struct RequestThing {
        var completion: (Codable?, Error?) -> Void
    }
    var inFlightGenericRequests: [String: [RequestThing]]
    
    func executeGenericCompletions(forKey key: String, result: Codable? /*T?*/, error: Error?) {
        guard let requestThings = inFlightGenericRequests[key] else { return }
        for requestThing in requestThings {
            requestThing.completion(result, error)
        }
        
        inFlightGenericRequests[key] = nil
    }
    
    func sendRequest<T: Codable>(for routable: Routable, numAuthRetries: Int, isRetrying: Bool, completion: @escaping (T?, Error?) -> Void) {
		var urlRequest = constructURLRequest(from: routable)
		dispatchQueue.async {
            
            var shouldSendRequest = isRetrying
            let requestKey = self.key(for: urlRequest, numAuthRetries: numAuthRetries)
            if self.inFlightGenericRequests[requestKey] == nil {
                self.inFlightGenericRequests[requestKey] = []
                shouldSendRequest = true
            }
            self.inFlightGenericRequests[requestKey]?.append(RequestThing(completion: completion))
            
            if (!shouldSendRequest) { return }
            
            
            if let willSendError = self.plugin?.willSendRequest(&urlRequest, needsAuthorization: routable.needsAuthorization) {
                switch willSendError {
                case GCFError.authError(let error):
                    return self.executeGenericCompletions(forKey: requestKey, result: nil, error: error)
                case GCFError.PluginError.failureAbortRequest:
                    return self.executeGenericCompletions(forKey: requestKey, result: nil, error: GCFError.pluginError)
                default:
                    break
                }
            }
            
			self.urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
				guard let strongself = self else { return }
				
                if let didReceiveError = strongself.plugin?.didReceive(data: data, response: response, error: error, forRequest: &urlRequest) {
                    
                    switch didReceiveError {
                    case GCFError.PluginError.failureAbortRequest:
                        return strongself.executeGenericCompletions(forKey: requestKey, result: nil, error: GCFError.pluginError)
                    case GCFError.PluginError.failureRetryRequest:
                        guard numAuthRetries > 0 else {
                            return strongself.executeGenericCompletions(forKey: requestKey, result: nil, error: GCFError.pluginError)
                        }
                        strongself.sendRequest(for: routable, numAuthRetries: numAuthRetries - 1, isRetrying: true, completion: completion)
                        return
                        
                    case GCFError.authError(let error):
                        return strongself.executeGenericCompletions(forKey: requestKey, result: nil, error: error)
                    default:
                        break
                    }
                }
				
				if let data = data, error == nil {
					do {
                        strongself.executeGenericCompletions(forKey: requestKey, result: try strongself.parseData(from: data), error: nil)
//                        completion(try strongself.parseData(from: data), nil)
					} catch {
                        strongself.executeGenericCompletions(forKey: requestKey, result: nil, error: GCFError.parsingError)
					}
					
				} else {
                    strongself.executeGenericCompletions(forKey: requestKey, result: nil, error: GCFError.requestError)
				}
				}.resume()
		}
	}
	
	public func sendRequest(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping (Bool, Error?) -> Void) {
		dispatchQueue.async {
			var urlRequest = self.constructURLRequest(from: routable)
			
            if let willSendError = self.plugin?.willSendRequest(&urlRequest, needsAuthorization: routable.needsAuthorization) {
                switch willSendError {
                case GCFError.authError(let error):
                    return completion(false, error)
                case GCFError.PluginError.failureAbortRequest:
                    return completion(false, GCFError.pluginError)
                default:
                    break
                }
            }
			
			self.urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
				guard let strongself = self else { return }
				
                if let didReceiveError = strongself.plugin?.didReceive(data: data, response: response, error: error, forRequest: &urlRequest) {
                    
                    switch didReceiveError {
                    case GCFError.PluginError.failureAbortRequest:
                        return completion(false, GCFError.pluginError)
                    case GCFError.PluginError.failureRetryRequest:
                        guard numAuthRetries > 0 else {
                            return completion(false, GCFError.pluginError)
                        }
                        strongself.sendRequest(for: routable, numAuthRetries: numAuthRetries - 1, completion: completion)
                        return
                    case GCFError.authError(let error):
                        return completion(false, error)
                    default:
                        break
                    }
                }
				
				if data != nil, error == nil {
					completion(true, nil)
				} else {
					completion(false, error)
				}
				}.resume()
		}
	}
    
    public func sendRequest(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping ([String: Any]?, Error?) -> Void) {
        dispatchQueue.async {
            var urlRequest = self.constructURLRequest(from: routable)
            
            if let willSendError = self.plugin?.willSendRequest(&urlRequest, needsAuthorization: routable.needsAuthorization) {
                switch willSendError {
                case GCFError.authError(let error):
                    return completion(nil, error)
                case GCFError.PluginError.failureAbortRequest:
                    return completion(nil, GCFError.pluginError)
                default:
                    break
                }
            }
            
            self.urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
                guard let strongself = self else { return }
                
                if let didReceiveError = strongself.plugin?.didReceive(data: data, response: response, error: error, forRequest: &urlRequest) {
                    
                    switch didReceiveError {
                    case GCFError.PluginError.failureAbortRequest:
                        return completion(nil, GCFError.pluginError)
                    case GCFError.PluginError.failureRetryRequest:
                        guard numAuthRetries > 0 else {
                            return completion(nil, GCFError.pluginError)
                        }
                        strongself.sendRequest(for: routable, numAuthRetries: numAuthRetries - 1, completion: completion)
                        return
                    case GCFError.authError(let error):
                        return completion(nil, error)
                    default:
                        break
                    }
                }
                
                if let data = data, error == nil {
                    do {
                        completion(try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any], nil)
                    } catch {
                        completion(nil, GCFError.parsingError)
                    }
                    
                } else {
                    completion(nil, GCFError.requestError)
                }

                }.resume()
        }
    }

    public func sendRequest(for routable: Routable, numAuthRetries: Int = 3, completion: @escaping (Data?, Error?) -> Void) {
        dispatchQueue.async {
            var urlRequest = self.constructURLRequest(from: routable)

            if let willSendError = self.plugin?.willSendRequest(&urlRequest, needsAuthorization: routable.needsAuthorization) {
                switch willSendError {
                case GCFError.authError(let error):
                    return completion(nil, error)
                case GCFError.PluginError.failureAbortRequest:
                    return completion(nil, GCFError.pluginError)
                default:
                    break
                }
            }

            self.urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in
                guard let strongself = self else { return }

                if let didReceiveError = strongself.plugin?.didReceive(data: data, response: response, error: error, forRequest: &urlRequest) {

                    switch didReceiveError {
                    case GCFError.PluginError.failureAbortRequest:
                        return completion(nil, GCFError.pluginError)
                    case GCFError.PluginError.failureRetryRequest:
                        guard numAuthRetries > 0 else {
                            return completion(nil, GCFError.pluginError)
                        }
                        strongself.sendRequest(for: routable, numAuthRetries: numAuthRetries - 1, completion: completion)
                        return
                    case GCFError.authError(let error):
                        return completion(nil, error)
                    default:
                        break
                    }
                }

                if let data = data, error == nil {
                    completion(data, nil)
                } else {
                    completion(nil, GCFError.requestError)
                }

                }.resume()
        }
    }
}
