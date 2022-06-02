//
//  ChallengeHandler.swift
//  Graphable
//
//  Created by Alan Downs on 5/23/18.
//  Copyright © 2018 mobileforming. All rights reserved.
//
// slightly modified from: https://www.bugsee.com/blog/ssl-certificate-pinning-in-mobile-applications/

import Foundation
import Security
import CommonCrypto

class GCFPinningDelegate: NSObject, URLSessionDelegate {

	let publicKeyHash: String
	let rsa2048Asn1Header: [UInt8] = [0x30, 0x82, 0x01, 0x22, 0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86, 0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00, 0x03, 0x82, 0x01, 0x0f, 0x00]

	required init(publicKey: String) {
		publicKeyHash = publicKey
	}

	private func sha256(data: Data) -> String {
		var keyWithHeader = Data(rsa2048Asn1Header)
		keyWithHeader.append(data)
		var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))

		keyWithHeader.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(keyWithHeader.count), &hash)
		}

		return Data(hash).base64EncodedString()
	}

	func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {

        if let serverTrust = checkNeedForPinning(challenge: challenge) {
            print(SecTrustGetCertificateCount(serverTrust))
            if let serverCertificate = SecTrustGetCertificateAtIndex(serverTrust, 0) {
                var serverPublicKeyData: NSData?
                if #available(iOS 12.0, *) {
                    if let serverPublicKey = SecCertificateCopyKey(serverCertificate) {
                        serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil )
                    }
                } else {
                    serverPublicKeyData = SecCertificateCopyData(serverCertificate) // TECH DEBT: make sure this is correct
                }
                if let data = serverPublicKeyData {
                    let keyHash = sha256(data: data as Data)
                    if keyHash == publicKeyHash {
                        return completionHandler(.useCredential, URLCredential(trust:serverTrust))
                    }
                }
            }
		}

		// Pinning failed
		completionHandler(.cancelAuthenticationChallenge, nil)
	}
    
    
    func checkNeedForPinning(challenge: URLAuthenticationChallenge) -> SecTrust? {
        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust else {
            return nil
        }
        
        if let serverTrust = challenge.protectionSpace.serverTrust {
            var secresult = SecTrustResultType.invalid
            

            if #available(iOS 12, *) {
                var error: CFError?
                if SecTrustEvaluateWithError(serverTrust, &error) {
                    return serverTrust
                } else {
                    // Diagnostic?
                }
            } else {
                let status = SecTrustEvaluate(serverTrust, &secresult)
                if errSecSuccess == status {
                    return serverTrust
                }
            }
        }
            
        return nil
    }
}
