// =============================================================================
// NerobluCore
// Copyright (C) NeroBlu. All rights reserved.
// =============================================================================
import UIKit

// MARK: - レイアウト制約生成関数 -

/// 制約(NSLayoutConstraint)を生成する
/// - parameter item: 制約を追加するオブジェクト
/// - parameter attr: 制約を追加するオブジェクトに与える属性
/// - parameter to: 制約の相手
/// - parameter attrTo: 制約相手に使用する属性
/// - parameter constant: 定数値
/// - parameter multiplier: 乗数値
/// - parameter relate: 計算式の関係性
/// - parameter priority: 制約の優先度
/// - returns: 制約(NSLayoutConstraint)オブジェクト
public func Constraint(item: AnyObject, _ attr: NSLayoutAttribute, to: AnyObject?, _ attrTo: NSLayoutAttribute, _ constant: CGFloat, multiplier: CGFloat = 1.0, relate: NSLayoutRelation = .Equal, priority: UILayoutPriority = UILayoutPriorityRequired) -> NSLayoutConstraint {
    let ret = NSLayoutConstraint(
        item:       item,
        attribute:  attr,
        relatedBy:  relate,
        toItem:     to,
        attribute:  attrTo,
        multiplier: multiplier,
        constant:   constant
    )
    ret.priority = priority
    return ret
}

// MARK: - UIView拡張 -
public extension UIView {
    
    /// すべてのレイアウト制約を削除する
    public func removeAllConstraints() {
        self.removeConstraints(self.constraints)
    }
    
    /// レイアウト制約を設定するための準備を行う
    public func prepareConstraints() {
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    /// レイアウト制約を設定する
    /// - parameter arrayOfConstraints: レイアウト制約の配列の配列
    /// - parameter on: 制約を追加するオブジェクトに与える属性
    /// - returns: 設定したレイアウト制約の配列
    public func setConstraints(arrayOfConstraints: [[NSLayoutConstraint]], on target: UIView? = nil) -> [NSLayoutConstraint] {
        return self.setConstraints(arrayOfConstraints: arrayOfConstraints, on: target, additional: nil)
    }
    
    /// レイアウト制約を設定する
    /// - parameter arrayOfConstraints: レイアウト制約の配列の配列
    /// - parameter on: 制約を追加するオブジェクトに与える属性
    /// - parameter additional: さらに追加するレイアウト制約の配列を返すクロージャ
    /// - returns: 設定したレイアウト制約の配列
    public func setConstraints(arrayOfConstraints arrayOfConstraints: [[NSLayoutConstraint]], on target: UIView? = nil, additional: (() -> ([NSLayoutConstraint]))?) -> [NSLayoutConstraint] {
        guard let target = self.omittableItem(target) as? UIView else { return [] }
        self.prepareConstraints()

        var ret = [NSLayoutConstraint]()
        for constraints in arrayOfConstraints {
            ret.appendContentsOf(constraints)

        }
        if let constraints = additional?() {
            ret.appendContentsOf(constraints)
        }
        
        target.addConstraints(ret)
        return ret
    }
}

// MARK: - UIView拡張: レイアウト制約の検索 -
public extension UIView {
    
    /// 指定したIDからレイアウト制約を検索して取得する
    /// - parameter identifier: ストーリーボード等で指定したID文字列
    /// - parameter on: 自身に制約を追加したビュー。検索はこのビューと自身に対して行う(省略時は自身の親ビューを対象にする)
    /// - returns: IDにマッチするレイアウト制約
    public func searchConstraint(identifier: String, on target: UIView? = nil) -> NSLayoutConstraint? {
        var constraints = self.constraints
        if let toItem = self.omittableItem(target) as? UIView {
            constraints.appendContentsOf(toItem.constraints)
        }
        for constraint in constraints {
            if let id = constraint.identifier where id == identifier {
                return constraint
            }
        }
        return nil
    }
}

// MARK: - UIView拡張: レイアウト制約(プライベート) -
private extension UIView {

