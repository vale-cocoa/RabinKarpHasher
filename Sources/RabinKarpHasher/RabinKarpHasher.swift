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
    public var range: Range<C.Index> {
        let upperBound = bytes.index(_lo, offsetBy: _length, limitedBy: bytes.endIndex) ?? bytes.endIndex
        
        return _lo..<upperBound
    }
    
    /// The actual rolling hash value for this rolling hasher. This value is calculated
    /// on the bytes colletion at the actual range value.
    public private(set) var rollingHashValue: Int
    
    fileprivate var _lo: C.Index
    
    fileprivate var _length: Int
    
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
        self._length = bytes.distance(from: r.lowerBound, to: r.upperBound)
        self._lo = r.lowerBound
        self.rm = Self._rm(for: self._length, q: q)
        self.rollingHashValue = Self._rollableHashValue(bytes[r], q: q)
    }
    
    /// Rolls forward the current rolling  hash value of this rolling hasher,
    /// by advancing one position the current range for the bytes collection.
    /// In case the current range has already reached the 
    ///
    /// - Complexity: O(1)
    public mutating func rollHashValue() {
        guard
            _length > 0,
            let _hi = bytes.index(_lo, offsetBy: _length, limitedBy: bytes.endIndex),
            _hi < bytes.endIndex
        else { return }
        
        defer {
            bytes.formIndex(after: &_lo)
        }
        let loValue = Int(bytes[_lo])
        let hiValue = Int(bytes[_hi])
        rollingHashValue = (rollingHashValue + q - rm * loValue % q) % q
        rollingHashValue = (rollingHashValue * Self._r + hiValue) % q
    }
    
    /// Check if two rolling hasher are comaprable by their rolling hash values.
    ///
    /// It make sense to compare two rolling hasher's rolling hash values only when both of them
    /// share the same `q` modulo value and calculate their rolling hash values on the same amount of bytes.
    ///  - Parameter lhs: A rolling hasher instance.
    ///  - Parameter rhs: A rolling hasher instance.
    ///  - Returns: A bool value: `true` when the two specified rolling hasher's rolling hash values can be
    ///             compared —that is when both rolling hashers shares the same `q` modulo value and
    ///             calculates their rolling hash value on the same amount of bytes—, `false` otherwise.
    /// - Complexity: O(1)
    @inlinable
    public static func areComparableByRollingHashValue(lhs: Self, rhs: Self) -> Bool {
        lhs.q == rhs.q && lhs.rm == rhs.rm
    }
    
}

// MARK: - Helpers
extension RabinKarpHasher {
    @inline(__always)
    fileprivate static var _r: Int { 256 }
    
    @inline(__always)
    fileprivate static func _rollableHashValue<S: Sequence>(_ bytes: S, q: Int) -> Int where S.Iterator.Element == UInt8 {
        
        return bytes
            .reduce(0, { (_r * $0 + Int($1)) % q })
    }
    
    @inline(__always)
    fileprivate static func _rm(for lenght: Int, q: Int) -> Int {
        guard lenght > 0 else { return 0 }
        
        var rm = 1
        for _ in 1..<lenght {
            rm = (rm * _r) % q
        }
        
        return rm
    }
    
}



