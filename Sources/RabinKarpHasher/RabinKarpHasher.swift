//
//  RabinKarpHasher.swift
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

public struct RabinKarpHasher: Equatable {
    fileprivate let _q: Int
    
    fileprivate let _rm: Int
    
    public private(set) var hashValue: Int
    
    public init<C:Collection>(_ bytes: C, q: Int) where C.Iterator.Element == UInt8 {
        precondition(q > 0, "q must be greater than 0")
        assert(Seeder._isPrime(q), "q must be prime")
        
        let rm = Self._rm(for: bytes.count, q: q)
        let hashValue = Self._rollableHashValue(bytes, q: q)
        
        self.init(hashValue: hashValue, q: q, rm: rm)
    }
    
    public mutating func rollHashValue(loByte: UInt8, hiByte: UInt8) {
        hashValue = (hashValue + _q - _rm * Int(loByte) % _q) % _q
        hashValue = (hashValue * Self._r + Int(hiByte)) % _q
    }
    
}

extension RabinKarpHasher {
    fileprivate static let _r = 257
    
    fileprivate static func _rollableHashValue<S: Sequence>(_ bytes: S, q: Int) -> Int where S.Iterator.Element == UInt8 {
        
        return bytes
            .reduce(0, { (_r * $0 + Int($1)) % q })
    }
    
    fileprivate static func _rm(for lenght: Int, q: Int) -> Int {
        guard lenght > 0 else { return 0 }
        
        var rm = 1
        for _ in 1..<lenght {
            rm = (rm * _r) % q
        }
        
        return rm
    }
    
    fileprivate init(hashValue: Int, q: Int, rm: Int) {
        self.hashValue = hashValue
        
        self._q = q
        
        self._rm = rm
    }
    
}