    private func constraint(
        attr:       NSLayoutAttribute,
        to:         AnyObject?         = nil,
        attrTo:     NSLayoutAttribute? = nil,
        constant:   CGFloat            = 0.0,
        multiplier: CGFloat            = 1.0,
        relate:     NSLayoutRelation   = .Equal,
        priority:   UILayoutPriority   = UILayoutPriorityRequired
        ) -> NSLayoutConstraint
    {
        return Constraint(
            self,
            attr,
            to: to,
            attrTo ?? attr, // attrToがnilならばattrを使う
            constant,
            multiplier: multiplier,
            relate: relate,
            priority: priority
        )
    }
    
    private func omittableItem(item: AnyObject?) -> AnyObject? {
        return item ?? self.superview
    }
}

// MARK: - UIView拡張: 位置 -
public extension UIView {
    
    /// 各辺からの距離を指定したレイアウト制約を配列で取得する
    /// - parameter top: 上端のマージン値(省略時は戻り値に含まれない)
    /// - parameter left: 左端のマージン値(省略時は戻り値に含まれない)
    /// - parameter bottom: 下端のマージン値(省略時は戻り値に含まれない)
    /// - parameter right: 右端のマージン値(省略時は戻り値に含まれない)
    /// - parameter toItem: 制約の対象ビューまたはオブジェクト(省略時は自身の親ビューを対象にする)
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(top top: T? = nil, left: T? = nil, bottom: T? = nil, right: T? = nil, toItem item: AnyObject? = nil) -> [NSLayoutConstraint] {
        
        var constraints = [NSLayoutConstraint]()
        
        if let v = top {
            constraints.append(self.constraint(.Top, constant: CGFloat.cast(v), to: self.omittableItem(item)))
        }
        if let v = left {
            constraints.append(self.constraint(.Leading, constant: CGFloat.cast(v), to: self.omittableItem(item)))
        }
        if let v = bottom {
            constraints.append(self.constraint(.Bottom, constant: -CGFloat.cast(v), to: self.omittableItem(item)))
        }
        if let v = right {
            constraints.append(self.constraint(.Trailing, constant: -CGFloat.cast(v), to: self.omittableItem(item)))
        }
        
        return constraints
    }
    
    /// 指定した位置のレイアウト制約を配列で取得する
    /// - parameter position: 位置
    /// - parameter toItem: 制約の対象ビューまたはオブジェクト(省略時は自身の親ビューを対象にする)
    /// - returns: NSLayoutConstraintの配列
    public func constraints(position position: CGPoint, toItem item: AnyObject? = nil) -> [NSLayoutConstraint] {
        return [
            self.constraint(.Top,     constant: position.x, to: self.omittableItem(item)),
            self.constraint(.Leading, constant: position.y, to: self.omittableItem(item)),
        ]
    }
    
    /// 指定したX座標のレイアウト制約を配列で取得する
    /// - parameter x: X座標(左端からの距離)
    /// - parameter toItem: 制約の対象ビューまたはオブジェクト(省略時は自身の親ビューを対象にする)
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(x x: T, toItem item: AnyObject? = nil) -> [NSLayoutConstraint] {
        return [
            self.constraint(.Top, constant: CGFloat.cast(x), to: self.omittableItem(item)),
        ]
    }
    
    /// 指定したY座標のレイアウト制約を配列で取得する
    /// - parameter y: Y座標(上端からの距離)
    /// - parameter toItem: 制約の対象ビューまたはオブジェクト(省略時は自身の親ビューを対象にする)
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(y y: T, toItem item: AnyObject? = nil) -> [NSLayoutConstraint] {
        return [
            self.constraint(.Leading, constant: CGFloat.cast(y), to: self.omittableItem(item)),
        ]
    }
}

// MARK: - UIView拡張: サイズ -
public extension UIView {
    
    /// 指定したサイズのレイアウト制約を配列で取得する
    /// - parameter size: サイズ
    /// - returns: NSLayoutConstraintの配列
    public func constraints(size size: CGSize) -> [NSLayoutConstraint] {
        return [
            self.constraint(.Width,  constant: size.width),
            self.constraint(.Height, constant: size.height),
        ]
    }
    
