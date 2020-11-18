import Foundation
import Combine
import Alamofire

public protocol HTTPBaseClient: URLBuildable {
    static var log: Bool { get }
}

// Requests that utilize interceptors
extension HTTPBaseClient {
    
    /// Make a HTTP request with a URL object that passes a JWT to the server in the request headers
    /// - Parameters:
    ///   - url: A URL object
    ///   - interceptor: An instance of JWTRequestInterceptor
    /// - Returns: A publisher that returns an object that conforms to Codable, or an error
    internal static func _request<T:Codable, U: Alamofire.RequestInterceptor>(url: URL, interceptor: U?) -> AnyPublisher<Response<T>,Error> {
        return Request<T,U>(url: url, interceptor: interceptor)
            .publisher
            .flatMap(prefetch)
            .flatMap(fetch)
            .flatMap(postfetch)
            .eraseToAnyPublisher()
    }
}

extension HTTPBaseClient {
    
    var log: Bool { return false }
    
    internal static func prefetch<T:Codable, U: Alamofire.RequestInterceptor>(_ request: Request<T,U>) -> AnyPublisher<Request<T,U>,Never> {
        print("Running prefetch \(request.url.absoluteString) \(request.timestamp)")
        return Just(request).eraseToAnyPublisher()
    }
    
    internal static func fetch<T:Codable, U: Alamofire.RequestInterceptor>(_ request: Request<T,U>) -> AnyPublisher<Response<T>,Error> {
        return request.result
    }
    
    internal static func postfetch<T:Codable>(_ response: Response<T>) -> AnyPublisher<Response<T>,Never> {
        print("Running postfetch \(response.url.absoluteString) \(response.timestamp)")
        return Just(response).eraseToAnyPublisher()
    }
    
    internal static func _log(data: Data) -> Data {
        // if log is true, log the data
        log ? print(String(decoding: data, as: UTF8.self)) : nil
        
        return data
    }
}
