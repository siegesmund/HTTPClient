import Foundation
import Combine
import Alamofire



public protocol HTTPBaseClient: URLBuildable {
    static var log: Bool { get }
}

// MARK: Internal Methods
extension HTTPBaseClient {
    
    var log: Bool { return false }
    
    internal static func _prefetch<T:Codable, U: Alamofire.RequestInterceptor>(_ request: HTTPRequest<T,U>) -> AnyPublisher<HTTPRequest<T,U>,Never> {
        if let prefetchHook = request.prefetchHook { prefetchHook(request) }
        return Just(request).eraseToAnyPublisher()
    }
    
    internal static func _fetch<T:Codable, U: Alamofire.RequestInterceptor>(_ request: HTTPRequest<T,U>) -> AnyPublisher<HTTPResponse<T>,Error> {
        return request.result
    }
    
    internal static func _postfetch<T:Codable>(_ response: HTTPResponse<T>) -> AnyPublisher<HTTPResponse<T>,Never> {
        if let responseHook = response.postfetchHook { responseHook(response) }
        return Just(response).eraseToAnyPublisher()
    }
    
    internal static func _log(data: Data) -> Data {
        // if log is true, log the data
        log ? print(String(decoding: data, as: UTF8.self)) : nil
        
        return data
    }
    
    /// Make a HTTP request with a URL object that passes a JWT to the server in the request headers
    /// - Parameters:
    ///   - url: A URL object
    ///   - interceptor: An instance of JWTRequestInterceptor
    /// - Returns: A publisher that returns an object that conforms to Codable, or an error
    internal static func _request<T:Codable,
                                  U: Alamofire.RequestInterceptor>(url: URL,
                                                                   interceptor: U?,
                                                                   prefetchHook: RequestHook<T,U>? = nil,
                                                                   postfetchHook: ResponseHook<T>? = nil,
                                                                   dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil) -> AnyPublisher<HTTPResponse<T>,Error> {
        
        return HTTPRequest<T,U>(url: url,
                                interceptor: interceptor,
                                prefetchHook: prefetchHook,
                                postfetchHook: postfetchHook,
                                dateDecodingStrategy: dateDecodingStrategy)
            .publisher
            .flatMap(_prefetch)
            .flatMap(_fetch)
            .flatMap(_postfetch)
            .eraseToAnyPublisher()
    }
}