    /// 指定した幅のレイアウト制約を配列で取得する
    /// - parameter width: 幅
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(width width: T) -> [NSLayoutConstraint] {
        return [
            self.constraint(.Width, constant: CGFloat.cast(width)),
        ]
    }
    
    /// 指定した高さのレイアウト制約を配列で取得する
    /// - parameter height: 高さ
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(height height: T) -> [NSLayoutConstraint] {
        return [
            self.constraint(.Height, constant: CGFloat.cast(height)),
        ]
    }
}

// MARK: - UIView拡張: CGRectでの指定 -
public extension UIView {
    
    /// 指定したCGRectからレイアウト制約を配列で取得する
    /// - parameter rect: CGRect
    /// - returns: NSLayoutConstraintの配列
    public func constraints(rect rect: CGRect, toItem item: AnyObject? = nil) -> [NSLayoutConstraint] {
        return [
            self.constraint(.Top,     constant: rect.origin.x, to: self.omittableItem(item)),
            self.constraint(.Leading, constant: rect.origin.y, to: self.omittableItem(item)),
            self.constraint(.Width,   constant: rect.size.width),
            self.constraint(.Height,  constant: rect.size.height),
        ]
    }
}

// MARK: - UIView拡張: フィット -
public extension UIView {
    
    /// 四辺一杯に収まるレイアウト制約を配列で取得する
    /// - parameter toItem: 制約の対象ビューまたはオブジェクト(省略時は自身の親ビューを対象にする)
    /// - returns: NSLayoutConstraintの配列
    public func constraints(fit item: AnyObject?) -> [NSLayoutConstraint] {
        return self.constraints(fit: 0, toItem: self.omittableItem(item))
    }
    
    /// 四辺一杯に収まるレイアウト制約を配列で取得する
    /// - parameter margin: マージン値
    /// - parameter toItem: 制約の対象ビューまたはオブジェクト(省略時は自身の親ビューを対象にする)
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(fit margin: T, toItem item: AnyObject? = nil) -> [NSLayoutConstraint] {
        let m = CGFloat.cast(margin)
        let inset = UIEdgeInsetsMake(m, m, m, m)
        return self.constraints(fit: inset, toItem: self.omittableItem(item))
    }
    
    /// 四辺一杯に収まるレイアウト制約を配列で取得する
    /// - parameter inset: マージン値のインセット
    /// - parameter toItem: 制約の対象ビューまたはオブジェクト(省略時は自身の親ビューを対象にする)
    /// - returns: NSLayoutConstraintの配列
    public func constraints(fit inset: UIEdgeInsets, toItem item: AnyObject? = nil) -> [NSLayoutConstraint] {
        return self.constraints(top: inset.top, left: inset.left, bottom: inset.bottom, right: inset.right, toItem: self.omittableItem(item))
    }
}

// MARK: - UIView拡張: サイズ揃え -
public extension UIView {
    
    /// 指定したビューとサイズを揃えるレイアウト制約を配列で取得する
    /// - parameter views: 対象のビュー
    /// - returns: NSLayoutConstraintの配列
    public func constraints(equalSizeToViews views: [UIView]) -> [NSLayoutConstraint] {
        var ret = [NSLayoutConstraint]()
        for view in views {
            ret.append(self.constraint(.Width,  to: view))
            ret.append(self.constraint(.Height, to: view))
        }
        return ret
    }
    
    /// 指定したビューとサイズを揃えるレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - returns: NSLayoutConstraintの配列
    public func constraints(equalSize view: UIView) -> [NSLayoutConstraint] {
        return self.constraints(equalSizeToViews: [view])
    }
}

// MARK: - UIView拡張: 幅揃え -
public extension UIView {

    /// 指定したビューと幅を揃えるレイアウト制約を配列で取得する
    /// - parameter views: 対象のビュー
    /// - returns: NSLayoutConstraintの配列
    public func constraints(equalWidthToViews views: [UIView]) -> [NSLayoutConstraint] {
        var ret = [NSLayoutConstraint]()
        for view in views {
            ret.append(self.constraint(.Width, to: view))
        }
        return ret
    }
    
