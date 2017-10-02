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
    var header: [String : String]? { get }
    var parameters: [String : String]? { get }
    var body: [String : Any]? { get }
}

public enum HTTPMethod: String {
	case get = "GET"
	case post = "POST"
	case put = "PUT"
	case delete = "DELETE"
}
