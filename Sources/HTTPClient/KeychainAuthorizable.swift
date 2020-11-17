import Foundation
import KeychainAccess

public protocol KeychainAuthorizable {
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
    public static func setToken(token: String) -> Bool {
        let keychain = Keychain(server: server, protocolType: .https)
        keychain[keychainAuthorizationTokenName] = token
        if let _ = keychain[keychainAuthorizationTokenName] {
            return true
        }
        return false
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
}
