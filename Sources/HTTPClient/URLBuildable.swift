import Foundation

public protocol URLBuildable {
    static var server: String { get }
}

extension URLBuildable {
    
    public static func url(path: String,
                    arguments: [URLQueryItem]? = nil,
                    https: Bool = true,
                    server: String = server) -> URL? {
        
        var components = URLComponents()
        components.scheme = https ? "https" : "http"
        components.host = server
        components.path = path
        components.queryItems = arguments
        
        return components.url
    }
    
    public static func url(path: String,
                    arguments: [String:String]?,
                    https: Bool = true,
                    server: String = server) -> URL? {
        
        var queryItems: [URLQueryItem]?
        if let arguments = arguments {
            if arguments.count > 0 {
                queryItems = [URLQueryItem]()
                for (key, value) in arguments {
                    queryItems?.append(URLQueryItem(name: key, value: value))
                }
            }
        }
        
        return url(path: path, arguments: queryItems, https: https, server: server)
    }
}
