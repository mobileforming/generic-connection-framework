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
        let description = "Expected type \(String(describing: T.self)) doess not conform to protocol Decodable"
        return .dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: description))
    }
}

extension Decodable {
    
    fileprivate static func openedJSONDecode(_ data: Data, using decoder: JSONDecoder = JSONDecoder()) throws -> Self? {
        return try? decoder.decode(self, from: data)
    }
}


extension JSONDecoder {
    
    func decodeIfValid<T>(_ type: T.Type, with data: Data) throws -> T {
        
        // Attempt to cast T as Decodable
        guard case let decodableType as Decodable.Type = T.self else {
            throw DecodingError.unsafeTypeError(type)
        }
        
        // right now we know decodableType is Decodable, but we have lost all other insight into its metatype
        // openedJSONDecode(data:using:) acts within a Decodable (static type) to return Self (metatype),
        // covertly creating the correct type. We don't know this from a compiler standpoint, however, so we
        // must optionally cast back to T in order to return a fully typed object
        guard let typedDecodable = try decodableType.openedJSONDecode(data, using: self) as? T else {
            throw DecodingError.unsafeTypeError(type)
        }
        
        return typedDecodable
        
    }
    
}

extension GCF {
    
    func parseData<T>(from data: Data?) throws -> T {
        
        do {
            switch T.self {
            
            case is Data.Type, is Optional<Data>.Type:
                return try unwrap(data)
                
            case is Bool.Type, is Optional<Bool>.Type:
                return try unwrap(data != nil)
                
            case is [String: Any].Type, is Optional<[String: Any]>.Type:
                return try unwrap(try? jsonParse(with: try unwrap(data)))
                
            
            case is Decodable.Type:
                return try unwrap(try? JSONDecoder().decodeIfValid(T.self, with: try unwrap(data)))
                
            default:
                throw GCFError.parsingError
                
            }
            
        } catch let error as GCFError {
            throw error
            
        } catch let error {
            throw GCFError.parsingError(error as? DecodingError)
            
        }
        
    }
    
    private func jsonParse<T>(with data: Data) throws -> T {
        let dict = try JSONSerialization.jsonObject(with: data, options: [])
        
        guard let typedDict = dict as? T else {
            throw GCFError.parsingError
            
        }
        
        return typedDict
        
    }
    
    // Mitigate the fact that we don't know anything
    // about <T>'s optionality inside parseData(from:)
    private func unwrap<T>(_ data: Any?) throws -> T {

        if let result = data as? T { // non-nil
            return result
        }
        
        guard let nilReturn: T = nil else { // nil, non-optional
            throw GCFError.parsingError
        }
        
        return nilReturn // nil, optional
    }

}
