//
//  CompletionQueue.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 1/28/19.
//  Copyright © 2019 mobileforming LLC. All rights reserved.
//

import Foundation

class CompletionQueue {
    
    typealias RequestKey = String
	
    private var inFlightRequests = [String: [Any]]()
	private var dispatchQueue: DispatchQueue
	private let lock = DispatchSemaphore(value: 1)
	
	init(queue: DispatchQueue? = nil) {
		dispatchQueue = queue ?? DispatchQueue.global(qos: .default)
	}

    func key<T>(for request: URLRequest, numAuthRetries: Int, completionType: T.Type) -> RequestKey {
        return "\(request.hashValue + numAuthRetries):\(String(describing:T.self))"
	}
	
	@discardableResult
	func shouldRequestContinue<T>(forRequest request: URLRequest, numAuthRetries: Int, completion: @escaping (T?, Error?) -> Void) -> Bool {
		return shouldRequestContinue(forKey: key(for: request, numAuthRetries: numAuthRetries, completionType: T.self), completion: completion)
	}
	
	@discardableResult
	func shouldRequestContinue<T>(forKey key: RequestKey, completion: @escaping (T?, Error?) -> Void) -> Bool {
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
	
    func processCompletions<T>(forRequest request: URLRequest, numAuthRetries: Int, result: T?, error: Error?) {
        processCompletions(forKey: key(for: request, numAuthRetries: numAuthRetries, completionType: T.self), result: result, error: error)
    }
    
    func processCompletions<T>(forKey key: RequestKey, result: T?, error: Error?) {
        
        dispatchQueue.async {
            self.lock.wait()
            guard let completions = self.inFlightRequests[key] as? [((T?, Error?) -> Void)] else {
                self.lock.signal()
                return
            }
            
            completions.forEach { $0(result, error) }
            self.inFlightRequests.removeValue(forKey: key)
            self.lock.signal()
        }
        
    }
    
}
