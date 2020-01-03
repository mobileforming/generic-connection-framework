//
//  MockGCFPlugin.swift
//  GenericConnectionFrameworkTests
//
//  Created by Alan Downs on 11/7/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//

import Foundation
@testable import GenericConnectionFramework

extension Encodable {
  func asDictionary() throws -> [String: Any] {
    let data = try JSONEncoder().encode(self)
    guard let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
      throw NSError()
    }
    return dictionary
  }
}

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

public enum MockErrorCode: Int, CaseIterable {
    case expiredHMAC =          1
    case other =                0
}

extension MockErrorCode: Comparable {
    
    static public func < (lhs: MockErrorCode, rhs: MockErrorCode) -> Bool {
        let left = lhs.rawValue
        let right = rhs.rawValue
        return left < right
    }

    static public func == (lhs: MockErrorCode, rhs: MockErrorCode) -> Bool {
        let left = lhs.rawValue
        let right = rhs.rawValue
        return left == right
    }
    
    static public func < (lhs: String, rhs: MockErrorCode) -> Bool {
        let right = rhs.rawValue
        guard
            let left = Int(lhs)
        else {
           return false
        }
        return left < right
    }

    static public func == (lhs: String, rhs: MockErrorCode) -> Bool {
        let right = rhs.rawValue
        guard
            let left = Int(lhs)
        else {
           return false
        }
        return left == right
    }
    
    static public func < (lhs: MockErrorCode, rhs: String) -> Bool {
        let left = lhs.rawValue
        guard
            let right = Int(rhs)
        else {
            return false
        }
        return left < right
    }

    static public func == (lhs: MockErrorCode, rhs: String) -> Bool {
        let left = lhs.rawValue
        guard
            let right = Int(rhs)
        else {
            return false
        }
        return left == right
    }
    
    static public func < (lhs: Int, rhs: MockErrorCode) -> Bool {
        let right = rhs.rawValue
        let left = lhs
        return left < right
    }

    static public func == (lhs: Int, rhs: MockErrorCode) -> Bool {
        let right = rhs.rawValue
        let left = lhs
        return left == right
    }
    
    static public func < (lhs: MockErrorCode, rhs: Int) -> Bool {
        let left = lhs.rawValue
        let right = rhs
        return left < right
    }

    static public func == (lhs: MockErrorCode, rhs: Int) -> Bool {
        let left = lhs.rawValue
        let right = rhs
        return left == right
    }
    
}

public class MockError: CustomNSError, Codable {
    
    public var errorDomain: String = ""
    public let errorDescription: String?
    public var errorUserInfo: [String : Any] = [:]
    public var errorCode: Int {
        guard
            let code = internalErrorCode
        else {
            return 0
        }
        return code
    }
    
    let errorType: String?
    let errorTrace: String?
    let internalErrorCode: Int?
    
    private enum CodingKeys: String, CodingKey {
        case errorCode = "ErrorCode"
        case errorType = "ErrorType"
        case errorDescription = "Description"
        case errorTrace = "Trace"
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let errorString = try container.decodeIfPresent(String.self, forKey: .errorCode) {
            self.internalErrorCode = Int(errorString) ?? 0
        } else {
            self.internalErrorCode = 0
        }
        self.errorType = try container.decodeIfPresent(String.self, forKey: .errorType)
        self.errorDescription = try container.decodeIfPresent(String.self, forKey: .errorDescription)
        self.errorTrace = try container.decodeIfPresent(String.self, forKey: .errorTrace)
        
        self.errorDomain = "Mock Error Domain"
        
        do {
            self.errorUserInfo = try self.asDictionary()
        } catch {
            print("Error converting MockError to dictionary")
        }
        
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(errorCode, forKey: .errorCode)
        try container.encode(errorDescription, forKey: .errorDescription)
        try container.encode(errorType, forKey: .errorType)
        try container.encode(errorTrace, forKey: .errorTrace)
    }
    
    init(errorCode: MockErrorCode?, errorType: String?, errorDescription: String?, errorTrace: String?) {
        self.internalErrorCode = (errorCode ?? .other).rawValue
        self.errorType = errorType
        self.errorDescription = errorDescription
        self.errorTrace = errorTrace
    }
    
    init(errorCode: String, errorType: String?, errorDescription: String?, errorTrace: String?) {
        self.internalErrorCode = Int(errorCode) ?? 0
        self.errorType = errorType
        self.errorDescription = errorDescription
        self.errorTrace = errorTrace
    }
    
    static func error(from data: Data) -> MockError? {
        let decoder = JSONDecoder()
        do {
            let parsed = try decoder.decode(MockError.self, from: data)
            return parsed
        } catch {
           print("Error parsing data into MockError")
        }
         return nil
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
                    mockError.errorCode == MockErrorCode.expiredHMAC {
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


