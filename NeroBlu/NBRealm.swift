// =============================================================================
// NBRealm
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit
import RealmSwift

/// ソート情報
/// - parameter String: フィールド名
/// - parameter Bool: 昇順: true、降順: false
public typealias NBRealmSort = [String : Bool]

/// 取得制限情報
/// - parameter offset: オフセット位置
/// - parameter count: 件数
public typealias NBRealmLimit = (offset: Int, count: Int)

// MARK: - NBRealm -

/// Realm自体の参照等を扱うクラス
open class NBRealm {
    
    /// Realmファイルのパス
    open static var realmPath: String {
        return Realm.Configuration.defaultConfiguration.fileURL?.absoluteString ?? ""
    }
    
    /// Realmオブジェクト
    open static var realm: Realm { return try! Realm() }
}
