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
	var variables: [String:AnyHashable]? { get }
}

public extension GraphRoutable {
	var body: [String:AnyHashable]? {
		var data = [String:AnyHashable]()
		data["query"] = query
		
		if let variables = variables {
			data["variables"] = variables
		}
		
		return data
	}
	
	var path: String {
		return ""
	}
}
