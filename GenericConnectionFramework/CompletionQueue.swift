//
//  CompletionQueue.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 1/28/19.
//  Copyright © 2019 mobileforming LLC. All rights reserved.
//

import Foundation

class CompletionQueue {
	
	private var inFlightRequests = [String: [Any]]()
	private var dispatchQueue: DispatchQueue
	private let lock = DispatchSemaphore(value: 1)
	
	init(queue: DispatchQueue? = nil) {
		dispatchQueue = queue ?? DispatchQueue.global(qos: .default)
	}

	func key(for request: URLRequest, numAuthRetries: Int) -> String {
		return "\(request.hashValue + numAuthRetries)"
	}
	
	@discardableResult
	func shouldRequestContinue<T: Codable>(forRequest request: URLRequest, numAuthRetries: Int, completion: @escaping (T?, Error?) -> Void) -> Bool {
		return shouldRequestContinue(forKey: key(for: request, numAuthRetries: numAuthRetries), completion: completion)
	}
	
	@discardableResult
	func shouldRequestContinue<T: Codable>(forKey key: String, completion: @escaping (T?, Error?) -> Void) -> Bool {
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
	
	func processCompletions<T: Codable>(forRequest request: URLRequest, numAuthRetries: Int, result: T?, error: Error?) {
		processCompletions(forKey: key(for: request, numAuthRetries: numAuthRetries), result: result, error: error)
	}
	
	func processCompletions<T: Codable>(forKey key: String, result: T?, error: Error?) {
	
		dispatchQueue.async {
			self.lock.wait()
			guard let completions = self.inFlightRequests[key] as! [(T?, Error?) -> Void]? else {
				self.lock.signal()
				return
			}
			
			completions.forEach { $0(result, error) }
			self.inFlightRequests.removeValue(forKey: key)
			self.lock.signal()
		}
	}
}
