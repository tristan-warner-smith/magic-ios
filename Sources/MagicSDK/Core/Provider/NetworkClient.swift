//
//  NetworkClient.swift
//  Magic
//
//  Created by Jerry Liu on 2/09/20.
//  Copyright © 2020 Magic Labs Inc. All rights reserved.
//

import Foundation
import PromiseKit

/// A base networking class that can send http requests
public class NetworkClient {
    
    /// Various errors that may occur while processing Web3 requests
    public enum Error: Swift.Error {
        /// The response did not include expected results
        case unexpectedResponse(Swift.Error?)
        /// The server returned an unexpected response code
        case invalidResponseCode
    }
    
    /// Internal queue for handling requests
    let queue: DispatchQueue
    
    /// Internal URLSession for this Web3Provider's RPC requests
    let session: URLSession = URLSession(configuration: .default)
    
    /// JSONEncoder for encoding RPCRequests
    let encoder = JSONEncoder()
    
    /// JSONDecoder for parsing RPCResponses
    let decoder = JSONDecoder()
    
    /// HTTP headers to add to all requests
    public var headers = [
        "Content-Type": "application/json"
    ]
    
    init() {
        self.queue = DispatchQueue(label: "MagicHttpProvider", attributes: .concurrent)
    }
    
    /// Encode an object with or without a prefix into data
    ///
    /// - Parameters:
    ///   - body: Object to encode. Must be Encodable.
    ///   - prefix: Optional string to prefix the body with
    /// - Returns: Promise resolving with the encoded Data
    func encode<T: Encodable>(body: T, withPrefix prefix: String? = nil) -> Promise<Data> {
        return Promise { resolver in
            queue.async {
                do {
                    let encoded: Data
                    if let prefix = prefix {
                        encoded = try self.encoder.encode([prefix: body])
                    } else {
                        encoded = try self.encoder.encode(body)
                    }
                    resolver.fulfill(encoded)
                } catch {
                    resolver.reject(error)
                }
            }
        }
    }
    
    /// Sends a basic http request.
    /// This method will create a URLRequest, and then run a URLSessionDataTask with the URLRequest.
    /// Once a response is received, the response will be validated for data and a valid status code
    /// before calling the callback with the resulting data or error.
    ///
    /// - Parameters:
    ///   - url: url for the request
    ///   - method: HTTP method to use
    ///   - body: Optional request body to include
    /// - Returns: Promise resolving with Data from the response if it's successful
    func postRequest(url: URL, method: String, body: Data?) -> Promise<Data> {
        return Promise { resolver in
            queue.async {
                var req = URLRequest(url: url)
                req.httpMethod = method
                req.httpBody = body
                
                // Add default headers
                for (k, v) in self.headers {
                    req.addValue(v, forHTTPHeaderField: k)
                }
                
                // Create the URLSessionTask
                let task = self.session.dataTask(with: req) { data, urlResponse, error in
                    guard let urlResponse = urlResponse as? HTTPURLResponse, let data = data, error == nil else {
                        resolver.reject(Error.unexpectedResponse(error))
                        return
                    }
                    
                    guard urlResponse.statusCode >= 200 && urlResponse.statusCode < 300 else {
                        resolver.reject(Error.invalidResponseCode)
                        return
                    }
                    
                   resolver.fulfill(data)
                }
                task.resume()
            }
        }
    }
    
}
