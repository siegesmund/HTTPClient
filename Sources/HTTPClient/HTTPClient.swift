import Foundation
import Combine
import Alamofire

public protocol HTTPClient: URLBuildable {}

extension HTTPClient {
    
    static func dataRequest(url: URL) -> DataRequest {
        return AF.request(url)
    }
    
    static func dataRequest(url: URL, interceptor: JWTRequestInterceptor?) -> DataRequest {
        return interceptor == nil ? AF.request(url) : AF.request(url, interceptor: interceptor)
    }
    
    static func dataRequest(url: URL, interceptor: HeaderAuthorizationRequestInterceptor?) -> DataRequest {
        return interceptor == nil ? AF.request(url) : AF.request(url, interceptor: interceptor)
    }
    
    static func dataRequest(url: URL, interceptor: QueryParameterAuthorizationRequestInterceptor?) -> DataRequest {
        return interceptor == nil ? AF.request(url) : AF.request(url, interceptor: interceptor)
    }
    
    static func processDataRequest<T:Codable>(dataRequest: DataRequest) -> AnyPublisher<T,Error> {
        return dataRequest
            .publishData()
            .result()
            .setFailureType(to: Error.self)
            .map { try! $0.get() }
            .decode(type: T.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    
    static func request<T:Codable>(url: URL) -> AnyPublisher<T,Error> {
        let request = dataRequest(url: url)
        return processDataRequest(dataRequest: request)
    }
    
    static func request<T:Codable>(url: URL, interceptor: JWTRequestInterceptor?) -> AnyPublisher<T,Error> {
        let request = dataRequest(url: url, interceptor: interceptor)
        return processDataRequest(dataRequest: request)
    }
    
    static func request<T:Codable>(url: URL, interceptor: HeaderAuthorizationRequestInterceptor?) -> AnyPublisher<T,Error> {
        let request = dataRequest(url: url, interceptor: interceptor)
        return processDataRequest(dataRequest: request)
    }
    
    static func request<T:Codable>(url: URL, interceptor: QueryParameterAuthorizationRequestInterceptor?) -> AnyPublisher<T,Error> {
        // Create the appropriate data request based on whether there is an interceptor
        let request = dataRequest(url: url, interceptor: interceptor)
        return processDataRequest(dataRequest: request)
    }

}
