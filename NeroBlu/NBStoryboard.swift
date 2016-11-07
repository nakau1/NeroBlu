// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - App拡張 -
public extension App {
    
    /// NBStoryboardオブジェクトを作成する
    /// - parameter name: ストリーボード名
    /// - parameter bundle: バンドル
    /// - parameter id: ストーリーボード上のID文字列 後から id(_:) メソッドからでも設定が可能
    /// - returns: NBStoryboard
    public static func Storyboard(_ name: String, bundle: Bundle? = nil, id: String? = nil) -> NBStoryboard {
        return NBStoryboard(name, bundle, id)
    }
}

// MARK: - NBStoryboard -

/// ストーリーボードに関する処理を行うクラス
open class NBStoryboard {
    
    /// ストーリーボードIDを設定する
    /// - parameter storyboardIdentifier: ストーリーボード上のID文字列
    /// - returns: 自身の参照
    open func id(_ storyboardIdentifier: String) -> NBStoryboard {
        self.storyboardIdentifier = storyboardIdentifier
        return self
    }
    
    /// ストーリーボード上のコントローラを取得する
    /// - returns: コントローラ(事前にストーリーボードIDの設定がない場合はルートビューコントローラを返却する)
    open func get() -> UIViewController {
        if let id = self.storyboardIdentifier {
            return self.storyboard.instantiateViewController(withIdentifier: id)
        } else {
            guard let vc = self.storyboard.instantiateInitialViewController() else {
                fatalError("not found root(initial) view controller in storyboard of '\(self.name)'")
            }
            return vc
        }
    }
    
    /// ストーリーボード上のコントローラを取得する
    /// - parameter type: 取得するビューコントローラの型
    /// - returns: コントローラ(事前にストーリーボードIDの設定がない場合はルートビューコントローラを返却する)
    open func get<T: UIViewController>(_ type: T.Type) -> T {
        guard let vc = self.get() as? T else {
            fatalError("view controller is not match '\(type.className)' in storyboard of '\(self.name)'")
        }
        return vc
    }
    
    fileprivate var storyboard: UIStoryboard
    fileprivate var name: String
    fileprivate var storyboardIdentifier: String?
    
    fileprivate init(_ name: String, _ bundle: Bundle?, _ id: String?) {
        self.name = name
        self.storyboardIdentifier = id
        self.storyboard = UIStoryboard(name: name, bundle: bundle)
    }
}

// MARK: - UINib拡張 -
public extension UINib {

    /// Nibファイルの存在確認を行ってからUINibオブジェクトを返す
    /// - parameter name: Nibファイル名
    /// - parameter bundle: バンドル
    /// - returns: UINibオブジェクト(存在しない場合はnil)
    public class func create(nibName name: String, bundle bundleOrNil: Bundle?) -> UINib? {
        let bundle = bundleOrNil ?? Bundle.main
        if let _ = bundle.path(forResource: name, ofType: "nib") {
            return UINib(nibName: name, bundle: bundle)
        }
        return nil
    }
}

