// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

/// エラーオブジェクトを簡易的に作成する
/// - parameter message: エラーメッセージ
/// - parameter code: エラーコード
/// - parameter domain: エラードメイン
/// - returns: エラーオブジェクト
public func Error(message: String, _ code: Int = -1, _ domain: String = "") -> NSError {
    return NSError(domain: domain, code: code, userInfo: [NSLocalizedDescriptionKey: message])
}

// MARK: - NSError拡張 -
public extension NSError {
    
    /// エラーメッセージ
    public var message: String {
        guard let ret = self.userInfo[NSLocalizedDescriptionKey] as? String else {
            return ""
        }
        return ret
    }
}

// MARK: - プロトコル: NBErrorRaisable -
public protocol NBErrorRaisable {
    
    /// エラーオブジェクト
    var error: NSError? { get }
    
    /// クラス名
    var className: String { get }

    /// エラーオブジェクトを自身にセットする
    /// - parameter error: エラーエラーオブジェクト
    func raiseError(error: NSError?)
}
public extension NBErrorRaisable {
    
    /// エラーオブジェクトを作成する
    /// - parameter message: エラーメッセージ
    /// - parameter code: エラーコード
    /// - returns: エラーオブジェクト
    public func createError(message: String, code: Int = -1) -> NSError {
        return Error(message, code, "\( self.className )ErrorDomain")
    }
    
    /// エラーオブジェクトを自身にセットする
    /// - parameter message: エラーメッセージ
    /// - parameter code: エラーコード
    public func raiseError(message: String, code: Int = -1) {
        self.raiseError(self.createError(message, code: code))
    }
    
    /// 今現在セットされているエラーオブジェクトを破棄する
    public func resetError() {
        self.raiseError(nil)
    }
}