    /// 指定したビューと幅を揃えるレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - returns: NSLayoutConstraintの配列
    public func constraints(equalWidth view: UIView) -> [NSLayoutConstraint] {
        return self.constraints(equalWidthToViews: [view])
    }
}

// MARK: - UIView拡張: 高さ揃え -
public extension UIView {

    /// 指定したビューと高さを揃えるレイアウト制約を配列で取得する
    /// - parameter views: 対象のビュー
    /// - returns: NSLayoutConstraintの配列
    public func constraints(equalHeightToViews views: [UIView]) -> [NSLayoutConstraint] {
        var ret = [NSLayoutConstraint]()
        for view in views {
            ret.append(self.constraint(.Height, to: view))
        }
        return ret
    }
    
    /// 指定したビューと高さを揃えるレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - returns: NSLayoutConstraintの配列
    public func constraints(equalHeight view: UIView) -> [NSLayoutConstraint] {
        return self.constraints(equalHeightToViews: [view])
    }
}

// MARK: - UIView拡張: 隣接(スペース指定あり) -
public extension UIView {
    
    /// 指定したビューの上に配置するレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - parameter space: 両者の間のスペース
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(aboveOf view: UIView, space: T) -> [NSLayoutConstraint] {
        return [
            self.constraint(.Bottom, to: view, attrTo: .Top, constant: -CGFloat.cast(space))
        ]
    }
    
    /// 指定したビューの下に配置するレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - parameter space: 両者の間のスペース
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(belowOf view: UIView, space: T) -> [NSLayoutConstraint] {
        return [
            self.constraint(.Top, to: view, attrTo: .Bottom, constant: CGFloat.cast(space))
        ]
    }
    
    /// 指定したビューの左に配置するレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - parameter space: 両者の間のスペース
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(leftOf view: UIView, space: T) -> [NSLayoutConstraint] {
        return [
            self.constraint(.Trailing, to: view, attrTo: .Leading, constant: -CGFloat.cast(space))
        ]
    }
    
    /// 指定したビューの右に配置するレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - parameter space: 両者の間のスペース
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(rightOf view: UIView, space: T) -> [NSLayoutConstraint] {
        return [
            self.constraint(.Leading, to: view, attrTo: .Trailing, constant: CGFloat.cast(space))
        ]
    }
}

// MARK: - UIView拡張: 隣接(スペース指定なし) -
public extension UIView {
    
    /// 指定したビューの上に配置するレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - returns: NSLayoutConstraintの配列
    public func constraints(aboveOf view: UIView) -> [NSLayoutConstraint] {
        return constraints(aboveOf: view, space: 0)
    }
    
    /// 指定したビューの下に配置するレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - returns: NSLayoutConstraintの配列
    public func constraints(belowOf view: UIView) -> [NSLayoutConstraint] {
        return constraints(belowOf: view, space: 0)
    }
    
    /// 指定したビューの左に配置するレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - returns: NSLayoutConstraintの配列
    public func constraints(leftOf view: UIView) -> [NSLayoutConstraint] {
        return constraints(leftOf: view, space: 0)
    }
    
    /// 指定したビューの右に配置するレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - returns: NSLayoutConstraintの配列
    public func constraints(rightOf view: UIView) -> [NSLayoutConstraint] {
        return constraints(rightOf: view, space: 0)
    }
}

// MARK: - UIView拡張: 上端揃え(アラインメント) -
public extension UIView {
    
    /// 指定したビューと上端を揃えるレイアウト制約を配列で取得する
    /// - parameter views: 対象のビューの配列
    /// - parameter diff: 揃え位置の差
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(alignTop views: [UIView], diff: T) -> [NSLayoutConstraint] {
        var ret = [NSLayoutConstraint]()
        for view in views {
            ret.append(self.constraint(.Top, to: view, attrTo: .Top, constant: CGFloat.cast(diff)))
        }
        return ret
    }
    
    /// 指定したビューと上端を揃えるレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - parameter diff: 揃え位置の差
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(alignTop view: UIView, diff: T) -> [NSLayoutConstraint] {
        return self.constraints(alignTop: [view], diff: diff)
    }
    
