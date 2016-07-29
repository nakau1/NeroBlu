// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - Array拡張 -
extension Array {
    
    /// 最初の要素のインデックス
    public var firstIndex: Int? {
        return self.indices.first
    }
    
    /// 最後の要素のインデックス
    public var lastIndex: Int? {
        return self.indices.last
    }
    
    /// 配列内からランダムに要素を取り出す
    ///
    /// 要素が空の場合はnilを返す
    public var random: Element? {
        guard let min = self.firstIndex, let max = self.lastIndex else { return nil }
        let index = Int.random(min: min, max: max)
        return self[index]
    }
    
    /// 新しい要素を足した配列を返す
    /// - note: 元の配列自身の要素は変わりません。その用途の場合は appendメソッドを使います
    /// - parameter e: 要素
    /// - returns: 要素を足した配列(元の配列自身は変わりません)
    public func add(e: Element) -> Array<Element> {
        return self + [e]
    }
    
    /// 新しい要素を足した配列を返す
    /// - note: 元の配列自身の要素は変わりません。その用途の場合は appendメソッドを使います
    /// - parameter e: 要素
    /// - returns: 要素を足した配列(元の配列自身は変わりません)
    public func add(e: [Element]) -> Array<Element> {
        return self + e
    }
}

// MARK: - Dictionary拡張 -
public extension Dictionary {
    
    /// 渡された辞書を自身にマージする(自身を書き換えます)
    /// - parameter dictionary: マージする辞書
    public mutating func merge(dictionary dic: Dictionary) {
        dic.forEach { self.updateValue($1, forKey: $0) }
    }
    
    /// 渡された辞書を自身にマージした新しい辞書を取得する(自身は書き換わりません)
    /// - parameter dictionary: マージする辞書
    /// - returns: 新しい辞書オブジェクト
    public func merged(dictionary dic: Dictionary) -> Dictionary {
        var ret = self
        dic.forEach { ret.updateValue($1, forKey: $0) }
        return ret
    }
}

// MARK: - flatMap拡張 -
public protocol NBSequenceOptionalType {
    
    associatedtype T
    
    var optionalValue: T? { get }
}

extension Optional: NBSequenceOptionalType {
    
    public var optionalValue: Wrapped? { return self }
}

public extension SequenceType where Generator.Element: NBSequenceOptionalType {
    
    /// nilを取り除いた非オプショナルなコレクション
    public var flatten: [Generator.Element.T] {
        return self.flatMap { $0.optionalValue }
    }
}
