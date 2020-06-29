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

public protocol Routable {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String :String]? { get }
    var parameters: [String: String]? { get }
    var needsAuthorization: Bool { get }
    
    @available(*, deprecated, renamed: "bodyData")
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
    
    public var bodyData: RoutableBodyData {
        return .none
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