    /// 指定したビューと上端を揃えるレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - returns: NSLayoutConstraintの配列
    public func constraints(alignTop view: UIView) -> [NSLayoutConstraint] {
        return self.constraints(alignTop: view, diff: 0)
    }
}

// MARK: - UIView拡張: 下端揃え(アラインメント) -
public extension UIView {
    
    /// 指定したビューと下端を揃えるレイアウト制約を配列で取得する
    /// - parameter views: 対象のビューの配列
    /// - parameter diff: 揃え位置の差
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(alignBottom views: [UIView], diff: T) -> [NSLayoutConstraint] {
        var ret = [NSLayoutConstraint]()
        for view in views {
            ret.append(self.constraint(.Bottom, to: view, attrTo: .Bottom, constant: -CGFloat.cast(diff)))
        }
        return ret
    }
    
    /// 指定したビューと下端を揃えるレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - parameter diff: 揃え位置の差
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(alignBottom view: UIView, diff: T) -> [NSLayoutConstraint] {
        return self.constraints(alignBottom: [view], diff: diff)
    }
    
    /// 指定したビューと下端を揃えるレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - returns: NSLayoutConstraintの配列
    public func constraints(alignBottom view: UIView) -> [NSLayoutConstraint] {
        return self.constraints(alignBottom: view, diff: 0)
    }
}

// MARK: - UIView拡張: 左端揃え(アラインメント) -
public extension UIView {
    
    /// 指定したビューと左端を揃えるレイアウト制約を配列で取得する
    /// - parameter views: 対象のビューの配列
    /// - parameter diff: 揃え位置の差
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(alignLeft views: [UIView], diff: T) -> [NSLayoutConstraint] {
        var ret = [NSLayoutConstraint]()
        for view in views {
            ret.append(self.constraint(.Leading, to: view, attrTo: .Leading, constant: CGFloat.cast(diff)))
        }
        return ret
    }
    
    /// 指定したビューと左端を揃えるレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - parameter diff: 揃え位置の差
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(alignLeft view: UIView, diff: T) -> [NSLayoutConstraint] {
        return self.constraints(alignLeft: [view], diff: diff)
    }
    
    /// 指定したビューと左端を揃えるレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - returns: NSLayoutConstraintの配列
    public func constraints(alignLeft view: UIView) -> [NSLayoutConstraint] {
        return self.constraints(alignLeft: view, diff: 0)
    }
}

// MARK: - UIView拡張: 右端揃え(アラインメント) -
public extension UIView {
    
    /// 指定したビューと右端を揃えるレイアウト制約を配列で取得する
    /// - parameter views: 対象のビューの配列
    /// - parameter diff: 揃え位置の差
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(alignRight views: [UIView], diff: T) -> [NSLayoutConstraint] {
        var ret = [NSLayoutConstraint]()
        for view in views {
            ret.append(self.constraint(.Trailing, to: view, attrTo: .Trailing, constant: -CGFloat.cast(diff)))
        }
        return ret
    }
    
    /// 指定したビューと右端を揃えるレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - parameter diff: 揃え位置の差
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(alignRight view: UIView, diff: T) -> [NSLayoutConstraint] {
        return self.constraints(alignRight: [view], diff: diff)
    }
    
    /// 指定したビューと右端を揃えるレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - returns: NSLayoutConstraintの配列
    public func constraints(alignRight view: UIView) -> [NSLayoutConstraint] {
        return self.constraints(alignRight: view, diff: 0)
    }
}

// MARK: - UIView拡張: 上下端揃え(アラインメント) -
public extension UIView {
    
    /// 指定したビューと上下端を揃えるレイアウト制約を配列で取得する
    /// - parameter views: 対象のビューの配列
    /// - parameter diff: 揃え位置の差
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(alignVertical views: [UIView], diff: T) -> [NSLayoutConstraint] {
        var ret = [NSLayoutConstraint]()
        for view in views {
            ret.append(self.constraint(.Top,    to: view, attrTo: .Top,    constant: CGFloat.cast(diff)))
            ret.append(self.constraint(.Bottom, to: view, attrTo: .Bottom, constant: -CGFloat.cast(diff)))
        }
        return ret
    }
    
