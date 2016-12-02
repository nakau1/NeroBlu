// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - Bool拡張 -
public extension Bool {
    
    /// 自身の真偽を反転させる(自身の値が変わる)
    mutating public func reverse() -> Bool {
        self = !self
        return self
    }
    
    /// 自身の真偽を反転させた値を返す(自身の値は変わらない)
    public var reversed: Bool { return !self }
}

// MARK: - CGFloat拡張 -
public extension CGFloat {
    
    /// 様々な数値をCGFloatに変換する
    /// - parameter number: 数値(整数、ダブル/フロート値、数字文字列)
    /// - returns: CGFloat値(変換できない場合は0を返す)
    public static func cast<T>(_ number: T) -> CGFloat {
        if      let v = number as? CGFloat { return v }
        else if let v = number as? Int     { return CGFloat(v) }
        else if let v = number as? Int8    { return CGFloat(v) }
        else if let v = number as? Int16   { return CGFloat(v) }
        else if let v = number as? Int32   { return CGFloat(v) }
        else if let v = number as? Int64   { return CGFloat(v) }
        else if let v = number as? Double  { return CGFloat(v) }
        else if let v = number as? Float   { return CGFloat(v) }
        else if let v = number as? String, let d = Double(v) {
            return CGFloat(d)
        }
        else { return 0 }
    }
}

public extension CGFloat {
    
    /// Intにキャストした値
    public var int: Int { return Int(self) }
    
    /// Floatにキャストした値
    public var float: Float { return Float(self) }
    
    /// Doubleにキャストした値
    public var double: Double { return Double(self) }
    
    /// 文字列にキャストした値
    public var string: String { return "\(self)" }
}

// MARK: - Int拡張 -
public extension Int {
    
    /// 指定した範囲の中から乱数を取得する
    /// - parameter min: 最小値
    /// - parameter max: 最大値
    /// - returns: 乱数
    public static func random(min n: Int, max x: Int) -> Int {
        let min = n < 0 ? 0 : n
        let max = x + 1
        let v = UInt32(max < min ? 0 : max - min)
        let r = Int(arc4random_uniform(v))
        return min + r
    }
    
    /// 指定した範囲の中から乱数を取得する
    /// - parameter range: 範囲
    /// - returns: 乱数
    public static func random(_ range: Range<Int>) -> Int {
        return random(min: range.lowerBound, max: range.upperBound)
    }
    
    /// 3桁区切りにフォーマットされた文字列
    public var formatted: String {
        let fmt = NumberFormatter()
        fmt.numberStyle       = .decimal
        fmt.groupingSeparator = ","
        fmt.groupingSize      = 3
        return fmt.string(from: NSNumber(integerLiteral: self)) ?? ""
    }
}

public extension Int {

    /// CGFloatにキャストした値
    public var f: CGFloat { return CGFloat(self) }
    
    /// Floatにキャストした値
    public var float: Float { return Float(self) }
    
    /// Doubleにキャストした値
    public var double: Double { return Double(self) }
    
    /// 文字列にキャストした値
    public var string: String { return "\(self)" }
}

// MARK: - Float拡張(キャスト) -
public extension Float {

    /// CGFloatにキャストした値
    public var f: CGFloat { return CGFloat(self) }
    
    /// Intにキャストした値
    public var int: Int { return Int(self) }
    
    /// Doubleにキャストした値
    public var double: Double { return Double(self) }
    
    /// 文字列にキャストした値
    public var string: String { return "\(self)" }
}

// MARK: - Double拡張(キャスト) -
public extension Double {
    
    /// CGFloatにキャストした値
    public var f: CGFloat { return CGFloat(self) }
    
    /// Intにキャストした値
    public var int: Int { return Int(self) }
    
    /// Floatにキャストした値
    public var float: Float { return Float(self) }
    
    /// 文字列にキャストした値
    public var string: String { return "\(self)" }
}

