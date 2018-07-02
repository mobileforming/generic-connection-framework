//
//  GraphRoutable.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 5/22/18.
//  Copyright © 2018 mobileforming LLC. All rights reserved.
//

import Foundation

public protocol GraphRoutable: Routable {
	var query: String { get }
	var variables: [String:Any]? { get }
}

public extension GraphRoutable {
	public var body: [String:Any]? {
		var data = [String:Any]()
		data["query"] = query
		
		if let variables = variables {
			data["variables"] = variables
		}
		
		return data
	}
	
	public var path: String {
		return ""
	}
}
