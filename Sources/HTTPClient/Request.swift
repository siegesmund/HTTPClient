import Foundation
import Combine
import Alamofire

public struct Request<T:Codable,U:Alamofire.RequestInterceptor> {
    
    let url: URL
    let interceptor: U?
    let timestamp: Date = Date()
    
    internal var dataRequest: DataRequest {
        return self.interceptor == nil ? AF.request(url) : AF.request(url, interceptor: self.interceptor)
    }
    
    var result: AnyPublisher<Response<T>,Error> {
        return dataRequest
            .publishData()
            .result()
            .map {
                let data = try! $0.get()
                let jsonData = try! JSONDecoder().decode(T.self, from: data)
                return Response<T>(url: self.url, data: jsonData, timestamp: self.timestamp)
            }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    var publisher: AnyPublisher<Request<T,U>,Never> {
        return Just(self).eraseToAnyPublisher()
    }
    
    init(url: URL, interceptor: U? = nil) {
        self.url = url
        self.interceptor = interceptor
    }
}
