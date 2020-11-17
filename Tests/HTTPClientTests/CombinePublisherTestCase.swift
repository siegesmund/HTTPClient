import XCTest
import Combine
import CombineExpectations
@testable import HTTPClient

protocol CombinePublisherTestCase: XCTestCase {}

extension CombinePublisherTestCase {
    
    func values<T>(_ publisher: AnyPublisher<T,Error>, timeout: Int = 10) -> T {
        let recorder = publisher.record()
        let elements = (try! wait(for: recorder.elements, timeout: TimeInterval(timeout))).compactMap { $0 }
        return elements.first!
    }
    
    func completion<T>(_ publisher: AnyPublisher<T,Error>, timeout: Int = 10) {
        let recorder = publisher.record()
        try! wait(for: recorder.completion, timeout: TimeInterval(timeout))
    }
    
    func finished<T>(_ publisher: AnyPublisher<T,Error>, timeout: Int = 10) {
        let recorder = publisher.record()
        try! wait(for: recorder.finished, timeout: TimeInterval(timeout))
    }
    
}
