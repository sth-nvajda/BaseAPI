//
//  Request.swift
//  BaseAPI
//
//  Created by Serhii Londar on 1/5/18.
//

import Foundation

#if swift(>=5.1) && os(Linux)
   import FoundationNetworking
#endif

public class Request {
    public var url: String
    public var method: RequestMethod
    public var parameters: [String : String]?
    public var headers: [String : String]?
    public var body: Data?
    
    public init(url: String, method: RequestMethod, parameters: [String : String]? = nil, headers: [String : String]? = nil, body: Data? = nil) {
        self.url = url
        self.method = method
        self.parameters = parameters
        self.headers = headers
        self.body = body
    }
    
    public func request() -> (request: URLRequest?, error: Error?) {
        // First encode just the base URL
        if let encodedBaseUrl = url.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) {
            // Then add the already-encoded parameters
            let finalUrl = appendParametersToUrl(encodedBaseUrl)
            if let url = URL(string: finalUrl) {
                var request = URLRequest(url: url)
                if let headers = headers {
                    for (key, value) in headers {
                        request.addValue(value, forHTTPHeaderField: key)
                    }
                }
                request.httpMethod = method.rawValue
                request.httpBody = body
                return (request, nil)
            }
        }
        return (nil, NSError(domain:"Unable to create URL from string \(url)", code:9999, userInfo:nil))
    }
    
    private func appendParametersToUrl(_ baseUrl: String) -> String {
        var retUrl = baseUrl
        if let parameters = parameters {
            if parameters.count > 0 {
                retUrl.append("?")
                parameters.keys.forEach {
                    guard let value = parameters[$0] else { return }
                    let escapedValue = value.addingPercentEncoding(withAllowedCharacters: CharacterSet.ba_URLQueryAllowedCharacterSet())
                    if let escapedValue = escapedValue {
                        retUrl.append("\($0)=\(escapedValue)&")
                    }
                }
                retUrl.removeLast()
            }
        }
        return retUrl
    }
}
