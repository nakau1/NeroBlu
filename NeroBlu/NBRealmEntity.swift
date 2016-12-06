// =============================================================================
// NBRealm
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit
import RealmSwift

// MARK: - NBRealmEntity -

/// RealmObjectを継承したデータエンティティクラス
open class NBRealmEntity: RealmSwift.Object {
    
    open static let IDKey       = "id"
    open static let CreatedKey  = "created"
    open static let ModifiedKey = "modified"
    
    /// オブジェクトID
    open dynamic var id : Int64 = 0 // = NBRealmEntityIDKey
    
    /// 作成日時
    open dynamic var created = Date() // = NBRealmEntityCreatedKey
    
    /// 更新日時
    open dynamic var modified = Date() // = NBRealmEntityModifiedKey
    
    /// 主キー設定
    open override static func primaryKey() -> String? {
        return NBRealmEntity.IDKey
    }
}
