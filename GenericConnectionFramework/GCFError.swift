//
//  GCFError.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 3/13/18.
//  Copyright © 2018 mobileforming LLC. All rights reserved.
//

import Foundation

public enum GCFError: Error {
    indirect case parsingError(GCFError)
	case requestError
	case pluginError
    case authError(error: Error)
    
	
	public enum PluginError: Error {
		case failureAbortRequest		// don't process remaining plugins, fail entire request
		case failureCompleteRequest		// don't process remaining plugins, finish the request
		case failureContinue			// continue with remaining plugins
        case failureRetryRequest        // don't process remaining plugins, retry the request
	}
    
    public enum ParsingError: Error {
        case codable(DecodingError?)
        case jsonSerialization(Error?)
        case noData
    }
	
	public enum RoutableError: Error {
		case invalidURL(message: String)
	}
}
