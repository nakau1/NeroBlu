// =============================================================================
// NBRealm
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit
import RealmSwift

/// オブジェクトIDのキー名
public let NBRealmEntityIDKey       = "id"
public let NBRealmEntityCreatedKey  = "created"
public let NBRealmEntityModifiedKey = "modified"

// MARK: - NBRealmEntity -

/// RealmObjectを継承したデータエンティティクラス
public class NBRealmEntity: RealmSwift.Object {
    
    /// オブジェクトID
    public dynamic var id : Int64 = 0 // = NBRealmEntityIDKey
    
    /// 作成日時
    public dynamic var created = NSDate() // = NBRealmEntityCreatedKey
    
    /// 更新日時
    public dynamic var modified = NSDate() // = NBRealmEntityModifiedKey
    
    /// 主キー設定
    public override static func primaryKey() -> String? {
        return NBRealmEntityIDKey
    }
}
