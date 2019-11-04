//
//  CompletionQueue.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 1/28/19.
//  Copyright © 2019 mobileforming LLC. All rights reserved.
//

import Foundation

public typealias ResponseHeader = [AnyHashable: Any]
public typealias ResponseCompletion<Q> = (ResponseHeader?, Q, Error?) -> Void
public typealias SimpleCompletion<Q> = (Q?, Error?) -> Void


class CompletionQueue {
    
    typealias RequestKey = String
	
    private var inFlightRequests = [String: [Any]]()
	private var dispatchQueue: DispatchQueue
	private let lock = DispatchSemaphore(value: 1)
	
	init(queue: DispatchQueue? = nil) {
		dispatchQueue = queue ?? DispatchQueue.global(qos: .default)
	}

    func key<T>(for routable: Routable, numAuthRetries: Int, completionType: T.Type) -> RequestKey {
        return "\(routable.hashVal &+ numAuthRetries):\(String(describing:T.self))"
	}
	
	@discardableResult
	func shouldRequestContinue<T>(forRoutable routable: Routable, numAuthRetries: Int, completion: @escaping ResponseCompletion<T?>) -> Bool {
		return shouldRequestContinue(forKey: key(for: routable, numAuthRetries: numAuthRetries, completionType: T.self), completion: completion)
	}
	
	@discardableResult
	func shouldRequestContinue<T>(forKey key: RequestKey, completion: @escaping ResponseCompletion<T?>) -> Bool {
		lock.wait()
		guard
            var value = inFlightRequests[key]
        else {
			inFlightRequests[key] = [completion]
			lock.signal()
			return true
		}
		
		value.append(completion)
        inFlightRequests[key] = value
		lock.signal()
		return false
	}
	
    func processCompletions<T>(forRoutable routable: Routable, response: URLResponse? = nil, numAuthRetries: Int, result: T?, error: Error?) {
        processCompletions(forKey: key(for: routable, numAuthRetries: numAuthRetries, completionType: T.self), response: response, result: result, error: error)
    }
    
    func processCompletions<T>(forKey key: RequestKey, response: URLResponse? = nil, result: T?, error: Error?) {
        
        dispatchQueue.async {
            self.lock.wait()
            guard let completions = self.inFlightRequests[key] as? [ResponseCompletion<T?>] else {
                self.lock.signal()
                return
            }
            
            completions.forEach { $0(response?.headers, result, error) }
            self.inFlightRequests.removeValue(forKey: key)
            self.lock.signal()
        }
        
    }
    
}

private extension URLResponse {
    
    var headers: ResponseHeader? {
        return (self as? HTTPURLResponse)?.allHeaderFields
    }
    
}

private extension Routable {
    
    var hashVal: Int {
        let hashableComponents: [AnyHashable?] = [path, method, parameters, body]
        
        return hashableComponents.compactMap { $0?.hashValue }.reduce(0, &+)
    }
    
}
