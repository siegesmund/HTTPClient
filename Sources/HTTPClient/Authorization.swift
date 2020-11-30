import Foundation
import Combine
import Alamofire

// MARK: Developer Facing Methods

//
//
//

public protocol NoAuthorization: HTTPBaseClient {}

extension NoAuthorization {
    public static func request<T:Codable>(path: String,
                                          arguments: [String:String]? = nil,
                                          https: Bool = true) -> AnyPublisher<HTTPResponse<T>,Error> {
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
                                          https: Bool = true,
                                          prefetch: RequestHook<T,QueryParameterAuthorizationRequestInterceptor>? = nil,
                                          postfetch: ResponseHook<T>? = nil,
                                          dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil) -> AnyPublisher<HTTPResponse<T>,Error> {
        
        return _request(url: url(path: path,
                                 arguments: arguments,
                                 https: https,
                                 server: server)!,
                        interceptor: interceptor,
                        prefetchHook: prefetch,
                        postfetchHook: postfetch,
                        dateDecodingStrategy: dateDecodingStrategy)
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
                                          https: Bool = true,
                                          prefetch: RequestHook<T,HeaderAuthorizationRequestInterceptor>? = nil,
                                          postfetch: ResponseHook<T>? = nil,
                                          dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil) -> AnyPublisher<HTTPResponse<T>,Error> {
        
        return _request(url: url(path: path,
                                 arguments: arguments,
                                 https: https,
                                 server: server)!,
                        interceptor: interceptor,
                        prefetchHook: prefetch,
                        postfetchHook: postfetch,
                        dateDecodingStrategy: dateDecodingStrategy)
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
                                          https: Bool = true,
                                          preRequestHook: RequestHook<T,JWTRequestInterceptor>? = nil,
                                          postRequestHook: ResponseHook<T>? = nil) -> AnyPublisher<HTTPResponse<T>,Error> {
        
        return _request(url: url(path: path, arguments: arguments, https: https, server: server)!,
                        interceptor: interceptor,
                        prefetchHook: preRequestHook,
                        postfetchHook: postRequestHook)
    }
}
