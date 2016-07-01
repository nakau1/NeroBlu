// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - NBResult -

/// 汎用的な結果ステータス
public enum NBResult {
    
    /// 未実行状態(初期状態)
    case None
    /// 成功
    case Succeed
    /// 失敗
    case Failed(NSError)
    /// キャンセル
    case Cancelled
    
    /// エラーオブジェクト(.Failedの場合だけ取得できる)
    public var error: NSError? { switch self { case let .Failed(err): return err default: return nil } }
    
    /// 成功/失敗(.Succeedの場合だけtrueになる)
    public var succeed: Bool { switch self { case .Succeed: return true default: return false } }
    
    /// 失敗状態かどうか(.Failedの場合だけtrueになる)
    public var failed: Bool { return (self.error != nil) }
    
    /// キャンセルしたかどうか(.Cancelledの場合だけtrueになる)
    public var cancelled: Bool { switch self { case .Cancelled: return true default: return false } }
    
    /// 実行したかどうか(.Noneの場合だけfalseになる)
    public var done: Bool { switch self { case .None: return false default: return true } }
}


// MARK: - プロトコル: NBResultable -

/// 結果を抱え込むオブジェクトとして振る舞うプロトコル
public protocol NBResultable {
    
    /// 結果
    var result: NBResult? { get }
}
