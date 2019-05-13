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

    func key<T>(for request: URLRequest, numAuthRetries: Int, completionType: T.Type) -> RequestKey {
        let absoluteStringHashValue = (request.url?.absoluteString ?? "").hashValue
        let httpBodyHashValue = request.httpBody.hashValue
        let httpMethodHashValue = (request.httpMethod ?? "").hashValue
        return "\(absoluteStringHashValue &+ httpBodyHashValue &+ httpMethodHashValue &+ numAuthRetries):\(String(describing:T.self))"
	}
	
	@discardableResult
	func shouldRequestContinue<T>(forRequest request: URLRequest, numAuthRetries: Int, completion: @escaping ResponseCompletion<T?>) -> Bool {
		return shouldRequestContinue(forKey: key(for: request, numAuthRetries: numAuthRetries, completionType: T.self), completion: completion)
	}
	
	@discardableResult
	func shouldRequestContinue<T>(forKey key: RequestKey, completion: @escaping ResponseCompletion<T?>) -> Bool {
		lock.wait()
		guard inFlightRequests[key] != nil else {
			inFlightRequests[key] = [completion]
			lock.signal()
			return true
		}
		
		inFlightRequests[key]!.append(completion)
		lock.signal()
		return false
	}
	
    func processCompletions<T>(forRequest request: URLRequest, response: URLResponse? = nil, numAuthRetries: Int, result: T?, error: Error?) {
        processCompletions(forKey: key(for: request, numAuthRetries: numAuthRetries, completionType: T.self), response: response, result: result, error: error)
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
