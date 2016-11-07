// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - NBReflection -

/// クラス情報を取り扱うクラス
open class NBReflection {
    
}

// MARK: - NBReflection拡張 (クラス -> 文字列) -
extension NBReflection {
    
    /// 引数の値のクラス名を返却する
    /// - parameter target: 対象の値
    /// - returns: クラス名
    public static func className(_ target: Any) -> String {
        return self.className(target, needsFullName: false)
    }
    
    /// 引数の値のパッケージ名(名前空間)+クラス名を返却する
    /// - parameter target: 対象の値
    /// - returns: "パッケージ名(名前空間).クラス名"形式の文字列
    public static func classNameWithPackage(_ target: Any) -> String {
        return self.className(target, needsFullName: true)
    }
    
    /// 引数の値のパッケージ名(名前空間)を返却する
    /// - parameter target: 対象の値
    /// - returns: パッケージ名(名前空間)
    public static func packageName(_ target: Any) -> String {
        let full  = self.className(target, needsFullName: true)
        let short = self.className(target, needsFullName: false)
        
        if let range = full.range(of: ".\(short)"), full != short {
            return full.substring(to: range.lowerBound)
        }
        return ""
    }
}

// MARK: - NBReflection拡張 (プライベート) -
extension NBReflection {
    
    fileprivate static func className(_ target: Any, needsFullName full: Bool) -> String {
        guard let cls = self.fetchClass(target: target) else { return "" }
        
        let fullName = NSStringFromClass(cls)
        if full { return fullName }
        
        if let shortName = fullName.components(separatedBy: ".").last {
            return shortName
        }
        return ""
    }
    
    fileprivate static func fetchClass(target: Any) -> AnyClass? {
        if let cls = target as? AnyClass {
            return cls
        } else if let obj = target as? AnyObject {
            return type(of: obj)
        } else {
            return nil
        }
    }
}

// MARK: - NSObject拡張 -
public extension NSObject {
    
    // MARK: インスタンスメソッド
    
    /// クラス名を返却する
    public var className: String {
        return NBReflection.className(self)
    }
    
    /// "パッケージ名(名前空間).クラス名"形式の文字列を返却する
    public var classNameWithPackage: String {
        return NBReflection.classNameWithPackage(self)
    }
    
    /// パッケージ名(名前空間)を返却する
    public var packageName: String {
        return NBReflection.packageName(self)
    }
    
    // MARK: クラスメソッド
    
    /// クラス名を返却する
    public static var className: String {
        return NBReflection.className(self)
    }
    
    /// "パッケージ名(名前空間).クラス名"形式の文字列を返却する
    public static var classNameWithPackage: String {
        return NBReflection.classNameWithPackage(self)
    }
    
    /// パッケージ名(名前空間)を返却する
    public static var packageName: String {
        return NBReflection.packageName(self)
    }
}
