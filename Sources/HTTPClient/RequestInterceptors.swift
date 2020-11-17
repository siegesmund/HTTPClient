import Foundation
import Combine
import Alamofire

// MARK: Interceptor Protocols

///
/// Both JWT and Header Token authorization use the HeaderTokenAuthorization interceptor.
/// The only difference between the two is that one uses Bearer <token> and the other uses Token <token>
/// as the Authorization value
///

// https://www.avanderlee.com/swift/authentication-alamofire-request-adapter/
internal protocol HeaderTokenAuthorizationInterceptor: Alamofire.RequestInterceptor {
    var value: String { get }
}

extension HeaderTokenAuthorizationInterceptor {
    public func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var mutableUrlRequest = urlRequest
        mutableUrlRequest.setValue(value, forHTTPHeaderField: "Authorization")
        completion(.success(mutableUrlRequest))
    }
}


// https://cocoacasts.com/working-with-nsurlcomponents-in-swift
internal protocol QueryParameterRequestAuthorizationInterceptor: Alamofire.RequestInterceptor {
    var token: String { get }
    var authParameterName: String { get }
}

internal extension QueryParameterRequestAuthorizationInterceptor {
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        // Create a URLComponents object from the URLRequest URL object
        var components: URLComponents? = URLComponents(url: urlRequest.url!, resolvingAgainstBaseURL: false)
        
        if components?.queryItems == nil {
            // If there are no queryItems, set queryItems equal to an array with the query parameter name = token
            components?.queryItems = [URLQueryItem(name: authParameterName, value: token)]
        } else {
            // Otherwise, append another URLQueryItem to the queryItems array
            components?.queryItems?.append(URLQueryItem(name: authParameterName, value: token))
        }
        
        // Create a mutable copy of the original request
        var mutableUrlRequest = urlRequest
        // Set the url - now with token query parameter - to the URLRequest's url property
        mutableUrlRequest.url = components?.url
        // Signal completion with the mutableUrlRequest
        completion(.success(mutableUrlRequest))
    }
}

// MARK: Interceptor Classes

/// Adds Authorization: Bearer <token> to the request headers
internal final class JWTRequestInterceptor: HeaderTokenAuthorizationInterceptor {
    internal var value: String
    init(jwt: String) {
        self.value = "Bearer \(jwt)"
    }
}

/// Adds Authorization: Token <token> to the request headers
internal final class HeaderAuthorizationRequestInterceptor: HeaderTokenAuthorizationInterceptor {
    internal var value: String
    init(token: String) {
        self.value = "Token \(token)"
    }
}

/// Adds a query parameter <authParameterName>=<token> to the url query string
internal final class QueryParameterAuthorizationRequestInterceptor: QueryParameterRequestAuthorizationInterceptor {
    internal var token: String
    internal var authParameterName: String
    init(token: String, authParameterName: String) {
        self.token = token
        self.authParameterName = authParameterName
    }
}
