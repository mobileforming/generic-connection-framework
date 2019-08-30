//
//  GCF+Parsing.swift
//  GenericConnectionFramework
//
//  Created by Christopher Spradling on 3/3/19.
//  Copyright © 2019 mobileforming LLC. All rights reserved.
//

import Foundation

extension DecodingError {
    fileprivate static func unsafeTypeError<T>(_ type: T.Type) -> DecodingError {
        let description = "Expected type \(String(describing: T.self)) does not conform to protocol Decodable"
        return .dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: description))
    }
}

extension Decodable {
    
    fileprivate static func openedJSONDecode(_ data: Data, using decoder: JSONDecoder = JSONDecoder()) throws -> Self {
            return try decoder.decode(self, from: data)

    }
}


extension JSONDecoder {
    
    func decodeIfValid<T>(_ type: T.Type, with data: Data?) throws -> T {
        
        guard let data = data else {
            throw GCFError.ParsingError.noData
        }
        
        // Attempt to cast T as Decodable
        guard case let decodableType as Decodable.Type = T.self else {
            throw GCFError.ParsingError.codable(.unsafeTypeError(type))
        }
        
        // right now we know decodableType is Decodable, but we have lost all other insight into its metatype.
        // openedJSONDecode(data:using:) acts within a Decodable (static type) to return Self (metatype),
        // covertly creating the correct type. We don't know this from a compiler standpoint, however, so we
        // must optionally cast back to T in order to return a fully typed object
        do {
            guard let typedDecodable = try decodableType.openedJSONDecode(data, using: self) as? T else {
                throw GCFError.ParsingError.codable(.unsafeTypeError(type))
            }
            
            return typedDecodable
            
        } catch let error {
            
            throw error as? GCFError.ParsingError ?? GCFError.ParsingError.codable(error as? DecodingError)
            
        }
        
    }
    
}

extension JSONSerialization {
    
    fileprivate static func parse<T>(with data: Data?) throws -> T {
        
        do {
            
            guard let data = data else {
                throw GCFError.ParsingError.noData
            }
            
            let dict = try jsonObject(with: data, options: [])
            
            guard let typedDict = dict as? T else {
                throw GCFError.ParsingError.jsonSerialization(nil)
            }
            
            return typedDict
            
        } catch let error {
            throw error as? GCFError.ParsingError ?? GCFError.ParsingError.jsonSerialization(error)
            
        }
        
    }
    
}

extension GCF {
    
    func parseData<T>(from data: Data?) throws -> T {
        
        do {

            let parsed: T?
            
            switch T.self {
            
            case is String.Type, is Optional<String>.Type:
               if let data = data {
                   parsed = String(data: data, encoding: .utf8) as! T?
               } else {
                   parsed = nil
               }

            case is Data.Type, is Optional<Data>.Type:
                parsed = data as? T
                
            case is Bool.Type, is Optional<Bool>.Type:
                parsed = (data != nil) as? T
                
            case is [String: Any].Type, is Optional<[String: Any]>.Type:
                parsed = try JSONSerialization.parse(with: data)
                
            case is Decodable.Type:
                parsed = try decoder.decodeIfValid(T.self, with: data)
                
            default:
                parsed = nil
                
            }
            
            return try unwrap(parsed)
            
        } catch let error {
            let gcfError = error as? GCFError.ParsingError ?? .codable(error as? DecodingError)
            return try unwrap(nil, error: gcfError)
            
        }
        
    }
    
    // Mitigate the fact that we don't know anything
    // about <T>'s optionality inside parseData(from:)
    private func unwrap<T>(_ data: Any?, error: GCFError.ParsingError = .noData) throws -> T {

        if let result = data as? T { // non-nil
            return result
        }
        
        guard let nilReturn: T = nil else { // nil, non-optional
            throw error
        }
        
        return nilReturn // nil, optional
        
    }

}
