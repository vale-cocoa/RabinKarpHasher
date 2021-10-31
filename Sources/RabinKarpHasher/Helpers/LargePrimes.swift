//
//  LargePrimes.swift
//  RabinKarpHasher
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

import Foundation

/// Utilityr to get randomly generated large prime numbers with a 10⁹ magnitude,
/// and also for testing if an int value is a prime number.
public enum LargePrimes {
    private static let _cache: NSCache<NSNumber, NSNumber> = {
        let cache = NSCache<NSNumber, NSNumber>()
        cache.name = "com.vdl.largePrimes"
        
        return cache
    }()
    
    private static let _range = 1_000_000_000..<10_000_000_000
    
    /// Check if the specified int value `n` is a prime number.
    ///
    /// - Parameter n: An int value to check if it's a prime number.
    /// - Returns:  A boolean value: `true` if the specified `n` int value is a  prime number,
    ///             otherwise `false`.
    /// - Complexity: O(*n*) where *n* is the length of `n`.
    public static func isPrime(_ n: Int) -> Bool {
        guard n >= 2 else { return false }
        
        guard
            let cached = _cache.object(forKey: n as NSNumber)
        else {
            let result = (2...Int(Double(n).squareRoot())).lazy.filter({ n % $0 == 0 }).first == nil
            defer { _cache.setObject(result as NSNumber, forKey: n as NSNumber) }
            
            return result
        }
        
        return (cached as NSNumber).boolValue
    }
    
    /// Get randomly a large prime number of 10⁹ magnitude.
    ///
    /// - Returns: An int value of 10⁹ magnitude that is also prime.
    /// - Complexity: O(10.000.000.000 - *n*) at worst, where *n* is the number of prime
    ///               numbers of 10⁹ magnitude.
    public static func randomLargePrime() -> Int {
        while true {
            let q = Int.random(in: _range)
            if let cached = _cache.object(forKey: q as NSNumber) {
                if cached.boolValue == true {
                    return q
                } else { continue }
            }
            guard
                isPrime(q)
            else {
                _cache.setObject(false as NSNumber, forKey: q as NSNumber)
                
                continue
            }
            defer {
                _cache.setObject(true as NSNumber, forKey: q as NSNumber)
            }
            
            return q
        }
    }
    
}
