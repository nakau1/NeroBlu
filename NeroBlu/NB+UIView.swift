// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - UIView拡張 -
public extension UIView {
    
    // MARK: Inspectables
    
    /// 枠線の幅
    @IBInspectable public var borderWidth: CGFloat {
        get    { return self.layer.borderWidth }
        set(v) { self.layer.borderWidth = v }
    }
    
    /// 枠線の色
    @IBInspectable public var borderColor: UIColor? {
        get {
            guard let color = self.layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
        set(v) { self.layer.borderColor = v?.cgColor }
    }
    
    /// 角丸
    @IBInspectable public var cornerRadius: CGFloat {
        get    { return self.layer.cornerRadius }
        set(v) { self.layer.cornerRadius = v }
    }
    
    // MARK: 配置ヒエラルキー関連
    
    /// 最上部のビューを返却する(自身が最上部ならば自身を返す)
    public var rootView : UIView {
        if let superview = self.superview {
            return superview.rootView
        }
        return self
    }
    
    /// 親ビューの設定と取得(nilを渡すと親ビューから削除される)
    public var parent: UIView? {
        get {
            return self.superview
        }
        set(v) {
            if let view = v {
                view.addSubview(self)
            } else {
                self.removeFromSuperview()
            }
        }
    }
    
    /// 自身からすべてのサブビューを削除する
    public func removeAllSubviews() {
        self.subviews.forEach { $0.removeFromSuperview() }
    }
    
    // MARK: インスタンス生成
    
    /// Xibからビューインスタンスを生成する
    ///
    /// 引数を省略した場合は、呼び出したクラス名からXIBファイル名を判定します
    ///
    ///     if let customView = CustmoView.loadFromNib() as? CustomView {
    ///         self.view.addSubview(customView)
    ///     }
    ///
    /// - parameter nibName: XIBファイル名
    /// - parameter bundle: バンドル
    /// - returns: 新しいビュー
    public class func loadFromNib<T: UIView>(_ type: T.Type, nibName: String? = nil, bundle: Bundle? = nil) -> T? {
        let name = nibName ?? NBReflection.className(type)
        let nib = UINib(nibName: name, bundle: bundle)
        return nib.instantiate(withOwner: nil, options: nil).first as? T
    }
    
    // MARK: 座標関連
    
    /// ビューのX座標
    public var x: CGFloat {
        get    { return self.frame.minX }
        set(v) { self.frame.origin.x = v }
    }
    
    /// ビューのY座標
    public var y: CGFloat {
        get    { return self.frame.minY }
        set(v) { self.frame.origin.y = v }
    }
    
    /// ビューの幅
    public var width: CGFloat {
        get    { return self.frame.width }
        set(v) { self.frame.size.width = v }
    }
    
    /// ビューの高さ
    public var height: CGFloat {
        get    { return self.frame.height }
        set(v) { self.frame.size.height = v }
    }
}