    /// 指定したビューと上下端を揃えるレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - parameter diff: 揃え位置の差
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(alignVertical view: UIView, diff: T) -> [NSLayoutConstraint] {
        return self.constraints(alignVertical: [view], diff: diff)
    }
    
    /// 指定したビューと上下端を揃えるレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - returns: NSLayoutConstraintの配列
    public func constraints(alignVertical view: UIView) -> [NSLayoutConstraint] {
        return self.constraints(alignVertical: view, diff: 0)
    }
}

// MARK: - UIView拡張: 左右端揃え(アラインメント) -
public extension UIView {
    
    /// 指定したビューと左右端を揃えるレイアウト制約を配列で取得する
    /// - parameter views: 対象のビューの配列
    /// - parameter diff: 揃え位置の差
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(alignHorizontal views: [UIView], diff: T) -> [NSLayoutConstraint] {
        var ret = [NSLayoutConstraint]()
        for view in views {
            ret.append(self.constraint(.Leading,  to: view, attrTo: .Leading,  constant: CGFloat.cast(diff)))
            ret.append(self.constraint(.Trailing, to: view, attrTo: .Trailing, constant: -CGFloat.cast(diff)))
        }
        return ret
    }
    
    /// 指定したビューと左右端を揃えるレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - parameter diff: 揃え位置の差
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(alignHorizontal view: UIView, diff: T) -> [NSLayoutConstraint] {
        return self.constraints(alignHorizontal: [view], diff: diff)
    }
    
    /// 指定したビューと左右端を揃えるレイアウト制約を配列で取得する
    /// - parameter view: 対象のビュー
    /// - returns: NSLayoutConstraintの配列
    public func constraints(alignHorizontal view: UIView) -> [NSLayoutConstraint] {
        return self.constraints(alignHorizontal: view, diff: 0)
    }
}

// MARK: - UIView拡張: ベースライン -
public extension UIView {
    
    /// 指定したビューのベースラインに配置するレイアウト制約を配列で取得する
    /// - parameter views: 対象のビュー(nil時は自身の親ビューを対象にする)
    /// - parameter diff: ベースライン位置からの差
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(baseline view: UIView?, diff: T) -> [NSLayoutConstraint] {
        return [
            self.constraint(.Baseline, to: self.omittableItem(view), attrTo: .Baseline, constant: CGFloat.cast(diff))
        ]
    }
    
    /// 指定したビューのベースラインに配置するレイアウト制約を配列で取得する
    /// - parameter views: 対象のビュー(nil時は自身の親ビューを対象にする)
    /// - returns: NSLayoutConstraintの配列
    public func constraints(baseline view: UIView?) -> [NSLayoutConstraint] {
        return self.constraints(baseline: view, diff: 0)
    }
}

// MARK: - UIView拡張: 水平中央配置 -
public extension UIView {
    
    /// 指定したビューの水平中央に配置するレイアウト制約を配列で取得する
    /// - parameter views: 対象のビュー(nil時は自身の親ビューを対象にする)
    /// - parameter diff: 中央位置からの差
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(centerX view: UIView?, diff: T) -> [NSLayoutConstraint] {
        return [
            self.constraint(.CenterX, to: self.omittableItem(view), attrTo: .CenterX, constant: CGFloat.cast(diff))
        ]
    }
    
    /// 指定したビューの水平中央に配置するレイアウト制約を配列で取得する
    /// - parameter views: 対象のビュー(nil時は自身の親ビューを対象にする)
    /// - returns: NSLayoutConstraintの配列
    public func constraints(centerX view: UIView?) -> [NSLayoutConstraint] {
        return self.constraints(centerX: view, diff: 0)
    }
}

// MARK: - UIView拡張: 垂直中央配置 -
public extension UIView {

