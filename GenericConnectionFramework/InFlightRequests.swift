//
//  InFlightRequests.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 1/28/19.
//  Copyright © 2019 mobileforming LLC. All rights reserved.
//

import Foundation

//call this something better
class RequestThing {
	
	private var inFlightRequests = [String: [Any]]()
	private var dispatchQueue: DispatchQueue
	private let lock = DispatchSemaphore(value: 1)
	
	init(queue: DispatchQueue? = nil) {
		dispatchQueue = queue ?? DispatchQueue.global(qos: .default)
	}

	func key(for request: URLRequest, numAuthRetries: Int) -> String {
		return "\(request.hashValue + numAuthRetries)"
	}
	
	func shouldRequestContinue<T: Codable>(forRequest request: URLRequest, numAuthRetries: Int, completion: @escaping (T?, Error?) -> Void) -> Bool {
		return shouldRequestContinue(forKey: key(for: request, numAuthRetries: numAuthRetries), completion: completion)
	}
	
	func shouldRequestContinue<T: Codable>(forKey key: String, completion: @escaping (T?, Error?) -> Void) -> Bool {
		guard inFlightRequests[key] != nil else {
			inFlightRequests[key] = [completion]
			return true
		}
		
		inFlightRequests[key]!.append(completion)
		return false
	}
	
	func processCompletions<T: Codable>(forRequest request: URLRequest, numAuthRetries: Int, result: T?, error: Error?) {
		processCompletions(forKey: key(for: request, numAuthRetries: numAuthRetries), result: result, error: error)
	}
	
	func processCompletions<T: Codable>(forKey key: String, result: T?, error: Error?) {
		lock.wait()
		
		dispatchQueue.async {
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
