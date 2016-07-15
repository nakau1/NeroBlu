// =============================================================================
// NerobluNetworking
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - NBNetworkResultState -

/// ネットワークリクエストの結果ステータス
public enum NBNetworkResultState {
    
    case None
    case Succeed
    case Failed(NSError)
    
    /// エラーオブジェクト(Failedの時だけ取得できる)
    public var error: NSError? { switch self { case let .Failed(err): return err default: return nil } }
    
    /// 成功かどうか
    public var succeed: Bool { switch self { case .Succeed: return true default: return false } }
    
    /// 失敗かどうか
    public var failed: Bool { switch self { case .Failed: return true default: return false } }
}

// MARK: - NBNetworkResult -

/// ネットワークリクエストの結果オブジェクトクラス
public class NBNetworkResult {
    
    /// 結果ステータス
    public internal(set) var state = NBNetworkResultState.None
    
    /// URLリクエスト
    public internal(set) var urlRequest: NSURLRequest?
    
    /// URLレスポンス
    public internal(set) var urlResponse: NSHTTPURLResponse?
    
    /// レスポンスの生データ
    public internal(set) var rowData: NSData?
    
    /// レスポンスとして返ってきた文字列(JSONの生データ等)
    /// - remark: 文字列として扱えないデータの場合はnil
    public internal(set) var rowString: String?
    
    /// HTTPステータスコード
    /// - remark: リクエストが行われないうちにエラーが発生した場合(アプリ側に問題等)は 0 を返す
    public internal(set) var statusCode = 0 // HTTP Status Code (e.g. 200 (= OK))
    
    /// MIMEタイプ
    public internal(set) var mimeType = ""
}

// MARK: 結果ステータスのラッピング
public extension NBNetworkResult {
    
    /// エラーオブジェクト(Failedの時だけ取得できる。state.errorのラッパ)
    public var error: NSError? { return self.state.error }
    
    /// 成功したかどうか(state.succeedのラッパ)
    public var succeed: Bool { return self.state.succeed }
    
    /// 失敗したかどうか(state.fialedのラッパ)
    public var fialed: Bool { return self.state.failed }
}

// MARK: デスクリプション
extension NBNetworkResult: CustomStringConvertible {
    
    public var description: String {
        var ret = "<NetworkResult"
        
        func commonDescription() -> String {
            var ret = ""
            ret += "URL:   '\( self.urlRequest?.URL?.absoluteString ?? "" )'\n"
            ret += "STATUS: \( self.statusCode )(\( NSHTTPURLResponse.localizedStringForStatusCode(self.statusCode) )), MIME-TYPE: '\( self.mimeType )' \n"
            return ret
        }
        
        switch self.state {
        case .None:
            ret += ">"
        case .Succeed:
            ret += ": OK> \n"
            ret += commonDescription()
        case let .Failed(error):
            ret += ": NG> \n"
            ret += commonDescription()
            ret += "ERROR: '\(error.localizedDescription)'"
        }
        
        return ret
    }
}
