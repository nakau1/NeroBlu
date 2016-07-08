// =============================================================================
// NBRealm
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit
import RealmSwift

// MARK: - NBRealmAccessor -

/// Realmオブジェクトのデータアクセサの基底クラス
public class NBRealmAccessor<T: NBRealmEntity>: CustomStringConvertible {
    
    /// エンティティ
    public typealias Entity = T
    
    /// Realmオブジェクトの参照
    public var realm: Realm { return NBRealm.realm }
    
    public init() {}
    
    public var description: String {
        return ""
    }
}

// MARK: - エンティティ生成 -
public extension NBRealmAccessor {
    
    /// 新しいエンティティを生成する
    /// - parameter withID: エンティティに与えるID(省略時は自動的に採番)
    /// - returns: 新しいエンティティ
    public func create(withID id: Int64? = nil) -> Entity {
        let ret = Entity()
        ret.id = id ?? self.autoIncrementedID
        return ret
    }
    
    /// 配列等(コレクションタイプ)から新しいエンティティを配列で生成する
    /// - parameter collection: CollectionTypeを実装したオブジェクト(配列等)
    /// - parameter withID: 最初のエンティティに与えるID(省略時は自動的に採番)。以降は配列要素数に合わせてインクリメントされる
    /// - parameter setup: 生成されたエンティティに対するセットアップ処理
    /// - remark: setup\
    ///           \
    ///           - parameter Entity: 生成されたエンティティ\
    ///           - parameter T.Generator.Element: コレクションの要素\
    ///           \
    ///           - returns: セットアップされたエンティティ
    /// - returns: 新しいエンティティ
    public func create<T: CollectionType>(collection: T, withID firstID: Int64, setup: (Entity, T.Generator.Element) -> Entity) -> [Entity] {
        var ret = [Entity]()
        var id = firstID ?? self.autoIncrementedID
        for element in collection {
            var entity = Entity()
            entity.id = id
            entity = setup(entity, element)
            ret.append(entity)
            id += 1
        }
        return ret
    }
}

// MARK: - エンティティ複製 -
public extension NBRealmAccessor {
    
    /// 渡したエンティティを複製した新しいエンティティを生成する
    /// - parameter object: コピーするエンティティ
    /// - returns: 引数のエンティティを複製した新しいエンティティ
    public func clone(object: Entity) -> Entity {
        let ret = Entity()
        ret.id       = object.id
        ret.created  = object.created
        ret.modified = object.modified
        return ret
    }
}

// MARK: - 汎用メソッド/プロパティ -
public extension NBRealmAccessor {
    
    /// オートインクリメントされたID値
    public var autoIncrementedID: Int64 {
        guard let max = self.realm.objects(Entity).sorted(NBRealmEntity.IDKey, ascending: false).first else {
            return 1
        }
        return max.id + 1
    }
}

// MARK: - レコード保存 -
public extension NBRealmAccessor {
    
    /// 指定したエンティティのレコードを更新する
    /// - parameter condition: 条件オブジェクト
    /// - parameter updating: データ更新クロージャ
    public func save(entity: Entity) {
        self.save([entity])
    }
    
    /// 指定したエンティティのレコードを更新する
    /// - parameter condition: 条件オブジェクト
    /// - parameter updating: データ更新クロージャ
    public func save(entities: [Entity]) {
        let r = self.realm
        try! r.write {
            for entity in entities {
                entity.modified = NSDate()
            }
            r.add(entities, update: true)
        }
    }
}

// MARK: - レコード取得 -
public extension NBRealmAccessor {
    
    /// 指定した条件とソートでレコードを抽出しエンティティの配列で取得する
    /// - parameter condition: 条件オブジェクト
    /// - parameter sort: ソート
    /// - parameter limit: 取得制限
    /// - returns: エンティティの配列
    public func select(condition condition: NSPredicate? = nil, sort: NBRealmSort? = nil, limit: NBRealmLimit? = nil) -> [Entity] {
        let result = self.getResult(condition: condition, sort: sort)
        if let limit = limit {
            var ret = [Entity]()
            for i in limit.offset...(limit.offset + limit.count) {
                ret.append(result[i])
            }
            return ret
        } else {
            return result.map {$0}
        }
    }
    