    /// 指定したビューの垂直中央に配置するレイアウト制約を配列で取得する
    /// - parameter views: 対象のビュー(nil時は自身の親ビューを対象にする)
    /// - parameter diff: 中央位置からの差
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(centerY view: UIView?, diff: T) -> [NSLayoutConstraint] {
        return [
            self.constraint(.CenterY, to: self.omittableItem(view), attrTo: .CenterY, constant: CGFloat.cast(diff))
        ]
    }
    
    /// 指定したビューの垂直中央に配置するレイアウト制約を配列で取得する
    /// - parameter views: 対象のビュー(nil時は自身の親ビューを対象にする)
    /// - returns: NSLayoutConstraintの配列
    public func constraints(centerY view: UIView?) -> [NSLayoutConstraint] {
        return self.constraints(centerY: view, diff: 0)
    }
}

// MARK: - UIView拡張: 中央配置 -
public extension UIView {
    
    /// 指定したビューの中央に配置するレイアウト制約を配列で取得する
    /// - parameter views: 対象のビュー(nil時は自身の親ビューを対象にする)
    /// - parameter x: 中央位置からの水平方向の差
    /// - parameter y: 中央位置からの垂直方向の差
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(centerOf view: UIView?, x: T, y: T) -> [NSLayoutConstraint] {
        return [
            self.constraint(.CenterX, to: self.omittableItem(view), attrTo: .CenterX, constant: CGFloat.cast(x)),
            self.constraint(.CenterY, to: self.omittableItem(view), attrTo: .CenterY, constant: CGFloat.cast(y))
        ]
    }
    
    /// 指定したビューの中央に配置するレイアウト制約を配列で取得する
    /// - parameter views: 対象のビュー(nil時は自身の親ビューを対象にする)
    /// - returns: NSLayoutConstraintの配列
    public func constraints(centerOf view: UIView?) -> [NSLayoutConstraint] {
        return self.constraints(centerOf: view, x: 0, y: 0)
    }
}

// MARK: - UIView拡張: アスペクト比率 -
public extension UIView {
    
    /// アスペクト比率を保つための制約を追加する
    /// - parameter view: アスペクト比率を取得する対象のビュー(nil時は自身のアスペクト比を対象にする)
    /// - returns: NSLayoutConstraintの配列
    public func constraints(aspectRatio view: UIView?) -> [NSLayoutConstraint] {
        return self.constraints(aspectRatio: view, width: 0, height: 0)
    }
    
    /// アスペクト比率を保つための制約を追加する
    /// - parameter view: アスペクト比率を取得する対象のビュー(nil時は自身のアスペクト比を対象にする)
    /// - parameter width: 幅の実値または幅の比率値
    /// - parameter height: 高さの実値または高さ比率値
    /// - returns: NSLayoutConstraintの配列
    public func constraints<T>(aspectRatio view: UIView?, width: T, height: T) -> [NSLayoutConstraint] {
        var w: CGFloat = CGFloat.cast(width), h: CGFloat = CGFloat.cast(height)
        if w <= 0 {
            w = (view == nil) ? self.bounds.size.width : view!.bounds.size.width
        }
        if h <= 0 {
            h = (view == nil) ? self.bounds.size.height : view!.bounds.size.height
        }
        if h == 0 { return [] } // for zero divide crash
        
        return [self.constraint(.Width, to: self, attrTo: .Height, multiplier: w / h)]
    }
}

// MARK: - UIViewController拡張 -
public extension UIViewController {
    
    /// 自身のビューの四辺一杯に収まるレイアウト制約を指定のビューに対して追加する
    /// - parameter view: 制約を追加するオブジェクト
    /// - returns: NSLayoutConstraintの配列
    public func addAllFitConstraints(toView view: UIView) {
        let constraints = [
            Constraint(view, .Top,      to: self.topLayoutGuide,    .Top,      0),
            Constraint(view, .Leading,  to: self.view,              .Leading,  0),
            Constraint(view, .Bottom,   to: self.bottomLayoutGuide, .Bottom,   0),
            Constraint(view, .Trailing, to: self.view,              .Trailing, 0),
        ]
        self.view.addConstraints(constraints)
    }
}
