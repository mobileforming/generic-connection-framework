//
//  Routable.swift
//  GenericConnectionFramework
//  
//  Routable pro
//
//  Created by Christopher Luc on 8/18/17.
//  Copyright © 2017 mobileforming LLC. All rights reserved.
//
public protocol Routable {
    var path: String { get }
    var method: String { get }
    var header: [String: String]? { get }
    var parameters: [String : String]? { get }
}
