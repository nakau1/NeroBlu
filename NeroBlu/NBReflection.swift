// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - NBReflection -

/// クラス情報を取り扱うクラス
public class NBReflection {
    
}

// MARK: - NBReflection拡張 (クラス -> 文字列) -
extension NBReflection {
    
    /// 引数の値のクラス名を返却する
    /// - parameter target: 対象の値
    /// - returns: クラス名
    public static func className(target: Any) -> String {
        return self.className(target, needsFullName: false)
    }
    
    /// 引数の値のパッケージ名(名前空間)+クラス名を返却する
    /// - parameter target: 対象の値
    /// - returns: "パッケージ名(名前空間).クラス名"形式の文字列
    public static func classNameWithPackage(target: Any) -> String {
        return self.className(target, needsFullName: true)
    }
    
    /// 引数の値のパッケージ名(名前空間)を返却する
    /// - parameter target: 対象の値
    /// - returns: パッケージ名(名前空間)
    public static func packageName(target: Any) -> String {
        let full  = self.className(target, needsFullName: true)
        let short = self.className(target, needsFullName: false)
        
        if let range = full.rangeOfString(".\(short)") where full != short {
            return full.substringToIndex(range.startIndex)
        }
        return ""
    }
}

// MARK: - NBReflection拡張 (プライベート) -
extension NBReflection {
    
    private static func className(target: Any, needsFullName full: Bool) -> String {
        guard let cls = self.fetchClass(target: target) else { return "" }
        
        let fullName = NSStringFromClass(cls)
        if full { return fullName }
        
        if let shortName = fullName.componentsSeparatedByString(".").last {
            return shortName
        }
        return ""
    }
    
    private static func fetchClass(target target: Any) -> AnyClass? {
        if let cls = target as? AnyClass {
            return cls
        } else if let obj = target as? AnyObject {
            return obj.dynamicType
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
