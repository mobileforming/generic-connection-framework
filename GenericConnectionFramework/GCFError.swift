//
//  GCFError.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 3/13/18.
//  Copyright © 2018 mobileforming LLC. All rights reserved.
//

import Foundation

public enum GCFError: Error {
	case parsingError
	case requestError
	case pluginError
    case authError(error: Error)
	
	public enum PluginError: Error {
		case failureAbortRequest		//fail entire request
		case failureCompleteRequest		//don't process remaining plugins, finish the request
		case failureContinue			//continue with remaining plugins
	}
	
	public enum RoutableError: Error {
		case invalidURL(message: String)
	}
}