    /// 指定した条件で抽出されるレコード数を取得する
    /// - parameter condition: 条件オブジェクト
    /// - returns: レコード数
    public func count(condition condition: NSPredicate? = nil) -> Int {
        return self.getResult(condition: condition, sort: nil).count
    }
    
    /// 指定した条件・ソートから結果オブジェクトを取得する
    /// - parameter condition: 条件オブジェクト
    /// - parameter sort: ソート
    /// - returns: RealmResultsオブジェクト
    private func getResult(condition condition: NSPredicate? = nil, sort: NBRealmSort? = nil) -> RealmSwift.Results<Entity> {
        var result = self.realm.objects(Entity)
        if let condition = condition {
            result = result.filter(condition)
        }
        if let sort = sort {
            sort.forEach {
                result = result.sorted($0.0, ascending: $0.1)
            }
        }
        return result
    }
}

// MARK: - レコード追加 -
public extension NBRealmAccessor {
    
    /// エンティティの配列からレコードを一括で新規追加する
    /// - parameter entities: 追加するエンティティの配列
    public func insert(entities: [Entity]) {
        let r = self.realm
        var i = 0, id: Int64 = 1
        try! r.write {
            for entity in entities {
                if i == 0 { id = entity.id }
                entity.id       = id + i
                entity.created  = NSDate()
                entity.modified = NSDate()
                r.add(entity, update: true)
                i += 1
            }
        }
    }
    
    /// エンティティからレコードを新規追加する
    /// - parameter entity: 追加するエンティティ
    public func insert(entity: Entity) {
        self.insert([entity])
    }
}

// MARK: - レコード削除 -
public extension NBRealmAccessor {
    
    /// 指定した条件に該当するレコードを削除する
    /// - parameter condition: 条件オブジェクト
    public func delete(condition: NSPredicate) {
        let r = self.realm
        try! r.write {
            r.delete(r.objects(Entity).filter(condition))
        }
    }
    
    /// 指定した複数のIDで抽出されるレコードを削除する
    /// - parameter ids: IDの配列
    public func delete(ids ids: [Int64]) {
        self.delete(NSPredicate(ids: ids))
    }
    
    /// 指定したIDのレコードを削除する
    /// - parameter id: ID
    public func delete(id id: Int64) {
        self.delete(NSPredicate(id: id))
    }
    
    /// 指定したエンティティのレコードを削除する
    /// - parameter entity: エンティティ
    public func delete(entity entity: Entity) {
        let r = self.realm
        try! r.write {
            r.delete(entity)
        }
    }
}

// MARK: - レコード更新 -
public extension NBRealmAccessor {
    
    /// データ更新クロージャ
    /// - parameter Entity: 更新対象のエンティティ
    /// - parameter Int: インデックス
    public typealias NBRealmUpdateClosure = (Entity, Int) -> Void
    
    /// 指定した条件で抽出されるレコードを更新する
    /// - parameter condition: 条件オブジェクト
    /// - parameter updating: データ更新クロージャ
    public func update(condition: NSPredicate? = nil, updating: NBRealmUpdateClosure) {
        let r = self.realm
        try! r.write {
            var result = r.objects(Entity)
            if let condition = condition {
                result = result.filter(condition)
            }
            var i = 0
            for entity in result {
                entity.modified = NSDate()
                updating(entity, i)
                i += 1
            }
        }
    }
    
    /// 指定した複数のIDで抽出されるレコードを更新する
    /// - parameter ids: IDの配列
    /// - parameter updating: データ更新クロージャ
    public func update(ids: [Int64], updating: NBRealmUpdateClosure) {
        self.update(NSPredicate(ids: ids), updating: updating)
    }
    
    /// 指定したIDのレコードを更新する
    /// - parameter id: ID
    /// - parameter updating: データ更新クロージャ
    public func update(id: Int64, updating: NBRealmUpdateClosure) {
        self.update(NSPredicate(id: id), updating: updating)
    }
    
    /// 指定したエンティティのレコードを更新する
    /// - parameter condition: 条件オブジェクト
    /// - parameter updating: データ更新クロージャ
    public func update(entity: Entity, updating: NBRealmUpdateClosure) {
        let r = self.realm
        try! r.write {
            entity.modified = NSDate()
            updating(entity, 0)
            r.add(entity, update: true)
        }
    }
}
