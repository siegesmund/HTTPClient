import Foundation
import Combine
import Alamofire

public typealias RequestHook<T:Codable,U:Alamofire.RequestInterceptor> = (HTTPRequest<T,U>) -> Void
public typealias ResponseHook<T:Codable> = (HTTPResponse<T>) -> Void

public struct HTTPRequest<T:Codable,U:Alamofire.RequestInterceptor> {
    
    public let url: URL
    public let timestamp: Date = Date()

    private let interceptor: U?
    internal let dateDecodingStrategy: JSONDecoder.DateDecodingStrategy?
    
    internal let prefetchHook: RequestHook<T,U>?
    internal let postfetchHook: ResponseHook<T>?
    
    internal var dataRequest: DataRequest {
        return self.interceptor == nil ? AF.request(url) : AF.request(url, interceptor: self.interceptor)
    }
    
    var result: AnyPublisher<HTTPResponse<T>,Error> {
        return dataRequest
            .publishData()
            .result()
            .map {
                let data = try! $0.get()
                let decoder = JSONDecoder()
                if let strategy = dateDecodingStrategy { decoder.dateDecodingStrategy = strategy }
                let jsonData = try! decoder.decode(T.self, from: data)
                return HTTPResponse<T>(url: self.url, data: jsonData, timestamp: self.timestamp, postfetchHook: postfetchHook)
            }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    var publisher: AnyPublisher<HTTPRequest<T,U>,Never> {
        return Just(self).eraseToAnyPublisher()
    }
    
    init(url: URL,
         interceptor: U? = nil,
         prefetchHook: RequestHook<T,U>? = nil,
         postfetchHook: ResponseHook<T>? = nil,
         dateDecodingStrategy: JSONDecoder.DateDecodingStrategy? = nil) {
        self.url = url
        self.interceptor = interceptor
        self.prefetchHook = prefetchHook
        self.postfetchHook = postfetchHook
        self.dateDecodingStrategy = dateDecodingStrategy
    }
}

public struct HTTPResponse<T:Codable> {
    public let url: URL
    public let data: T?
    public let timestamp: Date
    internal let postfetchHook: ResponseHook<T>?
}

