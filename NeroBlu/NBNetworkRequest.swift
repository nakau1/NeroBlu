// =============================================================================
// NerobluNetworking
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit
import Alamofire
import SwiftyJSON

// MARK: - NBNetworkRequest -

/// ネットワークリクエストとして振る舞うプロトコル
public protocol NBNetworkRequest {
    
    // MARK: Required
    
    /// レスポンスデータ
    associatedtype Response
    
    /// リクエスト先のURL
    var url: String { get }
    
    /// レスポンスタイプ
    var responseType: NBNetworkResponseType { get }
    
    /// リクエスト先に送信するHTTPヘッダ
    func response(object: AnyObject?, result: NBNetworkResult) -> Response?
    
    // MARK: Optional
    
    /// HTTPメソッド
    var method: AfMethod { get }
    
    /// リクエスト先に送信するパラメータ
    var parameters: [String : AnyObject]? { get }
    
    /// リクエスト先に送信するHTTPヘッダ
    var headers: [String : String]? { get }
    
    /// パラメータエンコーディング
    var parameterEncoding: AfEncoding { get }
}
public extension NBNetworkRequest {
    
    /// リクエスト実行前のAlamofire.Requestオブジェクトに対して処理を加えるためのクロージャ
    public var willRequest: NBAlamofireRequestProcessingClosure? {
        return nil
    }
    
    /// リクエスト実行前のAlamofire.Requestオブジェクトに対して処理を加えるためのクロージャ
    public var validateRequest: NBAlamofireRequestProcessingClosure? {
        return { req in req.validate() }
    }
    
    // MARK: Optional-Default
    
    public var method: AfMethod {
        return NBNetworkRequestDefaultConfig.method
    }
    
    public var parameters: [String : AnyObject]? {
        return NBNetworkRequestDefaultConfig.parameters
    }
    
    public var headers: [String : String]? {
        return NBNetworkRequestDefaultConfig.headers
    }
    
    public var parameterEncoding: AfEncoding {
        return NBNetworkRequestDefaultConfig.parameterEncoding
    }
}

// MARK: - NBNetworkRequestDefaultConfig -

/// NBNetworkRequestのデフォルト設定をクラス変数で保持するクラス
public class NBNetworkRequestDefaultConfig {
    
    /// HTTPメソッド
    public static var method = AfMethod.GET
    
    /// リクエスト先に送信するパラメータ
    public static var parameters: [String : AnyObject]? = nil
    
    /// リクエスト先に送信するHTTPヘッダ
    public static var headers: [String : String]? = nil
    
    /// リクエスト実行前のAlamofire.Requestオブジェクトに対して処理を加えるためのクロージャ
    public static var willRequest: NBAlamofireRequestProcessingClosure? = nil
    
    /// パラメータエンコーディング
    public static var parameterEncoding = AfEncoding.URL
}
