//
//  RabinKarpHasherTests.swift
//  RabinKarpHasherTests
//
//  Created by Valeriano Della Longa on 2021/10/26.
//  Copyright © 2021 Valeriano Della Longa. All rights reserved.
//
//  Permission to use, copy, modify, and/or distribute this software for any
//  purpose with or without fee is hereby granted, provided that the above
//  copyright notice and this permission notice appear in all copies.
//
//  THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
//  WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
//  MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
//  SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
//  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN AN
//  ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING OUT OF OR
//  IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
//

import XCTest
@testable import RabinKarpHasher

final class RabinKarpHasherTests: XCTestCase {
    var sut: RabinKarpHasher<String.UTF8View>!
    
    var bytes: String.UTF8View!
    
    var range: Range<String.Index>!
    
    var q: Int!
    
    override func setUp() {
        super.setUp()
        
        whenBytesIsEmpty()
    }
    
    override func tearDown() {
        sut = nil
        
        super.tearDown()
    }
    
    // MARK: - When
    func whenBytesIsEmpty() {
        bytes = "".utf8
        range = bytes.startIndex..<bytes.endIndex
        q = 1
        sut = RabinKarpHasher(bytes, range: range, q: q)
    }
    
    func whenBytesIsNotEmptyAndRangeIsEmpty() {
        bytes = "findinahaystackneedle".utf8
        range = bytes.startIndex..<bytes.startIndex
        q = LargePrimes.randomLargePrime()
        sut = RabinKarpHasher(bytes, range: range, q: q)
    }
    
    func whenBytesIsNotEmptyAndRangeIsNotEmpty() {
        bytes = "findinahaystackneedle".utf8
        let lowerBound = bytes.indices.randomElement()!
        let rangeLength = Int.random(in: 1...(bytes.distance(from: lowerBound, to: bytes.endIndex)))
        let upperBound = bytes.index(lowerBound, offsetBy: rangeLength)
        range = lowerBound..<upperBound
        q = LargePrimes.randomLargePrime()
        sut = RabinKarpHasher(bytes, range: range, q: q)
    }
    
    func whenBytesIsNotEmptyAndRangeIsNotEmptyAndRangeUpperBoundIsBytesEndIndex() {
        bytes = "findinahaystackneedle".utf8
        let length = Int.random(in: 1...bytes.count)
        let lowerBound = bytes.index(bytes.endIndex, offsetBy: -length)
        range = lowerBound..<bytes.endIndex
        q = LargePrimes.randomLargePrime()
        sut = RabinKarpHasher(bytes, range: range, q: q)
    }
    
    func whenBytesIsNotEmptyAndRangeIsNotEmptyAndRangeUpperBoundIsLessThanBytesEndIndex() {
        bytes = "findinahaystackneedle".utf8
        let length = Int.random(in: 1..<bytes.count)
        let upperBound = bytes.index(bytes.startIndex, offsetBy: length)
        range = bytes.startIndex..<upperBound
        q = LargePrimes.randomLargePrime()
        sut = RabinKarpHasher(bytes, range: range, q: q)
    }
    
    // MARK: - Tests
    func testInit_whenBytesIsEmpty() {
        whenBytesIsEmpty()
        
        XCTAssertNotNil(sut)
        XCTAssertTrue(sut.bytes.elementsEqual(bytes))
        XCTAssertEqual(sut.q, q)
        XCTAssertEqual(sut.rm, 0)
        XCTAssertTrue(sut.range.isEmpty)
        XCTAssertEqual(sut.rollingHashValue, 0)
    }
    
    func testInit_whenBytesIsNotEmptyAndRangeIsEmpty() {
        whenBytesIsNotEmptyAndRangeIsEmpty()
        
        XCTAssertNotNil(sut)
        XCTAssertTrue(sut.bytes.elementsEqual(bytes))
        XCTAssertEqual(sut.q, q)
        XCTAssertEqual(sut.rm, 0)
        XCTAssertTrue(sut.range.isEmpty)
        XCTAssertEqual(sut.rollingHashValue, 0)
    }
    
    func testInit_whenBytesIsNotEmptyAndRangeIsNotEmpty() {
        whenBytesIsNotEmptyAndRangeIsNotEmpty()
        
        XCTAssertNotNil(sut)
        XCTAssertTrue(sut.bytes.elementsEqual(bytes))
        XCTAssertEqual(sut.q, q)
        XCTAssertEqual(sut.range, range)
        let expectedRollingHashValue = bytes[sut.range]
            .reduce(0, { (256 * $0 + Int($1)) % q })
        XCTAssertEqual(sut.rollingHashValue, expectedRollingHashValue)
        let rangeLenght = bytes.distance(from: range.lowerBound, to: range.upperBound)
        let expectedRM = (1..<rangeLenght).reduce(1, { result, _ in (result * 256) % q })
        XCTAssertEqual(sut.rm, expectedRM)
    }
    
