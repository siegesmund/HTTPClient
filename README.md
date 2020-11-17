# HTTPClient

A collection of protocols written in Swift and built on Alamofire to make consuming REST APIs easier


### Authorization
- Read credentials from keychain
#### Easy authorization schemes
- JSON Web Token (JWT)
- API token passed via request headers
- API token passed via query parameters

#### Example
```swift
// Create a new object that conforms to one of the authorization protocols
struct MyAPIClientObject: QueryParameterAuthorization {
    static var server: String = "api.github.com"
    static var keychainAuthorizationTokenName: String = "GITHUB_API_TOKEN"
    
    // Build a url using the url(path:) method
    // TODO: Complete this documentation
    
}
```
