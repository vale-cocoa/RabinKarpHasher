//
//  LargePrimesTests.swift
//  RabinKarpHasherTests
//
//  Created by Valeriano Della Longa on 2021/10/29.
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

final class LargePrimesTests: XCTestCase {
    func testIsPrime_whenIsNotPrime_thenReturnsFalse() {
        XCTAssertFalse(LargePrimes.isPrime(9))
    }
    
    func testIsPrime_whenIsPrime_thenReturnsTrue() {
        XCTAssertTrue(LargePrimes.isPrime(17))
    }
    
    func testRandomLargePrime() {
        let q = LargePrimes.randomLargePrime()
        XCTAssertTrue(1_000_000_000..<10_000_000_000 ~= q, "\(q) is not of 10⁹ magnitude")
        
        let l = Int(Double(q).squareRoot())
        for div in 2...l where q % div == 0 {
            XCTFail("\(q) is not prime, cause is divisible by \(div)")
            
            return
        }
    }
    
    func testPerformance() {
        measure {
            let _ = LargePrimes.randomLargePrime()
        }
    }
    
}
