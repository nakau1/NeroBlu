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
    public func add(_ e: Element) -> Array<Element> {
        return self + [e]
    }
    
    /// 新しい要素を足した配列を返す
    /// - note: 元の配列自身の要素は変わりません。その用途の場合は appendメソッドを使います
    /// - parameter e: 要素
    /// - returns: 要素を足した配列(元の配列自身は変わりません)
    public func add(_ e: [Element]) -> Array<Element> {
        return self + e
    }
    
    /// 配列の範囲内かどうかを返す
    /// - parameter index: インデックス
    /// - returns: 配列の範囲内かどうか
    public func inRange(at index: Int) -> Bool {
        guard
            let first = self.firstIndex,
            let last  = self.lastIndex
            else {
                return false
        }
        return first <= index && index <= last
    }
    
    /// 配列範囲内に収まるインデックスを返す
    /// - note: 配列に要素がない場合は-1を返す
    /// - parameter index: インデックス
    /// - returns: 引数が0未満であれば最初のインデックス、最大インデックス以上であれば最後のインデックスを返す
    public func indexInRange(for index: Int) -> Int {
        guard
            let first = self.firstIndex,
            let last  = self.lastIndex
            else {
                return -1
        }
        if index < first {
            return first
        } else if last < index {
            return last
        } else {
            return index
        }
    }
    
    /// 配列範囲内に収まる要素を返す
    /// - note: 配列に要素がない場合はnilを返す
    /// - parameter index: インデックス
    /// - returns: 引数が0未満であれば最初の要素、最大インデックス以上であれば最後の要素を返す
    public func elementInRange(for index: Int) -> Element? {
        let i = self.indexInRange(for: index)
        if i < 0 {
            return nil
        }
        return self[i]
    }
    
    /// ループさせる場合の次の配列のインデックスを取得する
    /// - note: 配列に要素がない場合は-1を返す
    /// - parameter index: インデックス
    /// - returns: 次のインデックス
    public func nextLoopIndex(of index: Int) -> Int {
        guard let last = self.lastIndex else { return -1 }
        if index + 1 > last {
            return 0
        } else {
            return index + 1
        }
    }
    
    /// ループさせる場合の前の配列のインデックスを取得する
    /// - note: 配列に要素がない場合は-1を返す
    /// - parameter index: インデックス
    /// - returns: 前のインデックス
    public func previousLoopIndex(of index: Int) -> Int {
        guard let last = self.lastIndex else { return -1 }
        if index - 1 < 0 {
            return last
        } else {
            return index - 1
        }
    }
    
    /// 指定したインデックスの要素同士の入れ替え(移動)が可能かどうかを返す
    /// - parameter from: 移動する元のインデックス
    /// - parameter to: 移動する先のインデックス
    /// - returns: 要素が入れ替え(移動)可能かどうか
    public func isExchangable(from: Int, to: Int) -> Bool {
        return self.indices.contains(from) && self.indices.contains(to)
    }
    
    /// 指定したインデックスの要素同士を入れ替える
    /// - parameter from: 移動する元のインデックス
    /// - parameter to: 移動する先のインデックス
    /// - returns: 要素が入れ替え(移動)ができたかどうか
    public mutating func exchange(from: Int, to: Int) -> Bool {
        if from == to {
            return false
        } else if !self.isExchangable(from: from, to: to) {
            return false
        }
        swap(&self[from], &self[to])
        return true
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

public extension Sequence where Iterator.Element: NBSequenceOptionalType {
    
    /// nilを取り除いた非オプショナルなコレクション
    public var flatten: [Iterator.Element.T] {
        return self.flatMap { $0.optionalValue }
    }
}
