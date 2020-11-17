import Foundation
import Combine
import Alamofire

//
//
//

public protocol NoAuthorization: HTTPBaseClient {}

extension NoAuthorization {
    public static func request<T:Codable>(path: String,
                                          arguments: [String:String]? = nil,
                                          https: Bool = true) -> AnyPublisher<T,Error> {
        return _request(url: url(path: path,
                                 arguments: arguments,
                                 https: https,
                                 server: server)!,
                        interceptor: nil as NilRequestInterceptor?)
    }
}

//
//
//

public protocol QueryParameterAuthorization: HTTPBaseClient, TokenAuthorizable {}

extension QueryParameterAuthorization {
    
    private static var interceptor: QueryParameterAuthorizationRequestInterceptor {
        return QueryParameterAuthorizationRequestInterceptor(token: token!, authParameterName: "token")
    }
    
    public static func request<T:Codable>(path: String,
                                          arguments: [String:String]? = nil,
                                          https: Bool = true) -> AnyPublisher<T,Error> {
        
        return _request(url: url(path: path,
                                 arguments: arguments,
                                 https: https,
                                 server: server)!,
                        interceptor: interceptor)
    }
}

//
//
//

public protocol HeaderTokenAuthorization: HTTPBaseClient, TokenAuthorizable {}

extension HeaderTokenAuthorization {
    private static var interceptor: HeaderAuthorizationRequestInterceptor {
        return HeaderAuthorizationRequestInterceptor(token: token!)
    }
    
    public static func request<T:Codable>(path: String,
                                          arguments: [String:String]? = nil,
                                          https: Bool = true) -> AnyPublisher<T,Error> {
        
        return _request(url: url(path: path,
                                 arguments: arguments,
                                 https: https,
                                 server: server)!,
                        interceptor: interceptor)
    }
}

//
//
//

public protocol JWTAuthorization: HTTPBaseClient, TokenAuthorizable {}

extension JWTAuthorization {
    private static var interceptor: JWTRequestInterceptor {
        return JWTRequestInterceptor(jwt: token!)
    }
    
    public static func request<T:Codable>(path: String,
                                          arguments: [String:String]? = nil,
                                          https: Bool = true) -> AnyPublisher<T,Error> {
        
        return _request(url: url(path: path,
                                 arguments: arguments,
                                 https: https,
                                 server: server)!,
                        interceptor: interceptor)
    }
}
