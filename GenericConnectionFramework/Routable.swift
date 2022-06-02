//
//  Routable.swift
//  GenericConnectionFramework
//  
//  Routable pro
//
//  Created by Christopher Luc on 8/18/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//
import Foundation

public protocol DeprecatedRoutableCheatCode {
    var body: [String: AnyHashable]? { get }
}

public protocol Routable: DeprecatedRoutableCheatCode {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String :String]? { get }
    var parameters: [String: String]? { get }
    var needsAuthorization: Bool { get }
    
    @available(*, deprecated, message: "please use bodyData")
    var body: [String: AnyHashable]? { get }
    var bodyData: RoutableBodyData { get }
    
    // To be overriden...
    var defaultTimeout: TimeInterval { get }
    var cachePolicy: URLRequest.CachePolicy { get }
}



extension Routable {
    public var defaultTimeout: TimeInterval {
        return 60
    }
    
    public var cachePolicy: URLRequest.CachePolicy {
        return .useProtocolCachePolicy
    }
    
    public var body: [String: AnyHashable]? {
        return nil
    }
    
    public var bodyData: RoutableBodyData {
        return .none
    }
    
    public func configureHttpBody(urlRequest: inout URLRequest) {
        guard method == .post || method == .put || method == .patch else {
            return
        }
        
        // Cheap dirty hack to silence the warnings...
        // Handle Body Data
        if let body = (self as DeprecatedRoutableCheatCode).body {
             // This first condition is deprecated, remove when routable body is deleted
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        } else if case let RoutableBodyData.jsonObject(object) = bodyData  {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: object, options: [])
        } else if case let RoutableBodyData.jsonArray(array) = bodyData {
            urlRequest.httpBody = try? JSONSerialization.data(withJSONObject: array, options: [])
        } else if case let RoutableBodyData.data(data) = bodyData {
            urlRequest.httpBody = data
        }
        
        // Cheap dirty hack to silence the warnings...
        // Remove this after photo upload is finished converting to the body data property
        if urlRequest.allHTTPHeaderFields?["Content-Type"]?.contains("multipart/form-data") ?? false,
            let data = (self as DeprecatedRoutableCheatCode).body?["asset"] as? Data {
            urlRequest.httpBody = data
        }
        
    }
}

public enum HTTPMethod: String {
	case get = "GET"
	case post = "POST"
	case put = "PUT"
	case patch = "PATCH"
	case delete = "DELETE"
}

public enum RoutableBodyData {
    case none
    case jsonObject(_ object: [String: AnyHashable])
    case jsonArray(_ array: [AnyHashable])
    case data(_ data: Data)
}
