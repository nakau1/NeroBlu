// =============================================================================
// NerobluNetworking
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit
import Alamofire
import SwiftyJSON

// MARK: NBNetwork Defines

/// Alamofire.Requestのエイリアス
public typealias AfRequest = Alamofire.Request

/// Alamofire.Methodのエイリアス
public typealias AfMethod  = Alamofire.Method

// Alamofire.ParameterEncodingのエイリアス
public typealias AfEncoding = Alamofire.ParameterEncoding

/// 作成された Alamofire.Request をリクエスト前に加工するためのクロージャ
public typealias NBAlamofireRequestProcessingClosure = (AfRequest) -> AfRequest

// MARK: - NBNetworkResponseType -

/// レスポンスタイプ
public enum NBNetworkResponseType {
    
    case Data
    case String
    case JSON
    case PropertyList
}

// MARK: - NBNetwork -

/// ネットワーク経由のデータ取得を実行するクラス
public class NBNetwork {
    
    /// リクエストを実行する
    /// - parameter request: NBNetworkRequestを実装したリクエストオブジェクト
    /// - parameter responsed: レスポンスが返った時の処理
    public func request<T: AnyObject where T: NBNetworkRequest>(request: T, responsed: (NBNetworkResult, T.Response?) -> Void) {

        let req = self.createAlamofireRequest(networkRequest: request)
        let result = NBNetworkResult()

        switch request.responseType {
        case .Data:
            req.responseData() { r in
                self.assignResult(result, r.request, r.response, r.data, r.result.error)
                responsed(result, request.response(r.result.value, result: result))
            }
        case .String:
            req.responseString() { r in
                self.assignResult(result, r.request, r.response, r.data, r.result.error)
                responsed(result, request.response(r.result.value, result: result))
            }
        case .JSON:
            req.responseJSON() { r in
                self.assignResult(result, r.request, r.response, r.data, r.result.error)
                responsed(result, request.response(r.result.value, result: result))
            }
        case .PropertyList:
            req.responsePropertyList() { r in
                self.assignResult(result, r.request, r.response, r.data, r.result.error)
                responsed(result, request.response(r.result.value, result: result))
            }
        }
    }
    
    private func createAlamofireRequest<T: NBNetworkRequest>(networkRequest request: T) -> AfRequest {
        
        var req = Alamofire.request(
            request.method,
            request.url,
            parameters: request.parameters,
            encoding:   request.parameterEncoding,
            headers:    request.headers
        )
        if let processed = request.willRequest?(req) {
            req = processed
        }
        if let validated = request.validateRequest?(req) {
            req = validated
        }
        
        return req
    }
    
    private func assignResult(result: NBNetworkResult, _ urlRequest: NSURLRequest?, _ urlResponse: NSHTTPURLResponse?, _ rowData: NSData?, _ error: NSError?) {
        result.urlRequest  = urlRequest
        result.urlResponse = urlResponse
        result.rowData     = rowData
        
        if let v = urlResponse?.statusCode { result.statusCode = v }
        if let v = urlResponse?.MIMEType   { result.mimeType   = v }
        
        if let error = error {
            result.state = .Failed(error)
        } else {
            result.state = .Succeed
        }
    }
    
    public init() {}
}

// MARK: - ユーティリティメソッド -
public extension NBNetwork {
    
    /// 辞書からURLパラメータ文字列を返却する
    /// - parameter parameters: 辞書
    /// - returns: URLパラメータ文字列
    public class func urlParameterString(parameters: [String: AnyObject]?) -> String {
        let encoded = ParameterEncoding.URL.encode(NSURLRequest(URL: NSURL(string: "")!), parameters: parameters)
        return encoded.0.URLString
    }

    /// デバイスのID(UUID)
    /// - warning: 非推奨になる可能性もある
    public static var deviceIdentifier: String {
        guard let uuid = UIDevice.currentDevice().identifierForVendor else {
            print("fatal error: failed to obtain UIDevice#identifierForVendor")
            return ""
        }
        return uuid.UUIDString
    }
}
