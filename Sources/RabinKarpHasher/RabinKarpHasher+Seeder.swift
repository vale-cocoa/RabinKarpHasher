//
//  RabinKarpHasher+Seeder.swift
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

extension RabinKarpHasher {
    public enum Seeder {
        private static let _cachedPrimes = NSCache<NSNumber, NSNumber>()
        
        private static let _seedRange = 1_000_000_000..<10_000_000_000
        
        static func _isPrime(_ n: Int) -> Bool {
            (2...Int(Double(n).squareRoot())).lazy.filter({ n % $0 == 0 }).first == nil
        }
        
        public static func randomPrime() -> Int {
            while true {
                let q = Int.random(in: _seedRange)
                if let cached = _cachedPrimes.object(forKey: q as NSNumber) {
                    if cached.boolValue == true {
                        return q
                    } else {
                        continue
                    }
                }
                guard
                    _isPrime(q)
                else {
                    _cachedPrimes.setObject(false as NSNumber, forKey: q as NSNumber)
                    
                    continue
                }
                
                _cachedPrimes.setObject(false as NSNumber, forKey: q as NSNumber)
            }
        }
        
    }
    
}

