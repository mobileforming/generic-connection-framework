//
//  CompletionQueue.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 1/28/19.
//  Copyright © 2019 mobileforming LLC. All rights reserved.
//

import Foundation

class CompletionQueue {
	
    enum CompletionType: Int {
        case codable
        case bool
        case dictionary
    }
    
	private var inFlightRequests = [String: [Any]]()
	private var dispatchQueue: DispatchQueue
	private let lock = DispatchSemaphore(value: 1)
	
	init(queue: DispatchQueue? = nil) {
		dispatchQueue = queue ?? DispatchQueue.global(qos: .default)
	}

    func key(for request: URLRequest, numAuthRetries: Int, completionType: CompletionType) -> String {
        return "\(request.hashValue + numAuthRetries):\(completionType.rawValue)"
	}
	
    
    // MARK - Codable
    
	@discardableResult
	func shouldRequestContinue<T: Codable>(forRequest request: URLRequest, numAuthRetries: Int, completion: @escaping (T?, Error?) -> Void) -> Bool {
		return shouldRequestContinue(forKey: key(for: request, numAuthRetries: numAuthRetries, completionType: .codable), completion: completion)
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
        processCompletions(forKey: key(for: request, numAuthRetries: numAuthRetries, completionType: .codable), result: result, error: error)
    }
    
    func processCompletions<T: Codable>(forKey key: String, result: T?, error: Error?) {
        
        dispatchQueue.async {
            self.lock.wait()
            guard let completions = self.inFlightRequests[key] as? [(T?, Error?) -> Void] else {
                self.lock.signal()
                return
            }
            
            completions.forEach { $0(result, error) }
            self.inFlightRequests.removeValue(forKey: key)
            self.lock.signal()
        }
    }
    
    
    // MARK - Bool
    
    @discardableResult
    func shouldRequestContinue(forRequest request: URLRequest, numAuthRetries: Int, completion: @escaping (Bool, Error?) -> Void) -> Bool {
        return shouldRequestContinue(forKey: key(for: request, numAuthRetries: numAuthRetries, completionType: .bool), completion: completion)
    }
    
    @discardableResult
    func shouldRequestContinue(forKey key: String, completion: @escaping (Bool, Error?) -> Void) -> Bool {
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
    
    func processCompletions(forRequest request: URLRequest, numAuthRetries: Int, result: Bool, error: Error?) {
        processCompletions(forKey: key(for: request, numAuthRetries: numAuthRetries, completionType: .bool), result: result, error: error)
    }
    
    func processCompletions(forKey key: String, result: Bool, error: Error?) {
        
        dispatchQueue.async {
            self.lock.wait()
            guard let completions = self.inFlightRequests[key] as? [(Bool, Error?) -> Void] else {
                self.lock.signal()
                return
            }
            
            completions.forEach { $0(result, error) }
            self.inFlightRequests.removeValue(forKey: key)
            self.lock.signal()
        }
    }
    
    
    // MARK - Dictionary
    
    @discardableResult
    func shouldRequestContinue(forRequest request: URLRequest, numAuthRetries: Int, completion: @escaping ([String: Any]?, Error?) -> Void) -> Bool {
        return shouldRequestContinue(forKey: key(for: request, numAuthRetries: numAuthRetries, completionType: .dictionary), completion: completion)
    }
    
    @discardableResult
    func shouldRequestContinue(forKey key: String, completion: @escaping ([String: Any]?, Error?) -> Void) -> Bool {
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
    
    func processCompletions(forRequest request: URLRequest, numAuthRetries: Int, result: [String: Any]?, error: Error?) {
        processCompletions(forKey: key(for: request, numAuthRetries: numAuthRetries, completionType: .dictionary), result: result, error: error)
    }
    
    func processCompletions(forKey key: String, result: [String: Any]?, error: Error?) {
        
        dispatchQueue.async {
            self.lock.wait()
            guard let completions = self.inFlightRequests[key] as? [([String: Any]?, Error?) -> Void] else {
                self.lock.signal()
                return
            }
            
            completions.forEach { $0(result, error) }
            self.inFlightRequests.removeValue(forKey: key)
            self.lock.signal()
        }
    }
    
	
}
