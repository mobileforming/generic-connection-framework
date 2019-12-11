//
//  GCFError.swift
//  GenericConnectionFramework
//
//  Created by Alan Downs on 3/13/18.
//  Copyright © 2018 mobileforming LLC. All rights reserved.
//

import Foundation

public enum GCFError: Error {
	case parsingError(DecodingError?)
	case requestError(NSError?)
	case pluginError(NSError?)
    case authError(error: Error)
    
    public static var parsingError: GCFError {
        return .parsingError(nil)
    }
	
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

extension GCFError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .parsingError(decodingError: let decodeError):
            guard
                let desc = decodeError?.errorDescription
            else {
                return NSLocalizedString("Unknown reason", comment: "")
            }
            return NSLocalizedString(desc, comment: "")
            
        case .requestError(nserror: let nserror):
            guard
                let desc = (nserror as? LocalizedError)?.errorDescription
                else {
                    return NSLocalizedString("Unknown reason", comment: "")
            }
            return NSLocalizedString(desc, comment: "")
        case .pluginError(nserror: let nserror):
            guard
                let desc = (nserror as? LocalizedError)?.errorDescription
                else {
                    return NSLocalizedString("Unknown reason", comment: "")
            }
            return NSLocalizedString(desc, comment: "")
        case .authError(let error):
            let desc = error.localizedDescription
            return NSLocalizedString(desc, comment: "")
        }
    }
    public var failureReason: String? {
        switch self {
        case .parsingError(decodingError: let decodeError):
            guard
                let desc = decodeError?.failureReason
            else {
                return NSLocalizedString("Unknown failure reason", comment: "")
            }
            return NSLocalizedString(desc, comment: "")
        case .requestError(nserror: let nserror):
            guard
                let desc = (nserror as? LocalizedError)?.failureReason
            else {
                return NSLocalizedString("Unknown failure reason", comment: "")
            }
            return NSLocalizedString(desc, comment: "")
        case .pluginError(nserror: let nserror):
            guard
                let desc = (nserror as? LocalizedError)?.failureReason
            else {
                return NSLocalizedString("Unknown failure reason", comment: "")
            }
            return NSLocalizedString(desc, comment: "")
        case .authError(let error):
            guard
                let desc = (error as? LocalizedError)?.failureReason
            else {
                return NSLocalizedString("Unknown failure reason", comment: "")
            }
            return NSLocalizedString(desc, comment: "")
        }
    }
    public var recoverySuggestion: String? {
        switch self {
        case .parsingError(decodingError: let decodeError):
            guard
                let desc = decodeError?.recoverySuggestion
            else {
                return NSLocalizedString("Unknown recovery suggestion", comment: "")
            }
            return NSLocalizedString(desc, comment: "")
        case .requestError(nserror: let nserror):
            guard
                let desc = nserror?.localizedDescription
            else {
                return NSLocalizedString("Unknown recovery suggestion", comment: "")
            }
            return NSLocalizedString(desc, comment: "")
        case .pluginError(nserror: let nserror):
            guard
                let desc = nserror?.localizedDescription
            else {
                return NSLocalizedString("Unknown recovery suggestion", comment: "")
            }
            return NSLocalizedString(desc, comment: "")
        case .authError(let error):
            let desc = (error as NSError).localizedDescription
            return NSLocalizedString(desc, comment: "")
        }
    }
}

extension GCFError: CustomNSError {
    
}