    // MARK: - rollHashValue() tests
    func testRollHashValue_whenBytesIsEmpty_thenRangeAndRollingHashValueDontChange() {
        whenBytesIsEmpty()
        let prevHashValue = sut.rollingHashValue
        let prevRange = sut.range
        
        sut.rollHashValue()
        XCTAssertEqual(sut.rollingHashValue, prevHashValue)
        XCTAssertEqual(sut.range.lowerBound, prevRange.lowerBound)
        XCTAssertEqual(sut.range.upperBound, prevRange.upperBound)
    }
    
    func testRollHashValue_whenBytesIsNotEmptyAndRangeIsEmpty_thenRangeAndRollingHashValueDontChange() {
        whenBytesIsNotEmptyAndRangeIsEmpty()
        
        let prevHashValue = sut.rollingHashValue
        let prevRange = sut.range
        
        sut.rollHashValue()
        XCTAssertEqual(sut.rollingHashValue, prevHashValue)
        XCTAssertEqual(sut.range.lowerBound, prevRange.lowerBound)
        XCTAssertEqual(sut.range.upperBound, prevRange.upperBound)
    }
    
    func testRollHashValue_whenBytesIsNotEmptyAndRangeIsNotEmptyAndRangeUpperBoundIsBytesEndIndex_thenRangeAndRollingHashValueDontChange() {
        whenBytesIsNotEmptyAndRangeIsNotEmptyAndRangeUpperBoundIsBytesEndIndex()
        
        let prevHashValue = sut.rollingHashValue
        let prevRange = sut.range
        
        sut.rollHashValue()
        XCTAssertEqual(sut.rollingHashValue, prevHashValue)
        XCTAssertEqual(sut.range.lowerBound, prevRange.lowerBound)
        XCTAssertEqual(sut.range.upperBound, prevRange.upperBound)
    }
    
    func testRollHashValue_whenBytesIsNotEmptyAndRangeIsNotEmptyAndRangeUpperBoundIsLessThanBytesEndIndex_thenRangeAdvancesByOneAndRollingHashValueRollsOneByteAfter() {
        whenBytesIsNotEmptyAndRangeIsNotEmptyAndRangeUpperBoundIsLessThanBytesEndIndex()
        
        var expectedRollingHashValue = sut.rollingHashValue
        expectedRollingHashValue = (expectedRollingHashValue + q - sut.rm * Int(bytes[range.lowerBound]) % q) % q
        expectedRollingHashValue = (expectedRollingHashValue * 256 + Int(bytes[bytes.index(before: range.upperBound)])) % q
        
        sut.rollHashValue()
        XCTAssertEqual(sut.rollingHashValue, expectedRollingHashValue)
        XCTAssertEqual(sut.range.lowerBound, bytes.index(after: range.lowerBound))
        XCTAssertEqual(sut.range.upperBound, bytes.index(after: range.upperBound))
    }
    
    // MARK: - areComparableByRollingHashValues(lhs:rhs:) tests
    func testAreComparableByRollingHashValues_whenQValuesAreDifferent_thenReturnsFalse() {
        let q1 = 2
        let q2 = 7
        let bytes = "needle"
        let lhs = RabinKarpHasher(bytes.utf8, range: bytes.startIndex..., q: q1)
        let rhs = RabinKarpHasher(bytes.utf8, range: bytes.startIndex..., q: q2)
        XCTAssertFalse(RabinKarpHasher<String.UTF8View>.areComparableByRollingHashValue(lhs: lhs, rhs: rhs))
    }
    
    func testAreComparableByRollingHashValues_whenQValuesAreSameAndRMValuesAreDifferent_thenReturnsFalse() {
        let q = LargePrimes.randomLargePrime()
        let bytes = "needle"
        let lhs = RabinKarpHasher(bytes.utf8, range: bytes.startIndex..., q: q)
        let rhs = RabinKarpHasher(bytes.utf8, range: bytes.index(after: bytes.startIndex)..., q: q)
        XCTAssertFalse(RabinKarpHasher<String.UTF8View>.areComparableByRollingHashValue(lhs: lhs, rhs: rhs))
    }
    
    func testAreComparableByRollingHashValues_whenQValuesAreSameAndRMValuesAreSame_thenReturnsTrue() {
        let q = LargePrimes.randomLargePrime()
        let bytes1 = "needle"
        let bytes2 = "haystack"
        let lhs = RabinKarpHasher(bytes1.utf8, range: bytes1.startIndex..., q: q)
        let rhs = RabinKarpHasher(bytes2.utf8, range: bytes2.startIndex..<(bytes2.index(bytes2.startIndex, offsetBy: bytes1.count)), q: q)
        XCTAssertTrue(RabinKarpHasher<String.UTF8View>.areComparableByRollingHashValue(lhs: lhs, rhs: rhs))
    }
    
}
