// =============================================================================
// NBRealm
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - NSPredicate拡張: イニシャライザ(ID) -
public extension NSPredicate {
    
    /// イニシャライザ
    /// - parameter ids: IDの配列
    /// - parameter q: 検索文字列
    public convenience init(ids: [Int64]) {
        let arr = ids.map { NSNumber(value: $0 as Int64) }
        self.init(format: "\(NBRealmEntity.IDKey) IN %@", argumentArray: [arr])
    }
    
    /// イニシャライザ
    /// - parameter id: ID
    public convenience init(id: Int64) {
        self.init(format: "\(NBRealmEntity.IDKey) = %@", argumentArray: [NSNumber(value: id as Int64)])
    }
}

// MARK: - NSPredicate拡張: イニシャライザ(式) -
public extension NSPredicate {
    
    fileprivate convenience init(expression property: String, _ operation: String, _ value: AnyObject) {
        self.init(format: "\(property) \(operation) %@", argumentArray: [value])
    }
    
    /// イニシャライザ
    /// - remark: "プロパティ = 値" の条件を作成します
    /// - parameter property: プロパティ(フィールド)名
    /// - parameter value: 値
    /// - seealso: [NSPredicate Cheatsheet](https://realm.io/news/nspredicate-cheatsheet/)
    public convenience init(_ property: String, equal value: AnyObject) {
        self.init(expression: property, "=", value)
    }
    
    /// イニシャライザ
    /// - remark: "プロパティ != 値" の条件を作成します
    /// - parameter property: プロパティ(フィールド)名
    /// - parameter value: 値
    /// - seealso: [NSPredicate Cheatsheet](https://realm.io/news/nspredicate-cheatsheet/)
    public convenience init(_ property: String, notEqual value: AnyObject) {
        self.init(expression: property, "!=", value)
    }
    
    /// イニシャライザ
    /// - remark: "プロパティ >= 値" の条件を作成します
    /// - parameter property: プロパティ(フィールド)名
    /// - parameter value: 値
    /// - seealso: [NSPredicate Cheatsheet](https://realm.io/news/nspredicate-cheatsheet/)
    public convenience init(_ property: String, equalOrGreaterThan value: AnyObject) {
        self.init(expression: property, ">=", value)
    }
    
    /// イニシャライザ
    /// - remark: "プロパティ <= 値" の条件を作成します
    /// - parameter property: プロパティ(フィールド)名
    /// - parameter value: 値
    /// - seealso: [NSPredicate Cheatsheet](https://realm.io/news/nspredicate-cheatsheet/)
    public convenience init(_ property: String, equalOrLessThan value: AnyObject) {
        self.init(expression: property, "<=", value)
    }
    
    /// イニシャライザ
    /// - remark: "プロパティ > 値" の条件を作成します
    /// - parameter property: プロパティ(フィールド)名
    /// - parameter value: 値
    /// - seealso: [NSPredicate Cheatsheet](https://realm.io/news/nspredicate-cheatsheet/)
    public convenience init(_ property: String, greaterThan value: AnyObject) {
        self.init(expression: property, ">", value)
    }
    
    /// イニシャライザ
    /// - remark: "プロパティ < 値" の条件を作成します
    /// - parameter property: プロパティ(フィールド)名
    /// - parameter value: 値
    /// - seealso: [NSPredicate Cheatsheet](https://realm.io/news/nspredicate-cheatsheet/)
    public convenience init(_ property: String, lessThan value: AnyObject) {
        self.init(expression: property, "<", value)
    }
}

// MARK: - NSPredicate拡張: イニシャライザ(文字列検索) -
public extension NSPredicate {
    
    /// イニシャライザ
    /// - remark: あいまい文字列検索を行うための検索条件(LIKE検索)で初期化します\
    ///           文字列がどこかに含まれていればヒットします
    /// - warning: property は String型のフィールドである必要があります
    /// - parameter property: プロパティ(フィールド)名
    /// - parameter value: 値
    /// - seealso: [NSPredicate Cheatsheet](https://realm.io/news/nspredicate-cheatsheet/)
    public convenience init(_ property: String, contains q: String) {
        self.init(format: "\(property) CONTAINS '\(q)'")
    }
    
    /// イニシャライザ
    /// - remark: あいまい文字列検索を行うための検索条件(LIKE検索)で初期化します\
    ///           文字列が先頭に含まれていればヒットします
    /// - warning: property は String型のフィールドである必要があります
    /// - parameter property: プロパティ(フィールド)名
    /// - parameter value: 値
    /// - seealso: [NSPredicate Cheatsheet](https://realm.io/news/nspredicate-cheatsheet/)
    public convenience init(_ property: String, beginsWith q: String) {
        self.init(format: "\(property) BEGINSWITH '\(q)'")
    }
    
    /// イニシャライザ
    /// - remark: あいまい文字列検索を行うための検索条件(LIKE検索)で初期化します\
    ///           文字列が末尾に含まれていればヒットします
    /// - warning: property は String型のフィールドである必要があります
    /// - parameter property: プロパティ(フィールド)名
    /// - parameter value: 値
    /// - seealso: [NSPredicate Cheatsheet](https://realm.io/news/nspredicate-cheatsheet/)
    public convenience init(_ property: String, endsWith q: String) {
        self.init(format: "\(property) ENDSWITH '\(q)'")
    }
}

// MARK: - NSPredicate拡張: イニシャライザ(IN句) -
public extension NSPredicate {
    
