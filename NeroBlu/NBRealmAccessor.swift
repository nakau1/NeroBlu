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

// MARK: - レコード追加 -
public extension NBRealmAccessor {
	
	/// エンティティを一括で新規追加する
	/// - parameter entities: 追加するエンティティの配列
	public func add(entities: [Entity]) {
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
	
	/// エンティティを新規追加する
	/// - parameter entity: 追加するエンティティ
	public func add(entity: Entity) {
		self.add([entity])
	}
}


/*
// MARK: データ更新
public extension NBRealmAccessor {
    
    /// 指定した条件のRealmオブジェクトを一括で更新する
    /// - parameter type: Realmオブジェクト型
    /// - parameter predicate: 条件
    /// - parameter modify: 更新処理
    public func modifyWithPredicate<T : NBRealmObject>(type: T.Type, predicate: NSPredicate, modify: (T, Int) -> Void) {
        let r = self.realm
        try! r.write {
            let result = r.objects(type).filter(predicate)
            var i = 0
            for realmObject in result {
                realmObject.modified = NSDate()
                modify(realmObject, i)
                i += 1
            }
        }
    }
    
    /// 指定したIDのRealmオブジェクトを一括で更新する
    /// - parameter type: Realmオブジェクト型
    /// - parameter ids: IDの配列
    /// - parameter modify: 更新処理
    public func modifyByIDs<T : NBRealmObject>(type: T.Type, ids: [Int64], modify: (T, Int) -> Void) {
        self.modifyWithPredicate(type, predicate: self.predicateIDs(ids), modify: modify)
    }
    
    /// Realmオブジェクトの配列を渡して一括で更新する
    /// - parameter type: Realmオブジェクト型
    /// - parameter realmObjects: 更新するRealmオブジェクトの配列
    /// - parameter modify: 更新処理
    public func modify<T : NBRealmObject>(type: T.Type, _ realmObjects: [T], modify: (T, Int) -> Void) {
        let ids = realmObjects.map { return $0.id }
        self.modifyByIDs(type, ids: ids, modify: modify)
    }
    
    /// RealmオブジェクトのRealmSwift.List、またはRealmSwift.Resultを渡して一括で更新する
    /// - parameter type: Realmオブジェクト型
    /// - parameter realmObjects: 更新するRealmオブジェクトの配列
    /// - parameter modify: 更新処理
    public func modify<T : NBRealmObject, S: SequenceType where S.Generator.Element: NBRealmObject>(type: T.Type, _ realmObjects: S, modify: (T, Int) -> Void) {
        let array = realmObjects.map { return $0 as NBRealmObject }
        self.modify(type, array, modify: modify)
    }
    
    /// 渡したRealmオブジェクトを更新する
    /// - parameter type: Realmオブジェクト型
    /// - parameter realmObject: 更新するRealmオブジェクト
    /// - parameter modify: 更新処理
    public func modify<T : NBRealmObject>(type: T.Type, _ realmObject: T, modify: (T, Int) -> Void) {
        self.modifyByIDs(type, ids: [realmObject.id], modify: modify)
    }
}

// MARK: データ削除
public extension NBRealmAccessor {
    
    /// 指定した条件のRealmオブジェクトを一括で削除する
    /// - parameter type: Realmオブジェクト型
    /// - parameter predicate: 条件
    public func removeWithPredicate<T : NBRealmObject>(type: T.Type, predicate: NSPredicate) {
        let r = self.realm
        try! r.write {
            r.delete(r.objects(type).filter(predicate))
        }
    }
    
    /// 指定したIDのRealmオブジェクトを一括で削除する
    /// - parameter type: Realmオブジェクト型
    /// - parameter ids: IDの配列
    public func removeByIDs<T : NBRealmObject>(type: T.Type, ids: [Int64]) {
        self.removeWithPredicate(type, predicate: self.predicateIDs(ids))
    }
    
    /// Realmオブジェクトの配列を渡して一括で削除する
    /// - parameter type: Realmオブジェクト型
    /// - parameter realmObjects: 削除するRealmオブジェクトの配列
    public func remove<T : NBRealmObject>(type: T.Type, _ realmObjects: [T]) {
        let ids = realmObjects.map { return $0.id }
        self.removeByIDs(type, ids: ids)
    }
    
    /// RealmオブジェクトのRealmSwift.List、またはRealmSwift.Resultを渡して一括で削除する
    /// - parameter type: Realmオブジェクト型
    /// - parameter realmObjects: 削除するRealmオブジェクトの配列
    public func remove<T : NBRealmObject, S: SequenceType where S.Generator.Element: NBRealmObject>(type: T.Type, _ realmObjects: S) {
        let array = realmObjects.map { return $0 as NBRealmObject }
        self.remove(type, array)
    }
    
    /// 渡したRealmオブジェクトを削除する
    /// - parameter type: Realmオブジェクト型
    /// - parameter realmObject: 削除するRealmオブジェクト
    public func remove<T : NBRealmObject>(type: T.Type, _ realmObject: T) {
        self.removeByIDs(type, ids: [realmObject.id])
    }
}

// MARK: データ取得
public extension NBRealmAccessor {
    
    /// 指定した条件・ソートでRealmオブジェクトを配列で取得する
    /// - parameter type: Realmオブジェクト型
    /// - parameter condition: 条件オブジェクト
    /// - parameter sort: ソート([プロパティ名 : 昇順/降順]の辞書)
    /// - returns: Realmオブジェクトの配列
    public func fetch<T : NBRealmObject>(type: T.Type, condition: NSPredicate? = nil, sort: [String : Bool]? = [NBRealmObjectIDKey: false]) -> [T] {
        return self.getResults(type, condition: condition, sort: sort).map { return $0 }
    }
    
    /// 指定した条件のRealmオブジェクト数を取得する
    /// - parameter type: Realmオブジェクト型
    /// - parameter condition: 条件オブジェクト
    /// - returns: Realmオブジェクトの配列
    public func count<T : NBRealmObject>(type: T.Type, condition: NSPredicate? = nil) -> Int {
        return self.getResults(type, condition: condition).count
    }
    
    /// 指定した条件・ソートでの結果オブジェクトを取得する
    /// - parameter type: Realmオブジェクト型
    /// - parameter condition: 条件オブジェクト
    /// - parameter sort: ソート([プロパティ名 : 昇順/降順]の辞書)
    /// - returns: Realmオブジェクトの配列
    private func getResults<T : NBRealmObject>(type: T.Type, condition: NSPredicate? = nil, sort: [String : Bool]? = nil) -> RealmSwift.Results<T> {
        var result = self.realm.objects(type)
        if let f = condition {
            result = result.filter(f)
        }
        if let s = sort {
            s.forEach {
                result = result.sorted($0.0, ascending: $0.1)
            }
        }
        return result
    }
}

// MARK: 検索条件
public extension NBRealmAccessor {
    
    /// 複数の検索条件を1つにまとめて返却する
    /// - parameter conditions: 検索条件文字列の配列
    /// - parameter type: 結合種別
    /// - returns: 検索条件オブジェクト
    public func compoundPredicateWithConditions(conditions: [String], type: NSCompoundPredicateType = .AndPredicateType) -> NSPredicate {
        var predicates = [NSPredicate]()
        for condition in conditions {
            predicates.append(NSPredicate(format: condition))
        }
        return self.compoundPredicateWithPredicates(predicates, type: type)
    }
    
    /// 複数の検索条件を1つにまとめて返却する
    /// - parameter predicates: 検索条件オブジェクトの配列
    /// - parameter type: 結合種別
    /// - returns: 検索条件オブジェクト
    public func compoundPredicateWithPredicates(predicates: [NSPredicate], type: NSCompoundPredicateType = .AndPredicateType) -> NSPredicate {
        let ret: NSPredicate
        switch type {
        case .AndPredicateType: ret = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        case .OrPredicateType:  ret = NSCompoundPredicate(orPredicateWithSubpredicates:  predicates)
        case .NotPredicateType: ret = NSCompoundPredicate(notPredicateWithSubpredicate:  self.compoundPredicateWithPredicates(predicates))
        }
        return ret
    }
    
    /// IDの配列からのIN条件の検索条件を生成する
    /// - parameter ids: IDの配列
    /// - returns: 検索条件オブジェクト
    public func predicateIDs(ids: [Int64]) -> NSPredicate {
        return NSPredicate(format: "\(NBRealmObjectIDKey) IN {%@}", argumentArray: ids.map { return NSNumber(longLong: $0) } )
    }
    
    /// あいまい検索を行うための検索条件を生成する
    /// - parameter property: プロパティ名
    /// - parameter q: 検索文字列
    /// - returns: 検索条件オブジェクト
    public func predicateContainsString(property: String, _ q: String) -> NSPredicate {
        return NSPredicate(format: "\(property) CONTAINS '\(q)'")
    }
    
    /// 値の完全一致検索を行うための検索条件を生成する
    /// - parameter property: プロパティ名
    /// - parameter v: 値
    /// - returns: 検索条件オブジェクト
    public func predicateEqauls(property: String, _ v: AnyObject) -> NSPredicate {
        return NSPredicate(format: "\(property) = %@", argumentArray: [v])
    }
}

// MARK: ソート
public extension NBRealmAccessor {
    
    /// IDでソートするための辞書を返す
    /// - parameter ascending: 昇順/降順
    /// - parameter seed: 既にソート用の辞書がある場合に渡すと、追記される
    /// - returns: ソート用の辞書
    public func sortID(ascending: Bool = true, seed: [String : Bool] = [:]) -> [String : Bool] {
        return self.sortOf(NBRealmObjectIDKey, ascending: ascending, seed: seed)
    }
    
    /// 作成日時でソートするための辞書を返す
    /// - parameter ascending: 昇順/降順
    /// - parameter seed: 既にソート用の辞書がある場合に渡すと、追記される
    /// - returns: ソート用の辞書
    public func sortCreated(ascending: Bool = true, seed: [String : Bool] = [:]) -> [String : Bool] {
        return self.sortOf(NBRealmObjectCreatedKey, ascending: ascending, seed: seed)
    }
    
    /// 作成日時でソートするための辞書を返す
    /// - parameter ascending: 昇順/降順
    /// - parameter seed: 既にソート用の辞書がある場合に渡すと、追記される
    /// - returns: ソート用の辞書
    public func sortModified(ascending: Bool = true, seed: [String : Bool] = [:]) -> [String : Bool] {
        return self.sortOf(NBRealmObjectModifiedKey, ascending: ascending, seed: seed)
    }
    
    /// 指定したプロパティでソートするための辞書を返す
    /// - parameter property: プロパティ名
    /// - parameter ascending: 昇順/降順
    /// - parameter seed: 既にソート用の辞書がある場合に渡すと、追記される
    /// - returns: ソート用の辞書
    public func sortOf(property: String, ascending: Bool = true, seed: [String : Bool] = [:]) -> [String : Bool] {
        var seed = seed
        seed[property] = ascending
        return seed
    }
}

// MARK: - RealmSwift拡張 -
extension RealmSwift.List {
    
    /// 自身のデータを配列に変換する
    /// - returns: 変換された配列
    func toArray() -> [Element] {
        return self.map { return $0 }
    }
    
    /// 自身のデータを渡された配列でリセットする
    /// - parameter array: 配列
    func resetWithArray(array: [Element]) {
        self.removeAll()
        self.appendContentsOf(array)
    }
}

// MARK: - RealmSwift拡張 -
public extension String {
    
    /// Realm用にエスケープした文字列
    public var stringEscapedForRealm: String {
        return self.replace("\\", "\\\\").replace("'", "\\'")
    }
}
*/