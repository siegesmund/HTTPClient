import Foundation
import Combine

public protocol QueryParameterAuthorization: HTTPClient, KeychainAuthorizable {}

extension QueryParameterAuthorization {
    
    private static var interceptor: QueryParameterAuthorizationRequestInterceptor {
        return QueryParameterAuthorizationRequestInterceptor(token: token!, authParameterName: "token")
    }
    
    public static func request<T:Codable>(url: URL) -> AnyPublisher<T,Error> {
        return request(url: url, interceptor: interceptor)
    }
    
}

public protocol HeaderTokenAuthorization: HTTPClient, KeychainAuthorizable {}

extension HeaderTokenAuthorization {
    private static var interceptor: HeaderAuthorizationRequestInterceptor {
        return HeaderAuthorizationRequestInterceptor(token: token!)
    }
    
    public static func request<T:Codable>(url: URL) -> AnyPublisher<T,Error> {
        return request(url: url, interceptor: interceptor)
    }
}


public protocol JWTAuthorization: HTTPClient, KeychainAuthorizable {}

extension JWTAuthorization {
    private static var interceptor: JWTRequestInterceptor {
        return JWTRequestInterceptor(jwt: token!)
    }
    
    public static func request<T:Codable>(url: URL) -> AnyPublisher<T,Error> {
        return request(url: url, interceptor: interceptor)
    }
}
