import Foundation
import Combine
import Alamofire

public struct Response<T:Codable> {
    let url: URL
    let data: T?
    let timestamp: Date
}


