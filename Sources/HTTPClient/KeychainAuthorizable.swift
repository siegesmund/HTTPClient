import Foundation
import Combine
import KeychainAccess


public protocol KeychainAuthorizable: TokenAuthorizable {
    /// The base url of the server that the stored token authorizes, e.g. github.com
    static var server: String { get }
    /// The name of the key in Keychain
    static var keychainAuthorizationTokenName: String { get }
}

extension KeychainAuthorizable {
    
    /// The stored value associated with the object that conforms to KeychainAuthorizable
    public static var token: String? {
        let keychain = Keychain(server: server, protocolType: .https)
        return keychain[keychainAuthorizationTokenName]
    }
    
    /// A method to save tokens to Keychain
    /// - Parameter token: the token to save
    /// - Returns: true if the token was saved, false otherwise
    public static func setToken(token: String, sync: Bool = true) -> Bool {
        let keychain = Keychain(server: server, protocolType: .https)
            .synchronizable(sync)
        keychain[keychainAuthorizationTokenName] = token
        if let _ = keychain[keychainAuthorizationTokenName] {
            return true
        }
        return false
    }
    
    /// A method to save tokens to Keychain
    /// - Parameter token: the token to save
    /// - Returns: A publisher that emits true if the token was saved, false otherwise
    public static func setToken(token: String, sync: Bool = true) -> AnyPublisher<Bool,Never> {
        return Just(setToken(token: token, sync: sync)).eraseToAnyPublisher()
    }
    
    /// A convenience function to test if there is a Keychain value associated with a key
    /// - Returns: true if a keychain value exists, false otherwise
    public static func tokenExists() -> Bool {
        let keychain = Keychain(server: server, protocolType: .https)
        if let _ = keychain[keychainAuthorizationTokenName] {
            return true
        }
        return false
    }
    
    /// A convenience function to test if there is a Keychain value associated with a key
    /// - Returns: A publisher that emits true if a keychain value exists, false otherwise
    public static func tokenExists() -> AnyPublisher<Bool,Never> {
        return Just(tokenExists()).eraseToAnyPublisher()
    }
}
