// =============================================================================
// NBRealm
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

public extension NSPredicate {
	
	public convenience init(ids: [Int64]) {
		print(ids.map {
			return NSNumber(longLong: $0)
			})
		
		self.init(
			format: "\(NBRealmEntityIDKey) IN {%@}",
			argumentArray: ids.map {
				return NSNumber(longLong: $0)
			}
		)
	}
}



/*
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
*/