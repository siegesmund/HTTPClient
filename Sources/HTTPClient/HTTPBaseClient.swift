import Foundation
import Combine
import Alamofire


enum HTTPClientRequestError: Error {
    case decodingError
    case other(Error)
}

struct HTTPClientRequest<T:Codable,U:Alamofire.RequestInterceptor> {
    
    var url: URL
    var interceptor: U?
    var error: Error?
    let timestamp: Date = Date()
    
    internal var dataRequest: DataRequest {
        return self.interceptor == nil ? AF.request(url) : AF.request(url, interceptor: self.interceptor)
    }
    
    var result: AnyPublisher<T,Error> {
        return dataRequest
            .publishData()
            .result()
            .map { try! $0.get() }
            .decode(type: T.self, decoder: JSONDecoder())
            /*.mapError { (error) -> HTTPClientRequestError in
                switch error {
                case is Swift.DecodingError:
                    return .decodingError
                default:
                    return .other(error)
                }
            }*/
            .eraseToAnyPublisher()
    }
    
    var publisher: AnyPublisher<HTTPClientRequest,Never> {
        return Just(self).eraseToAnyPublisher()
    }
    
    init(url: URL, interceptor: U? = nil) {
        self.url = url
        self.interceptor = interceptor
    }
}

public protocol HTTPBaseClient: URLBuildable {
    static var log: Bool { get }
    static func prefetch()
    static func postfetch()
}

extension HTTPBaseClient {
    
    var log: Bool { return true }
    
    static func prefetch<T:Codable, U: Alamofire.RequestInterceptor>(_ request: HTTPClientRequest<T,U>) -> AnyPublisher<HTTPClientRequest<T,U>,Never> {
        print("Running prefetch \(request.url.absoluteString)")
        return Just(request).eraseToAnyPublisher()
    }
    
    static func postfetch() {
        print("Running postfetch")
    }
    
    internal static func _log(data: Data) -> Data {
        // if log is true, log the data
        log ? print(String(decoding: data, as: UTF8.self)) : nil
        
        return data
    }
    /*
    internal static func _dataRequest<T:Codable, U:Alamofire.RequestInterceptor>(_ request: HTTPClientRequest<T,U>) -> AnyPublisher<HTTPClientRequest<T,U>,Error> {
        
        var afRequest: DataRequest = (request.interceptor == nil ?
                                        AF.request(request.url) :
                                        AF.request(request.url, interceptor: request.interceptor))
            .publishData()
            .result()
            .map { HTTPClientRequest(url: request.url, interceptor: request.interceptor, result: $0, error: nil) }
        
        return afRequest
            .publishData()
            .result()
            .setFailureType(to: Error.self)

            .map(getData)
            .decode(type: T.self, decoder: JSONDecoder())
            .map {}
            .eraseToAnyPublisher()
    }
    
    
    internal static func getData(_ result: Result<Data,AFError>) -> Data {
        return try! result.get()
    }
    */
    /*
    internal static func _processDataRequest<T:Codable>(_ dataRequest: DataRequest) -> AnyPublisher<T,Error> {
        return dataRequest
            .publishData()
            .result()
            .setFailureType(to: Error.self)
            .map(getData)
            .map(_log)
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    */
}

// Requests that utilize interceptors
extension HTTPBaseClient {
    
    /// Make a HTTP request with a URL object that passes a JWT to the server in the request headers
    /// - Parameters:
    ///   - url: A URL object
    ///   - interceptor: An instance of JWTRequestInterceptor
    /// - Returns: A publisher that returns an object that conforms to Codable, or an error
    internal static func _request<T:Codable, U: Alamofire.RequestInterceptor>(url: URL, interceptor: U?) -> AnyPublisher<T, HTTPClientRequestError> {
        return HTTPClientRequest<T,U>(url: url, interceptor: interceptor)
            .publisher.setFailureType(to: Error.self)
            .flatMap({ r in r.request })
            // .flatMap { (r: HTTPClientRequest<T,U>) -> T in return r.result }
    }
}
