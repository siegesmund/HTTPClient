import Foundation
import Combine
import Alamofire

public protocol HTTPBaseClient: URLBuildable {}

extension HTTPBaseClient {
    
    internal static func log(data: Data) -> Data {
        print(String(decoding: data, as: UTF8.self))
        return data
    }
    
    internal static func _dataRequest<T:Alamofire.RequestInterceptor>(url: URL, interceptor: T? = nil) -> DataRequest {
        return interceptor == nil ? AF.request(url) : AF.request(url, interceptor: interceptor)
    }
    
    internal static func _processDataRequest<T:Codable>(dataRequest: DataRequest) -> AnyPublisher<T,Error> {
        return dataRequest
            .publishData()
            .result()
            .setFailureType(to: Error.self)
            .map { try! $0.get() }
            .map(log)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
}

// Requests that utilize interceptors
extension HTTPBaseClient {
    
    /*
    private static func request<T:Codable> (url: URL) -> AnyPublisher<T,Error> {
        return _request(url: url, interceptor: nil as NilRequestInterceptor?)
    }
    */
    
    /// Make a HTTP request with a URL object that passes a JWT to the server in the request headers
    /// - Parameters:
    ///   - url: A URL object
    ///   - interceptor: An instance of JWTRequestInterceptor
    /// - Returns: A publisher that returns an object that conforms to Codable, or an error
    internal static func _request<T:Codable, U: Alamofire.RequestInterceptor>(url: URL, interceptor: U?) -> AnyPublisher<T,Error> {
        let request = _dataRequest(url: url, interceptor: interceptor)
        return _processDataRequest(dataRequest: request)
    }
}
