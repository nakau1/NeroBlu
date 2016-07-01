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
