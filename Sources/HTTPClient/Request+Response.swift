import Foundation
import Combine
import Alamofire

public typealias RequestHook<T:Codable,U:Alamofire.RequestInterceptor> = (HTTPRequest<T,U>) -> Void
public typealias ResponseHook<T:Codable> = (HTTPResponse<T>) -> Void

public struct HTTPRequest<T:Codable,U:Alamofire.RequestInterceptor> {
    
    let url: URL
    let timestamp: Date = Date()

    private let interceptor: U?
    
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
                let jsonData = try! JSONDecoder().decode(T.self, from: data)
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
         postfetchHook: ResponseHook<T>? = nil) {
        self.url = url
        self.interceptor = interceptor
        self.prefetchHook = prefetchHook
        self.postfetchHook = postfetchHook
    }
}

public struct HTTPResponse<T:Codable> {
    let url: URL
    let data: T?
    let timestamp: Date
    let postfetchHook: ResponseHook<T>?
}

