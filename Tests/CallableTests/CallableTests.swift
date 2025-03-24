import XCTest
#if canImport(FoundationNetworking)
// Provided for `URL` related objects on Linux platforms.
import FoundationNetworking
#endif
@testable import Callable


final class CallableTests: XCTestCase {

    var testJSONPath: String? {
        Bundle.main.path(forResource: "Test", ofType: "json")
    }

    var testJSONURL: URL? {
        testJSONPath.map { URL(fileURLWithPath: $0) }
    }

    func testCallCodable() {
        let expectation: XCTestExpectation = self.expectation(description: "call")
        DispatchQueue(label: "call", qos: .background).async { 
            "https://api.publicapis.org/entries".url?.callCodable { (list: APIs?) in
                XCTAssertNotNil(list)
                if let list = list {
                    XCTAssertGreaterThan(list.entries.count, 1)
                } else {
                    XCTFail()
                }
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 4, handler: nil)
    }


    func testCallJSON() {
        let expectation: XCTestExpectation = self.expectation(description: "call")
        DispatchQueue(label: "call", qos: .background).async {
            "https://api.publicapis.org/entries".url?.callJSON { json in
                XCTAssertNotNil(json)
                XCTAssertGreaterThan(json.keys.count, 1)
                XCTAssertGreaterThan(json.values.count, 1)
                expectation.fulfill()
            }
        }
        waitForExpectations(timeout: 4, handler: nil)
    }

    static var allTests = [
        ("testCallCodable", testCallCodable),
        ("testCallJSON", testCallJSON),
    ]
}
