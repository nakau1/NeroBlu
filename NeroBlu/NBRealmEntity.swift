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

// MARK: 
public extension NBRealmEntity {
	
	/// RealmSwift.Listオブジェクトを配列に変換する
	/// - parameter list: RealmSwift.Listオブジェクト
	/// - returns: 変換された配列
	public func listToArray<T : NBRealmEntity>(list: RealmSwift.List<T>) -> [T] {
		return list.map { $0 }
	}
	
	/// 配列をRealmSwift.Listオブジェクトに変換する
	/// - parameter array: 配列
	/// - returns: 変換されたRealmSwift.Listオブジェクト
	public func arrayToList<T : NBRealmEntity>(array: [T]) -> RealmSwift.List<T> {
		let ret = RealmSwift.List<T>()
		ret.appendContentsOf(array)
		return ret
	}
}

//
/*MARK: - RealmSwift拡張 -
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