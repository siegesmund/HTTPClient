import XCTest
import Combine
import Alamofire
@testable import HTTPClient


struct SWAPIPeople: Codable,
                    NoAuthorization {
    
    static var log: Bool = true
    
    // URLBuildable
    // This must be just the server
    // No http/https; no /api or versioning.
    static var server: String = "swapi.dev"
    
    var name: String
    var height: String
    var mass: String
    var hair_color: String
    var skin_color: String
    var eye_color: String
    var birth_year: String
    var gender: String
    var homeworld: String
    var films: [String]
    var species: [String]
    var vehicles: [String]
    var starships: [String]
    var created: String
    var edited: String
    var url: String
}


public struct Metadata: Codable,
                        HeaderTokenAuthorization,
                        KeychainAuthorizable {

    public static var log: Bool = true
    
    
    public static var server: String = "api.tiingo.com"
    public static var keychainAuthorizationTokenName: String = "TIINGO_API_KEY"
    
    var ticker: String
    var name: String
    var description: String
    var startDate: String
    var endDate: String
}

final class HTTPClientTests: XCTestCase,
                             CombinePublisherTestCase {
    
    func testSwapi() {
        let publisher: AnyPublisher<HTTPResponse<SWAPIPeople>,Error> = SWAPIPeople.request(path: "/api/people/1/")
        XCTAssertEqual(values(publisher).data!.name, "Luke Skywalker")
    }
    
    func testTiingo() {
        let publisher: AnyPublisher<HTTPResponse<Metadata>,Error> = Metadata.request(path: "/tiingo/daily/AAPL", prefetch: { _ in print("I'm requesting the metadata for AAPL!!!")})
        XCTAssertEqual(values(publisher).data!.ticker, "AAPL")
    }
    
}
