//
//  MockGCFPlugin.swift
//  GenericConnectionFrameworkTests
//
//  Created by Alan Downs on 11/7/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import Foundation
@testable import GenericConnectionFramework

class MockGCFPlugin: GCFPlugin {

	var willSendCalledCount = 0
	var didReceiveCalledCount = 0
    var willSendError: Error?
    var didReceiveError: Error?
	
	func willSendRequest(_ request: inout URLRequest, needsAuthorization: Bool) -> Error? {
		willSendCalledCount += 1
        return willSendError
	}
	
	func didReceive(data: Data?, response: URLResponse?, error: Error?, forRequest request: inout URLRequest) -> Error? {
		didReceiveCalledCount += 1
        return didReceiveError
	}
}

public enum MockErrorCode: String, CaseIterable {
    
    case expiredHMAC =          "1"
    case other =                "0"
}

extension MockErrorCode: Comparable {
    
    static public func < (lhs: MockErrorCode, rhs: MockErrorCode) -> Bool {
        guard
            let left = Int(lhs.rawValue),
            let right = Int(rhs.rawValue)
        else {
           return lhs < rhs  // should never execute with current enum values
        }
        return left < right
    }

    static public func == (lhs: MockErrorCode, rhs: MockErrorCode) -> Bool {
        guard
            let left = Int(lhs.rawValue),
            let right = Int(rhs.rawValue)
        else {
           return lhs.rawValue == rhs.rawValue // should never execute with current enum values
        }
        return left == right
    }
    
    static public func < (lhs: String, rhs: MockErrorCode) -> Bool {
        guard
            let left = Int(lhs),
            let right = Int(rhs.rawValue)
        else {
           return lhs < rhs.rawValue
        }
        return left < right
    }

    static public func == (lhs: String, rhs: MockErrorCode) -> Bool {
        guard
            let left = Int(lhs),
            let right = Int(rhs.rawValue)
        else {
           return lhs == rhs.rawValue
        }
        return left == right
    }
    
    static public func < (lhs: MockErrorCode, rhs: String) -> Bool {
        guard
            let left = Int(lhs.rawValue),
            let right = Int(rhs)
        else {
            return lhs.rawValue < rhs
        }
        return left < right
    }

    static public func == (lhs: MockErrorCode, rhs: String) -> Bool {
        guard
            let left = Int(lhs.rawValue),
            let right = Int(rhs)
        else {
            return lhs.rawValue == rhs
        }
        return left == right
    }
    
}

public class MockError: Error {
    
    let errorCode: String
    let errorType: String?
    let errorDescription: String?
    let errorTrace: String?
    
    init(errorCode: MockErrorCode?, errorType: String?, errorDescription: String?, errorTrace: String?) {
        self.errorCode = (errorCode ?? .other).rawValue
        self.errorType = errorType
        self.errorDescription = errorDescription
        self.errorTrace = errorTrace
    }
    
    init(errorCode: String, errorType: String?, errorDescription: String?, errorTrace: String?) {
        self.errorCode = String(errorCode)
        self.errorType = errorType
        self.errorDescription = errorDescription
        self.errorTrace = errorTrace
    }
    
    static func error(from data: Data) -> MockError? {
        guard let jsonDict = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let dict = jsonDict as? [String: String] else {
                return nil
        }
        
        return MockError.error(from: dict)
    }
    
    static func error(from dict: [String: String]) -> MockError? {
        guard let code = dict["ErrorCode"] else { return nil }
        
        return MockError(errorCode: code, errorType: dict["ErrorType"], errorDescription: dict["Description"], errorTrace: dict["Trace"])
    }
   
}


class MockGCFPluginCustom: GCFPlugin {

    var willSendCalledCount = 0
    var didReceiveCalledCount = 0
    var willSendError: Error?
    var didReceiveError: Error?
    
    func willSendRequest(_ request: inout URLRequest, needsAuthorization: Bool) -> Error? {
        willSendCalledCount += 1
        return willSendError
    }
    
    func didReceive(data: Data?, response: URLResponse?, error: Error?, forRequest request: inout URLRequest) -> Error? {
    
            var isAuthError = false
            var returnError: Error?
            var mockError: MockError?
            var statusCode: Int = 0
            
            if let data = data,
                let error = MockError.error(from: data) {
                    mockError = error
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                statusCode = httpResponse.statusCode
            }
            
            if statusCode == 401 {
                if let mockError = mockError,
                    mockError.errorCode == "1" {
                    isAuthError = true
                } else {
                    returnError = mockError
                }
                print("MockAuthPlugin didReceiveResponse: \(String(describing: response as? HTTPURLResponse)), for request: \(request), error: \(String(describing: error))")
                
            } else if mockError != nil {
                        isAuthError = true
                print("MockAuthPlugin didReceiveResponse: \(String(describing: response)), for request: \(request), error: \(String(describing: mockError?.errorCode))")
            } else {
                returnError = mockError
            }
            
            if isAuthError {
                
                // and report that the request should be retried
                return GCFError.PluginError.failureRetryRequest
            }
            
            return returnError ?? error
        }
        
}


