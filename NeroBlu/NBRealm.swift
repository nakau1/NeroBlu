// =============================================================================
// NBRealm
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit
import RealmSwift

// MARK: - NBRealm -

/// Realm自体の参照等を扱うクラス
public class NBRealm {
	
	/// Realmファイルのパス
	public static var realmPath: String {
		//print(self.realm.schema.objectSchema)
		return Realm.Configuration.defaultConfiguration.path ?? ""
	}
	
	/// Realmオブジェクト
	public static var realm: Realm { return try! Realm() }
}

public extension NBRealm {
	
	/// 指定した型の新しいエンティティを生成する
	/// - parameter type: 型
	/// - parameter previousID: ループ中などに前回のIDを与えることで複数のユニークなIDのエンティティを作成できます
	/// - returns: 新しいエンティティ
	public static func create<T : NBRealmEntity>(type type: T.Type, previousID: Int64? = nil) -> T {
		let ret = T()
		if let previous = previousID {
			ret.id = previous + 1
		} else {
			ret.id = self.autoIncrementedID(type: type)
		}
		return ret
	}
	
	/// 渡したエンティティを複製した新しいエンティティを生成する
	/// - parameter object: コピーするエンティティ
	/// - returns: 引数のエンティティを複製した新しいエンティティ
	public static func clone<T : NBRealmEntity>(object: T) -> T {
		let ret = T()
		ret.id       = object.id
		ret.created  = object.created
		ret.modified = object.modified
		return ret
	}
	
	/// 指定した型のオートインクリメントされたID値を返却する
	/// - parameter type: 型
	/// - returns: オートインクリメントされたID値
	public static func autoIncrementedID<T : NBRealmEntity>(type type: T.Type) -> Int64 {
		guard let max = self.realm.objects(type).sorted(NBRealmEntityIDKey, ascending: false).first else {
			return 1
		}
		return max.id + 1
	}
}

// MARK: - RealmSwift.List拡張 -
public extension RealmSwift.List {
    
    public typealias Entity = Element
    
    /// 自身のデータを配列に変換する
    /// - returns: 変換された配列
    public var list: [Entity] {
        return self.map { return $0 }
    }
    
    /// 自身のデータを渡された配列でリセットする
    /// - parameter array: 配列
    public func reset(array: [Entity] = []) {
        self.removeAll()
        self.appendContentsOf(array)
    }
}
