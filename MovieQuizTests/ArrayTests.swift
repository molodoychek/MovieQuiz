import XCTest
@testable import MovieQuiz

final class ArrayTests: XCTestCase {
    
    func testGetValueInRange() {
        // Given
        let array = [1, 2, 3, 4, 5]
        
        // When
        let value = array.safe(at: 2)
        
        // Then
        XCTAssertNotNil(value)
        XCTAssertEqual(value, 3)
    }
    
    func testGetValueOutOfRange() {
        // Given
        let array = [1, 2, 3, 4, 5]
        
        // When
        let value = array.safe(at: 20)
        
        // Then
        XCTAssertNil(value)
    }
    
    func testGetValueWithNegativeIndex() {
        // Given
        let array = [1, 2, 3, 4, 5]
        
        // When
        let value = array.safe(at: -1)
        
        // Then
        XCTAssertNil(value)
    }
    
    func testEmptyArray() {
        // Given
        let array: [Int] = []
        
        // When
        let value = array.safe(at: 0)
        
        // Then
        XCTAssertNil(value)
    }
    
    func testStringArraySafeAccess() {
        // Given
        let array = ["apple", "banana", "cherry"]
        
        // When
        let value = array.safe(at: 1)
        
        // Then
        XCTAssertEqual(value, "banana")
    }
}
