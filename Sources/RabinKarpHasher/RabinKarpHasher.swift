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
public struct RabinKarpHasher<C: Collection> where C.Iterator.Element == UInt8 {
    /// The bidirectional collection of bytes this rolling hasher is hashing.
    public let bytes: C
    
    /// The modulo value this rolling hasher uses for calculating its rolling hash value.
    public let q: Int
    
    /// The reminder value this rolling hasher uses for rolling its hash value.
    public let rm: Int
    
    /// The range of the bytes collection the current rolling hash value is referred to.
    public var range: Range<C.Index> { _lo..<_hi }
    
    /// The actual rolling hash value for this rolling hasher. This value is calculated
    /// on the bytes colletion at the actual range value.
    public private(set) var rollingHashValue: Int
    
    fileprivate var _lo: C.Index
    
    fileprivate var _hi: C.Index
    
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
        self.q = q
        let length = bytes.distance(from: r.lowerBound, to: r.upperBound)
        self._lo = r.lowerBound
        self._hi = r.upperBound
        self.rm = Self._remainder(of: length, q: q)
        self.rollingHashValue = Self._rollableHashValue(bytes[r], q: q)
    }
    
    /// Rolls forward the current rolling  hash value of this rolling hasher,
    /// by advancing one position the current range for the bytes collection.
    /// In case the current range has already reached the 
    ///
    /// - Returns:  A boolean value, `true` when the rolling of the hash value effectively took place,
    ///             otherwise `false`.
    /// - Note: The rolling hash value can be effetively rolled only if the current `range` of this rolling hasher
    ///         is not empty and has not yet reached the `endIndex` of the `bytes` collection.
    /// - Complexity: O(1)
    @discardableResult
    public mutating func rollHashValue() -> Bool {
        guard
            !range.isEmpty,
            _hi < bytes.endIndex
        else { return false }
        
        defer {
            let loValue = Int(bytes[_lo])
            let hiValue = Int(bytes[_hi])
            rollingHashValue = (rollingHashValue + q - rm * loValue % q) % q
            rollingHashValue = (rollingHashValue * Self._radix + hiValue) % q
            bytes.formIndex(after: &_lo)
            bytes.formIndex(after: &_hi)
        }
        
        return true
    }
    
    /// Checks if this rolling hash has the same hash of another one.
    ///
    /// For two rolling hashers to have the same hash they must both have the same rolling hash values,
    /// as well as the same reminder `rm` value and modulo `q` value.
    ///
    /// - Parameter other: Another rolling hasher of type `T`.
    /// - Returns:  A boolean value, `true` if the rolling hasher specified as `other`
    ///             has the same `rollingHashValue`, modulo `q` value
    ///             and reminder `rm` value of this one; `false` otherwise.
    /// - Complexity: O(1)
    public func hasSameHash<T>(of other: RabinKarpHasher<T>) -> Bool {
        other.rollingHashValue == rollingHashValue && other.q == q && other.rm == rm
    }
    
}

// MARK: - Helpers
extension RabinKarpHasher {
    @inline(__always)
    fileprivate static var _radix: Int { 256 }
    
    @inline(__always)
    fileprivate static func _rollableHashValue<S: Sequence>(_ bytes: S, q: Int) -> Int where S.Iterator.Element == UInt8 {
        
        return bytes
            .reduce(0, { (_radix * $0 + Int($1)) % q })
    }
    
    @inline(__always)
    fileprivate static func _remainder(of lenght: Int, q: Int) -> Int {
        guard lenght > 0 else { return 0 }
        
        var rm = 1
        for _ in 1..<lenght {
            rm = (rm * _radix) % q
        }
        
        return rm
    }
    
}



