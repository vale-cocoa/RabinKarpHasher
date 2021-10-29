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

/// A hasher which provides rolling functionality as per Robin-Karp fingerprint algorithm.
public struct RabinKarpHasher<C: BidirectionalCollection>: Equatable where C.Iterator.Element == UInt8 {
    /// The bidirectional collection of bytes this rolling hasher is hashing.
    public let bytes: C
    
    /// The modulo value this rolling hasher uses for calculating its rolling hash value.
    public let q: Int
    
    /// The reminder value this rolling hasher uses for rolling its hash value.
    public let rm: Int
    
    /// The range of the bytes collection the current rolling hash value is referred to.
    public fileprivate(set) var range: Range<C.Index>
    
    /// The actual rolling hash value for this rolling hasher. This value is calculated
    /// on the bytes colletion at the actual range value.
    public private(set) var rollingHashValue: Int
    
    /// Create a new rolling hasher, hashing the specified bytes in the current range
    /// adopting the given `q` modulo value.
    ///
    /// - Parameter bytes:  A bidirectional collection of bytes to hash.
    /// - Parameter range:  A range expression relative to the given bytes,
    ///                     which would be the intial range of bytes to use from the given ones
    ///                     for calculating the intial hash value.
    /// - Parameter q:  The modulo value to use for hashing.
    ///                 **Must be greater than 0**.
    /// - Precondition: `q` must be greater than 0.
    /// - Warning: For better hashing quality, `q` should be a large prime number.
    public init<R: RangeExpression>(_ bytes: C, range: R, q: Int) where R.Bound == C.Index {
        precondition(q > 0)
        
        let r = range.relative(to: bytes)
        self.bytes = bytes
        self.range = r
        self.q = q
        let length = bytes.distance(from: r.lowerBound, to: r.upperBound)
        self.rm = Self._rm(for: length, q: q)
        self.rollingHashValue = Self._rollableHashValue(bytes[r], q: q)
    }
    
    /// Rolls forward the current rolling  hash value of this rolling hasher,
    /// by advancing one position the current range for the bytes collection.
    /// In case the current range has already reached the 
    ///
    /// - Complexity: O(1)
    public mutating func rollHashValue() {
        guard
            !range.isEmpty,
            range.upperBound < bytes.endIndex
        else { return }
        
        defer {
            let lo = bytes.index(after: range.lowerBound)
            let up = bytes.index(after: range.upperBound)
            range = lo..<up
        }
        let loByte = bytes[range.lowerBound]
        let hiByte = bytes[bytes.index(before: range.upperBound)]
        rollingHashValue = (rollingHashValue + q - rm * Int(loByte) % q) % q
        rollingHashValue = (rollingHashValue * Self._r + Int(hiByte)) % q
    }
    
    // MARK: - Equatable conformance
    public static func == (lhs: RabinKarpHasher<C>, rhs: RabinKarpHasher<C>) -> Bool {
        lhs.rollingHashValue == rhs.rollingHashValue && lhs.rm == rhs.rm && lhs.q == rhs.q
    }
    
}

extension RabinKarpHasher {
    fileprivate static var _r: Int { 256 }
    
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
    
}



