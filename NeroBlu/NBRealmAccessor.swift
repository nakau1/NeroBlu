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

// MARK: - インスタンス管理 -
public extension NBRealmAccessor {
	
	/// 新しいエンティティを生成する
	/// - parameter previousID: ループ中などに前回のIDを与えることで複数のユニークなIDのエンティティを作成できます
	/// - returns: 新しいエンティティ
	public func create(previousID previousID: Int64? = nil) -> Entity {
		return NBRealm.create(type: Entity.self, previousID: previousID)
	}
	
	/// 渡したエンティティを複製した新しいエンティティを生成する
	/// - parameter object: コピーするエンティティ
	/// - returns: 引数のエンティティを複製した新しいエンティティ
	public func clone(object: Entity) -> Entity {
		return NBRealm.clone(object)
	}
	
	/// オートインクリメントされたID値
	public var autoIncrementedID: Int64 {
		return NBRealm.autoIncrementedID(type: Entity.self)
	}
}

// MARK: - レコード取得 -
public extension NBRealmAccessor {
    
    /// ソート情報
    /// - complexity: String フィールド名
    /// - complexity: Bool 昇順: true、降順: false
    public typealias NBRealmSort = [String : Bool]
    
    /// エンティティを配列で取得する
    /// - parameter condition: 条件オブジェクト
    /// - parameter sort: ソート
    /// - returns: エンティティの配列
    public func select(condition condition: NSPredicate? = nil, sort: NBRealmSort? = nil) -> [Entity] {
        return self.getResult(condition: condition, sort: sort).map { return $0 }
    }
    
    /// 指定した条件で抽出されるレコード数を取得する
    /// - parameter condition: 条件オブジェクト
    /// - parameter sort: ソート
    /// - returns: レコード数
    public func count(condition condition: NSPredicate? = nil) -> Int {
        return self.getResult(condition: condition, sort: nil).count
    }
    
    /// 指定した条件・ソートから結果オブジェクトを取得する
    /// - parameter condition: 条件オブジェクト
    /// - parameter sort: ソート
    /// - returns: RealmResultsオブジェクト
    private func getResult(condition condition: NSPredicate? = nil, sort: NBRealmSort? = nil) -> RealmSwift.Results<T> {
        var result = self.realm.objects(Entity)
        if let filter = condition {
            result = result.filter(filter)
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
    
    /// 指定したIDに該当するレコードを削除する
    /// - parameter ids: IDの配列
    public func delete(ids ids: [Int64]) {
        
    }
    
    /// 指定したエンティティのレコードを削除する
    /// - parameter entity: エンティティ
    public func delete(entity entity: Entity) {
        
    }
}

// MARK: データ更新
public extension NBRealmAccessor {
    
    /// データ更新クロージャ
    /// - complexity: Entity 更新対象のエンティティ
    /// - complexity: Int インデックス
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
    
    /// 指定した条件で抽出されるレコードを更新する
    /// - parameter condition: 条件オブジェクト
    /// - parameter updating: データ更新クロージャ
    public func update(ids: [Int64], updating: NBRealmUpdateClosure) {
        
    }
    
    /// 指定した条件で抽出されるレコードを更新する
    /// - parameter condition: 条件オブジェクト
    /// - parameter updating: データ更新クロージャ
    public func update(entity: Entity, updating: NBRealmUpdateClosure) {
        
    }
}
