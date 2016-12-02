// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - 共通typealias -

/// 引数・戻り値を持たないクロージャ
public typealias VoidClosure = () -> ()

/// 処理完了時のハンドラクロージャ
public typealias CompletionHandler = VoidClosure

/// 処理完了時のハンドラクロージャ(オプショナルのエラー付き)
public typealias CompletionHandlerWithError = (NSError?) -> ()

/// 処理完了時のハンドラクロージャ(結果ステータス付き)
public typealias CompletionHandlerWithResult = (NBResult) -> ()

/// オプショナルの値も渡せるprint関数
/// - parameter items: 値(可変長引数)
/// - parameter separator: セパレータ文字
/// - parameter terminator: 終了文字
public func print(_ items: Any?..., separator: String = ", ", terminator: String = "\n") {
    for (i, item) in items.enumerated() {
        let t = (i == items.lastIndex!) ? terminator : separator
        print(item ?? NSNull(), terminator: t)
    }
}