    /// イニシャライザ
    /// - remark: IN句検索条件で初期化します
    /// - parameter property: プロパティ(フィールド)名
    /// - parameter values: 値の配列
    /// - seealso: [NSPredicate Cheatsheet](https://realm.io/news/nspredicate-cheatsheet/)
    public convenience init(_ property: String, valuesIn values: [AnyObject]) {
        self.init(format: "\(property) IN %@", argumentArray: [values])
    }
}

// MARK: - NSPredicate拡張: イニシャライザ(BETWEEN句) -
public extension NSPredicate {
    
    /// イニシャライザ
    /// - remark: BETWEEN句検索条件で初期化します
    /// - parameter property: プロパティ(フィールド)名
    /// - parameter between: 最小値
    /// - parameter to: 最大値
    /// - seealso: [NSPredicate Cheatsheet](https://realm.io/news/nspredicate-cheatsheet/)
    public convenience init(_ property: String, between min: AnyObject, to max: AnyObject) {
        self.init(format: "\(property) BETWEEN {%@, %@}", argumentArray: [min, max])
    }
    
    /// イニシャライザ
    /// - remark: 日時の範囲の条件で初期化します
    /// - warning: property は Date(NSDate)型のフィールドである必要があります\
    ///            fromDate と toDate 両方に nil を渡すことは好ましくありません
    /// - parameter property: プロパティ(フィールド)名
    /// - parameter fromDate: From日時
    /// - parameter toDate: To日時
    /// - seealso: [NSPredicate Cheatsheet](https://realm.io/news/nspredicate-cheatsheet/)
    public convenience init(_ property: String, fromDate: Date?, toDate: Date?) {
        var format = "", args = [AnyObject]()
        if let from = fromDate {
            format += "\(property) >= %@"
            args.append(from as AnyObject)
        }
        if let to = toDate {
            if !format.isEmpty {
                format += " AND "
            }
            format += "\(property) <= %@"
            args.append(to as AnyObject)
        }
        if !args.isEmpty {
            self.init(format: format, argumentArray: args)
        } else {
            self.init(value: true)
        }
    }
}

// MARK: - NSPredicate拡張: イニシャライザ(nil比較) -
public extension NSPredicate {
    
    /// イニシャライザ
    /// - remark: nilかどうかの比較条件で初期化します
    /// - parameter property: プロパティ(フィールド)名
    /// - seealso: [NSPredicate Cheatsheet](https://realm.io/news/nspredicate-cheatsheet/)
    public convenience init(isNil property: String) {
        self.init(format: "\(property) == nil", argumentArray: nil)
    }
    
    /// イニシャライザ
    /// - remark: nilでないかどうかの比較条件で初期化します
    /// - parameter property: プロパティ(フィールド)名
    /// - seealso: [NSPredicate Cheatsheet](https://realm.io/news/nspredicate-cheatsheet/)
    public convenience init(isNotNil property: String) {
        self.init(format: "\(property) != nil", argumentArray: nil)
    }
}

// MARK: - NSPredicate拡張: イニシャライザ(集計用) -
public extension NSPredicate {
    
    /// ANY句を加えた条件を返す
    /// - property　of: オブジェクト名
    /// - seealso: [NSPredicate Cheatsheet](https://realm.io/news/nspredicate-cheatsheet/)
    public func any(of objectName: String) -> NSPredicate {
        let format = "ANY \(objectName)." + self.predicateFormat
        return NSPredicate(format: format)
    }
}

// MARK: - NSPredicate拡張: コンパウンド(条件結合) -
public extension NSPredicate {
    
    /// 空の条件を返す
    /// - note: 実際には常にTRUEとなるNSPredicateを返します
    public static var empty: NSPredicate { return NSPredicate(value: true) }
    
    /// 常にFALSEとなるNSPredicateを返す
    public static var dead: NSPredicate { return NSPredicate(value: false) }
    
    /// AND条件結合したNSPredicateを返す
    /// - parameter predicates: NSPredicateの配列
    /// - returns: 条件結合したNSPredicate
    public func and(_ predicate: NSPredicate) -> NSPredicate {
        return self.compound([predicate], type: .and)
    }
    
    /// OR条件結合したNSPredicateを返す
    /// - parameter predicates: NSPredicateの配列
    /// - returns: 条件結合したNSPredicate
    public func or(_ predicate: NSPredicate) -> NSPredicate {
        return self.compound([predicate], type: .or)
    }
    
    /// 条件結合したNSPredicateを返す
    /// - parameter predicates: NSPredicateの配列
    /// - returns: 条件結合したNSPredicate
    public func not(_ predicate: NSPredicate) -> NSPredicate {
        return self.compound([predicate], type: .not)
    }
    
    /// 条件結合したNSPredicateを返す
    /// - parameter predicates: NSPredicateの配列
    /// - parameter type: 結合の種別
    /// - returns: 条件結合したNSPredicate
    public func compound(_ predicates: [NSPredicate], type: NSCompoundPredicate.LogicalType = .and) -> NSPredicate {
        var p = predicates; p.insert(self, at: 0)
        switch type {
        case .and: return NSCompoundPredicate(andPredicateWithSubpredicates: p)
        case .or:  return NSCompoundPredicate(orPredicateWithSubpredicates:  p)
        case .not: return NSCompoundPredicate(notPredicateWithSubpredicate:  self.compound(p))
        }
    }
}