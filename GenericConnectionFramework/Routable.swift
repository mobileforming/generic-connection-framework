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
    var headers: [String:String]? { get }
    var parameters: [String:String]? { get }
    var body: [String:Any]? { get }
	var needsAuthorization: Bool { get }
    
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
}

public enum HTTPMethod: String {
	case get = "GET"
	case post = "POST"
	case put = "PUT"
	case patch = "PATCH"
	case delete = "DELETE"
}
